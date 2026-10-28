import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';

import '../../../core/data/local_failure.dart';
import '../data/practice_repository.dart';
import '../data/sessions_repository.dart';
import 'practice_clock.dart';

/// One engine per application scope. Commands never overlap storage writes.
class PracticeEngine extends ChangeNotifier {
  PracticeEngine(
    this.repository, {
    PracticeClock? clock,
    DateTime Function()? utcNow,
    bool ticking = true,
  }) : _clock = clock ?? StopwatchPracticeClock(),
       _now = utcNow ?? (() => DateTime.now().toUtc()),
       _ticking = ticking;
  final bool _ticking;
  final PracticeRepository repository;
  final PracticeClock _clock;
  final DateTime Function() _now;
  Timer? _ticker;
  Future<void> _tail = Future.value();
  PracticeRecord? record;
  List<PracticeRecord> pending = const [];
  LocalFailure? failure;
  bool ready = false;
  bool busy = false;
  bool _foreground = true;
  bool _counting = false;
  bool _disposed = false;
  bool _checkpointQueued = false;
  Future<bool>? _creating;
  String? _draftNote;
  int? _manualSeconds;
  String? _manualDate;
  void stageDraft(String note, {int? manualSeconds, String? manualDate}) {
    _draftNote = note;
    _manualSeconds = manualSeconds;
    _manualDate = manualDate;
  }

  int _baseMilliseconds = 0;
  int _savedMilliseconds = 0;
  int get milliseconds =>
      _baseMilliseconds + (_counting ? _clock.elapsed.inMilliseconds : 0);
  int get seconds => milliseconds ~/ 1000;
  bool get running => _counting && record?.session.status == 'running';
  bool get foreground => _foreground;
  bool get hasUnfinished =>
      ['draft', 'running', 'paused'].contains(record?.session.status) ||
      pending.isNotEmpty;

  Future<bool> openPending() async {
    if (['draft', 'running', 'paused'].contains(record?.session.status)) {
      return true;
    }
    final next = pending.firstOrNull;
    return next == null ? false : select(next.session.id);
  }

  void _emit() {
    if (!_disposed) notifyListeners();
  }

  void _freeze() {
    _ticker?.cancel();
    _ticker = null;
    if (!_counting) return;
    _clock.stop();
    _baseMilliseconds += _clock.elapsed.inMilliseconds;
    _clock.reset();
    _counting = false;
  }

  void _adopt(PracticeRecord? next) {
    _freeze();
    record = next;
    _draftNote = null;
    _manualSeconds = null;
    _manualDate = null;
    _baseMilliseconds = next?.milliseconds ?? 0;
    _savedMilliseconds = _baseMilliseconds;
  }

  Future<bool> _serial(Future<void> Function() action, {bool quiet = false}) {
    final completer = Completer<bool>();
    _tail = _tail.then((_) async {
      if (_disposed) {
        completer.complete(false);
        return;
      }
      if (!quiet) busy = true;
      _emit();
      try {
        await action();
        failure = null;
        completer.complete(true);
      } on Object catch (error) {
        _freeze();
        failure = localFailure(error);
        completer.complete(false);
      } finally {
        if (!quiet) busy = false;
        _emit();
      }
    });
    return completer.future;
  }

  Future<bool> initialize() => _serial(() async {
    pending = await repository.recover();
    _adopt(pending.firstOrNull);
    ready = true;
  });

  Future<bool> select(String id) => _serial(() async {
    if (running) throw const LocalFailure(LocalFailureKind.conflict);
    final next = await repository.find(id);
    if (next == null) throw const LocalFailure(LocalFailureKind.notFound);
    _adopt(next);
  });

  Future<void> _persist({
    String? status,
    String? reason,
    bool clearReason = false,
    bool includeDraft = true,
    String? note,
    DateTime? ended,
    DateTime? started,
  }) async {
    final current = record;
    if (current == null) throw const LocalFailure(LocalFailureKind.notFound);
    final elapsed = milliseconds;
    final value = current.session.copyWith(
      activeSeconds: elapsed ~/ 1000,
      status: status,
      interruptionReason: clearReason
          ? const Value(null)
          : reason == null
          ? const Value.absent()
          : Value(reason),
      note: note == null && (!includeDraft || _draftNote == null)
          ? const Value.absent()
          : Value(note ?? (includeDraft ? _draftNote : null)),
      startedAtUtc: started == null ? const Value.absent() : Value(started),
      endedAtUtc: ended == null ? const Value.absent() : Value(ended),
    );
    record = await repository.write(
      value,
      milliseconds: elapsed,
      manualSeconds: includeDraft ? _manualSeconds : null,
      manualDateLocal: includeDraft ? _manualDate : null,
    );
    _savedMilliseconds = elapsed;
  }

