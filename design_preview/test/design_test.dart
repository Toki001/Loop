import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:loop/shared/design_system/components.dart';
import 'package:loop/shared/design_system/tokens.dart';

import '../lib/preview.dart';

Future<void> loadReviewFonts() async {
  final configFile = File('.dart_tool/package_config.json').absolute;
  final config =
      jsonDecode(await configFile.readAsString()) as Map<String, dynamic>;
  final packages = (config['packages'] as List<dynamic>)
      .cast<Map<String, dynamic>>();
  final flutter = packages.singleWhere((p) => p['name'] == 'flutter');
  final packageDirectory = Directory.fromUri(
    configFile.uri.resolve(flutter['rootUri'] as String),
  );
  final sdk = packageDirectory.parent.parent;
  final loader = FontLoader('LoopReviewRoboto');
  for (final weight in ['Regular', 'Medium', 'Bold']) {
    final file = File(
      '${sdk.path}/bin/cache/artifacts/material_fonts/Roboto-$weight.ttf',
    );
    loader.addFont(file.readAsBytes().then(ByteData.sublistView));
  }
  await loader.load();
  final iconLoader = FontLoader('MaterialIcons');
  iconLoader.addFont(
    File(
      '${sdk.path}/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    ).readAsBytes().then(ByteData.sublistView),
  );
  await iconLoader.load();
  // macOS golden baseline: use an installed CJK font without redistributing it.
  final cjkLoader = FontLoader('LoopReviewCJK');
  cjkLoader.addFont(
    File('/System/Library/Fonts/Hiragino Sans GB.ttc')
        .readAsBytes()
        .then(ByteData.sublistView),
  );
  await cjkLoader.load();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadReviewFonts);

  test('essential semantic color pairings meet AA in both palettes', () {
    final measured = <Map<String, Object>>[];
    for (final palette in [LoopPalette.light, LoopPalette.dark]) {
      final pairs = <String, (Color, Color)>{
        'body on canvas': (palette.ink, palette.background),
        'body on card': (palette.ink, palette.surface),
        'supporting text on canvas': (palette.inkMuted, palette.background),
        'supporting text on card': (palette.inkMuted, palette.surface),
        'action label': (palette.onBrand, palette.brand),
        'brand text on card': (palette.brand, palette.surface),
        'active destination label': (palette.brand, palette.brandSoft),
        'success text': (palette.success, palette.surface),
        'warning text': (palette.warning, palette.surface),
        'danger text': (palette.danger, palette.surface),
        'focus indicator': (palette.focus, palette.surface),
      };
      for (final entry in pairs.entries) {
        final a = entry.value.$1.computeLuminance();
        final b = entry.value.$2.computeLuminance();
        final ratio = a > b ? (a + .05) / (b + .05) : (b + .05) / (a + .05);
        measured.add({
          'theme': identical(palette, LoopPalette.light) ? 'light' : 'dark',
          'pair': entry.key,
          'ratio': ratio,
          'minimum': 4.5,
        });
        expect(ratio, greaterThanOrEqualTo(4.5), reason: entry.key);
      }
    }
    Directory('build').createSync(recursive: true);
    File(
      'build/contrast.json',
    ).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(measured));
  });

  const viewports = <String, Size>{
    'android_compact': Size(320, 568),
    'android_large': Size(412, 915),
    'iphone': Size(390, 844),
    'tablet': Size(768, 1024),
  };
  for (final viewport in viewports.entries) {
    for (final brightness in Brightness.values) {
      for (final scale in [1.0, 2.0]) {
        final variant = '${viewport.key}_${brightness.name}_${scale.toInt()}x';
        for (final scene in PreviewScene.values) {
          testWidgets('layout and golden ${scene.name}_$variant', (
            tester,
          ) async {
            tester.view.physicalSize = viewport.value;
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            await tester.pumpWidget(
              LoopDesignPreview(
                scene: scene,
                brightness: brightness,
                textScale: scale,
                reducedMotion: true,
                showControls: false,
                fontFamily: 'LoopReviewRoboto',
              ),
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull, reason: '$scene $variant');
            expect(
              find.text('Design preview — synthetic data'),
              findsOneWidget,
            );
            if (scene == PreviewScene.practice) {
              expect(find.text('Resume').hitTestable(), findsOneWidget);
              expect(
                find.text('Finish practice').hitTestable(),
                findsOneWidget,
              );
            }
            await expectLater(
              find.byType(MaterialApp),
              matchesGoldenFile(
                '../../docs/verification/design/goldens/${scene.name}_$variant.png',
              ),
            );
            if (scene == PreviewScene.reflection) {
              // Form save stays reachable even when content exceeds the viewport.
              await tester.ensureVisible(find.text('Save and finish'));
              await tester.pumpAndSettle();
              expect(
                find.text('Save and finish').hitTestable(),
                findsOneWidget,
              );
              expect(tester.takeException(), isNull);
            }
            if (scene == PreviewScene.welcome) {
              expect(find.text('Choose a skill').hitTestable(), findsOneWidget);
              expect(find.text('Skip for now').hitTestable(), findsOneWidget);
            }
          });
        }
        for (final state in PreviewState.values.where(
          (s) => s != PreviewState.content,
        )) {
          testWidgets('recovery state ${state.name}_$variant', (tester) async {
            tester.view.physicalSize = viewport.value;
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            await tester.pumpWidget(
              LoopDesignPreview(
                state: state,
                brightness: brightness,
                textScale: scale,
                reducedMotion: true,
                showControls: false,
                fontFamily: 'LoopReviewRoboto',
              ),
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            await expectLater(
              find.byType(MaterialApp),
              matchesGoldenFile(
                '../../docs/verification/design/goldens/state_${state.name}_$variant.png',
              ),
            );
            final actionLabel = switch (state) {
              PreviewState.empty => 'Add first skill',
              PreviewState.error => 'Review retry behavior',
              PreviewState.permissionDenied => 'Continue with a note',
              _ => null,
            };
            if (actionLabel != null) {
              await tester.ensureVisible(find.text(actionLabel));
              await tester.pumpAndSettle();
              expect(find.text(actionLabel).hitTestable(), findsOneWidget);
              expect(tester.takeException(), isNull);
            }
          });
        }
      }
    }
  }

  testWidgets('large text navigation reaches all five destinations', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const LoopDesignPreview(textScale: 2, showControls: false),
    );
    await tester.pumpAndSettle();
    expect(tester.getSize(find.text('Navigate')).height, lessThanOrEqualTo(44));
    expect(tester.getSize(find.text('Practice')).height, lessThanOrEqualTo(44));
    await tester.tap(find.text('Navigate'));
    await tester.pumpAndSettle();
    for (final label in loopDestinations) {
      expect(find.text(label), findsWidgets);
    }
    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();
    expect(find.text('The work you\ncan come back to.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('native button supports keyboard and keeps a 48dp hit target', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: LoopTheme.build(Brightness.light),
        home: Scaffold(
          body: Center(
            child: LoopButton(
              label: 'Start practice',
              onPressed: () => calls++,
            ),
          ),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(calls, 1);
    final size = tester.getSize(find.byType(FilledButton));
    expect(size.height, greaterThanOrEqualTo(48));
    expect(size.width, greaterThanOrEqualTo(48));
  });

  testWidgets('timer provides a single verbal duration', (tester) async {
    final handle = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: TimerDisplay(seconds: 516))),
      );
      expect(find.bySemanticsLabel('8 minutes 36 seconds'), findsOneWidget);
    } finally {
      handle.dispose();
    }
  });

  testWidgets('custom button honors reduced animation signals', (tester) async {
    Duration? duration;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Builder(
            builder: (context) {
              duration = LoopMotion.duration(context, LoopMotion.press);
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(duration, Duration.zero);
  });

  testWidgets('iOS reduce motion is honored independently of Android flag', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(reduceMotion: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    Duration? duration;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: false),
          child: Builder(
            builder: (context) {
              duration = LoopMotion.duration(context, LoopMotion.press);
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(duration, Duration.zero);
  });

  testWidgets(
    'visible Today controls have labels, contrast and native hit targets',
    (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          const LoopDesignPreview(
            showControls: false,
            fontFamily: 'LoopReviewRoboto',
          ),
        );
        await tester.pumpAndSettle();
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
      } finally {
        semantics.dispose();
      }
    },
  );

  testWidgets('RTL and 200 percent text preserve compact layout', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const LoopDesignPreview(
        scene: PreviewScene.skills,
        textScale: 2,
        textDirection: TextDirection.rtl,
        showControls: false,
        fontFamily: 'LoopReviewRoboto',
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Navigate').hitTestable(), findsOneWidget);
  });

  testWidgets(
    'keyboard and large text keep reflection input and Save reachable',
    (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(deterministicCursor: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      tester.view.viewInsets = const FakeViewPadding(bottom: 240);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpWidget(
        const LoopDesignPreview(
          scene: PreviewScene.reflection,
          textScale: 2,
          showControls: false,
          fontFamily: 'LoopReviewRoboto',
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField).first,
        'Start with the spaces between shapes.',
      );
      await tester.ensureVisible(find.text('Save and finish'));
      await tester.pumpAndSettle();
      expect(find.text('Save and finish').hitTestable(), findsOneWidget);
      expect(
        find.text('Start with the spaces between shapes.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          '../../docs/verification/design/goldens/reflection_keyboard_android_compact_light_2x.png',
        ),
      );
    },
  );
}
