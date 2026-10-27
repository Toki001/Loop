import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:loop/features/settings/data/file_preferences_repository.dart';
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
        // The dedicated verification simulator is owner-controlled; no journal data
        // or network requests are created by this test. Repeated runs preserve prefs.
        final deadline = DateTime.now().add(const Duration(seconds: 20));
        while (find.text('Skip for now').evaluate().isEmpty &&
            find.text('Your practice starts here').evaluate().isEmpty &&
            DateTime.now().isBefore(deadline)) {
          await tester.pump(const Duration(milliseconds: 100));
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
        final repository = FilePreferencesRepository(directory);
        final saved = await repository.load();
        expect(saved.appearance, Appearance.dark);
        expect(saved.onboardingSeen, true);
        expect(await File('${directory.path}/preferences.json').exists(), true);

        // A new bootstrap/provider graph reads the file, not the prior UI state.
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
