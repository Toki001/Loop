import 'package:drift/drift.dart';

import '../../../core/data/database/loop_database.dart';
import '../../../core/data/local_failure.dart';
import '../../../core/data/validation.dart';
import '../../../features/progress/data/metrics_repository.dart';
import '../domain/skill_draft.dart';
import '../domain/goal_rules.dart';
import '../domain/goal_measure.dart';
import '../domain/starter_catalog.dart';
import 'skills_repository.dart';

class SkillDetailData {
  const SkillDetailData({
    required this.skill,
    required this.goals,
    required this.exercises,
    required this.definitions,
    required this.sessions,
    required this.readings,
  });
  final Skill skill;
  final List<Goal> goals;
  final List<Exercise> exercises;
  final List<MetricDefinition> definitions;
  final List<Session> sessions;
  final List<MetricReading> readings;
}

class SkillCardData {
  const SkillCardData(this.skill, this.lastPracticed, this.nextStep, this.goal);
  final Skill skill;
  final DateTime? lastPracticed;
  final String? nextStep;
  final String? goal;
}

/// Coordinates owned setup/snapshot reads. Widgets never call SQL tables.
class SkillManagementRepository {
  SkillManagementRepository(this._db)
    : skills = SkillsRepository(_db),
      _metrics = MetricsRepository(_db);
  final LoopDatabase _db;
  final SkillsRepository skills;
  final MetricsRepository _metrics;

  Future<Skill> create(SkillDraft draft) => guardLocal(
    () => _db.transaction(() async {
      draft.validate();
      final order =
          (await _db
                  .customSelect(
                    'SELECT COALESCE(MAX(sort_order), -1) + 1 AS next_order FROM skills WHERE archived_at_utc IS NULL',
                  )
                  .getSingle())
              .read<int>('next_order');
      final skill = await skills.create(
        name: draft.name,
        kind: draft.kind,
        iconKey: draft.iconKey,
        accentKey: draft.accentKey,
        description: draft.description,
        defaultPracticeMinutes: draft.practiceMinutes,
      );
      await (_db.update(_db.skills)..where((s) => s.id.equals(skill.id))).write(
        SkillsCompanion(sortOrder: Value(order)),
      );
      if (draft.includeStarters) {
        final catalog = StarterCatalog.exercises(draft.kind);
        for (var i = 0; i < catalog.length; i++) {
          final starter = catalog[i];
          final exercise = await skills.createExercise(
            skillId: skill.id,
            title: starter.title,
            instructions: starter.instructions,
            templateId: starter.id,
          );
          await skills.updateExercise(exercise.copyWith(sortOrder: i));
        }
        for (final metric in StarterCatalog.metrics(draft.kind)) {
          await _metrics.create(
            MetricDefinitionsCompanion(
              skillId: Value(skill.id),
              label: Value(metric.label),
              unitKey: Value(metric.unit),
              valueType: const Value('numeric'),
              direction: Value(metric.direction),
              scaleMin: Value(metric.minimum),
              scaleMax: Value(metric.maximum),
              sourceHint: Value(metric.source),
            ),
          );
        }
      }
      if (draft.firstGoal?.trim().isNotEmpty == true) {
        await skills.createGoal(
          GoalsCompanion(
            skillId: Value(skill.id),
            title: Value(draft.firstGoal!.trim()),
            type: const Value('qualitative'),
            status: const Value('active'),
          ),
        );
      }
      return skill.copyWith(sortOrder: order);
    }),
  );

  Future<void> update(String id, SkillDraft draft) => guardLocal(
    () => _db.transaction(() async {
      draft.validate();
      final existing = await skills.find(id);
      if (existing == null) throw const LocalFailure(LocalFailureKind.notFound);
      await skills.update(
        existing.copyWith(
          name: draft.name,
          kind: draft.kind.name,
          iconKey: draft.iconKey,
          accentKey: draft.accentKey,
          description: Value(draft.description),
          defaultPracticeMinutes: Value(draft.practiceMinutes),
        ),
      );
      // Category edits never recreate/overwrite owned exercises or definitions.
    }),
  );

