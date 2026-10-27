import 'dart:async';
import 'dart:io';

import 'package:loop/core/data/database/open_database.dart';
import 'package:loop/core/data/settings_repository.dart';
import 'package:loop/core/media/private_files.dart';

/// Host process-kill harness. Its sole argument is the test-owned private temp
/// directory. Never used by the application or with a user's real database.
Future<void> main(List<String> arguments) async {
  final database = await openDatabase(
    await PrivateFiles.open(Directory(arguments.single)),
  );
  final settings = SettingsRepository(database);
  await settings.putAll({'committedProbe': 'synthetic committed value'});
  await database.transaction(() async {
    await settings.putAll({'uncommittedProbe': 'synthetic pending value'});
    stdout.writeln('READY_FOR_TEST_KILL');
    await stdout.flush();
    await Completer<void>().future;
  });
}
