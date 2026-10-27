import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop/bootstrap.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  for (final newer in [false, true]) {
    testWidgets(
      '${newer ? 'newer' : 'damaged'} database recovery preserves bytes across retry',
      (tester) async {
        final directory = await tester.runAsync(
          () => Directory.systemTemp.createTemp('loop-sql-recovery-'),
        );
        addTearDown(() => directory!.delete(recursive: true));
        final file = File('${directory!.path}/loop.sqlite');
        final before = await tester.runAsync(() async {
          if (newer) {
            final database = sqlite3.open(file.path);
            database.execute('PRAGMA user_version = 99');
            database.execute('CREATE TABLE future_content (value TEXT)');
            database.execute("INSERT INTO future_content VALUES ('synthetic')");
            database.close();
          } else {
            await file.writeAsString('damaged synthetic database', flush: true);
          }
          return file.readAsBytes();
        });
        await tester.pumpWidget(
          BootstrapHost(directoryProvider: () async => directory),
        );
        Future<void> waitForRecovery() async {
          final title = find.text('We could not open your practice data');
          final deadline = DateTime.now().add(const Duration(seconds: 5));
          while (title.evaluate().isEmpty &&
              DateTime.now().isBefore(deadline)) {
            await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 10)),
            );
            await tester.pump();
          }
          expect(title, findsOneWidget);
          expect(
            find.text('Reset preferences and keep a recovery copy'),
            findsNothing,
          );
          expect(find.text('Skip for now'), findsNothing);
          expect(find.textContaining('synthetic'), findsNothing);
          expect(find.textContaining(directory.path), findsNothing);
          expect(await tester.runAsync(file.readAsBytes), before);
        }

        await waitForRecovery();
        await tester.tap(find.text('Try again'));
        await tester.pump();
        await waitForRecovery();
        await tester.pumpWidget(const SizedBox.shrink());
        expect(tester.takeException(), isNull);
      },
    );
  }
}