  Stream<List<SkillCardData>> watchCards({bool archived = false}) =>
      guardLocalStream(
        () => _db
            .customSelect(
              'SELECT id FROM skills',
              readsFrom: {_db.skills, _db.goals, _db.sessions},
            )
            .watch()
            .asyncMap(
              (_) => _db.transaction(() async {
                final owned =
                    await (_db.select(_db.skills)
                          ..where(
                            (s) => archived
                                ? s.archivedAtUtc.isNotNull()
                                : s.archivedAtUtc.isNull(),
                          )
                          ..orderBy([
                            (s) => OrderingTerm.asc(s.sortOrder),
                            (s) => OrderingTerm.asc(s.id),
                          ]))
                        .get();
                final sessions =
                    await (_db.select(_db.sessions)
                          ..where((s) => s.status.equals('completed'))
                          ..orderBy([
                            (s) => OrderingTerm.desc(s.endedAtUtc),
                            (s) => OrderingTerm.asc(s.id),
                          ]))
                        .get();
                final goals =
                    await (_db.select(_db.goals)
                          ..where((g) => g.status.equals('active'))
                          ..orderBy([
                            (g) => OrderingTerm.asc(g.createdAtUtc),
                            (g) => OrderingTerm.asc(g.id),
                          ]))
                        .get();
                final last = <String, Session>{};
                final activeGoal = <String, Goal>{};
                for (final s in sessions) {
                  last.putIfAbsent(s.skillId, () => s);
                }
                for (final g in goals) {
                  activeGoal.putIfAbsent(g.skillId, () => g);
                }
                return [
                  for (final s in owned)
                    SkillCardData(
                      s,
                      last[s.id]?.endedAtUtc,
                      last[s.id]?.nextStep?.trim().isNotEmpty == true
                          ? last[s.id]!.nextStep
                          : null,
                      activeGoal[s.id]?.title,
                    ),
                ];
              }),
            ),
      );

  Stream<SkillDetailData?> watchDetail(String id) => guardLocalStream(
    () => _db
        .customSelect(
          'SELECT id FROM skills WHERE id = ?',
          variables: [Variable(id)],
          readsFrom: {
            _db.skills,
            _db.goals,
            _db.exercises,
            _db.metricDefinitions,
            _db.metricReadings,
            _db.sessions,
          },
        )
        .watch()
        .asyncMap((rows) async {
          if (rows.isEmpty) return null;
          return detail(id);
        }),
  );

  Future<SkillDetailData?> detail(String id) => guardLocal(
    () => _db.transaction(() async {
      final skill = await skills.find(id);
      if (skill == null) return null;
      final sessions =
          await (_db.select(_db.sessions)
                ..where((s) => s.skillId.equals(id))
                ..orderBy([
                  (s) => OrderingTerm.desc(s.endedAtUtc),
                  (s) => OrderingTerm.asc(s.id),
                ]))
              .get();
      final readings =
          await (_db.select(_db.metricReadings).join([
                innerJoin(
                  _db.sessions,
                  _db.sessions.id.equalsExp(_db.metricReadings.sessionId),
                ),
              ])..where(_db.sessions.skillId.equals(id)))
              .map((row) => row.readTable(_db.metricReadings))
              .get();
      return SkillDetailData(
        skill: skill,
        goals:
            await (_db.select(_db.goals)
                  ..where((g) => g.skillId.equals(id))
                  ..orderBy([
                    (g) => OrderingTerm.asc(g.createdAtUtc),
                    (g) => OrderingTerm.asc(g.id),
                  ]))
                .get(),
        exercises:
            await (_db.select(_db.exercises)
                  ..where((e) => e.skillId.equals(id))
                  ..orderBy([
                    (e) => OrderingTerm.asc(e.sortOrder),
                    (e) => OrderingTerm.asc(e.id),
                  ]))
                .get(),
        definitions: await _metrics.definitions(id, includeArchived: true),
        sessions: sessions,
        readings: readings,
      );
    }),
  );

  Future<Exercise> duplicateExercise(String id) => guardLocal(
    () => _db.transaction(() async {
      final source = await (_db.select(
        _db.exercises,
      )..where((e) => e.id.equals(id))).getSingleOrNull();
      if (source == null) throw const LocalFailure(LocalFailureKind.notFound);
      final created = await skills.createExercise(
        skillId: source.skillId,
        title: source.title,
        instructions: source.instructions,
        defaultSeconds: source.defaultSeconds,
      );
      final order =
          (await _db
                  .customSelect(
                    'SELECT COALESCE(MAX(sort_order), -1) + 1 AS next_order FROM exercises WHERE skill_id = ?',
                    variables: [Variable(source.skillId)],
                  )
                  .getSingle())
              .read<int>('next_order');
      final result = created.copyWith(sortOrder: order);
      await skills.updateExercise(result);
      return result;
    }),
  );

  Future<void> reorderExercises(String skillId, List<String> ids) => guardLocal(
    () => _db.transaction(() async {
      final active =
          await (_db.select(_db.exercises)..where(
                (e) => e.skillId.equals(skillId) & e.isArchived.equals(false),
              ))
              .get();
      if (ids.toSet().length != ids.length ||
          ids.length != active.length ||
          !ids.toSet().containsAll(active.map((e) => e.id))) {
        throw const LocalFailure(LocalFailureKind.invalid);
      }
      for (var i = 0; i < ids.length; i++) {
        await (_db.update(
          _db.exercises,
        )..where((e) => e.id.equals(ids[i]))).write(
          ExercisesCompanion(
            sortOrder: Value(i),
            updatedAtUtc: Value(utcNow()),
          ),
        );
      }
    }),
  );

  Future<void> setExerciseArchived(String id, bool archived) => guardLocal(
    () async {
      requireChanged(
        await (_db.update(_db.exercises)..where((e) => e.id.equals(id))).write(
          ExercisesCompanion(
            isArchived: Value(archived),
            updatedAtUtc: Value(utcNow()),
          ),
        ),
      );
    },
  );

