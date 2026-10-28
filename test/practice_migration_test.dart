import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop/core/data/database/loop_database.dart';
import 'package:loop/core/data/database/open_database.dart';
import 'package:loop/core/data/local_failure.dart';
import 'package:loop/core/media/private_files.dart';
import 'package:loop/features/practice/data/practice_repository.dart';
import 'package:loop/features/practice/domain/practice_engine.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

class _InterruptedClockTable extends Migrator {
  _InterruptedClockTable(super.database);
  @override
  Future<void> createTable(TableInfo<Table, Object?> table) async {
    await super.createTable(table);
    if (table.actualTableName == 'practice_checkpoints')
      throw const LocalFailure(LocalFailureKind.full);
  }
}

class _InterruptedDatabase extends LoopDatabase {
  _InterruptedDatabase(super.executor);
  @override
  Migrator createMigrator() => _InterruptedClockTable(this);
}

void main() {
  late Directory directory;
  late PrivateFiles files;
  LoopDatabase? db;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('loop-v3-clock-upgrade-');
    files = await PrivateFiles.open(directory);
    final raw = sql.sqlite3.open((await files.databaseFile()).path);
    raw.execute('PRAGMA foreign_keys=ON');
    raw.execute(
      await File('test/fixtures/database/schema_v3.sql').readAsString(),
    );
    raw.execute(
      await File('test/fixtures/database/seed_v1.sql').readAsString(),
    );
    raw.execute(
      'INSERT INTO data_migrations VALUES (2,1793088001),(3,1793088002)',
    );
    raw.execute(
      "INSERT INTO sessions(id, skill_id, entry_mode, status, active_seconds, created_at_utc, updated_at_utc) VALUES ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','11111111-1111-4111-8111-111111111111','timed','draft',17,1793088001,1793088001)",
    );
    raw.execute(
      "UPDATE sessions SET status='running', started_at_utc=1793088001, revision=1 WHERE id='aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'",
    );
    raw.close();
  });
  tearDown(() async {
    await db?.close();
    await directory.delete(recursive: true);
  });

  test('v3 migration preserves all existing rows and legacy running time', () async {
    final raw = sql.sqlite3.open((await files.databaseFile()).path);
    final before = <String, List<Map<String, Object?>>>{};
    final columns = <String, List<String>>{};
    for (final table in raw.select(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
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
    for (final name in before.keys) {
      final projection = columns[name]!.map((c) => '"$c"').join(',');
      final rows = await db!
          .customSelect(
            'SELECT $projection FROM "$name"${name == 'data_migrations' ? ' WHERE version <= 3' : ''}',
          )
          .get();
      expect(
        rows.map((r) => r.data),
        unorderedEquals(before[name]!),
        reason: name,
      );
    }
    expect(await db!.select(db!.practiceCheckpoints).get(), isEmpty);
    final engine = PracticeEngine(PracticeRepository(db!), ticking: false);
    expect(await engine.initialize(), true);
    expect(engine.record!.session.status, 'paused');
    expect(engine.record!.session.interruptionReason, 'recovered');
    expect(engine.milliseconds, 17000);
    expect(engine.running, false);
    expect(engine.record!.checkpoint!.activeMilliseconds, 17000);
    engine.dispose();
  });

  test(
    'failure after clock-table DDL rolls back version schema and all rows',
    () async {
      db = _InterruptedDatabase(
        NativeDatabase(
          await files.databaseFile(),
          setup: (raw) => raw.execute('PRAGMA foreign_keys=ON'),
        ),
      );
      await expectLater(
        db!.customSelect('SELECT 1').get(),
        throwsA(isA<LocalFailure>()),
      );
      await db!.close();
      db = null;
      final raw = sql.sqlite3.open((await files.databaseFile()).path);
      expect(raw.select('PRAGMA user_version').single.values.single, 3);
      expect(
        raw.select(
          "SELECT name FROM sqlite_master WHERE name='practice_checkpoints'",
        ),
        isEmpty,
      );
      expect(raw.select('SELECT * FROM sessions'), hasLength(2));
      expect(raw.select('SELECT * FROM data_migrations'), hasLength(3));
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
      expect(await db!.select(db!.sessions).get(), hasLength(2));
    },
  );
}
