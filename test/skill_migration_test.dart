import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop/core/data/database/loop_database.dart';
import 'package:loop/core/data/database/open_database.dart';
import 'package:loop/core/data/local_failure.dart';
import 'package:loop/core/media/private_files.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

class _FailAfterGoalRebuild extends Migrator {
  _FailAfterGoalRebuild(super.database);
  @override
  Future<void> alterTable(TableMigration migration) async {
    await super.alterTable(migration);
    throw const LocalFailure(LocalFailureKind.unavailable);
  }
}

class _InterruptedV3 extends LoopDatabase {
  _InterruptedV3(super.executor);
  @override
  Migrator createMigrator() => _FailAfterGoalRebuild(this);
}

void main() {
  late Directory directory;
  late PrivateFiles files;
  LoopDatabase? db;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('loop-m04-to-m05-');
    files = await PrivateFiles.open(directory);
  });
  tearDown(() async {
    await db?.close();
    await directory.delete(recursive: true);
  });

  Future<sql.Database> seedV2() async {
    final raw = sql.sqlite3.open((await files.databaseFile()).path);
    raw.execute('PRAGMA foreign_keys = ON');
    raw.execute(
      await File('test/fixtures/database/schema_v2.sql').readAsString(),
    );
    raw.execute(
      await File('test/fixtures/database/seed_v1.sql').readAsString(),
    );
    raw.execute('INSERT INTO data_migrations VALUES (2,1793088001)');
    raw.execute(
      "INSERT INTO file_cleanup_queue VALUES ('media/aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa.blob',1793088001)",
    );
    raw.execute(
      "UPDATE goals SET status = 'completed', completed_at_utc = 1793088001",
    );
    raw.execute('PRAGMA user_version = 2');
    return raw;
  }

  test('real M04 v2 schema preserves every seeded column, completion and queued work', () async {
    final raw = await seedV2();
    final before = <String, List<Map<String, Object?>>>{};
    final columns = <String, List<String>>{};
    for (final table in raw.select(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'",
    )) {
      final name = table['name'] as String;
      columns[name] = raw
          .select('PRAGMA table_info("$name")')
          .map((r) => r['name'] as String)
          .toList();
      before[name] = raw
          .select('SELECT * FROM "$name"')
          .map(Map<String, Object?>.from)
          .toList();
    }
    raw.close();
    db = await openDatabase(files);
    await db!.validateDatabaseSchema(
      options: const ValidationOptions(
        validateDropped: true,
        validateColumnConstraints: true,
      ),
    );
    for (final table in before.keys) {
      final projection = columns[table]!.map((c) => '"$c"').join(',');
      final rows = await db!
          .customSelect(
            'SELECT $projection FROM "$table"${table == 'data_migrations' ? ' WHERE version <= 2' : ''}',
          )
          .get();
      expect(
        rows.map((r) => r.data),
        unorderedEquals(before[table]!),
        reason: table,
      );
    }
    final goal = (await db!.select(db!.goals).get()).single;
    expect(goal.motivation, isNull);
    expect(
      goal.completedAtUtc,
      DateTime.fromMillisecondsSinceEpoch(1793088001000, isUtc: true),
    );
    expect((await db!.select(db!.dataMigrations).get()).map((m) => m.version), [
      1,
      2,
      3,
      4,
      5,
    ]);
    // Recreated goal-unit triggers must still reject incompatible updates.
    await expectLater(
      guardLocal(
        () => db!.customStatement("UPDATE goals SET target_unit='bpm'"),
      ),
      throwsA(
        isA<LocalFailure>().having(
          (e) => e.kind,
          'kind',
          LocalFailureKind.conflict,
        ),
      ),
    );
    expect((await db!.select(db!.goals).get()).single.targetUnit, 'wpm');
  });

  test(
    'interrupted v2 goals rebuild rolls back data/schema/version and retries',
    () async {
      (await seedV2()).close();
      db = _InterruptedV3(
        NativeDatabase(
          await files.databaseFile(),
          setup: (database) => database.execute('PRAGMA foreign_keys = ON'),
        ),
      );
      await expectLater(
        db!.customSelect('SELECT 1').get(),
        throwsA(isA<LocalFailure>()),
      );
      await db!.close();
      db = null;
      final raw = sql.sqlite3.open((await files.databaseFile()).path);
      expect(raw.select('PRAGMA user_version').single.values.single, 2);
      expect(
        raw.select('PRAGMA table_info(goals)').map((r) => r['name']),
        isNot(contains('motivation')),
      );
      expect(
        raw
            .select('SELECT completed_at_utc FROM goals')
            .single['completed_at_utc'],
        1793088001,
      );
      expect(raw.select('SELECT * FROM file_cleanup_queue'), hasLength(1));
      expect(raw.select('PRAGMA integrity_check').single.values.single, 'ok');
      raw.close();
      db = await openDatabase(files);
      expect(
        (await db!.customSelect('PRAGMA user_version').getSingle())
            .data
            .values
            .single,
        LoopDatabase.currentVersion,
      );
      expect((await db!.select(db!.goals).get()).single.status, 'completed');
    },
  );
}
