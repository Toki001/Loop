import 'package:drift/drift.dart';

import '../local_failure.dart';
import 'utc_datetime.dart';

part 'loop_database.g.dart';

/// Private to persistence/repository code; views never execute table writes.
@DriftDatabase(include: {'schema.drift'})
class LoopDatabase extends _$LoopDatabase {
  LoopDatabase(super.executor);
  static const currentVersion = 5;

  @override
  int get schemaVersion => currentVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => transaction(() async {
      await migrator.createAll();
      await into(dataMigrations).insert(
        DataMigrationsCompanion.insert(
          version: const Value(currentVersion),
          completedAtUtc: DateTime.now().toUtc(),
        ),
      );
      await customStatement('PRAGMA user_version = $currentVersion');
    }),
    onUpgrade: (migrator, from, to) => transaction(() async {
      if (from < 1 || from >= currentVersion || to != currentVersion) {
        throw const LocalFailure(LocalFailureKind.unsupportedVersion);
      }
      if (from < 2) {
        // V1 is the unreleased, frozen M04 schema before durable deletion work.
        await migrator.createTable(fileCleanupQueue);
        await migrator.createTrigger(cleanupDeletedMedia);
        await into(dataMigrations).insert(
          DataMigrationsCompanion.insert(
            version: const Value(2),
            completedAtUtc: DateTime.now().toUtc(),
          ),
        );
      }
      if (from < 3) {
        // Goals have no inbound foreign keys. Drift retains their unit triggers.
        await migrator.alterTable(
          TableMigration(goals, newColumns: [goals.motivation]),
        );
        await into(dataMigrations).insert(
          DataMigrationsCompanion.insert(
            version: const Value(3),
            completedAtUtc: DateTime.now().toUtc(),
          ),
        );
      }
      if (from < 4) {
        await migrator.createTable(practiceCheckpoints);
        await into(dataMigrations).insert(
          DataMigrationsCompanion.insert(
            version: const Value(4),
            completedAtUtc: DateTime.now().toUtc(),
          ),
        );
      }
      if (from < 5) {
        // ADD COLUMN preserves inbound session references and clock fractions.
        await migrator.addColumn(sessions, sessions.whatGotEasier);
        await migrator.createTable(journalDrafts);
        await into(dataMigrations).insert(
          DataMigrationsCompanion.insert(
            version: const Value(5),
            completedAtUtc: DateTime.now().toUtc(),
          ),
        );
      }
      await customStatement('PRAGMA user_version = $currentVersion');
    }),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement('PRAGMA busy_timeout = 5000');
      await customStatement('PRAGMA synchronous = FULL');
      if ((await customSelect('PRAGMA foreign_key_check').get()).isNotEmpty) {
        throw const LocalFailure(LocalFailureKind.corrupt);
      }
    },
  );
}
