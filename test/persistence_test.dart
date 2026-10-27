import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:loop/core/data/database/loop_database.dart';
import 'package:loop/core/data/database/open_database.dart';
import 'package:loop/core/data/local_failure.dart';
import 'package:loop/core/data/settings_repository.dart';
import 'package:loop/core/data/storage.dart';
import 'package:loop/core/media/media_repository.dart';
import 'package:loop/core/media/private_files.dart';
import 'package:loop/features/practice/data/sessions_repository.dart';
import 'package:loop/features/progress/data/metrics_repository.dart';
import 'package:loop/features/reminders/data/reminders_repository.dart';
import 'package:loop/features/settings/data/database_preferences_repository.dart';
import 'package:loop/features/settings/data/file_preferences_repository.dart';
import 'package:loop/features/settings/domain/preferences.dart';
import 'package:loop/features/skills/data/skills_repository.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

Matcher failure(LocalFailureKind kind) =>
    throwsA(isA<LocalFailure>().having((e) => e.kind, 'kind', kind));

void main() {
  late Directory directory;
  late PrivateFiles files;
  late LoopDatabase db;
  late SkillsRepository skills;
  late SessionsRepository sessions;
  late MetricsRepository metrics;
  final now = DateTime.utc(2026, 10, 27, 8);

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('loop-storage-test-');
    files = await PrivateFiles.open(directory);
    db = await openDatabase(files);
    skills = SkillsRepository(db);
    sessions = SessionsRepository(db);
    metrics = MetricsRepository(db);
  });
  tearDown(() async {
    await db.close();
    await directory.delete(recursive: true);
  });

  Future<Skill> skill([String name = 'Synthetic typing']) =>
      skills.create(name: name, kind: SkillKind.typing);

  MetricDefinitionsCompanion definition(
    String skillId, {
    String unit = 'wpm',
    String type = 'numeric',
  }) => MetricDefinitionsCompanion(
    skillId: Value(skillId),
    label: const Value('Test measurement'),
    unitKey: Value(unit),
    valueType: Value(type),
    direction: const Value('up'),
    sourceHint: const Value('manual'),
    scaleMin: type == 'numeric' ? const Value(0) : const Value.absent(),
    scaleMax: type == 'numeric' ? const Value(300) : const Value.absent(),
  );

  MetricReadingsCompanion reading(
    String sessionId,
    MetricDefinition definition, {
    double? number = 40,
    String? text,
    bool? checked,
  }) => MetricReadingsCompanion(
    sessionId: Value(sessionId),
    metricDefinitionId: Value(definition.id),
    definitionVersion: Value(definition.version),
    numericValue: Value(number),
    textValue: Value(text),
    boolValue: Value(checked),
    sourceType: const Value('self_reported'),
    measuredAtUtc: Value(now),
  );

  test(
    'fresh database has all tables, foreign keys and no production seed',
    () async {
      expect(await db.select(db.skills).get(), isEmpty);
      expect(await db.select(db.sessions).get(), isEmpty);
      expect(
        (await db.customSelect('PRAGMA foreign_keys').getSingle())
            .data
            .values
            .single,
        1,
      );
      expect(
        (await db.customSelect('PRAGMA user_version').getSingle())
            .data
            .values
            .single,
        2,
      );
      expect(await db.select(db.dataMigrations).get(), hasLength(1));
      expect(db.allTables, hasLength(13));
    },
  );

  test('skill edit/archive/reorder/restore keeps immutable history', () async {
    final a = await skill('A');
    final b = await skill('B');
    final session = await sessions.createDraft(a.id);
    await skills.update(a.copyWith(name: 'Renamed'));
    await skills.reorder([b.id, a.id]);
    expect((await skills.watch().first).map((s) => s.id), [b.id, a.id]);
    await skills.setArchived(a.id, true);
    expect(await skills.watch().first, hasLength(1));
    expect((await sessions.find(session.id))?.skillId, a.id);
    await skills.setArchived(a.id, false);
    expect((await skills.find(a.id))?.name, 'Renamed');
    await expectLater(
      skills.reorder([a.id, a.id]),
      failure(LocalFailureKind.invalid),
    );
    expect((await skills.watch().first).map((s) => s.id), [b.id, a.id]);
  });

  test(
    'grapheme validation accepts 60 emoji and rejects blank/61 names',
    () async {
      final name = List.filled(60, '👩🏽‍🎨').join();
      expect((await skill(name)).name, name);
      await expectLater(skill('   '), failure(LocalFailureKind.invalid));
      await expectLater(skill('${name}a'), failure(LocalFailureKind.invalid));
    },
  );

  test('foreign keys prevent orphan sessions and exercises', () async {
    await expectLater(
      sessions.createDraft('00000000-0000-4000-8000-000000000000'),
      failure(LocalFailureKind.conflict),
    );
    await expectLater(
      skills.createExercise(skillId: 'absent', title: 'Exercise'),
      failure(LocalFailureKind.conflict),
    );
  });

  test('goal create/read/edit/delete and invalid targets', () async {
    final s = await skill();
    final goal = await skills.createGoal(
      GoalsCompanion(
        skillId: Value(s.id),
        title: const Value('Practice 3 times'),
        type: const Value('weekly_target'),
        targetValue: const Value(3),
        targetUnit: const Value('sessions'),
        status: const Value('active'),
      ),
    );
    expect(await skills.watchGoals(s.id).first, hasLength(1));
    await skills.updateGoal(
      goal.copyWith(status: 'completed', completedAtUtc: Value(now)),
    );
    expect((await skills.watchGoals(s.id).first).single.completedAtUtc, now);
    await expectLater(
      skills.createGoal(
        GoalsCompanion(
          skillId: Value(s.id),
          title: const Value('Invalid'),
          type: const Value('cumulative'),
          status: const Value('active'),
        ),
      ),
      failure(LocalFailureKind.conflict),
    );
    await skills.deleteGoal(goal.id);
    expect(await skills.watchGoals(s.id).first, isEmpty);
  });

  test('goals cannot use a different skill metric', () async {
    final a = await skill('A');
    final b = await skill('B');
    final metric = await metrics.create(definition(a.id));
    await expectLater(
      skills.createGoal(
        GoalsCompanion(
          skillId: Value(b.id),
          title: const Value('Threshold'),
          type: const Value('threshold'),
          status: const Value('active'),
          metricDefinitionId: Value(metric.id),
          definitionVersion: const Value(1),
          targetValue: const Value(50),
        ),
      ),
      failure(LocalFailureKind.conflict),
    );
  });

  test(
    'exercises preserve title snapshots after edit/archive/delete',
    () async {
      final s = await skill();
      final e = await skills.createExercise(
        skillId: s.id,
        title: 'Original',
        templateId: 'test-template',
      );
      var session = await sessions.createDraft(s.id);
      session = await sessions.save(
        session.copyWith(activeSeconds: 60),
        expectedRevision: 0,
      );
      await sessions.replaceExercises(session.id, [
        SessionExercise(
          sessionId: session.id,
          exerciseId: e.id,
          exerciseTitleSnapshot: e.title,
          ordinal: 0,
          allocatedSeconds: 60,
        ),
      ]);
      await skills.updateExercise(
        e.copyWith(title: 'Changed', isArchived: true),
      );
      expect(await skills.watchExercises(s.id).first, isEmpty);
      await skills.deleteExercise(e.id);
      final snapshot = (await sessions.exercises(session.id)).single;
      expect(snapshot.exerciseId, isNull);
      expect(snapshot.exerciseTitleSnapshot, 'Original');
    },
  );

  test(
    'exercise allocations rollback together on overflow/cross-skill',
    () async {
      final s = await skill();
      final other = await skill('Other');
      final exercise = await skills.createExercise(
        skillId: other.id,
        title: 'Other',
      );
      var session = await sessions.createDraft(s.id);
      session = await sessions.save(
        session.copyWith(activeSeconds: 10),
        expectedRevision: 0,
      );
      final original = SessionExercise(
        sessionId: session.id,
        exerciseTitleSnapshot: 'Snapshot',
        ordinal: 0,
        allocatedSeconds: 10,
      );
      await sessions.replaceExercises(session.id, [original]);
      await expectLater(
        sessions.replaceExercises(session.id, [
          original.copyWith(allocatedSeconds: const Value(11)),
        ]),
        failure(LocalFailureKind.conflict),
      );
      expect(
        (await sessions.exercises(session.id)).single.allocatedSeconds,
        10,
      );
      await expectLater(
        sessions.replaceExercises(session.id, [
          original.copyWith(exerciseId: Value(exercise.id)),
        ]),
        failure(LocalFailureKind.conflict),
      );
      await expectLater(
        sessions.save(session.copyWith(activeSeconds: 9), expectedRevision: 1),
        failure(LocalFailureKind.conflict),
      );
    },
  );

  test(
    'state transitions, optimistic revisions and one running timer are atomic',
    () async {
      final s = await skill();
      final draft = await sessions.createDraft(s.id);
      final second = await sessions.createDraft(s.id);
      var running = await sessions.save(
        draft.copyWith(status: 'running', startedAtUtc: Value(now)),
        expectedRevision: 0,
      );
      await expectLater(
        sessions.save(
          second.copyWith(status: 'running', startedAtUtc: Value(now)),
          expectedRevision: 0,
        ),
        failure(LocalFailureKind.conflict),
      );
      await expectLater(
        sessions.save(
          draft.copyWith(note: const Value('Stale')),
          expectedRevision: 0,
        ),
        failure(LocalFailureKind.conflict),
      );
      running = await sessions.save(
        running.copyWith(status: 'paused', activeSeconds: 30),
        expectedRevision: 1,
      );
      final complete = await sessions.save(
        running.copyWith(
          status: 'completed',
          endedAtUtc: Value(now.add(const Duration(minutes: 5))),
        ),
        expectedRevision: 2,
      );
      expect(complete.activeSeconds, 30); // No wall-clock duration inference.
      await expectLater(
        sessions.save(
          complete.copyWith(status: 'running'),
          expectedRevision: 3,
        ),
        failure(LocalFailureKind.conflict),
      );
    },
  );

  test(
    'manual zero requires deliberate evidence-only intent and an end',
    () async {
      final s = await skill();
      await expectLater(
        sessions.createDraft(s.id, mode: EntryMode.manual),
        failure(LocalFailureKind.invalid),
      );
      final duration = await sessions.createDraft(
        s.id,
        mode: EntryMode.manual,
        manualIntent: ManualIntent.duration,
      );
      await expectLater(
        sessions.save(
          duration.copyWith(status: 'completed', endedAtUtc: Value(now)),
          expectedRevision: 0,
        ),
        failure(LocalFailureKind.conflict),
      );
      final evidence = await sessions.createDraft(
        s.id,
        mode: EntryMode.manual,
        manualIntent: ManualIntent.evidenceOnly,
      );
      await expectLater(
        sessions.save(
          evidence.copyWith(status: 'completed'),
          expectedRevision: 0,
        ),
        failure(LocalFailureKind.conflict),
      );
      final saved = await sessions.save(
        evidence.copyWith(status: 'completed', endedAtUtc: Value(now)),
        expectedRevision: 0,
      );
      expect(saved.activeSeconds, 0);
      expect(saved.manualIntent, 'evidence_only');
    },
  );

  test(
    'metric versions preserve readings and prevent unit rewriting',
    () async {
      final s = await skill();
      final session = await sessions.createDraft(s.id);
      final first = await metrics.create(definition(s.id));
      final value = await metrics.record(reading(session.id, first));
      final second = await metrics.newVersion(
        definition(s.id, unit: 'bpm'),
        id: first.id,
        previousVersion: 1,
      );
      expect(second.version, 2);
      expect((await metrics.readings(session.id)).single.definitionVersion, 1);
      await expectLater(
        guardLocal(
          () =>
              (db.update(db.metricDefinitions)
                    ..where((d) => d.id.equals(first.id) & d.version.equals(1)))
                  .write(
                    const MetricDefinitionsCompanion(unitKey: Value('bpm')),
                  ),
        ),
        failure(LocalFailureKind.conflict),
      );
      await metrics.edit(value.copyWith(numericValue: const Value(45)));
      expect((await metrics.readings(session.id)).single.numericValue, 45);
      await metrics.setArchived(first.id, 1, true);
      expect(await metrics.definitions(s.id), hasLength(1));
      await metrics.deleteReading(value.id);
      expect(await metrics.readings(session.id), isEmpty);
    },
  );

  test(
    'readings reject wrong skill/type/range/duplicate and nonfinite numbers',
    () async {
      final a = await skill('A');
      final b = await skill('B');
      final session = await sessions.createDraft(a.id);
      final metric = await metrics.create(definition(a.id));
      final other = await metrics.create(definition(b.id));
      await expectLater(
        metrics.record(reading(session.id, other)),
        failure(LocalFailureKind.conflict),
      );
      await expectLater(
        metrics.record(reading(session.id, metric, number: -1)),
        failure(LocalFailureKind.conflict),
      );
      await expectLater(
        metrics.record(
          reading(session.id, metric, number: null, text: 'wrong'),
        ),
        failure(LocalFailureKind.conflict),
      );
      await expectLater(
        metrics.record(reading(session.id, metric, number: double.nan)),
        failure(LocalFailureKind.invalid),
      );
      await expectLater(
        metrics.record(reading(session.id, metric, number: double.infinity)),
        failure(LocalFailureKind.invalid),
      );
      await metrics.record(reading(session.id, metric));
      await expectLater(
        metrics.record(reading(session.id, metric)),
        failure(LocalFailureKind.conflict),
      );
    },
  );

  test('text and checklist retain missing numeric values as null', () async {
    final s = await skill();
    final session = await sessions.createDraft(s.id);
    final text = await metrics.create(
      definition(s.id, type: 'text', unit: 'observation'),
    );
    final check = await metrics.create(
      definition(s.id, type: 'checklist', unit: 'done'),
    );
    await metrics.record(
      reading(session.id, text, number: null, text: 'Synthetic observation'),
    );
    await metrics.record(
      reading(session.id, check, number: null, checked: false),
    );
    final values = await metrics.readings(session.id);
    expect(values.every((v) => v.numericValue == null), true);
    expect(
      values.singleWhere((v) => v.metricDefinitionId == check.id).boolValue,
      false,
    );
  });

  test('reminder CRUD validates time and weekday constraints', () async {
    final repository = RemindersRepository(db);
    final r = await repository.create(
      const RemindersCompanion(
        localTimeHHmm: Value('08:30'),
        weekdaysBitset: const Value(127),
        ianaZone: const Value('Asia/Manila'),
        messageId: const Value('practice'),
      ),
    );
    expect(await repository.watch().first, hasLength(1));
    await repository.update(r.copyWith(enabled: true));
    expect((await repository.watch().first).single.enabled, true);
    await expectLater(
      repository.update(r.copyWith(localTimeHHmm: '24:00')),
      failure(LocalFailureKind.conflict),
    );
    await expectLater(
      repository.update(r.copyWith(weekdaysBitset: 0)),
      failure(LocalFailureKind.conflict),
    );
    await repository.delete(r.id);
    expect(await repository.watch().first, isEmpty);
  });

  test('settings JSON batch rolls back and remove persists', () async {
    final settings = SettingsRepository(db);
    await settings.putAll({'weekStart': 1, 'locale': 'en'});
    await expectLater(
      settings.putAll({'weekStart': 2, '': true}),
      failure(LocalFailureKind.conflict),
    );
    expect(await settings.read('weekStart'), 1);
    await settings.remove('locale');
    expect(await settings.read('locale'), isNull);
  });

  test('legacy preference import is lossless, atomic and only once', () async {
    final legacy = FilePreferencesRepository(directory);
    const original = Preferences(
      appearance: Appearance.dark,
      onboardingSeen: true,
      extensions: {
        'future': {
          'nested': ['value', 1, null],
        },
      },
    );
    await legacy.save(original);
    final originalBytes = await File('${directory.path}/preferences.json')
        .readAsBytes();
    final repository = DatabasePreferencesRepository(db, directory);
    await repository.importLegacy();
    final loaded = await repository.load();
    expect(loaded.appearance, Appearance.dark);
    expect(loaded.extensions, original.extensions);
    await repository.save(loaded.copyWith(appearance: Appearance.light));
    await repository.importLegacy();
    expect((await repository.load()).appearance, Appearance.light);
    expect(
      await File('${directory.path}/preferences.json').readAsBytes(),
      originalBytes,
    );
    await expectLater(
      repository.resetCorruptPreferences(),
      failure(LocalFailureKind.corrupt),
    );
  });

  test(
    'corrupt/future legacy preferences remain intact without import marker',
    () async {
      final file = File('${directory.path}/preferences.json');
      final repository = DatabasePreferencesRepository(db, directory);
      await file.writeAsString('{damaged');
      await expectLater(
        repository.importLegacy(),
        throwsA(isA<PreferencesFailure>()),
      );
      expect(
        await SettingsRepository(db).read('m03PreferencesImported'),
        isNull,
      );
      expect(await file.readAsString(), '{damaged');
      await file.writeAsString(
        '{"schema":99,"appearance":"dark","onboardingSeen":true}',
      );
      await expectLater(
        repository.importLegacy(),
        throwsA(
          isA<PreferencesFailure>().having(
            (e) => e.kind,
            'kind',
            PreferencesFailureKind.unsupportedVersion,
          ),
        ),
      );
      expect(await SettingsRepository(db).read('theme'), isNull);
    },
  );

  test(
    'legacy import never overwrites prior SQL settings without a marker',
    () async {
      await SettingsRepository(db).putAll({'theme': 'dark'});
      final preferences = DatabasePreferencesRepository(db, directory);
      await preferences.importLegacy();
      expect((await preferences.load()).appearance, Appearance.dark);
    },
  );

  test('metric goals require the definition version unit', () async {
    final s = await skill();
    final metric = await metrics.create(definition(s.id));
    final goal = GoalsCompanion(
      skillId: Value(s.id),
      title: const Value('Threshold'),
      type: const Value('threshold'),
      status: const Value('active'),
      metricDefinitionId: Value(metric.id),
      definitionVersion: const Value(1),
      targetValue: const Value(50),
      targetUnit: const Value('bpm'),
    );
    await expectLater(
      skills.createGoal(goal),
      failure(LocalFailureKind.conflict),
    );
    expect(
      (await skills.createGoal(goal.copyWith(targetUnit: const Value('wpm'))))
          .targetUnit,
      'wpm',
    );
  });

  test(
    'real close/reopen preserves data, preferences and constraints',
    () async {
      final s = await skill();
      final repository = DatabasePreferencesRepository(db, directory);
      await repository.importLegacy();
      await repository.save(
        const Preferences(appearance: Appearance.dark, onboardingSeen: true),
      );
      await db.close();
      db = await openDatabase(files);
      expect((await SkillsRepository(db).find(s.id))?.name, s.name);
      expect(
        (await DatabasePreferencesRepository(db, directory).load()).appearance,
        Appearance.dark,
      );
      expect(
        (await db.customSelect('PRAGMA foreign_key_check').get()),
        isEmpty,
      );
    },
  );

  test(
    'bounded SQLite page limit causes SQLITE_FULL and rolls back old data',
    () async {
      final settings = SettingsRepository(db);
      await settings.putAll({'unchanged': 'original'});
      final count =
          (await db.customSelect('PRAGMA page_count').getSingle())
                  .data
                  .values
                  .single
              as int;
      await db.customStatement('PRAGMA max_page_count = $count');
      // Multiple bounded values fill only this test database, never the host disk.
      await expectLater(
        settings.putAll({
          for (var i = 0; i < 100; i++)
            'large$i': List.filled(50000, 'x').join(),
        }),
        failure(LocalFailureKind.full),
      );
      expect(await settings.read('unchanged'), 'original');
      expect(await settings.read('large0'), isNull);
      await db.customStatement('PRAGMA max_page_count = 100000');
      await settings.putAll({'retry': true});
      expect(await settings.read('retry'), true);
    },
  );

  test(
    'corrupt database returns sanitized failure and never resets its bytes',
    () async {
      await db.close();
      final file = await files.databaseFile();
      final corrupt = List<int>.generate(4096, (i) => i % 255);
      await file.writeAsBytes(corrupt, flush: true);
      await expectLater(openDatabase(files), failure(LocalFailureKind.corrupt));
      expect(await file.readAsBytes(), corrupt);
    },
  );

  test('future schema is rejected without modifying database bytes', () async {
    await db.close();
    final file = await files.databaseFile();
    final raw = sql.sqlite3.open(file.path);
    raw.execute('PRAGMA user_version = 99');
    raw.close();
    final before = await file.readAsBytes();
    await expectLater(
      openDatabase(files),
      failure(LocalFailureKind.unsupportedVersion),
    );
    expect(await file.readAsBytes(), before);
  });

  test(
    'live query failures expose safe categories instead of raw errors',
    () async {
      // A real failed query can include SQL or private parameters. Repository
      // streams retain the same typed boundary as one-shot writes/reads.
      await db.customStatement('DROP TABLE skills');
      await expectLater(skills.watch(), emitsError(isA<LocalFailure>()));
    },
  );

  test('unversioned database with existing tables is preserved', () async {
    await db.close();
    final file = await files.databaseFile();
    await file.delete();
    final raw = sql.sqlite3.open(file.path);
    raw.execute('CREATE TABLE prior_content (value TEXT NOT NULL)');
    raw.execute("INSERT INTO prior_content VALUES ('synthetic sentinel')");
    raw.close();
    final before = await file.readAsBytes();
    await expectLater(openDatabase(files), failure(LocalFailureKind.corrupt));
    expect(await file.readAsBytes(), before);
  });

  test(
    'unavailable database and symlink sidecar fail without external writes',
    () async {
      await db.close();
      final file = await files.databaseFile();
      await file.delete();
      await Directory(file.path).create();
      await expectLater(
        openDatabase(files),
        failure(LocalFailureKind.unsafePath),
      );
      await Directory(file.path).delete();
      final outside = await File('${directory.path}/sentinel')
          .writeAsString('unchanged');
      final link = Link('${file.path}-wal');
      await link.create(outside.path);
      await expectLater(
        openDatabase(files),
        failure(LocalFailureKind.unsafePath),
      );
      expect(await outside.readAsString(), 'unchanged');
    },
  );

  test(
    'media commit compensation, missing detection and durable cascade cleanup',
    () async {
      final s = await skill();
      final session = await sessions.createDraft(s.id);
      final repository = MediaRepository(db, files);
      final asset = await repository.attach(
        sessionId: session.id,
        kind: 'image',
        mime: 'image/test-fixture',
        bytes: Stream.value([1, 2, 3, 4]),
        captureSource: 'file_import',
      );
      await repository.updateLabel(
        asset.id,
        label: 'Synthetic',
        isBaseline: true,
      );
      expect(
        (await repository.watchForSession(session.id).first).single.isBaseline,
        true,
      );
      await expectLater(
        repository.attach(
          sessionId: 'missing',
          kind: 'audio',
          mime: 'audio/test-fixture',
          bytes: Stream.value([5, 6]),
          captureSource: 'file_import',
        ),
        failure(LocalFailureKind.conflict),
      );
      expect(await files.mediaPaths().toList(), hasLength(1));
      await File('${directory.path}/${asset.relativePath}')
          .writeAsBytes([4, 3, 2, 1]);
      final missing = await FileReconciler(db, files).run();
      expect(missing.missing, 1);
      expect(
        (await repository.watchForSession(session.id).first)
            .single
            .storageState,
        'missing',
      );
      await sessions.deleteConfirmed(session.id);
      expect(await db.select(db.fileCleanupQueue).get(), hasLength(1));
      await db.close();
      db = await openDatabase(files);
      final result = await FileReconciler(db, files).run();
      expect(result.deleted, 1);
      expect(result.cleanupRemaining, 0);
      expect(await files.mediaPaths().toList(), isEmpty);
    },
  );

  test(
    'reconciler retains unreferenced evidence and reports its bounded scan',
    () async {
      final orphan = await files.write(Stream.value([8, 9]));
      final report = await FileReconciler(db, files).run(limit: 1);
      expect(report.unreferenced, 1);
      await files.verify(orphan);
    },
  );

  test(
    'failed storage bootstrap keeps journal data when legacy prefs are damaged',
    () async {
      final s = await skill();
      await db.close();
      await File('${directory.path}/preferences.json')
          .writeAsString('{damaged');
      await expectLater(
        LoopStorage.open(directory),
        throwsA(isA<PreferencesFailure>()),
      );
      db = await openDatabase(files);
      expect((await SkillsRepository(db).find(s.id))?.id, s.id);
    },
  );

  test('failure mapping strips content, SQL and paths', () {
    final error = localFailure(
      sql.SqliteException(
        extendedResultCode: 13,
        message: 'personal note',
        causingStatement: 'private SQL',
        parametersToStatement: ['private content'],
      ),
    );
    expect(error.toString(), 'Local storage failure: full');
  });
}
