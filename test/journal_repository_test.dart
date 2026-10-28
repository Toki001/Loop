import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:loop/core/data/database/loop_database.dart';
import 'package:loop/core/data/local_failure.dart';
import 'package:loop/core/data/storage.dart';
import 'package:loop/core/data/validation.dart';
import 'package:loop/features/journal/data/journal_repository.dart';
import 'package:loop/features/journal/domain/journal_draft_writer.dart';
import 'package:loop/features/journal/domain/journal_entry.dart';
import 'package:loop/features/practice/data/practice_repository.dart';
import 'package:loop/features/practice/data/sessions_repository.dart';
import 'package:loop/features/skills/data/skills_repository.dart';

class _FailDraftOnce extends JournalRepository {
  _FailDraftOnce(super.database);
  bool fail = true;
  @override
  Future<void> saveDraft({
    required String sessionId,
    required String purpose,
    required int baseRevision,
    required Map<String, Object?> form,
  }) {
    if (fail) {
      fail = false;
      throw const LocalFailure(LocalFailureKind.full);
    }
    return super.saveDraft(
      sessionId: sessionId,
      purpose: purpose,
      baseRevision: baseRevision,
      form: form,
    );
  }
}

Matcher get failure => throwsA(isA<LocalFailure>());

void main() {
  late Directory directory;
  late LoopStorage storage;
  late JournalRepository journal;
  late PracticeRepository practice;
  late Skill skill;
  late MetricDefinition measure;
  final end = DateTime.utc(2026, 10, 26, 8);
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('loop-journal-');
    storage = await LoopStorage.open(directory);
    journal = JournalRepository(storage.database);
    practice = journal.practice;
    skill = await storage.skills.create(
      name: 'Synthetic typing',
      kind: SkillKind.typing,
    );
    measure = await storage.metrics.create(
      MetricDefinitionsCompanion(
        skillId: Value(skill.id),
        label: const Value('Words per minute'),
        unitKey: const Value('wpm'),
        valueType: const Value('numeric'),
        direction: const Value('up'),
        sourceHint: const Value('manual'),
        scaleMin: const Value(0),
        scaleMax: const Value(300),
      ),
    );
  });
  tearDown(() async {
    await storage.close();
    await directory.delete(recursive: true);
  });
  Future<PracticeRecord> draft({String? skillId}) => practice.create(
    skillId: skillId ?? skill.id,
    exerciseIds: [],
    mode: EntryMode.manual,
    manualIntent: ManualIntent.duration,
  );
  JournalReflection reflection({
    double value = 40,
    String easier = 'Lighter touch',
  }) => JournalReflection(
    note: 'A personal observation',
    whatGotEasier: easier,
    nextStep: 'Repeat slowly',
    effortRating: 3,
    readings: [
      JournalReadingInput(
        definitionId: measure.id,
        version: measure.version,
        numericValue: value,
        sourceNote: 'Same passage, entered by me',
      ),
    ],
  );
  Future<PracticeRecord> finish(
    PracticeRecord record,
    JournalReflection input, {
    int seconds = 120,
  }) => journal.complete(
    record.session.copyWith(
      status: 'completed',
      activeSeconds: seconds,
      endedAtUtc: Value(end),
      startedAtUtc: Value(end.subtract(Duration(seconds: seconds))),
    ),
    milliseconds: seconds * 1000,
    reflection: input,
  );

  test(
    'atomic optional reflection/readings finish is durable and idempotent',
    () async {
      final pending = await draft();
      await journal.saveDraft(
        sessionId: pending.session.id,
        purpose: 'finish',
        baseRevision: pending.session.revision,
        form: {'version': 1, 'number': '4.'},
      );
      final saved = await finish(pending, reflection());
      final retried = await finish(pending, reflection());
      expect(retried.session, saved.session);
      expect(
        await storage.database.select(storage.database.sessions).get(),
        hasLength(1),
      );
      expect((await journal.find(saved.session.id))!.readings, hasLength(1));
      expect(await journal.draft(saved.session.id, 'finish'), isNull);
      await storage.close();
      storage = await LoopStorage.open(directory);
      journal = JournalRepository(storage.database);
      final reopened = (await journal.find(saved.session.id))!;
      expect(reopened.session.whatGotEasier, 'Lighter touch');
      expect(reopened.session.nextStep, 'Repeat slowly');
      expect(reopened.session.effortRating, 3);
      expect(reopened.readings.single.sourceType, 'self_reported');
      expect(reopened.readings.single.numericValue, 40);
      expect(reopened.readings.single.measuredAtUtc, end);
    },
  );

  test(
    'failure after a reading insert rolls back session, readings and draft',
    () async {
      final other = await storage.metrics.create(
        MetricDefinitionsCompanion(
          skillId: Value(skill.id),
          label: const Value('Errors'),
          unitKey: const Value('count'),
          valueType: const Value('numeric'),
          direction: const Value('down'),
          sourceHint: const Value('manual'),
        ),
      );
      final pending = await draft();
      await journal.saveDraft(
        sessionId: pending.session.id,
        purpose: 'finish',
        baseRevision: pending.session.revision,
        form: {'version': 1, 'note': 'Retain me'},
      );
      await storage.database.customStatement(
        '''CREATE TRIGGER fail_second_reading BEFORE INSERT ON metric_readings
      WHEN NEW.metric_definition_id = '${other.id}' BEGIN SELECT RAISE(ABORT, 'injected_write_failure'); END''',
      );
      final input = JournalReflection(
        note: 'Complete together',
        readings: [
          ...reflection().readings,
          JournalReadingInput(
            definitionId: other.id,
            version: 1,
            numericValue: 2,
          ),
        ],
      );
      await expectLater(finish(pending, input), failure);
      final after = (await journal.find(pending.session.id))!;
      expect(after.session.status, 'draft');
      expect(after.session.revision, 0);
      expect(after.session.note, isNull);
      expect(after.readings, isEmpty);
      expect((await practice.find(pending.session.id))!.milliseconds, 0);
      expect(await journal.draft(pending.session.id, 'finish'), isNotNull);
      await storage.database.customStatement(
        'DROP TRIGGER fail_second_reading',
      );
      await finish(pending, input);
      expect((await journal.find(pending.session.id))!.readings, hasLength(2));
      expect(await journal.draft(pending.session.id, 'finish'), isNull);
    },
  );

  test(
    'actual SQLITE_FULL retains draft and incomplete session then retries',
    () async {
      final pending = await draft();
      await journal.saveDraft(
        sessionId: pending.session.id,
        purpose: 'finish',
        baseRevision: 0,
        form: {'version': 1, 'note': 'Draft stays'},
      );
      final db = storage.database;
      await db.customStatement('PRAGMA wal_checkpoint(TRUNCATE)');
      final pages = (await db.customSelect('PRAGMA page_count').getSingle())
          .read<int>('page_count');
      await db.customStatement('PRAGMA max_page_count = $pages');
      final input = JournalReflection(note: List.filled(100000, 'q').join());
      await expectLater(
        finish(pending, input),
        throwsA(
          isA<LocalFailure>().having(
            (e) => e.kind,
            'kind',
            LocalFailureKind.full,
          ),
        ),
      );
      expect((await journal.find(pending.session.id))!.session.status, 'draft');
      expect(await journal.draft(pending.session.id, 'finish'), isNotNull);
      await db.customStatement('PRAGMA max_page_count = 1000000');
      await finish(pending, input);
      expect(
        (await journal.find(pending.session.id))!.session.note,
        input.note,
      );
    },
  );

  test('blank reflection is valid, changed completion is a conflict', () async {
    final pending = await draft();
    final saved = await finish(pending, JournalReflection());
    expect(saved.session.effortRating, isNull);
    await expectLater(
      finish(pending, JournalReflection(note: 'Different')),
      failure,
    );
    await expectLater(
      finish(pending, JournalReflection(), seconds: 121),
      failure,
    );
    expect((await journal.find(saved.session.id))!.session.activeSeconds, 120);
  });

  test('readings reject nonfinite, wrong type/range/skill and invented provenance atomically', () async {
    final pending = await draft();
    final another = await storage.skills.create(
      name: 'Another',
      kind: SkillKind.custom,
    );
    final foreign = await storage.metrics.create(
      MetricDefinitionsCompanion(
        skillId: Value(another.id),
        label: const Value('Count'),
        unitKey: const Value('count'),
        valueType: const Value('numeric'),
        direction: const Value('up'),
        sourceHint: const Value('manual'),
      ),
    );
    final bad = [
      JournalReadingInput(
        definitionId: measure.id,
        version: 1,
        numericValue: double.nan,
      ),
      JournalReadingInput(
        definitionId: measure.id,
        version: 1,
        numericValue: double.infinity,
      ),
      JournalReadingInput(
        definitionId: measure.id,
        version: 1,
        numericValue: 301,
      ),
      JournalReadingInput(
        definitionId: measure.id,
        version: 1,
        textValue: 'wrong',
      ),
      JournalReadingInput(
        definitionId: foreign.id,
        version: 1,
        numericValue: 2,
      ),
      JournalReadingInput(
        definitionId: measure.id,
        version: 1,
        numericValue: 2,
        sourceType: 'instrument_import',
      ),
    ];
    for (final reading in bad) {
      await expectLater(
        finish(pending, JournalReflection(readings: [reading])),
        failure,
      );
      expect((await journal.find(pending.session.id))!.session.status, 'draft');
      expect(await storage.metrics.readings(pending.session.id), isEmpty);
    }
    await expectLater(
      finish(
        pending,
        JournalReflection(
          readings: [
            reflection().readings.single,
            reflection().readings.single,
          ],
        ),
      ),
      failure,
    );
  });

  test('amendment preserves reading identity, increments once and rejects stale changes', () async {
    final saved = await finish(await draft(), reflection());
    final original = (await journal.find(saved.session.id))!;
    final edited = await journal.amend(
      saved.session.id,
      expectedRevision: saved.session.revision,
      reflection: reflection(value: 45),
    );
    expect(edited.revision, saved.session.revision + 1);
    final after = (await journal.find(saved.session.id))!;
    expect(after.readings.single.id, original.readings.single.id);
    expect(
      after.readings.single.createdAtUtc,
      original.readings.single.createdAtUtc,
    );
    final retry = await journal.amend(
      saved.session.id,
      expectedRevision: saved.session.revision,
      reflection: reflection(value: 45),
    );
    expect(retry.revision, edited.revision);
    await expectLater(
      journal.amend(
        saved.session.id,
        expectedRevision: saved.session.revision,
        reflection: reflection(value: 46),
      ),
      failure,
    );
    expect(
      (await journal.find(saved.session.id))!.readings.single.numericValue,
      45,
    );
  });

  test('manual amendment requires confirmation and updates only explicit duration/date', () async {
    final saved = await finish(await draft(), reflection());
    await expectLater(
      journal.amend(
        saved.session.id,
        expectedRevision: saved.session.revision,
        reflection: reflection(),
        manual: ManualJournalAmendment(
          seconds: 90,
          endedAtUtc: end,
          confirmed: false,
        ),
      ),
      failure,
    );
    final edited = await journal.amend(
      saved.session.id,
      expectedRevision: saved.session.revision,
      reflection: reflection(),
      manual: ManualJournalAmendment(
        seconds: 90,
        endedAtUtc: end,
        confirmed: true,
      ),
    );
    expect(edited.activeSeconds, 90);
    expect(edited.entryMode, 'manual');
    expect(edited.startedAtUtc, end.subtract(const Duration(seconds: 90)));
    expect((await practice.find(saved.session.id))!.milliseconds, 90000);
    await expectLater(
      journal.amend(
        saved.session.id,
        expectedRevision: edited.revision,
        reflection: reflection(),
        manual: ManualJournalAmendment(
          seconds: 0,
          endedAtUtc: end,
          confirmed: true,
        ),
      ),
      failure,
    );
  });

  test('timeline is live, stable and filters completed dates, skills and snapshots', () async {
    final values = <List<JournalSummary>>[];
    final subscription = journal
        .watchTimeline(const JournalFilter())
        .listen(values.add);
    final saved = await finish(await draft(), reflection());
    await storage.sessions.replaceExercises(saved.session.id, [
      SessionExercise(
        sessionId: saved.session.id,
        exerciseTitleSnapshot: 'Original title',
        ordinal: 0,
      ),
    ]);
    await storage.skills.setArchived(skill.id, true);
    final filtered = await journal
        .watchTimeline(
          JournalFilter(
            skillId: skill.id,
            fromUtc: end,
            untilUtc: end.add(const Duration(seconds: 1)),
            exerciseTitle: 'Original title',
          ),
        )
        .first;
    expect(filtered.single.session.id, saved.session.id);
    expect(filtered.single.skillName, skill.name);
    expect(
      await journal.watchTimeline(JournalFilter(untilUtc: end)).first,
      isEmpty,
    );
    expect(await journal.watchExerciseTitles(skillId: skill.id).first, [
      'Original title',
    ]);
    await journal.amend(
      saved.session.id,
      expectedRevision: saved.session.revision,
      reflection: reflection(easier: 'Changed'),
    );
    final updated = await journal.watchTimeline(const JournalFilter()).first;
    expect(updated.single.session.whatGotEasier, 'Changed');
    await subscription.cancel();
    expect(values, isNotEmpty);
    final leap = JournalFilter.nextLocalDay(DateTime(2024, 2, 29));
    expect(leap, DateTime(2024, 3, 1));
  });

  test(
    'delete/undo restores stable aggregate IDs and refuses a second restore',
    () async {
      final saved = await finish(await draft(), reflection());
      await storage.sessions.replaceExercises(saved.session.id, [
        SessionExercise(
          sessionId: saved.session.id,
          exerciseTitleSnapshot: 'Historical',
          ordinal: 0,
        ),
      ]);
      final before = (await journal.find(saved.session.id))!;
      final receipt = await journal.deleteConfirmed(
        saved.session.id,
        expectedRevision: saved.session.revision,
      );
      expect(receipt.canUndo, true);
      expect((await journal.watchOverview().first).sessions, 0);
      expect((await journal.watchOverview().first).seconds, 0);
      expect(await journal.find(saved.session.id), isNull);
      expect(await storage.metrics.readings(saved.session.id), isEmpty);
      await journal.undo(receipt);
      final restored = (await journal.find(saved.session.id))!;
      expect(restored.session.id, before.session.id);
      expect(restored.session.revision, before.session.revision + 1);
      expect(restored.readings, before.readings);
      expect(restored.exercises, before.exercises);
      expect((await practice.find(saved.session.id))!.milliseconds, 120000);
      expect((await journal.watchOverview().first).sessions, 1);
      expect((await journal.watchOverview().first).seconds, 120);
      await expectLater(journal.undo(receipt), failure);
      expect(
        await journal.watchTimeline(const JournalFilter()).first,
        hasLength(1),
      );
    },
  );

  test(
    'media deletion queues cleanup and never promises metadata-only undo',
    () async {
      final saved = await finish(await draft(), reflection());
      final path = 'media/${newId()}.png';
      await storage.database
          .into(storage.database.mediaAssets)
          .insert(
            MediaAssetsCompanion.insert(
              id: newId(),
              sessionId: saved.session.id,
              kind: 'image',
              mime: 'image/png',
              byteLength: 3,
              sha256: List.filled(64, '0').join(),
              relativePath: path,
              captureSource: 'file_import',
              storageState: 'ready',
              createdAtUtc: end,
            ),
          );
      final receipt = await journal.deleteConfirmed(
        saved.session.id,
        expectedRevision: saved.session.revision,
      );
      expect(receipt.canUndo, false);
      await expectLater(journal.undo(receipt), failure);
      expect(
        (await storage.database.select(storage.database.fileCleanupQueue).get())
            .single
            .relativePath,
        path,
      );
      expect(await journal.find(saved.session.id), isNull);
    },
  );

  test(
    'raw invalid form text survives reopening without becoming a reading',
    () async {
      final pending = await draft();
      await journal.saveDraft(
        sessionId: pending.session.id,
        purpose: 'finish',
        baseRevision: 0,
        form: {'version': 1, 'number': '-.', 'note': '🪷\n${'z' * 10000}'},
      );
      await storage.close();
      storage = await LoopStorage.open(directory);
      journal = JournalRepository(storage.database);
      expect(
        (await journal.draft(pending.session.id, 'finish'))!.formJson,
        contains('-.'),
      );
      expect(await storage.metrics.readings(pending.session.id), isEmpty);
      await expectLater(
        journal.saveDraft(
          sessionId: pending.session.id,
          purpose: 'finish',
          baseRevision: 0,
          form: {'version': 2},
        ),
        failure,
      );
    },
  );

  test(
    'draft writer retains failed content and drains the latest form on close',
    () async {
      final pending = await draft();
      final failing = _FailDraftOnce(storage.database);
      final writer = JournalDraftWriter(
        failing,
        debounce: const Duration(hours: 1),
      );
      writer.stage(
        sessionId: pending.session.id,
        purpose: 'finish',
        baseRevision: 0,
        form: {'version': 1, 'text': 'first'},
      );
      expect(await writer.flush(), false);
      expect(writer.hasPending, true);
      expect(writer.failures.values.single.kind, LocalFailureKind.full);
      writer.stage(
        sessionId: pending.session.id,
        purpose: 'finish',
        baseRevision: 0,
        form: {'version': 1, 'text': 'latest'},
      );
      await writer.close();
      expect(writer.hasPending, false);
      expect(writer.failures, isEmpty);
      expect(
        (await journal.draft(pending.session.id, 'finish'))!.formJson,
        contains('latest'),
      );
      writer.dispose();
    },
  );

  test('draft close waits for an actual pending SQLite transaction', () async {
    final pending = await draft();
    final started = Completer<void>();
    final release = Completer<void>();
    final held = storage.database.transaction(() async {
      started.complete();
      await release.future;
    });
    await started.future;
    final writer = JournalDraftWriter(
      journal,
      debounce: const Duration(hours: 1),
    );
    writer.stage(
      sessionId: pending.session.id,
      purpose: 'finish',
      baseRevision: 0,
      form: {'version': 1, 'note': 'pending'},
    );
    var closed = false;
    final closing = writer.close().then((_) {
      closed = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(closed, false);
    release.complete();
    await held;
    await closing;
    expect(await journal.draft(pending.session.id, 'finish'), isNotNull);
    writer.dispose();
  });
  test('typed observations preserve false and signed custom values; counts and ratings remain bounded', () async {
    Future<MetricDefinition> define(String unit, String type) =>
        storage.metrics.create(
          MetricDefinitionsCompanion(
            skillId: Value(skill.id),
            label: Value(unit),
            unitKey: Value(unit),
            valueType: Value(type),
            direction: const Value('none'),
            sourceHint: Value(unit == 'rating_1_5' ? 'self_rating' : 'manual'),
          ),
        );
    final count = await define('count', 'numeric'),
        percent = await define('percent', 'numeric'),
        rating = await define('rating_1_5', 'numeric');
    final signed = await define('signed_offset', 'numeric'),
        text = await define('observation', 'text'),
        check = await define('completed', 'checklist');
    final pending = await draft();
    for (final pair in [
      (count, -1.0),
      (count, 1.5),
      (percent, 101.0),
      (rating, 0.0),
      (rating, 2.5),
    ]) {
      await expectLater(
        finish(
          pending,
          JournalReflection(
            readings: [
              JournalReadingInput(
                definitionId: pair.$1.id,
                version: 1,
                numericValue: pair.$2,
              ),
            ],
          ),
        ),
        failure,
      );
    }
    await finish(
      pending,
      JournalReflection(
        readings: [
          JournalReadingInput(
            definitionId: count.id,
            version: 1,
            numericValue: 2,
          ),
          JournalReadingInput(
            definitionId: signed.id,
            version: 1,
            numericValue: -2.5,
          ),
          JournalReadingInput(
            definitionId: text.id,
            version: 1,
            textValue: 'A quieter phrase',
          ),
          JournalReadingInput(
            definitionId: check.id,
            version: 1,
            boolValue: false,
          ),
        ],
      ),
    );
    final values = (await journal.find(pending.session.id))!.readings;
    expect(
      values.firstWhere((r) => r.metricDefinitionId == check.id).boolValue,
      false,
    );
    expect(
      values.firstWhere((r) => r.metricDefinitionId == signed.id).numericValue,
      -2.5,
    );
  });
  test('manual amendment retry normalizes SQL timestamp precision and does not increment again', () async {
    final saved = await finish(await draft(), JournalReflection());
    final changedEnd = end
        .subtract(const Duration(days: 1))
        .add(const Duration(milliseconds: 123));
    final input = ManualJournalAmendment(
      seconds: 90,
      endedAtUtc: changedEnd,
      confirmed: true,
    );
    final first = await journal.amend(
      saved.session.id,
      expectedRevision: saved.session.revision,
      reflection: JournalReflection(),
      manual: input,
    );
    final retry = await journal.amend(
      saved.session.id,
      expectedRevision: saved.session.revision,
      reflection: JournalReflection(),
      manual: input,
    );
    expect(retry, first);
    expect(first.endedAtUtc!.millisecond, 0);
    final checkpoint = (await practice.find(saved.session.id))!.checkpoint!;
    expect(checkpoint.manualSeconds, 90);
    expect(
      checkpoint.manualDateLocal,
      changedEnd.toLocal().toIso8601String().substring(0, 10),
    );
  });
  test('timed draft cannot finish without start and measured history cannot become manual', () async {
    final pending = await practice.create(skillId: skill.id, exerciseIds: []);
    await expectLater(finish(pending, JournalReflection()), failure);
    final running = await practice.write(
      pending.session.copyWith(
        status: 'running',
        startedAtUtc: Value(end.subtract(const Duration(minutes: 2))),
      ),
      milliseconds: 0,
    );
    final saved = await finish(running, JournalReflection());
    await expectLater(
      journal.amend(
        saved.session.id,
        expectedRevision: saved.session.revision,
        reflection: JournalReflection(),
        manual: ManualJournalAmendment(
          seconds: 30,
          endedAtUtc: end,
          confirmed: true,
        ),
      ),
      failure,
    );
    expect((await journal.find(saved.session.id))!.session.entryMode, 'timed');
    expect((await journal.find(saved.session.id))!.session.activeSeconds, 120);
  });
}
