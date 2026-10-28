import 'dart:io';
import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop/app/routing.dart';
import 'package:loop/core/data/database/loop_database.dart';
import 'package:loop/core/data/local_failure.dart';
import 'package:loop/features/practice/data/practice_repository.dart';
import 'package:loop/features/skills/data/skill_management_repository.dart';
import 'package:loop/features/skills/domain/skill_draft.dart';
import 'package:loop/features/skills/domain/skill_kind.dart';

import 'app_test.dart' show pumpApp;

Finder field(String label) => find.byWidgetPredicate(
  (widget) => widget is TextField && widget.decoration?.labelText == label,
);

Future<void> waitForSkillWidget(WidgetTester tester, Finder finder) async {
  final deadline = DateTime.now().add(const Duration(seconds: 8));
  while (finder.evaluate().isEmpty && DateTime.now().isBefore(deadline)) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump();
  }
  expect(finder, findsWidgets);
  await tester.pumpAndSettle();
}

Future<void> tapSkillWidget(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  expect(
    finder.hitTestable(),
    findsOneWidget,
    reason: 'The intended control must actually receive the tap.',
  );
  await tester.tap(finder);
  await tester.pump();
  final deadline = DateTime.now().add(const Duration(seconds: 8));
  do {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  } while ((tester.binding.hasScheduledFrame ||
          find.byType(CircularProgressIndicator).evaluate().isNotEmpty) &&
      DateTime.now().isBefore(deadline));
  expect(
    find.byType(CircularProgressIndicator),
    findsNothing,
    reason: 'Save must finish with a committed result or a recoverable error.',
  );
}

class SkillTestStorage {
  SkillTestStorage(this.database)
    : skillManagement = SkillManagementRepository(database);
  final LoopDatabase database;
  final SkillManagementRepository skillManagement;
}

class ControlledSkillReads extends SkillManagementRepository {
  ControlledSkillReads(super.database, this.stream);
  final Stream<SkillDetailData?> stream;
  @override
  Stream<SkillDetailData?> watchDetail(String id) => stream;
}

Future<(SkillTestStorage, ProviderContainer)> pumpSkills(
  WidgetTester tester, {
  String route = '/skills',
  double scale = 1,
  Size size = const Size(390, 844),
  Future<void> Function(SkillTestStorage)? prepare,
  SkillManagementRepository Function(SkillTestStorage)? presentationRepository,
}) async {
  final directory = (await tester.runAsync(
    () => Directory.systemTemp.createTemp('loop-skill-widget-'),
  ))!;
  final storage = SkillTestStorage(
    LoopDatabase(
      NativeDatabase(
        File('${directory.path}/loop.sqlite'),
        setup: (database) => database.execute('PRAGMA foreign_keys = ON'),
      ),
    ),
  );
  await tester.runAsync(() => storage.database.customSelect('SELECT 1').get());
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await storage.database.close();
      await directory.delete(recursive: true);
    });
  });
  if (prepare != null) await tester.runAsync(() => prepare(storage));
  final container = await pumpApp(
    tester,
    route: route,
    scale: scale,
    size: size,
    practiceRepository: PracticeRepository(storage.database),
    skillRepository:
        presentationRepository?.call(storage) ?? storage.skillManagement,
  );
  return (storage, container);
}

