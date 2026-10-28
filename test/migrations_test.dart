import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop/core/data/database/loop_database.dart';
import 'package:loop/core/data/database/open_database.dart';
import 'package:loop/core/data/local_failure.dart';
import 'package:loop/core/media/media_repository.dart';
import 'package:loop/core/media/private_files.dart';
import 'package:loop/features/skills/data/skills_repository.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

class _InterruptedMigrator extends Migrator {
  _InterruptedMigrator(super.database);
  @override
  Future<void> createTrigger(Trigger trigger) {
    if (trigger.entityName == 'cleanup_deleted_media') {
      throw const LocalFailure(LocalFailureKind.unavailable);
    }
    return super.createTrigger(trigger);
  }
}

class _InterruptedDatabase extends LoopDatabase {
  _InterruptedDatabase(super.executor);
  @override
  Migrator createMigrator() => _InterruptedMigrator(this);
}

void main() {
  late Directory directory;
  late PrivateFiles files;
  LoopDatabase? database;
  const skillId = '11111111-1111-4111-8111-111111111111';
  const mediaPath = 'media/99999999-9999-4999-8999-999999999999.blob';

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('loop-migration-test-');
    files = await PrivateFiles.open(directory);
  });
  tearDown(() async {
    await database?.close();
    database = null;
    await directory.delete(recursive: true);
  });

  Future<void> seed() async {
    final file = await files.databaseFile();
    final raw = sql.sqlite3.open(file.path);
    try {
      raw.execute('PRAGMA foreign_keys = ON');
      raw.execute(
        await File('test/fixtures/database/schema_v1.sql').readAsString(),
      );
      raw.execute(
        await File('test/fixtures/database/seed_v1.sql').readAsString(),
      );
    } finally {
      raw.close();
    }
    await File('${directory.path}/$mediaPath')
        .writeAsBytes([1, 2, 3], flush: true);
  }

  test(
    'fresh schema matches generated definitions and frozen v4 SQL',
    () async {
      database = await openDatabase(files);
      await database!.validateDatabaseSchema(
        options: const ValidationOptions(
          validateDropped: true,
          validateColumnConstraints: true,
        ),
      );
      // Compare the frozen DDL with a fresh production DB, including indexes and triggers.
      final fixture = sql.sqlite3.openInMemory();
      try {
        fixture.execute(
          await File('test/fixtures/database/schema_v4.sql').readAsString(),
        );
        final expected = fixture.select(
          "SELECT name,sql FROM sqlite_master WHERE name NOT LIKE 'sqlite_%' ORDER BY name",
        );
        final actual = await database!
            .customSelect(
              "SELECT name,sql FROM sqlite_master WHERE name NOT LIKE 'sqlite_%' ORDER BY name",
            )
            .get();
        expect(
          actual.map((r) => r.data),
          expected.map(Map<String, Object?>.from),
        );
      } finally {
        fixture.close();
      }
    },
  );

  test(
    'seeded internal v1 migration preserves every entity and enables cleanup',
    () async {
      await seed();
      database = await openDatabase(files);
      final db = database!;
      await db.validateDatabaseSchema(
        options: const ValidationOptions(
          validateDropped: true,
          validateColumnConstraints: true,
        ),
      );
      expect(
        (await db.select(db.skills).get()).single.name,
        'Synthetic typing',
      );
      expect(
        (await db.select(db.sessions).get()).single.note,
        'Synthetic prior-version journal',
      );
      expect((await db.select(db.sessions).get()).single.activeSeconds, 0);
      expect(
        (await db.select(db.sessions).get()).single.endedAtUtc!.isUtc,
        true,
      );
      expect(
        (await db.select(db.sessionExercises).get())
            .single
            .exerciseTitleSnapshot,
        'Synthetic exercise',
      );
      expect(
        (await db.select(db.metricReadings).get()).single.numericValue,
        40,
      );
      expect(
        (await db.select(db.metricDefinitions).get()).single.unitKey,
        'wpm',
      );
      expect((await db.select(db.goals).get()).single.targetValue, 60);
      expect(await db.select(db.exercises).get(), hasLength(1));
      expect(await db.select(db.mediaAssets).get(), hasLength(1));
      expect(await db.select(db.reminders).get(), hasLength(1));
      expect(await db.select(db.settings).get(), hasLength(1));
      expect(await db.select(db.exportHistory).get(), hasLength(1));
      expect((await db.select(db.dataMigrations).get()).map((m) => m.version), [
        1,
        2,
        3,
        4,
      ]);
      expect(await db.select(db.fileCleanupQueue).get(), isEmpty);
      await SkillsRepository(db).deleteConfirmed(skillId);
      expect(await db.select(db.sessions).get(), isEmpty);
      expect(await db.select(db.metricReadings).get(), isEmpty);
      expect(await db.select(db.metricDefinitions).get(), isEmpty);
      expect(await db.select(db.goals).get(), isEmpty);
      expect(await db.select(db.reminders).get(), isEmpty);
      expect(
        (await db.select(db.fileCleanupQueue).get()).single.relativePath,
        mediaPath,
      );
      expect((await FileReconciler(db, files).run()).deleted, 1);
      expect(await File('${directory.path}/$mediaPath').exists(), false);
    },
  );

  test(
    'interrupted migration rolls back DDL and version, then reopens safely',
    () async {
      await seed();
      final file = await files.databaseFile();
      database = _InterruptedDatabase(NativeDatabase(file));
      await expectLater(
        database!.customSelect('SELECT 1').get(),
        throwsA(isA<LocalFailure>()),
      );
      await database!.close();
      database = null;
      final raw = sql.sqlite3.open(file.path);
      try {
        expect(raw.select('PRAGMA user_version').single.values.single, 1);
        expect(
          raw.select(
            "SELECT name FROM sqlite_master WHERE name = 'file_cleanup_queue'",
          ),
          isEmpty,
        );
        expect(
          raw.select('SELECT note FROM sessions').single['note'],
          'Synthetic prior-version journal',
        );
        expect(raw.select('PRAGMA integrity_check').single.values.single, 'ok');
      } finally {
        raw.close();
      }
      database = await openDatabase(files);
      expect(
        (await database!.customSelect('PRAGMA user_version').getSingle())
            .data
            .values
            .single,
        LoopDatabase.currentVersion,
      );
      expect(
        (await database!.select(database!.sessions).get()).single.note,
        'Synthetic prior-version journal',
      );
    },
  );
}
