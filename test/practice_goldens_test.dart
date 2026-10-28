import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop/app/l10n/app_localizations.dart';
import 'package:loop/app/routing.dart';
import 'package:loop/features/practice/data/sessions_repository.dart';
import 'package:loop/features/practice/presentation/practice_providers.dart';
import 'package:loop/shared/design_system/tokens.dart';

import '../design_preview/test/design_test.dart' show loadReviewFonts;
import 'helpers/drive_async.dart';
import 'practice_widgets_test.dart' show pumpPractice, settlePractice;
import 'skill_widgets_test.dart' show field, waitForSkillWidget;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadReviewFonts);
  for (final brightness in Brightness.values) {
    for (final compact in [false, true]) {
      final variant =
          '${compact ? 'compact_2x' : 'phone_1x'}_${brightness.name}';
      for (final scene in [
        'setup',
        'running',
        'paused',
        'recovered',
        'manual',
        'journal',
        'failure',
        'saved',
      ]) {
        testWidgets('M06 functional golden $scene $variant', (tester) async {
          final context = await pumpPractice(
            tester,
            scale: compact ? 2 : 1,
            size: compact ? const Size(320, 640) : const Size(390, 844),
          );
          final engine = context.container.read(practiceEngineProvider);
          String route = '/practice/setup';
          if (scene != 'setup') {
            {
              final manual = scene == 'manual' || scene == 'journal';
              expect(
                await driveAsync(
                  tester,
                  engine.create(
                    skillId: context.skillId,
                    plannedSeconds: manual ? null : 600,
                    mode: manual ? EntryMode.manual : EntryMode.timed,
                    manualIntent: !manual
                        ? null
                        : scene == 'journal'
                        ? ManualIntent.evidenceOnly
                        : ManualIntent.duration,
                  ),
                ),
                true,
              );
              if (manual) {
                engine.stageDraft(
                  'A personal observation, with no score.',
                  manualSeconds: scene == 'manual' ? 780 : 0,
                  manualDate: '2026-10-27',
                );
                expect(
                  await driveAsync(
                    tester,
                    engine.saveNote('A personal observation, with no score.'),
                  ),
                  true,
                );
              } else {
                context.clock.advance(const Duration(milliseconds: 65432));
                engine.tick();
                await driveAsync(tester, engine.idle);
                if (scene == 'failure') {
                  context.repository.fail = true;
                  expect(await driveAsync(tester, engine.pause()), false);
                } else if (scene == 'recovered') {
                  expect(await driveAsync(tester, engine.initialize()), true);
                } else if (scene == 'paused') {
                  expect(await driveAsync(tester, engine.pause()), true);
                  expect(
                    await driveAsync(
                      tester,
                      engine.saveNote(
                        'Keep the next attempt small and repeatable.',
                      ),
                    ),
                    true,
                  );
                } else if (scene == 'saved') {
                  await driveAsync(tester, engine.pause());
                  final session = engine.record!.session;
                  final start = DateTime.utc(2026, 10, 27, 10);
                  final saved = await driveAsync(
                    tester,
                    context.repository.write(
                      session.copyWith(
                        status: 'completed',
                        startedAtUtc: Value(start),
                        endedAtUtc: Value(
                          start.add(const Duration(seconds: 65)),
                        ),
                        note: const Value(
                          'One deliberate attempt. No measured improvement claimed.',
                        ),
                      ),
                      milliseconds: 65432,
                    ),
                  );
                  route = '/sessions/${saved.session.id}';
                  await driveAsync(tester, engine.initialize());
                }
              }
            }
            if (scene != 'saved') route = '/practice/active';
          }
          final theme = LoopTheme.build(
            brightness,
            fontFamily: 'LoopReviewRoboto',
            fontFamilyFallback: ['LoopReviewCJK'],
          );
          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: context.container,
              child: MaterialApp.router(
                debugShowCheckedModeBanner: false,
                theme: theme,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                routerConfig: context.container.read(routerProvider),
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(disableAnimations: true),
                  child: child!,
                ),
              ),
            ),
          );
          context.container.read(routerProvider).go(route);
          final ready = switch (scene) {
            'setup' => find.text('Change skill'),
            'manual' => find.text('Duration entered by you'),
            'journal' => find.text('Zero practice minutes'),
            'saved' => find.text('Saved on this device'),
            _ => find.text(scene == 'running' ? 'Pause' : 'Resume'),
          };
          await waitForSkillWidget(tester, ready);
          await settlePractice(tester, context);
          expect(tester.takeException(), isNull);
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile(
              '../docs/verification/design/goldens/m06_${scene}_$variant.png',
            ),
          );
          if (scene == 'manual' || scene == 'journal') {
            expect(
              find
                  .text(
                    scene == 'manual'
                        ? 'Save manual practice'
                        : 'Save journal entry',
                  )
                  .hitTestable(),
              findsOneWidget,
            );
            await tester.ensureVisible(find.text('Discard entry'));
          } else if (!['setup', 'saved'].contains(scene)) {
            expect(find.text('Finish').hitTestable(), findsOneWidget);
            await tester.ensureVisible(field('Practice note · optional'));
          } else if (scene == 'setup') {
            await tester.ensureVisible(find.text('Start practice'));
          }
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
