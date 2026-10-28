import 'package:drift/drift.dart';

import '../../../core/data/database/loop_database.dart';
import '../../../core/data/local_failure.dart';
import '../../../core/data/validation.dart';

enum EntryMode { timed, manual }

enum ManualIntent {
  duration('duration'),
  evidenceOnly('evidence_only');

  const ManualIntent(this.stored);
  final String stored;
}

class SessionsRepository {
  const SessionsRepository(this._db);
  final LoopDatabase _db;

  Future<Session?> find(String id) => guardLocal(
    () => (_db.select(
      _db.sessions,
    )..where((s) => s.id.equals(id))).getSingleOrNull(),
  );

  Stream<List<Session>> watchForSkill(String skillId) => guardLocalStream(
    () =>
        (_db.select(_db.sessions)
              ..where((s) => s.skillId.equals(skillId))
              ..orderBy([
                (s) => OrderingTerm.desc(s.endedAtUtc),
                (s) => OrderingTerm.asc(s.id),
              ]))
            .watch(),
  );

  Future<Session> createDraft(
    String skillId, {
    EntryMode mode = EntryMode.timed,
    ManualIntent? manualIntent,
    String? localDisplayZone,
  }) => guardLocal(() async {
    if ((mode == EntryMode.manual) != (manualIntent != null)) {
      throw const LocalFailure(LocalFailureKind.invalid);
    }
    final now = utcNow();
    return _db
        .into(_db.sessions)
        .insertReturning(
          SessionsCompanion.insert(
            id: newId(),
            skillId: skillId,
            entryMode: mode.name,
            status: 'draft',
            manualIntent: Value(manualIntent?.stored),
            localDisplayZone: Value(localDisplayZone),
            createdAtUtc: now,
            updatedAtUtc: now,
          ),
        );
  });

  /// Optimistic revision prevents stale screens/racing actions from losing data.
  /// This persists domain intent; M06 supplies monotonic clock/checkpoint logic.
  Future<Session> save(Session value, {required int expectedRevision}) =>
      guardLocal(
        () => _db.transaction(() async {
          validText(value.note);
          validText(value.whatGotEasier);
          validText(value.nextStep, maximum: 10000);
          final next = value.copyWith(
            updatedAtUtc: utcNow(),
            revision: expectedRevision + 1,
          );
          final count =
              await (_db.update(_db.sessions)..where(
                    (s) =>
                        s.id.equals(value.id) &
                        s.revision.equals(expectedRevision),
                  ))
                  .write(next.toCompanion(false));
          if (count != 1) throw const LocalFailure(LocalFailureKind.conflict);
          return (await find(value.id))!;
        }),
      );

  Future<void> replaceExercises(
    String sessionId,
    List<SessionExercise> snapshots,
  ) => guardLocal(
    () => _db.transaction(() async {
      if (await find(sessionId) == null)
        throw const LocalFailure(LocalFailureKind.notFound);
      if (snapshots.any((e) => e.sessionId != sessionId) ||
          snapshots.map((e) => e.ordinal).toSet().length != snapshots.length) {
        throw const LocalFailure(LocalFailureKind.invalid);
      }
      await (_db.delete(
        _db.sessionExercises,
      )..where((e) => e.sessionId.equals(sessionId))).go();
      for (final snapshot in snapshots) {
        validName(snapshot.exerciseTitleSnapshot, maximum: 120);
        validText(snapshot.resultNote);
        await _db.into(_db.sessionExercises).insert(snapshot);
      }
    }),
  );

  Future<List<SessionExercise>> exercises(String sessionId) => guardLocal(
    () =>
        (_db.select(_db.sessionExercises)
              ..where((e) => e.sessionId.equals(sessionId))
              ..orderBy([(e) => OrderingTerm.asc(e.ordinal)]))
            .get(),
  );

  Future<void> deleteConfirmed(String id) => guardLocal(
    () => _db.transaction(() async {
      requireChanged(
        await (_db.delete(_db.sessions)..where((s) => s.id.equals(id))).go(),
      );
    }),
  );
}
