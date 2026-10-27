import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:loop/core/data/storage.dart';

void main() {
  test('SIGKILL preserves committed SQLite data and rolls back pending transaction', () async {
    final directory = await Directory.systemTemp.createTemp(
      'loop-process-recovery-',
    );
    Process? child;
    try {
      child = await Process.start('dart', [
        '--suppress-analytics',
        'run',
        'test/helpers/crash_writer.dart',
        directory.path,
      ]);
      final errors = StringBuffer();
      final stderrSubscription = child.stderr
          .transform(utf8.decoder)
          .listen(errors.write);
      await child.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .firstWhere(
            (line) => line == 'READY_FOR_TEST_KILL',
            orElse: () => throw StateError(
              'Synthetic child exited before checkpoint: $errors',
            ),
          )
          .timeout(
            const Duration(seconds: 40),
            onTimeout: () => throw StateError(
              'Synthetic child did not reach its transaction checkpoint: $errors',
            ),
          );
      expect(child.kill(ProcessSignal.sigkill), true);
      expect(await child.exitCode, -9);
      await stderrSubscription.cancel();
      child = null;
      final storage = await LoopStorage.open(directory);
      try {
        expect(
          await storage.settings.read('committedProbe'),
          'synthetic committed value',
        );
        expect(await storage.settings.read('uncommittedProbe'), isNull);
        expect(
          (await storage.database
                  .customSelect('PRAGMA integrity_check')
                  .getSingle())
              .data
              .values
              .single,
          'ok',
        );
        await storage.settings.putAll({'retryAfterCrash': true});
        expect(await storage.settings.read('retryAfterCrash'), true);
      } finally {
        await storage.close();
      }
    } finally {
      child?.kill(ProcessSignal.sigkill);
      if (child != null) await child.exitCode;
      await directory.delete(recursive: true);
    }
  }, timeout: const Timeout(Duration(seconds: 60)));
}
