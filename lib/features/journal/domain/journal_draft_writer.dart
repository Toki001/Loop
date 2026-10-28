import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/data/local_failure.dart';
import '../data/journal_repository.dart';

class _DraftWrite {
  _DraftWrite(
    this.sessionId,
    this.purpose,
    this.baseRevision,
    Map<String, Object?> form,
  ) : form = Map<String, Object?>.from(jsonDecode(jsonEncode(form)) as Map);
  final String sessionId;
  final String purpose;
  final int baseRevision;
  final Map<String, Object?> form;
}

/// Application-owned, so route disposal cannot abandon a pending SQL write.
class JournalDraftWriter extends ChangeNotifier {
  JournalDraftWriter(
    this.repository, {
    this.debounce = const Duration(milliseconds: 600),
  });
  final JournalRepository repository;
  final Duration debounce;
  final Map<String, _DraftWrite> _pending = {};
  final Map<String, LocalFailure> failures = {};
  Future<void> _tail = Future.value();
  Future<void>? _closing;
  Timer? _timer;
  bool _disposed = false;
  bool get hasPending => _pending.isNotEmpty;
  bool hasPendingFor(String sessionId, String purpose) =>
      _pending.containsKey(key(sessionId, purpose));
  Future<void> get idle => _tail;
  String key(String sessionId, String purpose) => '$sessionId/$purpose';
  void _emit() {
    if (!_disposed) notifyListeners();
  }

  void stage({
    required String sessionId,
    required String purpose,
    required int baseRevision,
    required Map<String, Object?> form,
  }) {
    if (_closing != null || _disposed) return;
    _pending[key(sessionId, purpose)] = _DraftWrite(
      sessionId,
      purpose,
      baseRevision,
      form,
    );
    _timer?.cancel();
    _timer = Timer(debounce, () => unawaited(flush()));
    _emit();
  }

  Future<bool> flush() {
    _timer?.cancel();
    _timer = null;
    final result = Completer<bool>();
    _tail = _tail.then((_) async {
      var succeeded = true;
      for (final entry in _pending.entries.toList()) {
        final write = entry.value;
        try {
          await repository.saveDraft(
            sessionId: write.sessionId,
            purpose: write.purpose,
            baseRevision: write.baseRevision,
            form: write.form,
          );
          if (identical(_pending[entry.key], write)) _pending.remove(entry.key);
          failures.remove(entry.key);
        } on Object catch (error) {
          failures[entry.key] = localFailure(error);
          succeeded = false;
        }
      }
      _emit();
      result.complete(succeeded);
    });
    return result.future;
  }

  /// Call after flush and successful completion/discard; queued writes are drained.
  void forget(String sessionId, String purpose) {
    final id = key(sessionId, purpose);
    _pending.remove(id);
    failures.remove(id);
    if (_pending.isEmpty) {
      _timer?.cancel();
      _timer = null;
    }
    _emit();
  }

  Future<void> close() => _closing ??= flush().then((_) {});

  @override
  void dispose() {
    unawaited(close());
    _disposed = true;
    super.dispose();
  }
}
