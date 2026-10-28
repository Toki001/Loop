import 'package:drift/drift.dart';

import '../../../core/data/database/loop_database.dart';
import '../../../core/data/local_failure.dart';
import '../../../core/data/validation.dart';
import 'sessions_repository.dart';

class PracticeRecord {
  const PracticeRecord(this.session, this.checkpoint, this.exercises);
  final Session session;
  final PracticeCheckpoint? checkpoint;
  final List<SessionExercise> exercises;
  int get milliseconds =>
      checkpoint?.activeMilliseconds ?? session.activeSeconds * 1000;
}

/// Atomic coordinator for session clock, notes and selected exercise snapshots.
class PracticeRepository {
  PracticeRepository(this.database) : sessions = SessionsRepository(database);
  final LoopDatabase database;
  final SessionsRepository sessions;

  Future<PracticeRecord?> find(String id) => guardLocal(() async {
    final session = await sessions.find(id);
    if (session == null) return null;
    final checkpoint = await (database.select(
      database.practiceCheckpoints,
    )..where((c) => c.sessionId.equals(id))).getSingleOrNull();
    return PracticeRecord(session, checkpoint, await sessions.exercises(id));
  });

  Future<List<PracticeRecord>> pending() => guardLocal(() async {
    final rows =
        await (database.select(database.sessions)
              ..where((s) => s.status.isIn(['draft', 'running', 'paused']))
              ..orderBy([
                (s) => OrderingTerm.desc(s.updatedAtUtc),
                (s) => OrderingTerm.asc(s.id),
              ]))
            .get();
    return [for (final row in rows) (await find(row.id))!];
  });

  Future<List<PracticeRecord>> recover() => guardLocal(
    () => database.transaction(() async {
      for (final record in await pending()) {
        if (record.session.status == 'running') {
          await write(
            record.session.copyWith(
              status: 'paused',
              interruptionReason: const Value('recovered'),
            ),
            milliseconds: record.milliseconds,
          );
        }
      }
      return pending();
    }),
  );

  Future<PracticeRecord> create({
    required String skillId,
    required List<String> exerciseIds,
    int? plannedSeconds,
    EntryMode mode = EntryMode.timed,
    ManualIntent? manualIntent,
  }) => guardLocal(
    () => database.transaction(() async {
      if (plannedSeconds != null &&
          (plannedSeconds < 60 || plannedSeconds > 10800))
        throw const LocalFailure(LocalFailureKind.invalid);
      if ((await pending()).isNotEmpty)
        throw const LocalFailure(LocalFailureKind.conflict);
      final skill = await (database.select(
        database.skills,
      )..where((s) => s.id.equals(skillId))).getSingleOrNull();
      if (skill == null || skill.archivedAtUtc != null)
        throw const LocalFailure(LocalFailureKind.invalid);
      if (exerciseIds.toSet().length != exerciseIds.length)
        throw const LocalFailure(LocalFailureKind.invalid);
      final chosen = <Exercise>[];
      for (final id in exerciseIds) {
        final exercise = await (database.select(
          database.exercises,
        )..where((e) => e.id.equals(id))).getSingleOrNull();
        if (exercise == null ||
            exercise.skillId != skillId ||
            exercise.isArchived)
          throw const LocalFailure(LocalFailureKind.invalid);
        chosen.add(exercise);
      }
      final session = await sessions.createDraft(
        skillId,
        mode: mode,
        manualIntent: manualIntent,
      );
      await sessions.replaceExercises(session.id, [
        for (var i = 0; i < chosen.length; i++)
          SessionExercise(
            sessionId: session.id,
            exerciseId: chosen[i].id,
            exerciseTitleSnapshot: chosen[i].title,
            ordinal: i,
          ),
      ]);
      await database
          .into(database.practiceCheckpoints)
          .insert(
            PracticeCheckpointsCompanion.insert(
              sessionId: session.id,
              activeMilliseconds: 0,
              plannedSeconds: Value(plannedSeconds),
              checkpointAtUtc: utcNow(),
            ),
          );
      return (await find(session.id))!;
    }),
  );

  Future<PracticeRecord> write(
    Session value, {
    required int milliseconds,
    int? manualSeconds,
    String? manualDateLocal,
  }) => guardLocal(
    () => database.transaction(() async {
      if (milliseconds < 0 || milliseconds ~/ 1000 != value.activeSeconds)
        throw const LocalFailure(LocalFailureKind.invalid);
      if (manualSeconds != null &&
          (manualSeconds < 0 || manualSeconds > 604800))
        throw const LocalFailure(LocalFailureKind.invalid);
      if (manualDateLocal != null &&
          (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(manualDateLocal) ||
              DateTime.tryParse(manualDateLocal)
                      ?.toIso8601String()
                      .substring(0, 10) !=
                  manualDateLocal))
        throw const LocalFailure(LocalFailureKind.invalid);
      final existing = await sessions.find(value.id);
      if (existing == null) throw const LocalFailure(LocalFailureKind.notFound);
      // A lost response/repeated Finish returns the already committed identity.
      if (existing.status == 'completed' && value.status == 'completed')
        return (await find(value.id))!;
      final saved = await sessions.save(
        value,
        expectedRevision: value.revision,
      );
      final prior = await (database.select(
        database.practiceCheckpoints,
      )..where((c) => c.sessionId.equals(saved.id))).getSingleOrNull();
      await database
          .into(database.practiceCheckpoints)
          .insertOnConflictUpdate(
            PracticeCheckpointsCompanion.insert(
              sessionId: saved.id,
              activeMilliseconds: milliseconds,
              plannedSeconds: Value(prior?.plannedSeconds),
              manualSeconds: Value(manualSeconds ?? prior?.manualSeconds ?? 0),
              manualDateLocal: Value(manualDateLocal ?? prior?.manualDateLocal),
              checkpointAtUtc: utcNow(),
            ),
          );
      if (saved.status == 'discarded') {
        await (database.delete(
          database.journalDrafts,
        )..where((d) => d.sessionId.equals(saved.id))).go();
      }
      return (await find(saved.id))!;
    }),
  );
}
