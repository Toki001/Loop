import 'dart:convert';
import 'dart:io';

import 'package:loop_sqlite_encryption_spike/experiment.dart';

Future<void> main() async {
  try {
    stdout.writeln(jsonEncode(await runEncryptionExperiment()));
  } on EncryptionExperimentFailure catch (error) {
    stderr.writeln(error); // Sanitized stage only, never raw SQLite exceptions.
    exitCode = 1;
  }
}
