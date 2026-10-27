import 'package:drift/drift.dart';

import '../../../core/data/database/loop_database.dart';
import '../../../core/data/local_failure.dart';
import '../../../core/data/validation.dart';
import '../domain/skill_kind.dart';

export '../domain/skill_kind.dart';

/// Skills, goals and exercises share one skill transaction boundary.
class SkillsRepository {
  const SkillsRepository(this._db);
  final LoopDatabase _db;

  Stream<List<Skill>> watch({bool archived = false}) => guardLocalStream(
    () =>
        (_db.select(_db.skills)
              ..where(
                (s) => archived
                    ? s.archivedAtUtc.isNotNull()
                    : s.archivedAtUtc.isNull(),
              )
              ..orderBy([
                (s) => OrderingTerm.asc(s.sortOrder),
                (s) => OrderingTerm.asc(s.id),
              ]))
            .watch(),
  );

  Future<Skill?> find(String id) => guardLocal(
    () => (_db.select(
      _db.skills,
    )..where((s) => s.id.equals(id))).getSingleOrNull(),
  );

  Future<Skill> create({
    required String name,
    required SkillKind kind,
    String iconKey = 'practice',
    String accentKey = 'brand',
    String? description,
    int? defaultPracticeMinutes,
  }) => guardLocal(() async {
    final normalized = validName(name);
    validText(description, maximum: 4000);
    final now = utcNow();
    return _db
        .into(_db.skills)
        .insertReturning(
          SkillsCompanion.insert(
            id: newId(),
            name: normalized,
            kind: kind.name,
            iconKey: iconKey,
            accentKey: accentKey,
            description: Value(description),
            createdAtUtc: now,
            updatedAtUtc: now,
            defaultPracticeMinutes: Value(defaultPracticeMinutes),
          ),
        );
  });

  Future<void> update(Skill value) => guardLocal(() async {
    final name = validName(value.name);
    validText(value.description, maximum: 4000);
    requireChanged(
      await (_db.update(_db.skills)..where((s) => s.id.equals(value.id))).write(
        SkillsCompanion(
          name: Value(name),
          kind: Value(value.kind),
          iconKey: Value(value.iconKey),
          accentKey: Value(value.accentKey),
          description: Value(value.description),
          defaultPracticeMinutes: Value(value.defaultPracticeMinutes),
          updatedAtUtc: Value(utcNow()),
        ),
      ),
    );
  });

  Future<void> setArchived(String id, bool archived) => guardLocal(() async {
    requireChanged(
      await (_db.update(_db.skills)..where((s) => s.id.equals(id))).write(
        SkillsCompanion(
          archivedAtUtc: Value(archived ? utcNow() : null),
          updatedAtUtc: Value(utcNow()),
        ),
      ),
    );
  });

  Future<void> reorder(List<String> ids) => guardLocal(
    () => _db.transaction(() async {
      final active = await (_db.select(
        _db.skills,
      )..where((s) => s.archivedAtUtc.isNull())).get();
      if (ids.toSet().length != ids.length ||
          ids.length != active.length ||
          !ids.toSet().containsAll(active.map((s) => s.id))) {
        throw const LocalFailure(LocalFailureKind.invalid);
      }
      for (var i = 0; i < ids.length; i++) {
        await (_db.update(_db.skills)..where((s) => s.id.equals(ids[i]))).write(
          SkillsCompanion(sortOrder: Value(i), updatedAtUtc: Value(utcNow())),
        );
      }
    }),
  );

  /// Caller must obtain explicit destructive scope confirmation (M12).
  Future<void> deleteConfirmed(String id) => guardLocal(
    () => _db.transaction(() async {
      requireChanged(
        await (_db.delete(_db.skills)..where((s) => s.id.equals(id))).go(),
      );
    }),
  );

  Stream<List<Goal>> watchGoals(String skillId) => guardLocalStream(
    () =>
        (_db.select(_db.goals)
              ..where((g) => g.skillId.equals(skillId))
              ..orderBy([
                (g) => OrderingTerm.asc(g.createdAtUtc),
                (g) => OrderingTerm.asc(g.id),
              ]))
            .watch(),
  );

  Future<Goal> createGoal(GoalsCompanion value) => guardLocal(() async {
    validName(value.title.value, maximum: 120);
    finite(value.targetValue.value);
    return _db
        .into(_db.goals)
        .insertReturning(
          value.copyWith(
            id: Value(newId()),
            createdAtUtc: Value(utcNow()),
            updatedAtUtc: Value(utcNow()),
          ),
        );
  });

  Future<void> updateGoal(Goal value) => guardLocal(() async {
    validName(value.title, maximum: 120);
    finite(value.targetValue);
    final existing = await (_db.select(
      _db.goals,
    )..where((g) => g.id.equals(value.id))).getSingleOrNull();
    if (existing == null) throw const LocalFailure(LocalFailureKind.notFound);
    if (existing.skillId != value.skillId)
      throw const LocalFailure(LocalFailureKind.invalid);
    await _db
        .update(_db.goals)
        .replace(
          value.copyWith(
            updatedAtUtc: utcNow(),
            createdAtUtc: existing.createdAtUtc,
          ),
        );
  });

  Future<void> deleteGoal(String id) => guardLocal(() async {
    requireChanged(
      await (_db.delete(_db.goals)..where((g) => g.id.equals(id))).go(),
    );
  });

  Stream<List<Exercise>> watchExercises(
    String skillId, {
    bool includeArchived = false,
  }) => guardLocalStream(
    () =>
        (_db.select(_db.exercises)
              ..where(
                (e) =>
                    e.skillId.equals(skillId) &
                    (includeArchived
                        ? const Constant(true)
                        : e.isArchived.equals(false)),
              )
              ..orderBy([
                (e) => OrderingTerm.asc(e.sortOrder),
                (e) => OrderingTerm.asc(e.id),
              ]))
            .watch(),
  );

  Future<Exercise> createExercise({
    required String skillId,
    required String title,
    String instructions = '',
    int? defaultSeconds,
    String? templateId,
  }) => guardLocal(() async {
    final normalized = validName(title, maximum: 120);
    validText(instructions, maximum: 10000);
    final now = utcNow();
    return _db
        .into(_db.exercises)
        .insertReturning(
          ExercisesCompanion.insert(
            id: newId(),
            skillId: skillId,
            title: normalized,
            instructions: Value(instructions),
            defaultSeconds: Value(defaultSeconds),
            templateId: Value(templateId),
            createdAtUtc: now,
            updatedAtUtc: now,
          ),
        );
  });

  Future<void> updateExercise(Exercise value) => guardLocal(() async {
    final title = validName(value.title, maximum: 120);
    validText(value.instructions, maximum: 10000);
    requireChanged(
      await (_db.update(_db.exercises)..where(
            (e) => e.id.equals(value.id) & e.skillId.equals(value.skillId),
          ))
          .write(
            ExercisesCompanion(
              title: Value(title),
              instructions: Value(value.instructions),
              defaultSeconds: Value(value.defaultSeconds),
              isArchived: Value(value.isArchived),
              sortOrder: Value(value.sortOrder),
              updatedAtUtc: Value(utcNow()),
            ),
          ),
    );
  });

  Future<void> deleteExercise(String id) => guardLocal(() async {
    requireChanged(
      await (_db.delete(_db.exercises)..where((e) => e.id.equals(id))).go(),
    );
  });
}
