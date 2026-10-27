import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:loop/core/data/storage.dart';
import 'package:loop/core/data/storage_protection.dart';
import 'package:loop/core/data/local_failure.dart';
import 'package:loop/features/settings/domain/preferences.dart';
import 'package:loop/main.dart' as app;
import 'package:path_provider/path_provider.dart';

Future<void> waitFor(WidgetTester tester, Finder finder) async {
  final deadline = DateTime.now().add(const Duration(seconds: 20));
  while (finder.evaluate().isEmpty && DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(finder, findsWidgets);
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'native offline shell saves appearance and reopens durable preferences',
    (tester) async {
      final originalErrorBuilder = ErrorWidget.builder;
      try {
        app.main();
        await tester.pump();
        // Assert the actual adapter before waiting for a page. A native storage
        // failure must identify this gate using safe categories, not SQL/paths.
        final native = await const StorageProtection().inspect();
        expect(native['privateStorage'], true);
        expect(native['backupExcluded'], true);
        if (Platform.isIOS) {
          expect(
            native['protectionPolicy'],
            'NSFileProtectionCompleteUntilFirstUserAuthentication',
          );
          if (native['isSimulator'] != true) {
            expect(
              native['protection'],
              'NSFileProtectionCompleteUntilFirstUserAuthentication',
            );
          }
        }
        // The dedicated verification simulator is owner-controlled; no journal data
        // or network requests are created by this test. Repeated runs preserve prefs.
        final deadline = DateTime.now().add(const Duration(seconds: 20));
        while (find.text('Skip for now').evaluate().isEmpty &&
            find.text('Your practice starts here').evaluate().isEmpty &&
            DateTime.now().isBefore(deadline)) {
          await tester.pump(const Duration(milliseconds: 100));
          if (find
              .text('We could not open your practice data')
              .evaluate()
              .isNotEmpty) {
            try {
              final probe = await LoopStorage.open(
                await getApplicationSupportDirectory(),
              );
              await probe.close();
            } on LocalFailure catch (failure) {
              fail(
                'Native persistence recovery category: ${failure.kind.name}',
              );
            }
            fail('Bootstrap recovery despite readable database');
          }
        }
        if (find.text('Skip for now').evaluate().isNotEmpty) {
          await tester.tap(find.text('Skip for now'));
        }
        await waitFor(tester, find.text('Your practice starts here'));
        for (final entry in [
          ('Skills', 'Make room for what you want to learn'),
          ('Practice', 'Start with a skill'),
          ('Progress', 'Progress begins with a practice record'),
          ('Library', 'Keep the work you can come back to'),
        ]) {
          await tester.tap(find.text(entry.$1).last);
          await waitFor(tester, find.text(entry.$2));
        }
        await tester.tap(find.byTooltip('Settings'));
        await waitFor(tester, find.text('Dark'));
        await tester.tap(find.text('Dark'));
        await tester.pumpAndSettle();
        final directory = await getApplicationSupportDirectory();
        final storage = await LoopStorage.open(directory);
        try {
          final saved = await storage.preferences.load();
          expect(saved.appearance, Appearance.dark);
          expect(saved.onboardingSeen, true);
          expect(await File('${directory.path}/loop.sqlite').exists(), true);
          final protection = await const StorageProtection().inspect();
          expect(protection['privateStorage'], true);
          expect(protection['backupExcluded'], true);
          if (Platform.isIOS) {
            expect(
              protection['protectionPolicy'],
              'NSFileProtectionCompleteUntilFirstUserAuthentication',
            );
            if (protection['isSimulator'] != true) {
              expect(
                protection['protection'],
                'NSFileProtectionCompleteUntilFirstUserAuthentication',
              );
              expect(protection['allEntriesProtected'], true);
            }
            expect(
              protection['protectedEntriesChecked'] as int,
              greaterThan(0),
            );
          }
          expect(await storage.settings.read('m03PreferencesImported'), true);
          // Only policy/structural facts are reported; no paths or journal data.
          debugPrint(
            'LOOP_STORAGE_EVIDENCE:${jsonEncode({'platform': Platform.operatingSystem, 'native': protection, 'legacyPreferencesRetained': await File('${directory.path}/preferences.json').exists(), 'schemaVersion': (await storage.database.customSelect('PRAGMA user_version').getSingle()).data.values.single, 'integrity': (await storage.database.customSelect('PRAGMA quick_check').getSingle()).data.values.single, 'appearance': saved.appearance.name, 'onboardingSeen': saved.onboardingSeen, 'preferenceImportCommitted': true})}',
          );
        } finally {
          await storage.close();
        }

        // A new bootstrap/provider graph reads SQLite, not the prior UI state.
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        app.main();
        await waitFor(tester, find.text('Your practice starts here'));
        expect(find.text('Skip for now'), findsNothing);
        expect(
          Theme.of(tester.element(find.text('Your practice starts here')))
              .brightness,
          Brightness.dark,
        );
        expect(tester.takeException(), isNull);
      } finally {
        ErrorWidget.builder = originalErrorBuilder;
      }
    },
  );
}
