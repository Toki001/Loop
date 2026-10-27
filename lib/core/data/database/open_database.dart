import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../media/private_files.dart';
import '../local_failure.dart';
import 'loop_database.dart';

void _prepare(Database database) {
  final version =
      database.select('PRAGMA user_version').single.values.single as int;
  if (version > LoopDatabase.currentVersion)
    throw const LocalFailure(LocalFailureKind.unsupportedVersion);
  if (version == 0 &&
      database
          .select(
            "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%' LIMIT 1",
          )
          .isNotEmpty) {
    throw const LocalFailure(LocalFailureKind.corrupt);
  }
  final integrity = database.select('PRAGMA quick_check');
  if (integrity.length != 1 || integrity.single.values.single != 'ok') {
    throw const LocalFailure(LocalFailureKind.corrupt);
  }
  database.execute('PRAGMA foreign_keys = ON');
  database.execute('PRAGMA journal_mode = WAL');
  database.execute('PRAGMA synchronous = FULL');
  database.execute('PRAGMA secure_delete = ON');
}

Future<LoopDatabase> openDatabase(PrivateFiles files) => guardLocal(() async {
  final file = await files.databaseFile();
  final database = LoopDatabase(
    NativeDatabase.createInBackground(file, setup: _prepare),
  );
  try {
    await database.customSelect('SELECT 1').get();
    return database;
  } on Object {
    await database.close();
    rethrow;
  }
});
