import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop/app/l10n/app_localizations.dart';
import 'package:loop/app/routing.dart';
import 'package:loop/features/skills/domain/goal_rules.dart';
import 'package:loop/features/skills/domain/skill_draft.dart';
import 'package:loop/features/skills/domain/skill_kind.dart';
import 'package:loop/shared/design_system/tokens.dart';

import '../design_preview/test/design_test.dart' show loadReviewFonts;
import 'skill_widgets_test.dart' show pumpSkills, waitForSkillWidget, field;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadReviewFonts);
  for (final brightness in Brightness.values) {
    for (final compact in [false, true]) {
      final variant =
          '${compact ? 'compact_2x' : 'phone_1x'}_${brightness.name}';
      for (final scene in [
        'categories',
        'setup',
        'skills',
        'detail',
        'goal',
        'measured_goal',
        'exercise',
      ]) {
        testWidgets('M07 current skill screen golden $scene $variant', (
          tester,
        ) async {
          late String id;
          late String goalId;
          late String measuredGoalId;
          late String exerciseId;
          final (_, container) = await pumpSkills(
            tester,
            scale: compact ? 2 : 1,
            size: compact ? const Size(320, 640) : const Size(390, 844),
            prepare: (storage) async {
              final skill = await storage.skillManagement.create(
                const SkillDraft(
                  name: 'Studio practice · 練習',
                  kind: SkillKind.music,
                  description:
                      'Synthetic verification fixture. No observed practice.',
                  firstGoal: 'Play a short section comfortably',
                ),
              );
              id = skill.id;
              final detail = (await storage.skillManagement.detail(id))!;
              goalId = detail.goals.single.id;
              await storage.database.customStatement(
                'UPDATE goals SET created_at_utc = ? WHERE id = ?',
                [1767225600, goalId],
              );
              exerciseId = detail.exercises.first.id;
              measuredGoalId = (await storage.skillManagement.saveGoal(
                id,
                GoalDraft(
                  title: 'Steady tempo',
                  type: GoalType.threshold,
                  definition: detail.definitions
                      .where((d) => d.unitKey == 'bpm')
                      .single,
                  unit: 'bpm',
                  target: 96,
                  dateLocal: '2027-02-28',
                  motivation:
                      'A comfortable pace, measured with the same method.',
                ),
              )).id;
              await storage.skillManagement.create(
                const SkillDraft(
                  name: 'Étude with a deliberately long repeated skill name',
                  kind: SkillKind.custom,
                  includeStarters: false,
                ),
              );
            },
          );
          final route = switch (scene) {
            'categories' => '/skills/new',
            'setup' => '/skills/new/setup?kind=music',
            'detail' => '/skills/$id',
            'goal' => '/skills/$id/goals/$goalId/edit',
            'measured_goal' => '/skills/$id/goals/$measuredGoalId/edit',
            'exercise' => '/skills/$id/exercises/$exerciseId/edit',
            _ => '/skills',
          };
          final theme = LoopTheme.build(
            brightness,
            fontFamily: 'LoopReviewRoboto',
            fontFamilyFallback: ['LoopReviewCJK'],
          );
          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: container,
              child: MaterialApp.router(
                debugShowCheckedModeBanner: false,
                theme: theme,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                routerConfig: container.read(routerProvider),
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(disableAnimations: true),
                  child: child!,
                ),
              ),
            ),
          );
          container.read(routerProvider).go(route);
          final ready = switch (scene) {
            'categories' => find.text('What would you like to practice?'),
            'setup' => field('Skill name'),
            'goal' || 'measured_goal' => field('Goal title'),
            'exercise' => field('Exercise title'),
            'detail' => find.widgetWithText(ChoiceChip, 'Timeline'),
            _ => find.text('Studio practice · 練習'),
          };
          await waitForSkillWidget(tester, ready);
          expect(tester.takeException(), isNull);
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile(
              '../docs/verification/design/goldens/m07_skill_${scene}_$variant.png',
            ),
          );
          if (scene == 'setup' ||
              scene == 'goal' ||
              scene == 'measured_goal' ||
              scene == 'exercise') {
            final label = scene == 'setup'
                ? 'Create skill'
                : scene == 'exercise'
                ? 'Save exercise'
                : 'Save goal';
            expect(find.text(label).hitTestable(), findsOneWidget);
            // Inspect the complete scrollable form, including fields below the capture.
            final last = scene == 'setup'
                ? find.text('Include starter exercises')
                : scene == 'exercise'
                ? field('Suggested seconds (optional)')
                : field('Why this goal? (optional)');
            await tester.ensureVisible(last);
            await tester.pumpAndSettle();
            expect(last.hitTestable(), findsOneWidget);
          }
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
