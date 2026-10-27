import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:loop/core/data/database/loop_database.dart';
import 'package:loop/core/data/database/open_database.dart';
import 'package:loop/core/data/local_failure.dart';
import 'package:loop/core/media/private_files.dart';
import 'package:loop/features/skills/data/skill_management_repository.dart';
import 'package:loop/features/skills/data/skills_repository.dart';
import 'package:loop/features/skills/domain/goal_rules.dart';
import 'package:loop/features/skills/domain/goal_measure.dart';
import 'package:loop/features/skills/domain/skill_draft.dart';
import 'package:loop/features/skills/domain/starter_catalog.dart';

void main() {
  late Directory directory;
  late LoopDatabase db;
  late SkillManagementRepository repository;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('loop-skill-management-');
    db = await openDatabase(await PrivateFiles.open(directory));
    repository = SkillManagementRepository(db);
  });
  tearDown(() async {
    await db.close();
    await directory.delete(recursive: true);
  });

  test(
    'custom goal measurement and goal commit together without readings',
    () async {
      final skill = await repository.create(
        const SkillDraft(
          name: 'Custom',
          kind: SkillKind.custom,
          includeStarters: false,
        ),
      );
      final goal = await repository.saveGoal(
        skill.id,
        const GoalDraft(
          title: 'Read comfortably',
          type: GoalType.threshold,
          target: 25,
          unit: 'pages',
        ),
        newMeasure: const GoalMeasure(
          label: 'Pages in an hour',
          unit: 'pages',
          direction: 'up',
        ),
      );
      final detail = (await repository.detail(skill.id))!;
      expect(detail.definitions.single.id, goal.metricDefinitionId);
      expect(detail.definitions.single.unitKey, 'pages');
      expect(detail.definitions.single.sourceHint, 'manual');
      expect(detail.readings, isEmpty);
      expect(detail.sessions, isEmpty);
      await db.close();
      db = await openDatabase(await PrivateFiles.open(directory));
      repository = SkillManagementRepository(db);
      final reopened = (await repository.detail(skill.id))!;
      expect(
        reopened.goals.single.metricDefinitionId,
        reopened.definitions.single.id,
      );
      expect(reopened.goals.single.targetValue, 25);
    },
  );

  test('invalid new goal measures roll back definitions and preserve existing goal', () async {
    final skill = await repository.create(
      const SkillDraft(
        name: 'Custom',
        kind: SkillKind.custom,
        includeStarters: false,
      ),
    );
    final original = await repository.saveGoal(
      skill.id,
      const GoalDraft(title: 'Own milestone', type: GoalType.qualitative),
    );
    for (final item in [
      (GoalType.cumulative, 'wpm', 'up', 50.0),
      (GoalType.cumulative, 'count', 'down', 10.0),
      (GoalType.threshold, 'percent', 'up', 101.0),
      (GoalType.threshold, 'practice_sessions', 'up', 5.0),
      (GoalType.threshold, 'count', 'none', 5.0),
    ]) {
      await expectLater(
        repository.saveGoal(
          skill.id,
          GoalDraft(
            title: 'Invalid replacement',
            type: item.$1,
            target: item.$4,
            unit: item.$2,
          ),
          id: original.id,
          newMeasure: GoalMeasure(
            label: 'Synthetic measure',
            unit: item.$2,
            direction: item.$3,
          ),
        ),
        throwsA(isA<LocalFailure>()),
      );
      final data = (await repository.detail(skill.id))!;
      expect(data.definitions, isEmpty);
      expect(data.goals.single.title, 'Own milestone');
      expect(data.goals.single.type, 'qualitative');
    }
  });

  test(
    'each category creates owned suggestions without recorded progress',
    () async {
      for (final kind in SkillKind.values) {
        final skill = await repository.create(
          SkillDraft(name: 'Synthetic ${kind.name}', kind: kind),
        );
        final detail = (await repository.detail(skill.id))!;
        expect(
          detail.exercises.map((e) => e.templateId),
          StarterCatalog.exercises(kind).map((e) => e.id),
        );
        expect(detail.definitions.length, StarterCatalog.metrics(kind).length);
        expect(detail.sessions, isEmpty);
        expect(detail.readings, isEmpty);
        expect(detail.goals, isEmpty);
      }
      final all = await repository.watchCards().first;
      expect(all.map((s) => s.skill.sortOrder), List.generate(8, (i) => i));
      expect(
        all.every(
          (s) =>
              s.lastPracticed == null && s.goal == null && s.nextStep == null,
        ),
        true,
      );
    },
  );

  test(
    'partial setup failure rolls back skill, starters, metrics and first goal',
    () async {
      await db.customStatement(
        "CREATE TRIGGER synthetic_fail_metric BEFORE INSERT ON metric_definitions BEGIN SELECT RAISE(ABORT, 'synthetic'); END",
      );
      const draft = SkillDraft(
        name: 'Retry',
        kind: SkillKind.typing,
        firstGoal: 'Comfortable typing',
      );
      await expectLater(repository.create(draft), throwsA(isA<LocalFailure>()));
      expect(await db.select(db.skills).get(), isEmpty);
      expect(await db.select(db.exercises).get(), isEmpty);
      expect(await db.select(db.metricDefinitions).get(), isEmpty);
      expect(await db.select(db.goals).get(), isEmpty);
      await db.customStatement('DROP TRIGGER synthetic_fail_metric');
      final created = await repository.create(draft);
      expect(
        (await repository.detail(created.id))!.goals.single.title,
        'Comfortable typing',
      );
    },
  );

  test('duplicate names and category changes preserve owned customizations across reopen', () async {
    const draft = SkillDraft(name: 'Repeated', kind: SkillKind.music);
    final a = await repository.create(draft);
    final b = await repository.create(draft);
    expect(a.id, isNot(b.id));
    final before = (await repository.detail(a.id))!;
    final exercise = before.exercises.first;
    await repository.saveExercise(
      skillId: a.id,
      id: exercise.id,
      title: 'My variation',
      instructions: 'My own prompt',
      seconds: 30,
    );
    await repository.update(
      a.id,
      const SkillDraft(
        name: 'Renamed',
        kind: SkillKind.custom,
        includeStarters: false,
        practiceMinutes: null,
      ),
    );
    await repository.skills.setArchived(a.id, true);
    expect(
      (await repository.watchCards(archived: true).first).single.skill.id,
      a.id,
    );
    await db.close();
    db = await openDatabase(await PrivateFiles.open(directory));
    repository = SkillManagementRepository(db);
    final after = (await repository.detail(a.id))!;
    expect(after.skill.kind, 'custom');
    expect(after.skill.defaultPracticeMinutes, isNull);
    expect(after.exercises.map((e) => e.id), before.exercises.map((e) => e.id));
    expect(
      after.exercises.singleWhere((e) => e.id == exercise.id).instructions,
      'My own prompt',
    );
    expect(
      after.definitions.map((e) => e.id),
      before.definitions.map((e) => e.id),
    );
    await repository.skills.setArchived(a.id, false);
    expect(await repository.watchCards().first, hasLength(2));
  });

  test('exercise duplication, archive and complete-set reorder preserve identities', () async {
    final skill = await repository.create(
      const SkillDraft(name: 'Typing', kind: SkillKind.typing),
    );
    final before = (await repository.detail(skill.id))!.exercises;
    final duplicate = await repository.duplicateExercise(before.first.id);
    expect(duplicate.id, isNot(before.first.id));
    expect(duplicate.templateId, isNull);
    expect(duplicate.instructions, before.first.instructions);
    final ids = [...before.map((e) => e.id), duplicate.id].reversed.toList();
    await repository.reorderExercises(skill.id, ids);
    expect(
      (await repository.detail(skill.id))!.exercises.map((e) => e.id),
      ids,
    );
    await expectLater(
      repository.reorderExercises(skill.id, [ids.first]),
      throwsA(isA<LocalFailure>()),
    );
    expect(
      (await repository.detail(skill.id))!.exercises.map((e) => e.id),
      ids,
    );
    await repository.skills.updateExercise(
      duplicate.copyWith(isArchived: true),
    );
    expect(
      await repository.skills.watchExercises(skill.id).first,
      hasLength(3),
    );
    expect(
      await repository.skills
          .watchExercises(skill.id, includeArchived: true)
          .first,
      hasLength(4),
    );
  });

  test('goal type edits, dates, motivation, completion and archive preserve history', () async {
    final skill = await repository.create(
      const SkillDraft(
        name: 'A personal aim',
        kind: SkillKind.custom,
        includeStarters: false,
      ),
    );
    final goal = await repository.saveGoal(
      skill.id,
      const GoalDraft(
        title: 'A small deliverable',
        type: GoalType.deliverable,
        dateLocal: '2028-02-29',
        motivation: 'For myself',
      ),
    );
    await repository.setGoalStatus(goal.id, 'completed');
    final completed = (await repository.detail(skill.id))!.goals.single;
    expect(completed.completedAtUtc, isNotNull);
    await repository.setGoalStatus(goal.id, 'archived');
    final archived = (await repository.detail(skill.id))!.goals.single;
    expect(archived.completedAtUtc, completed.completedAtUtc);
    expect(archived.motivation, 'For myself');
    await repository.setGoalStatus(goal.id, 'completed');
    expect(
      (await repository.detail(skill.id))!.goals.single.completedAtUtc,
      completed.completedAtUtc,
    );
    await repository.setGoalStatus(goal.id, 'active');
    expect(
      (await repository.detail(skill.id))!.goals.single.completedAtUtc,
      isNull,
    );
    await expectLater(
      repository.saveGoal(
        skill.id,
        const GoalDraft(
          title: 'Invalid date',
          type: GoalType.qualitative,
          dateLocal: '2027-02-29',
        ),
      ),
      throwsA(isA<LocalFailure>()),
    );
    await repository.saveGoal(
      skill.id,
      const GoalDraft(
        title: 'Practice regularly',
        type: GoalType.weeklyTarget,
        target: 3,
        unit: 'days_per_week',
      ),
      id: goal.id,
    );
    final updated = (await repository.detail(skill.id))!.goals.single;
    expect(updated.id, goal.id);
    expect(updated.type, 'weekly_target');
    expect(updated.motivation, isNull);
  });

  test('invalid plans/accents/targets/cross-skill definitions leave rows unchanged', () async {
    await expectLater(
      repository.create(
        const SkillDraft(
          name: 'Too long a plan',
          kind: SkillKind.music,
          practiceMinutes: 181,
        ),
      ),
      throwsA(isA<LocalFailure>()),
    );
    final skill = await repository.create(
      const SkillDraft(name: 'Typing', kind: SkillKind.typing),
    );
    final other = await repository.create(
      const SkillDraft(name: 'Other', kind: SkillKind.custom),
    );
    final metric = (await repository.detail(skill.id))!.definitions
        .firstWhere((d) => d.unitKey == 'wpm');
    await expectLater(
      repository.saveGoal(
        other.id,
        GoalDraft(
          title: 'Wrong skill',
          type: GoalType.threshold,
          target: 40,
          unit: metric.unitKey,
          definition: metric,
        ),
      ),
      throwsA(isA<LocalFailure>()),
    );
    await expectLater(
      repository.saveGoal(
        skill.id,
        GoalDraft(
          title: 'Invalid sum of speed',
          type: GoalType.cumulative,
          target: 100,
          unit: metric.unitKey,
          definition: metric,
        ),
      ),
      throwsA(isA<LocalFailure>()),
    );
    await expectLater(
      repository.saveGoal(
        skill.id,
        const GoalDraft(
          title: 'Invalid week',
          type: GoalType.weeklyTarget,
          target: 8,
          unit: 'days_per_week',
        ),
      ),
      throwsA(isA<LocalFailure>()),
    );
    expect(await db.select(db.goals).get(), isEmpty);
    expect(await db.select(db.sessions).get(), isEmpty);
  });
}
