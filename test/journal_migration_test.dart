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

class _InterruptedJournalMigrator extends Migrator {
  _InterruptedJournalMigrator(super.database);
  @override
  Future<void> createTable(TableInfo<Table, Object?> table) async {
    await super.createTable(table);
    if (table.actualTableName == 'journal_drafts')
      throw const LocalFailure(LocalFailureKind.full);
  }
}

class _InterruptedJournalDatabase extends LoopDatabase {
  _InterruptedJournalDatabase(super.executor);
  @override
  Migrator createMigrator() => _InterruptedJournalMigrator(this);
}

void main() {
  late Directory directory;
  late PrivateFiles files;
  LoopDatabase? db;
  const sessionId = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('loop-v4-journal-');
    files = await PrivateFiles.open(directory);
    final raw = sql.sqlite3.open((await files.databaseFile()).path);
    raw.execute('PRAGMA foreign_keys=ON');
    raw.execute(
      await File('test/fixtures/database/schema_v4.sql').readAsString(),
    );
    raw.execute(
      await File('test/fixtures/database/seed_v1.sql').readAsString(),
    );
    raw.execute(
      'INSERT INTO data_migrations VALUES (2,1793088001),(3,1793088002),(4,1793088003)',
    );
    raw.execute(
      "INSERT INTO sessions(id,skill_id,entry_mode,status,active_seconds,created_at_utc,updated_at_utc) VALUES ('$sessionId','11111111-1111-4111-8111-111111111111','timed','draft',17,1793088001,1793088001)",
    );
    raw.execute(
      "INSERT INTO practice_checkpoints(session_id,active_milliseconds,planned_seconds,manual_seconds,manual_date_local,checkpoint_at_utc) VALUES ('$sessionId',17987,120,0,NULL,1793088002)",
    );
    raw.close();
  });
  tearDown(() async {
    await db?.close();
    await directory.delete(recursive: true);
  });

  test('v4 to v5 preserves every old cell, FK and fractional checkpoint', () async {
    final raw = sql.sqlite3.open((await files.databaseFile()).path);
    final before = <String, List<Map<String, Object?>>>{};
    final columns = <String, List<String>>{};
    for (final row in raw.select(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
    )) {
      final name = row['name'] as String;
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
            'SELECT $projection FROM "$table"${table == 'data_migrations' ? ' WHERE version<=4' : ''}',
          )
          .get();
      expect(
        rows.map((r) => r.data),
        unorderedEquals(before[table]!),
        reason: table,
      );
    }
    expect(
      (await db!.select(db!.practiceCheckpoints).get())
          .single
          .activeMilliseconds,
      17987,
    );
    expect(
      (await db!.select(db!.sessions).get()).every(
        (s) => s.whatGotEasier == null,
      ),
      true,
    );
    expect(await db!.select(db!.journalDrafts).get(), isEmpty);
    expect(await db!.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
  });
  test(
    'failure after ADD COLUMN and draft DDL rolls both back and retries',
    () async {
      db = _InterruptedJournalDatabase(
        NativeDatabase(await files.databaseFile()),
      );
      await expectLater(
        db!.customSelect('SELECT 1').get(),
        throwsA(isA<LocalFailure>()),
      );
      await db!.close();
      db = null;
      final raw = sql.sqlite3.open((await files.databaseFile()).path);
      expect(raw.select('PRAGMA user_version').single.values.single, 4);
      expect(
        raw
            .select('PRAGMA table_info(sessions)')
            .any((r) => r['name'] == 'what_got_easier'),
        false,
      );
      expect(
        raw.select(
          "SELECT name FROM sqlite_master WHERE name='journal_drafts'",
        ),
        isEmpty,
      );
      expect(
        raw
            .select('SELECT active_milliseconds FROM practice_checkpoints')
            .single
            .values
            .single,
        17987,
      );
      expect(raw.select('SELECT * FROM data_migrations'), hasLength(4));
      expect(raw.select('PRAGMA integrity_check').single.values.single, 'ok');
      raw.close();
      db = await openDatabase(files);
      expect(
        (await db!.customSelect('PRAGMA user_version').getSingle())
            .data
            .values
            .single,
        5,
      );
      expect(
        (await db!.select(db!.practiceCheckpoints).get())
            .single
            .activeMilliseconds,
        17987,
      );
      expect(await db!.select(db!.sessions).get(), hasLength(2));
    },
  );
}