  Future<Goal> saveGoal(
    String skillId,
    GoalDraft draft, {
    String? id,
    GoalMeasure? newMeasure,
  }) => guardLocal(
    () => _db.transaction(() async {
      if (await skills.find(skillId) == null)
        throw const LocalFailure(LocalFailureKind.notFound);
      final existing = id == null
          ? null
          : await (_db.select(
              _db.goals,
            )..where((g) => g.id.equals(id))).getSingleOrNull();
      if (id != null && existing == null)
        throw const LocalFailure(LocalFailureKind.notFound);
      if (existing != null && existing.skillId != skillId)
        throw const LocalFailure(LocalFailureKind.invalid);
      if (newMeasure != null) {
        newMeasure.validate();
        if (draft.definition != null ||
            ![GoalType.cumulative, GoalType.threshold].contains(draft.type)) {
          throw const LocalFailure(LocalFailureKind.invalid);
        }
        final definition = await _metrics.create(
          MetricDefinitionsCompanion(
            skillId: Value(skillId),
            label: Value(newMeasure.label),
            unitKey: Value(newMeasure.unit),
            direction: Value(newMeasure.direction),
            valueType: const Value('numeric'),
            scaleMin: const Value(0),
            scaleMax: Value(newMeasure.unit == 'percent' ? 100.0 : null),
            sourceHint: const Value('manual'),
          ),
        );
        draft = GoalDraft(
          title: draft.title,
          type: draft.type,
          definition: definition,
          target: draft.target,
          unit: definition.unitKey,
          dateLocal: draft.dateLocal,
          motivation: draft.motivation,
        );
      }
      draft.validate(skillId, existing: existing);
      if (existing == null)
        return skills.createGoal(
          GoalsCompanion(
            skillId: Value(skillId),
            title: Value(draft.title.trim()),
            type: Value(draft.type.stored),
            status: const Value('active'),
            metricDefinitionId: Value(draft.definition?.id),
            definitionVersion: Value(draft.definition?.version),
            targetValue: Value(draft.target),
            targetUnit: Value(draft.unit),
            targetDateLocal: Value(draft.dateLocal),
            motivation: Value(draft.motivation),
          ),
        );
      final next = existing.copyWith(
        title: draft.title.trim(),
        type: draft.type.stored,
        metricDefinitionId: Value(draft.definition?.id),
        definitionVersion: Value(draft.definition?.version),
        targetValue: Value(draft.target),
        targetUnit: Value(draft.unit),
        targetDateLocal: Value(draft.dateLocal),
        motivation: Value(draft.motivation),
      );
      await skills.updateGoal(next);
      return (await (_db.select(
        _db.goals,
      )..where((g) => g.id.equals(next.id))).getSingle());
    }),
  );

  Future<void> setGoalStatus(String id, String status) => guardLocal(
    () => _db.transaction(() async {
      if (!['active', 'completed', 'paused', 'archived'].contains(status))
        throw const LocalFailure(LocalFailureKind.invalid);
      final existing = await (_db.select(
        _db.goals,
      )..where((g) => g.id.equals(id))).getSingleOrNull();
      if (existing == null) throw const LocalFailure(LocalFailureKind.notFound);
      await skills.updateGoal(
        existing.copyWith(
          status: status,
          completedAtUtc: Value(switch (status) {
            'completed' => existing.completedAtUtc ?? utcNow(),
            'archived' => existing.completedAtUtc,
            _ => null,
          }),
        ),
      );
    }),
  );

  Future<Exercise> saveExercise({
    required String skillId,
    required String title,
    required String instructions,
    int? seconds,
    String? id,
  }) => guardLocal(
    () => _db.transaction(() async {
      validName(title, maximum: 120);
      validText(instructions, maximum: 10000);
      if (seconds != null && (seconds < 1 || seconds > 10800))
        throw const LocalFailure(LocalFailureKind.invalid);
      if (id == null) {
        final exercise = await skills.createExercise(
          skillId: skillId,
          title: title,
          instructions: instructions,
          defaultSeconds: seconds,
        );
        final order =
            (await _db
                    .customSelect(
                      'SELECT COALESCE(MAX(sort_order), -1) + 1 AS next_order FROM exercises WHERE skill_id = ?',
                      variables: [Variable(skillId)],
                    )
                    .getSingle())
                .read<int>('next_order');
        final next = exercise.copyWith(sortOrder: order);
        await skills.updateExercise(next);
        return next;
      }
      final existing = await (_db.select(
        _db.exercises,
      )..where((e) => e.id.equals(id))).getSingleOrNull();
      if (existing == null) throw const LocalFailure(LocalFailureKind.notFound);
      if (existing.skillId != skillId)
        throw const LocalFailure(LocalFailureKind.invalid);
      final next = existing.copyWith(
        title: title.trim(),
        instructions: instructions,
        defaultSeconds: Value(seconds),
      );
      await skills.updateExercise(next);
      return next;
    }),
  );
}