  Future<bool> create({
    required String skillId,
    List<String> exerciseIds = const [],
    int? plannedSeconds,
    EntryMode mode = EntryMode.timed,
    ManualIntent? manualIntent,
    bool start = true,
  }) {
    if (_creating != null) return _creating!;
    final operation = _serial(() async {
      if (!ready) throw const LocalFailure(LocalFailureKind.unavailable);
      _adopt(
        await repository.create(
          skillId: skillId,
          exerciseIds: exerciseIds,
          plannedSeconds: plannedSeconds,
          mode: mode,
          manualIntent: manualIntent,
        ),
      );
      pending = await repository.pending();
      if (mode == EntryMode.timed && start) await _resume();
    });
    _creating = operation;
    unawaited(operation.whenComplete(() => _creating = null));
    return operation;
  }

  Future<void> _resume() async {
    final session = record?.session;
    if (session == null ||
        session.entryMode != 'timed' ||
        !['draft', 'paused', 'running'].contains(session.status))
      throw const LocalFailure(LocalFailureKind.invalid);
    if (running) return;
    if (!_foreground) return;
    await _persist(
      status: 'running',
      clearReason: true,
      started: session.startedAtUtc == null ? _now() : null,
    );
    if (_disposed) return;
    if (!_foreground) {
      await _persist(status: 'paused', reason: 'background');
      return;
    }
    _clock.reset();
    _clock.start();
    _counting = true;
    if (_ticking)
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) => tick());
  }

  Future<bool> resume() => _serial(_resume);

  Future<bool> pause({String reason = 'user'}) {
    _freeze();
    return _serial(() async {
      _freeze();
      if (record?.session.status == 'running')
        await _persist(status: 'paused', reason: reason);
      // A failed checkpoint/pause is retried with all still-held elapsed time.
      else if (record?.session.status == 'paused')
        await _persist(reason: reason);
      else if (record?.session.status == 'draft' && _draftNote != null)
        await _persist();
    });
  }

  Future<bool> setForeground(bool value) {
    _foreground = value;
    if (value) return Future.value(true); // Never automatically resume.
    return pause(reason: 'background');
  }

  Future<bool> saveNote(String note) => _serial(() async {
    if (running || !['draft', 'paused'].contains(record?.session.status))
      throw const LocalFailure(LocalFailureKind.invalid);
    await _persist(note: note);
  });

  Future<bool> finish() {
    _freeze();
    return _serial(() async {
      _freeze();
      final session = record?.session;
      if (session?.status == 'completed') return;
      if (session == null ||
          session.entryMode != 'timed' ||
          !['running', 'paused'].contains(session.status))
        throw const LocalFailure(LocalFailureKind.invalid);
      final now = _now();
      // Wall-clock corrections affect history, never active duration; maintain
      // the historical SQL ordering constraint without adding practice seconds.
      final end =
          session.startedAtUtc != null && now.isBefore(session.startedAtUtc!)
          ? session.startedAtUtc!
          : now;
      await _persist(
        status: 'completed',
        ended: end,
        reason: now.isBefore(end) ? 'clock_adjusted' : null,
      );
      pending = await repository.pending();
    });
  }

  Future<bool> completeManual({
    required int seconds,
    required DateTime endedAtUtc,
    required bool confirmed,
    String note = '',
  }) => _serial(() async {
    final session = record?.session;
    if (session != null &&
        session.entryMode == 'manual' &&
        session.status == 'completed' &&
        confirmed &&
        seconds == session.activeSeconds &&
        endedAtUtc.toUtc().millisecondsSinceEpoch ~/ 1000 ==
            session.endedAtUtc!.millisecondsSinceEpoch ~/ 1000 &&
        note == (session.note ?? ''))
      return;
    if (!confirmed ||
        session == null ||
        session.entryMode != 'manual' ||
        session.status != 'draft' ||
        seconds < 0 ||
        seconds > 604800 ||
        endedAtUtc.toUtc().isAfter(_now()) ||
        (seconds == 0 && session.manualIntent != 'evidence_only') ||
        (seconds != 0 && session.manualIntent == 'evidence_only'))
      throw const LocalFailure(LocalFailureKind.invalid);
    _baseMilliseconds = seconds * 1000;
    await _persist(
      status: 'completed',
      note: note,
      ended: endedAtUtc.toUtc(),
      started: endedAtUtc.toUtc().subtract(Duration(seconds: seconds)),
    );
    pending = await repository.pending();
  });

  Future<bool> discard() {
    _freeze();
    return _serial(() async {
      if (record == null ||
          !['draft', 'running', 'paused'].contains(record!.session.status))
        throw const LocalFailure(LocalFailureKind.invalid);
      await _persist(status: 'discarded', includeDraft: false);
      pending = await repository.pending();
      _adopt(pending.firstOrNull);
    });
  }

  /// Exposed for deterministic tests; normal operation ticks at 1 Hz.
  void tick() {
    if (_disposed || !running) return;
    _emit();
    if (milliseconds - _savedMilliseconds < 5000 || _checkpointQueued || busy)
      return;
    _checkpointQueued = true;
    unawaited(
      _serial(() async {
        if (record?.session.status == 'running') await _persist();
      }, quiet: true).whenComplete(() => _checkpointQueued = false),
    );
  }

  Future<void> get idle => _tail;
  @override
  void dispose() {
    _disposed = true;
    _ticker?.cancel();
    _freeze();
    super.dispose();
  }
}
