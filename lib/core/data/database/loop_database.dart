import 'package:drift/drift.dart';

import '../local_failure.dart';
import 'utc_datetime.dart';

part 'loop_database.g.dart';

/// Private to persistence/repository code; views never execute table writes.
@DriftDatabase(include: {'schema.drift'})
class LoopDatabase extends _$LoopDatabase {
  LoopDatabase(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => transaction(() async {
      await migrator.createAll();
      await into(dataMigrations).insert(
        DataMigrationsCompanion.insert(
          version: const Value(2),
          completedAtUtc: DateTime.now().toUtc(),
        ),
      );
      await customStatement('PRAGMA user_version = 2');
    }),
    onUpgrade: (migrator, from, to) => transaction(() async {
      if (from != 1 || to != 2) {
        throw const LocalFailure(LocalFailureKind.unsupportedVersion);
      }
      // V1 is the unreleased, frozen M04 schema before durable deletion work.
      await migrator.createTable(fileCleanupQueue);
      await migrator.createTrigger(cleanupDeletedMedia);
      await into(dataMigrations).insert(
        DataMigrationsCompanion.insert(
          version: const Value(2),
          completedAtUtc: DateTime.now().toUtc(),
        ),
      );
      await customStatement('PRAGMA user_version = 2');
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
