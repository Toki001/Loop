import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop/app/l10n/app_localizations.dart';
import 'package:loop/app/routing.dart';
import 'package:loop/features/journal/domain/journal_entry.dart';
import 'package:loop/features/journal/presentation/journal_providers.dart';
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
        'reflection',
        'edit',
        'timeline',
        'detail',
        'empty',
        'keyboard',
        'today',
        'today_first',
      ]) {
        testWidgets('M07 journal golden $scene $variant', (tester) async {
          final context = await pumpPractice(
            tester,
            scale: compact ? 2 : 1,
            size: compact ? const Size(320, 640) : const Size(390, 844),
          );
          final engine = context.container.read(practiceEngineProvider);
          var route = scene == 'today_first' ? '/today' : '/sessions';
          if (!['empty', 'today_first'].contains(scene)) {
            expect(
              await driveAsync(
                tester,
                engine.create(
                  skillId: context.skillId,
                  mode: EntryMode.timed,
                  plannedSeconds: 600,
                ),
              ),
              true,
            );
            context.clock.advance(const Duration(milliseconds: 65432));
            await driveAsync(tester, engine.pause());
            final id = engine.record!.session.id;
            final start = DateTime.utc(2026, 10, 27, 10);
            await driveAsync(
              tester,
              context.repository.write(
                engine.record!.session.copyWith(startedAtUtc: Value(start)),
                milliseconds: 65432,
              ),
            );
            await driveAsync(tester, engine.initialize());
            if (!['reflection', 'keyboard'].contains(scene)) {
              final session = engine.record!.session.copyWith(
                status: 'completed',
                endedAtUtc: Value(start.add(const Duration(seconds: 65))),
              );
              await driveAsync(
                tester,
                context.container
                    .read(journalRepositoryProvider)
                    .complete(
                      session,
                      milliseconds: 65432,
                      reflection: JournalReflection(
                        note: 'Synthetic verification fixture. No observed improvement is claimed.',
                        whatGotEasier: 'A lighter touch felt more comfortable.',
                        nextStep: 'Repeat the same short passage.',
                        effortRating: 3,
                      ),
                    ),
              );
              await driveAsync(
                tester,
                context.db.customStatement(
                  'UPDATE sessions SET updated_at_utc = ?, revision = revision + 1 WHERE id = ?',
                  [1793095265, id],
                ),
              );
              await driveAsync(tester, engine.initialize());
            }
            route = switch (scene) {
              'reflection' || 'keyboard' => '/practice/review/$id',
              'edit' => '/sessions/$id/edit',
              'detail' => '/sessions/$id',
              'today' => '/today',
              _ => '/sessions',
            };
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
                  data: MediaQuery.of(context).copyWith(
                    disableAnimations: true,
                    viewInsets: scene == 'keyboard'
                        ? const EdgeInsets.only(bottom: 260)
                        : null,
                  ),
                  child: child!,
                ),
              ),
            ),
          );
          context.container.read(routerProvider).go(route);
          final ready = switch (scene) {
            'reflection' ||
            'keyboard' ||
            'edit' => field('What got easier? · optional'),
            'detail' => find.text('Saved on this device'),
            'today' || 'today_first' => find.text('Your practice, so far'),
            'empty' => find.text('No saved practice yet'),
            _ => find.text('Skill: All skills'),
          };
          await waitForSkillWidget(tester, ready);
          if (scene == 'keyboard') {
            await tester.ensureVisible(field('What got easier? · optional'));
            await tester.tap(field('What got easier? · optional'));
            await tester.pumpAndSettle();
          }
          await settlePractice(tester, context);
          expect(tester.takeException(), isNull);
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile(
              '../docs/verification/design/goldens/m07_${scene}_$variant.png',
            ),
          );
          if (['reflection', 'keyboard', 'edit'].contains(scene)) {
            expect(
              find
                  .text(scene == 'edit' ? 'Save changes' : 'Save and finish')
                  .hitTestable(),
              findsOneWidget,
            );
          }
        });
      }
    }
  }
}
