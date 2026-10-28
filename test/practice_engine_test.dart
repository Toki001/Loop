import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop/core/data/database/loop_database.dart';
import 'package:loop/core/data/local_failure.dart';
import 'package:loop/features/practice/data/practice_repository.dart';
import 'package:loop/features/practice/data/sessions_repository.dart';
import 'package:loop/features/practice/domain/practice_clock.dart';
import 'package:loop/features/practice/domain/practice_engine.dart';
import 'package:loop/features/skills/data/skill_management_repository.dart';
import 'package:loop/features/skills/domain/skill_draft.dart';
import 'package:loop/features/skills/domain/skill_kind.dart';

class TestPracticeClock implements PracticeClock {
  Duration value = Duration.zero;
  bool running = false;
  void advance(Duration delta) {
    if (running) value += delta;
  }

  @override
  Duration get elapsed => value;
  @override
  void start() => running = true;
  @override
  void stop() => running = false;
  @override
  void reset() => value = Duration.zero;
}

class ControlledPracticeRepository extends PracticeRepository {
  ControlledPracticeRepository(super.database);
  bool fail = false;
  Completer<void>? entered;
  Completer<void>? release;
  @override
  Future<PracticeRecord> write(
    Session value, {
    required int milliseconds,
    int? manualSeconds,
    String? manualDateLocal,
  }) async {
    if (fail) throw const LocalFailure(LocalFailureKind.full);
    entered?.complete();
    entered = null;
    final hold = release;
    release = null;
    if (hold != null) await hold.future;
    return super.write(
      value,
      milliseconds: milliseconds,
      manualSeconds: manualSeconds,
      manualDateLocal: manualDateLocal,
    );
  }
}

