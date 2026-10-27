import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop/app/app.dart';
import 'package:loop/app/licenses.dart';
import 'package:loop/app/routing.dart';
import 'package:loop/bootstrap.dart';
import 'package:loop/features/settings/domain/preferences.dart';
import 'package:loop/features/settings/presentation/preferences_controller.dart';

import 'preferences_test.dart' show ControlledPreferencesRepository;

Future<ProviderContainer> pumpApp(
  WidgetTester tester, {
  String route = '/today',
  bool seen = true,
  double scale = 1,
  Size size = const Size(390, 844),
  ControlledPreferencesRepository? repository,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  final container = ProviderContainer(
    overrides: [
      preferencesRepositoryProvider.overrideWithValue(
        repository ?? ControlledPreferencesRepository(),
      ),
      initialPreferencesProvider.overrideWithValue(
        Preferences(onboardingSeen: seen),
      ),
      initialLocationProvider.overrideWithValue(route),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const LoopApp()),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  test('bundled icon license and attribution are accessible through acknowledgments', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerLoopLicenses();
    final entries = await LicenseRegistry.licenses
        .where((entry) => entry.packages.contains('Material Icons'))
        .toList();
    expect(entries, hasLength(1));
    final text = entries.single.paragraphs
        .map((paragraph) => paragraph.text)
        .join('\n');
    expect(text, contains('Attribution 4.0 International'));
    expect(text, contains('Glyphs unchanged'));
    expect(text, contains('creativecommons.org/licenses/by/4.0/'));
  });
  testWidgets(
    'first install supports skip and saves onboarding before navigation',
    (tester) async {
      final repository = ControlledPreferencesRepository();
      await pumpApp(tester, seen: false, repository: repository);
      expect(find.text('Skip for now'), findsOneWidget);
      await tester.tap(find.text('Skip for now'));
      await tester.pumpAndSettle();
      expect(repository.value.onboardingSeen, true);
      expect(find.text('Your practice starts here'), findsOneWidget);
      expect(find.text('Skip for now'), findsNothing);
    },
  );

  testWidgets('failed onboarding save stays on screen with actual recovery', (
    tester,
  ) async {
    final repository = ControlledPreferencesRepository()..fail = true;
    await pumpApp(tester, seen: false, repository: repository);
    await tester.tap(find.text('Choose a skill'));
    await tester.pumpAndSettle();
    expect(find.text('Skip for now'), findsOneWidget);
    expect(find.textContaining('could not be saved'), findsOneWidget);
    expect(repository.value.onboardingSeen, false);
    repository.fail = false;
    await tester.tap(find.text('Choose a skill'));
    await tester.pumpAndSettle();
    expect(find.text('Make room for what you want to learn'), findsOneWidget);
  });

  testWidgets(
    'all five tabs show truthful empty states and no simulated actions',
    (tester) async {
      await pumpApp(tester);
      for (final destination in [
        ('Skills', 'Make room for what you want to learn'),
        ('Practice', 'Start with a skill'),
        ('Progress', 'Progress begins with a practice record'),
        ('Library', 'Keep the work you can come back to'),
        ('Today', 'Your practice starts here'),
      ]) {
        await tester.tap(find.text(destination.$1).last);
        await tester.pumpAndSettle();
        expect(find.text(destination.$2), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
      expect(find.text('Start timer'), findsNothing);
      expect(find.text('Add skill'), findsNothing);
      expect(find.textContaining('Guitar'), findsNothing);
    },
  );

  testWidgets(
    'Settings persists appearance without replacing the tab router; back returns',
    (tester) async {
      final repository = ControlledPreferencesRepository();
      final container = await pumpApp(tester, repository: repository);
      final router = container.read(routerProvider);
      await tester.tap(find.text('Library').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();
      expect(repository.value.appearance, Appearance.dark);
      expect(container.read(routerProvider), same(router));
      expect(
        Theme.of(tester.element(find.text('Dark'))).brightness,
        Brightness.dark,
      );
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Keep the work you can come back to'), findsOneWidget);
    },
  );

  testWidgets('appearance failure leaves theme unchanged and retry saves it', (
    tester,
  ) async {
    final repository = ControlledPreferencesRepository()..fail = true;
    await pumpApp(tester, route: '/settings', repository: repository);
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.text('Dark'))).brightness,
      Brightness.light,
    );
    expect(find.textContaining('could not be saved'), findsOneWidget);
    repository.fail = false;
    await tester.ensureVisible(find.text('Try again'));
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.text('Dark'))).brightness,
      Brightness.dark,
    );
  });

  for (final path in [
    '/skills/missing',
    '/sessions/private-value',
    '/practice/review/missing',
    '/progress/missing',
    '/compare',
    '/not-a-route',
  ]) {
    testWidgets('missing deep link recovers safely: $path', (tester) async {
      await pumpApp(tester, route: path);
      expect(find.text('This item is not available'), findsOneWidget);
      expect(find.textContaining('private-value'), findsNothing);
      await tester.tap(find.text('Back to Today'));
      await tester.pumpAndSettle();
      expect(find.text('Your practice starts here'), findsOneWidget);
    });
  }

  testWidgets('active-session link cannot fabricate a running session', (
    tester,
  ) async {
    final container = await pumpApp(tester, route: '/practice/active');
    expect(
      container.read(routerProvider).routeInformationProvider.value.uri.path,
      '/practice/setup',
    );
    expect(find.text('Start with a skill'), findsOneWidget);
  });

  testWidgets('fresh deep links go through onboarding', (tester) async {
    await pumpApp(tester, route: '/sessions/missing', seen: false);
    expect(find.text('Skip for now'), findsOneWidget);
    expect(find.text('This item is not available'), findsNothing);
  });

  testWidgets('tab and route restore without inventing session state', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.text('Library').last);
    await tester.pumpAndSettle();
    await tester.restartAndRestore();
    await tester.pumpAndSettle();
    expect(find.text('Keep the work you can come back to'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final route in [
    '/onboarding',
    '/today',
    '/skills',
    '/practice/setup',
    '/progress',
    '/library',
    '/settings',
    '/settings/privacy',
  ]) {
    testWidgets('compact 200% text has reachable navigation: $route', (
      tester,
    ) async {
      await pumpApp(
        tester,
        route: route,
        seen: route != '/onboarding',
        scale: 2,
        size: const Size(320, 640),
      );
      expect(tester.takeException(), isNull);
      if (route == '/onboarding') {
        expect(
          tester.getRect(find.text('Skip for now')).bottom,
          lessThanOrEqualTo(640),
        );
      } else if (route != '/settings' && route != '/settings/privacy') {
        await tester.tap(find.text('Navigate'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Library').last);
        await tester.tap(find.text('Library').last);
        await tester.pumpAndSettle();
        expect(find.text('Keep the work you can come back to'), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'unavailable storage has a retry and exposes no raw private error',
    (tester) async {
      var tries = 0;
      await tester.pumpWidget(
        BootstrapHost(
          directoryProvider: () async {
            tries++;
            throw const FileSystemException('private internal diagnostic');
          },
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('We could not open your local preferences'),
        findsOneWidget,
      );
      expect(find.textContaining('private internal diagnostic'), findsNothing);
      expect(find.textContaining('Reset preferences and'), findsNothing);
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(tries, 2);
    },
  );

  testWidgets(
    'damaged preferences recovery keeps original and reopens onboarding',
    (tester) async {
      final directory = await tester.runAsync(
        () => Directory.systemTemp.createTemp('loop-recovery-ui-'),
      );
      addTearDown(() async => directory!.delete(recursive: true));
      final file = File('${directory!.path}/preferences.json');
      await tester.runAsync(() => file.writeAsString('{damaged'));
      await tester.pumpWidget(
        BootstrapHost(directoryProvider: () async => directory),
      );
      Future<void> waitForIo(Finder finder) async {
        final deadline = DateTime.now().add(const Duration(seconds: 5));
        while (finder.evaluate().isEmpty && DateTime.now().isBefore(deadline)) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 10)),
          );
          await tester.pump();
        }
        expect(finder, findsOneWidget);
      }

      final reset = find.text('Reset preferences and keep a recovery copy');
      await waitForIo(reset);
      await tester.ensureVisible(reset);
      await tester.tap(reset);
      await waitForIo(find.text('Skip for now'));
      final originals = await tester.runAsync(
        () async => directory
            .list()
            .where((entry) => entry.path.contains('preferences-recovery-'))
            .toList(),
      );
      expect(originals, hasLength(1));
      expect(
        await tester.runAsync(
          () => File(originals!.single.path).readAsString(),
        ),
        '{damaged',
      );
      expect(tester.takeException(), isNull);
    },
  );
}