void main() {
  testWidgets(
    'an editor retains its draft across a query error and recovered snapshot',
    (tester) async {
      final snapshots = StreamController<SkillDetailData?>();
      addTearDown(snapshots.close);
      late SkillDetailData initial;
      final (storage, container) = await pumpSkills(
        tester,
        prepare: (storage) async {
          final skill = await storage.skillManagement.create(
            const SkillDraft(name: 'Before edit', kind: SkillKind.custom),
          );
          initial = (await storage.skillManagement.detail(skill.id))!;
        },
        presentationRepository: (storage) =>
            ControlledSkillReads(storage.database, snapshots.stream),
      );
      container.read(routerProvider).go('/skills/${initial.skill.id}/edit');
      await tester.pumpAndSettle();
      snapshots.add(initial);
      await waitForSkillWidget(tester, field('Skill name'));
      await tester.enterText(field('Skill name'), 'Draft survives');
      snapshots.addError(const LocalFailure(LocalFailureKind.unavailable));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(field('Skill name')).controller!.text,
        'Draft survives',
      );
      snapshots.add(initial);
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(field('Skill name')).controller!.text,
        'Draft survives',
      );
      await tapSkillWidget(tester, find.text('Save skill'));
      expect(
        (await tester.runAsync(
          () => storage.skillManagement.detail(initial.skill.id),
        ))!.skill.name,
        'Draft survives',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'category and setup controls have labels and native touch targets',
    (tester) async {
      final (_, container) = await pumpSkills(tester, route: '/skills/new');
      final semantics = tester.ensureSemantics();
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      container.read(routerProvider).go('/skills/new/setup?kind=music');
      await tester.pumpAndSettle();
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      semantics.dispose();
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'setup validates Unicode, retains failed draft and commits once on rapid save',
    (tester) async {
      final (storage, container) = await pumpSkills(
        tester,
        route: '/skills/new/setup?kind=music',
      );
      final name = List.filled(30, 'é語').join();
      await tester.enterText(field('Skill name'), '$name!');
      await tapSkillWidget(tester, find.text('Create skill'));
      expect(find.text('Use 1–60 characters.'), findsOneWidget);
      await tester.enterText(field('Skill name'), name);
      await tester.runAsync(
        () => storage.database.customStatement(
          "CREATE TRIGGER synthetic_reject BEFORE INSERT ON goals BEGIN SELECT RAISE(ABORT, 'private SQL must not be shown'); END",
        ),
      );
      await tester.enterText(field('First goal (optional)'), 'Play with ease');
      await tapSkillWidget(tester, find.text('Create skill'));
      await waitForSkillWidget(tester, find.text('Not saved yet'));
      expect(find.text('private SQL must not be shown'), findsNothing);
      expect(
        tester.widget<TextField>(field('Skill name')).controller!.text,
        name,
      );
      expect(
        await tester.runAsync(
          () => storage.database.select(storage.database.skills).get(),
        ),
        isEmpty,
      );
      await tester.runAsync(
        () => storage.database.customStatement('DROP TRIGGER synthetic_reject'),
      );
      await tester.tap(find.text('Create skill'));
      await tester.tap(find.text('Create skill'));
      await waitForSkillWidget(
        tester,
        find.widgetWithText(ChoiceChip, 'Goals'),
      );
      await tapSkillWidget(tester, find.widgetWithText(ChoiceChip, 'Goals'));
      await waitForSkillWidget(tester, find.text('Current goals'));
      final cards = (await tester.runAsync(
        () => storage.skillManagement.watchCards().first,
      ))!;
      expect(cards, hasLength(1));
      final detail = (await tester.runAsync(
        () => storage.skillManagement.detail(cards.single.skill.id),
      ))!;
      expect(detail.exercises, hasLength(3));
      expect(detail.goals.single.title, 'Play with ease');
      expect(detail.sessions, isEmpty);
      expect(container.read(routerProvider).canPop(), true);
      await tester.pageBack();
      await waitForSkillWidget(
        tester,
        find.text('Make room for what you want to learn'),
      );
      expect(find.text('Create skill'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'category selection custom setup and unsaved back confirmation are usable',
    (tester) async {
      final (storage, _) = await pumpSkills(tester, route: '/skills/new');
      await tapSkillWidget(tester, find.text('Custom'));
      await tapSkillWidget(tester, find.text('Continue'));
      await tester.enterText(field('Skill name'), '手仕事 🌿');
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Leave without saving?'), findsOneWidget);
      await tapSkillWidget(tester, find.text('Cancel'));
      expect(
        tester.widget<TextField>(field('Skill name')).controller!.text,
        '手仕事 🌿',
      );
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tapSkillWidget(tester, find.text('Discard changes'));
      expect(find.text('What would you like to practice?'), findsOneWidget);
      expect(
        await tester.runAsync(() => storage.skillManagement.watchCards().first),
        isEmpty,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'active skills can be reordered, searched, archived and restored without loss',
    (tester) async {
      final (storage, container) = await pumpSkills(
        tester,
        prepare: (storage) async {
          for (final name in ['Alpha', 'Beta', 'Gamma']) {
            await storage.skillManagement.create(
              SkillDraft(name: name, kind: SkillKind.custom),
            );
          }
        },
      );
      await waitForSkillWidget(tester, find.text('Alpha'));
      await tapSkillWidget(tester, find.text('Reorder'));
      await tapSkillWidget(tester, find.byTooltip('Move Beta earlier'));
      await tester.runAsync(() => storage.skillManagement.watchCards().first);
      await tester.pumpAndSettle();
      final ordered = (await tester.runAsync(
        () => storage.skillManagement.watchCards().first,
      ))!;
      expect(ordered.map((c) => c.skill.name), ['Beta', 'Alpha', 'Gamma']);
      await tester.enterText(field('Search skills'), 'no match');
      await tester.pump();
      expect(find.text('No matching skills'), findsOneWidget);
      await tapSkillWidget(tester, find.text('Clear search'));
      container.read(routerProvider).go('/skills/${ordered.first.skill.id}');
      await waitForSkillWidget(tester, find.text('Archive skill'));
      await tapSkillWidget(tester, find.text('Archive skill'));
      expect(find.text('Archive this skill?'), findsOneWidget);
      await tapSkillWidget(tester, find.text('Archive skill').last);
      await waitForSkillWidget(tester, find.text('Restore skill'));
      final retained = (await tester.runAsync(
        () => storage.skillManagement.detail(ordered.first.skill.id),
      ))!;
      expect(retained.exercises, hasLength(1));
      expect(retained.skill.archivedAtUtc, isNotNull);
      container.read(routerProvider).go('/skills');
      await waitForSkillWidget(tester, find.text('Active'));
      await tapSkillWidget(tester, find.text('Archived'));
      await waitForSkillWidget(tester, find.text('Beta'));
      expect(find.text('Alpha'), findsNothing);
      await tapSkillWidget(tester, find.text('View skill'));
      await waitForSkillWidget(tester, find.text('Restore skill'));
      await tapSkillWidget(tester, find.text('Restore skill'));
      await tapSkillWidget(tester, find.text('Restore skill').last);
      await waitForSkillWidget(tester, find.text('Archive skill'));
      expect(
        (await tester.runAsync(
          () => storage.skillManagement.detail(retained.skill.id),
        ))!.skill.archivedAtUtc,
        isNull,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'qualitative goal has explicit completion and archived completion survives',
    (tester) async {
      late String id;
      final (storage, container) = await pumpSkills(
        tester,
        prepare: (storage) async {
          id = (await storage.skillManagement.create(
            const SkillDraft(
              name: 'Singing',
              kind: SkillKind.voice,
              includeStarters: false,
            ),
          )).id;
        },
      );
      container.read(routerProvider).go('/skills/$id/goals/new');
      await waitForSkillWidget(tester, field('Goal title'));
      await tester.enterText(field('Goal title'), 'Sing a verse comfortably');
      await tester.enterText(field('Target date (optional)'), '2027-02-30');
      await tapSkillWidget(tester, find.text('Save goal'));
      expect(find.text('Enter a valid date as YYYY-MM-DD.'), findsOneWidget);
      await tester.enterText(field('Target date (optional)'), '2028-02-29');
      await tester.enterText(
        field('Why this goal? (optional)'),
        'Share a song',
      );
      await tapSkillWidget(tester, find.text('Save goal'));
      await waitForSkillWidget(tester, find.text('Sing a verse comfortably'));
      expect(find.byType(LinearProgressIndicator), findsNothing);
      await tapSkillWidget(
        tester,
        find.byTooltip('Actions for goal Sing a verse comfortably'),
      );
      await tapSkillWidget(tester, find.text('Mark complete'));
      await waitForSkillWidget(tester, find.text('Marked complete by you'));
      final completed = (await tester.runAsync(
        () => storage.skillManagement.detail(id),
      ))!.goals.single;
      await tapSkillWidget(
        tester,
        find.byTooltip('Actions for goal Sing a verse comfortably'),
      );
      await tapSkillWidget(tester, find.text('Archive goal'));
      await tapSkillWidget(tester, find.text('Archive goal').last);
      await tester.runAsync(() => storage.skillManagement.detail(id));
      await tapSkillWidget(tester, find.text('Archived goals'));
      await waitForSkillWidget(tester, find.text('Marked complete by you'));
      final archived = (await tester.runAsync(
        () => storage.skillManagement.detail(id),
      ))!.goals.single;
      expect(archived.completedAtUtc, completed.completedAtUtc);
      expect(archived.motivation, 'Share a song');
      expect(archived.targetDateLocal, '2028-02-29');
      expect(archived.status, 'archived');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'exercise edits and duplicate create separate owned records with archive recovery',
    (tester) async {
      late String id;
      final (storage, container) = await pumpSkills(
        tester,
        prepare: (storage) async {
          id = (await storage.skillManagement.create(
            const SkillDraft(name: 'Drawing', kind: SkillKind.drawing),
          )).id;
        },
      );
      final original = (await tester.runAsync(
        () => storage.skillManagement.detail(id),
      ))!.exercises.first;
      container
          .read(routerProvider)
          .go('/skills/$id/exercises/${original.id}/edit');
      await waitForSkillWidget(tester, field('Exercise title'));
      await tester.enterText(field('Exercise title'), 'Line study');
      await tester.enterText(
        field('Instructions (optional)'),
        'Observe one edge, then draw it slowly.',
      );
      await tester.enterText(field('Suggested seconds (optional)'), '90');
      await tapSkillWidget(tester, find.text('Save exercise'));
      await waitForSkillWidget(tester, find.text('Line study'));
      await tapSkillWidget(
        tester,
        find.byTooltip('Actions for exercise Line study'),
      );
      await tapSkillWidget(tester, find.text('Duplicate exercise'));
      await waitForSkillWidget(tester, field('Exercise title'));
      await tester.enterText(field('Exercise title'), 'Second line study');
      await tapSkillWidget(tester, find.text('Save exercise'));
      await waitForSkillWidget(tester, find.text('Second line study'));
      final copied = (await tester.runAsync(
        () => storage.skillManagement.detail(id),
      ))!.exercises;
      expect(copied, hasLength(4));
      expect(copied.last.templateId, isNull);
      expect(copied.last.id, isNot(original.id));
      expect(copied.last.defaultSeconds, 90);
      expect(
        copied.last.instructions,
        'Observe one edge, then draw it slowly.',
      );
      await tapSkillWidget(
        tester,
        find.byTooltip('Actions for exercise Second line study'),
      );
      await tapSkillWidget(tester, find.text('Archive exercise'));
      await tapSkillWidget(tester, find.text('Archive exercise').last);
      await tester.runAsync(() => storage.skillManagement.detail(id));
      await tapSkillWidget(tester, find.text('Archived exercises'));
      await waitForSkillWidget(tester, find.text('Second line study'));
      await tapSkillWidget(
        tester,
        find.byTooltip('Actions for exercise Second line study'),
      );
      await tapSkillWidget(tester, find.text('Restore exercise'));
      await tester.runAsync(() => storage.skillManagement.detail(id));
      await tapSkillWidget(tester, find.text('Current exercises'));
      await waitForSkillWidget(tester, find.text('Second line study'));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'measured and weekly goals validate targets and save their actual meaning',
    (tester) async {
      late String id;
      final (storage, container) = await pumpSkills(
        tester,
        prepare: (storage) async {
          id = (await storage.skillManagement.create(
            const SkillDraft(
              name: 'Custom',
              kind: SkillKind.custom,
              includeStarters: false,
            ),
          )).id;
        },
      );
      container.read(routerProvider).go('/skills/$id/goals/new');
      await waitForSkillWidget(tester, field('Goal title'));
      await tester.enterText(field('Goal title'), 'Accuracy target');
      await tapSkillWidget(tester, find.text('Qualitative goal'));
      await tapSkillWidget(tester, find.text('Reach a measured value').last);
      await tester.enterText(
        field('Measure name'),
        'Accuracy from a manual drill',
      );
      await tapSkillWidget(
        tester,
        find.widgetWithText(DropdownButtonFormField<String>, 'Unit'),
      );
      await tapSkillWidget(tester, find.text('%').last);
      await tester.enterText(field('Target (%)'), '101');
      await tapSkillWidget(tester, find.text('Save goal'));
      expect(
        find.text('The maximum for this measure is 100.0.'),
        findsOneWidget,
      );
      await tester.enterText(field('Target (%)'), '95');
      await tapSkillWidget(tester, find.text('Save goal'));
      await waitForSkillWidget(tester, find.text('Accuracy target'));
      final data = (await tester.runAsync(
        () => storage.skillManagement.detail(id),
      ))!;
      expect(data.definitions.single.unitKey, 'percent');
      expect(data.goals.single.targetValue, 95);
      expect(data.readings, isEmpty);
      expect(data.sessions, isEmpty);
      expect(find.byType(LinearProgressIndicator), findsNothing);
      container.read(routerProvider).go('/skills/$id/goals/new');
      await waitForSkillWidget(tester, field('Goal title'));
      await tester.enterText(field('Goal title'), 'Return gently');
      await tapSkillWidget(tester, find.text('Qualitative goal'));
      await tapSkillWidget(
        tester,
        find.text('Weekly practice suggestion').last,
      );
      await tester.enterText(field('Practice days per week'), '8');
      await tapSkillWidget(tester, find.text('Save goal'));
      expect(
        find.text('Choose a whole number from 1 to 7 days.'),
        findsOneWidget,
      );
      await tester.enterText(field('Practice days per week'), '3');
      await tapSkillWidget(tester, find.text('Save goal'));
      await waitForSkillWidget(tester, find.text('0 of 3 practice days'));
      expect(
        (await tester.runAsync(() => storage.skillManagement.detail(id)))!.goals
            .singleWhere((g) => g.title == 'Return gently')
            .type,
        'weekly_target',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'compact 200% setup with keyboard keeps create reachable and fields scrollable',
    (tester) async {
      await pumpSkills(
        tester,
        route: '/skills/new/setup?kind=voice',
        scale: 2,
        size: const Size(320, 640),
      );
      tester.view.viewInsets = const FakeViewPadding(bottom: 200);
      addTearDown(tester.view.resetViewInsets);
      await tester.enterText(
        field('Skill name'),
        '練習 ${List.filled(8, 'Long name').join()}',
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Create skill').hitTestable(), findsOneWidget);
      await tapSkillWidget(tester, find.text('Create skill'));
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(field('Why this skill? (optional)'));
      await tester.pumpAndSettle();
      expect(field('Why this skill? (optional)').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