void main() {
  late Directory directory;
  late LoopDatabase db;
  late Skill skill;
  late TestPracticeClock clock;
  late ControlledPracticeRepository repository;
  late PracticeEngine engine;
  late DateTime now;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('loop-practice-test-');
    db = LoopDatabase(NativeDatabase(File('${directory.path}/test.sqlite')));
    skill = await SkillManagementRepository(db).create(
      const SkillDraft(name: 'Deliberate practice', kind: SkillKind.custom),
    );
    repository = ControlledPracticeRepository(db);
    clock = TestPracticeClock();
    now = DateTime.utc(2026, 10, 28, 12);
    engine = PracticeEngine(
      repository,
      clock: clock,
      utcNow: () => now,
      ticking: false,
    );
    expect(await engine.initialize(), true);
  });
  tearDown(() async {
    await engine.idle;
    engine.dispose();
    await db.close();
    await directory.delete(recursive: true);
  });

  test(
    'two foreground minutes plus ten background minutes count only foreground',
    () async {
      expect(await engine.create(skillId: skill.id), true);
      clock.advance(const Duration(minutes: 2));
      expect(await engine.setForeground(false), true);
      clock.advance(const Duration(minutes: 10));
      now = now.add(const Duration(minutes: 12));
      expect(engine.seconds, 120);
      expect(engine.record!.session.status, 'paused');
      await engine.setForeground(true);
      expect(engine.running, false);
      expect(await engine.finish(), true);
      final saved = (await repository.find(engine.record!.session.id))!;
      expect(saved.session.activeSeconds, 120);
      expect(saved.milliseconds, 120000);
    },
  );

  test('fractional seconds survive 100 short pause/resume segments', () async {
    await engine.create(skillId: skill.id);
    for (var i = 0; i < 100; i++) {
      clock.advance(const Duration(milliseconds: 123));
      expect(await engine.pause(), true);
      expect(await engine.resume(), true);
    }
    await engine.finish();
    expect(engine.milliseconds, 12300);
    expect(engine.record!.session.activeSeconds, 12);
  });

  test(
    'rapid Start Resume and Finish produce one completed identity',
    () async {
      final starts = await Future.wait([
        engine.create(skillId: skill.id),
        engine.create(skillId: skill.id),
      ]);
      expect(starts, [true, true]);
      final id = engine.record!.session.id;
      await engine.pause();
      expect(await Future.wait([engine.resume(), engine.resume()]), [
        true,
        true,
      ]);
      clock.advance(const Duration(seconds: 11));
      expect(
        await Future.wait(List.generate(12, (_) => engine.finish())),
        everyElement(true),
      );
      final rows = await db.select(db.sessions).get();
      expect(rows, hasLength(1));
      expect(rows.single.id, id);
      expect(rows.single.status, 'completed');
      expect(rows.single.activeSeconds, 11);
      clock.advance(const Duration(hours: 1));
      expect(engine.seconds, 11);
      expect(clock.running, false);
    },
  );

  test(
    'background while Start awaits commit never starts clock afterward',
    () async {
      final entered = Completer<void>();
      final release = Completer<void>();
      repository.entered = entered;
      repository.release = release;
      final start = engine.create(skillId: skill.id);
      await entered.future;
      final background = engine.setForeground(false);
      clock.advance(const Duration(minutes: 10));
      release.complete();
      expect(await start, true);
      expect(await background, true);
      expect(engine.running, false);
      expect(engine.record!.session.status, 'paused');
      expect(engine.seconds, 0);
    },
  );

  test(
    'queued Resume then Pause ends paused and freezes at command boundary',
    () async {
      await engine.create(skillId: skill.id);
      clock.advance(const Duration(seconds: 3));
      await engine.pause();
      expect(await Future.wait([engine.resume(), engine.pause()]), [
        true,
        true,
      ]);
      expect(engine.running, false);
      expect(clock.running, false);
      expect(engine.seconds, 3);
    },
  );

  test(
    'failed pause stops clock, preserves unsaved elapsed/note and retries',
    () async {
      await engine.create(skillId: skill.id);
      clock.advance(const Duration(milliseconds: 12789));
      repository.fail = true;
      expect(await engine.pause(), false);
      expect(engine.failure!.kind, LocalFailureKind.full);
      clock.advance(const Duration(minutes: 10));
      expect(engine.milliseconds, 12789);
      repository.fail = false;
      expect(await engine.pause(), true);
      expect(engine.record!.session.status, 'paused');
      expect(await engine.saveNote('What changed 🖌️'), true);
      repository.fail = true;
      expect(await engine.finish(), false);
      expect(engine.record!.session.status, 'paused');
      repository.fail = false;
      expect(await engine.finish(), true);
      final saved = (await repository.find(engine.record!.session.id))!;
      expect(saved.milliseconds, 12789);
      expect(saved.session.note, 'What changed 🖌️');
    },
  );

  test(
    'checkpoint kill/reopen restores only committed time as paused',
    () async {
      await engine.create(skillId: skill.id, plannedSeconds: 600);
      clock.advance(const Duration(milliseconds: 6750));
      engine.tick();
      await engine.idle;
      clock.advance(const Duration(seconds: 3));
      final id = engine.record!.session.id;
      engine.dispose();
      await db.close();
      db = LoopDatabase(NativeDatabase(File('${directory.path}/test.sqlite')));
      repository = ControlledPracticeRepository(db);
      clock = TestPracticeClock();
      now = now.add(const Duration(days: 365));
      engine = PracticeEngine(
        repository,
        clock: clock,
        utcNow: () => now,
        ticking: false,
      );
      expect(await engine.initialize(), true);
      expect(engine.record!.session.id, id);
      expect(engine.milliseconds, 6750);
      expect(engine.record!.session.status, 'paused');
      expect(engine.record!.session.interruptionReason, 'recovered');
      expect(engine.record!.checkpoint!.plannedSeconds, 600);
      expect(engine.running, false);
    },
  );

  test(
    'wall-clock jumps and timezone changes never alter monotonic duration',
    () async {
      await engine.create(skillId: skill.id);
      clock.advance(const Duration(seconds: 30));
      now = now.subtract(const Duration(hours: 4));
      await engine.pause();
      await engine.resume();
      clock.advance(const Duration(seconds: 15));
      await engine.finish();
      expect(engine.seconds, 45);
      expect(
        engine.record!.session.endedAtUtc,
        engine.record!.session.startedAtUtc,
      );
      expect(engine.record!.session.interruptionReason, 'clock_adjusted');
    },
  );

  test(
    'manual entry requires confirmation and explicit positive duration',
    () async {
      await engine.create(
        skillId: skill.id,
        mode: EntryMode.manual,
        manualIntent: ManualIntent.duration,
      );
      expect(
        await engine.completeManual(
          seconds: 300,
          endedAtUtc: now,
          confirmed: false,
        ),
        false,
      );
      expect(
        await engine.completeManual(
          seconds: 0,
          endedAtUtc: now,
          confirmed: true,
        ),
        false,
      );
      expect(
        await engine.completeManual(
          seconds: -1,
          endedAtUtc: now,
          confirmed: true,
        ),
        false,
      );
      expect(
        await engine.completeManual(
          seconds: 604801,
          endedAtUtc: now,
          confirmed: true,
        ),
        false,
      );
      expect(
        await engine.completeManual(
          seconds: 300,
          endedAtUtc: now.add(const Duration(days: 1)),
          confirmed: true,
        ),
        false,
      );
      expect(
        await engine.completeManual(
          seconds: 300,
          endedAtUtc: now,
          confirmed: true,
          note: 'Manual observation',
        ),
        true,
      );
      expect(engine.record!.session.activeSeconds, 300);
      expect(engine.record!.session.entryMode, 'manual');
      expect(engine.record!.session.manualIntent, 'duration');
      expect(
        engine.record!.session.startedAtUtc,
        now.subtract(const Duration(minutes: 5)),
      );
    },
  );

  test(
    'evidence-only intent records zero duration and never runs clock',
    () async {
      await engine.create(
        skillId: skill.id,
        mode: EntryMode.manual,
        manualIntent: ManualIntent.evidenceOnly,
      );
      expect(await engine.resume(), false);
      expect(
        await engine.completeManual(
          seconds: 1,
          endedAtUtc: now,
          confirmed: true,
        ),
        false,
      );
      expect(
        await engine.completeManual(
          seconds: 0,
          endedAtUtc: now,
          confirmed: true,
        ),
        true,
      );
      expect(engine.record!.session.activeSeconds, 0);
      expect(engine.record!.session.manualIntent, 'evidence_only');
      expect(clock.running, false);
    },
  );

  test(
    'checkpoint failure rolls back session and checkpoint together',
    () async {
      await engine.create(skillId: skill.id);
      final before = engine.record!.session;
      clock.advance(const Duration(milliseconds: 10987));
      await db.customStatement(
        "CREATE TRIGGER synthetic_fail_checkpoint BEFORE UPDATE ON practice_checkpoints BEGIN SELECT RAISE(ABORT, 'synthetic_failure'); END",
      );
      expect(await engine.pause(), false);
      final durable = (await repository.find(before.id))!;
      expect(durable.session.status, 'running');
      expect(durable.session.revision, before.revision);
      expect(durable.session.activeSeconds, 0);
      expect(durable.milliseconds, 0);
      expect(engine.milliseconds, 10987);
      await db.customStatement('DROP TRIGGER synthetic_fail_checkpoint');
      expect(await engine.pause(), true);
      expect(engine.record!.session.status, 'paused');
      expect(engine.record!.milliseconds, 10987);
    },
  );

  test('duplicate manual Save returns the one persisted completion', () async {
    await engine.create(
      skillId: skill.id,
      mode: EntryMode.manual,
      manualIntent: ManualIntent.duration,
    );
    expect(
      await Future.wait(
        List.generate(
          8,
          (_) => engine.completeManual(
            seconds: 1200,
            endedAtUtc: now,
            confirmed: true,
            note: 'Manual source',
          ),
        ),
      ),
      everyElement(true),
    );
    expect(await db.select(db.sessions).get(), hasLength(1));
    expect(engine.failure, isNull);
    expect(engine.record!.session.activeSeconds, 1200);
  });

  test('Pause remains available and freezes immediately during held checkpoint I/O', () async {
    await engine.create(skillId: skill.id);
    final entered = Completer<void>();
    final release = Completer<void>();
    repository.entered = entered;
    repository.release = release;
    clock.advance(const Duration(seconds: 6));
    engine.tick();
    await entered.future;
    expect(
      engine.busy,
      false,
      reason: 'Automatic checkpoint I/O must not disable human Pause.',
    );
    clock.advance(const Duration(milliseconds: 250));
    final pause = engine.pause();
    clock.advance(const Duration(minutes: 10));
    expect(engine.milliseconds, 6250);
    release.complete();
    expect(await pause, true);
    expect(engine.record!.milliseconds, 6250);
    expect(engine.record!.session.status, 'paused');
  });

  test(
    'Discard is available even with invalid unsaved manual draft fields',
    () async {
      await engine.create(
        skillId: skill.id,
        mode: EntryMode.manual,
        manualIntent: ManualIntent.duration,
      );
      final id = engine.record!.session.id;
      engine.stageDraft(
        List.filled(100001, 'x').join(),
        manualSeconds: -1,
        manualDate: 'invalid',
      );
      expect(await engine.discard(), true);
      expect(engine.record, isNull);
      final discarded = (await repository.find(id))!;
      expect(discarded.session.status, 'discarded');
      expect(discarded.session.note, isNull);
      expect(discarded.milliseconds, 0);
    },
  );

  test(
    'disposing during Resume never restarts the clock after the write',
    () async {
      await engine.create(skillId: skill.id);
      await engine.pause();
      final entered = Completer<void>();
      final release = Completer<void>();
      repository.entered = entered;
      repository.release = release;
      final resume = engine.resume();
      await entered.future;
      engine.dispose();
      release.complete();
      expect(await resume, true);
      expect(clock.running, false);
      engine = PracticeEngine(repository, ticking: false);
      expect(await engine.initialize(), true);
      expect(engine.record!.session.status, 'paused');
    },
  );

  test(
    'manual draft duration date and note survive background and reopen',
    () async {
      await engine.create(
        skillId: skill.id,
        mode: EntryMode.manual,
        manualIntent: ManualIntent.duration,
      );
      engine.stageDraft(
        'Remember this approach',
        manualSeconds: 780,
        manualDate: '2026-10-27',
      );
      expect(await engine.setForeground(false), true);
      final id = engine.record!.session.id;
      engine.dispose();
      engine = PracticeEngine(repository, ticking: false);
      expect(await engine.initialize(), true);
      expect(engine.record!.session.id, id);
      expect(engine.record!.session.status, 'draft');
      expect(engine.record!.session.note, 'Remember this approach');
      expect(engine.record!.checkpoint!.manualSeconds, 780);
      expect(engine.record!.checkpoint!.manualDateLocal, '2026-10-27');
      expect(engine.record!.session.activeSeconds, 0);
    },
  );

  test(
    'pending draft prevents another plan; discard retains audit and frees it',
    () async {
      await engine.create(skillId: skill.id, start: false);
      final firstId = engine.record!.session.id;
      expect(await engine.create(skillId: skill.id), false);
      expect(await engine.discard(), true);
      expect((await repository.find(firstId))!.session.status, 'discarded');
      expect(await engine.create(skillId: skill.id), true);
      expect(engine.record!.session.id, isNot(firstId));
    },
  );

  test('exercise snapshots atomic; foreign archived and duplicate selections rejected', () async {
    final detail = (await SkillManagementRepository(db).detail(skill.id))!;
    final id = detail.exercises.first.id;
    expect(
      await engine.create(skillId: skill.id, exerciseIds: [id, id]),
      false,
    );
    expect(await db.select(db.sessions).get(), isEmpty);
    expect(await engine.create(skillId: skill.id, exerciseIds: [id]), true);
    expect(
      engine.record!.exercises.single.exerciseTitleSnapshot,
      detail.exercises.first.title,
    );
    expect(engine.record!.exercises.single.exerciseId, id);
    await engine.discard();
    await SkillManagementRepository(db).skills.setArchived(skill.id, true);
    expect(await engine.create(skillId: skill.id), false);
    expect((await db.select(db.sessions).get()), hasLength(1));
  });
}
