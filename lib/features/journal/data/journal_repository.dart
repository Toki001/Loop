import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/data/database/loop_database.dart';
import '../../../core/data/local_failure.dart';
import '../../../core/data/validation.dart';
import '../../practice/data/practice_repository.dart';
import '../../practice/data/sessions_repository.dart';
import '../../progress/data/metrics_repository.dart';
import '../domain/journal_entry.dart';

class JournalRepository {
  JournalRepository(this.database, {PracticeRepository? practice})
    : practice = practice ?? PracticeRepository(database),
      sessions = SessionsRepository(database),
      metrics = MetricsRepository(database);
  final LoopDatabase database;
  final PracticeRepository practice;
  final SessionsRepository sessions;
  final MetricsRepository metrics;

  Stream<JournalOverview> watchOverview() => guardLocalStream(
    () => database
        .customSelect(
          "SELECT COUNT(*) AS total, COALESCE(SUM(active_seconds), 0) AS seconds FROM sessions WHERE status = 'completed'",
          readsFrom: {database.sessions},
        )
        .watchSingle()
        .map(
          (row) => JournalOverview(
            sessions: row.read<int>('total'),
            seconds: row.read<int>('seconds'),
          ),
        ),
  );

  Stream<List<Skill>> watchSkills() => guardLocalStream(
    () =>
        (database.select(database.skills)..orderBy([
              (s) => OrderingTerm.asc(s.name),
              (s) => OrderingTerm.asc(s.id),
            ]))
            .watch(),
  );

  Future<JournalDetail?> find(String id) => guardLocal(
    () => database.transaction(() async {
      final session = await sessions.find(id);
      if (session == null) return null;
      final skill = await (database.select(
        database.skills,
      )..where((s) => s.id.equals(session.skillId))).getSingle();
      return JournalDetail(
        session: session,
        skill: skill,
        exercises: await sessions.exercises(id),
        readings: await metrics.readings(id),
        definitions: await metrics.definitions(
          session.skillId,
          includeArchived: true,
        ),
        mediaCount: (await (database.select(
          database.mediaAssets,
        )..where((m) => m.sessionId.equals(id))).get()).length,
      );
    }),
  );

  Stream<JournalDetail?> watchDetail(String id) => guardLocalStream(
    () => database
        .customSelect(
          'SELECT id FROM sessions WHERE id = ?',
          variables: [Variable.withString(id)],
          readsFrom: {
            database.sessions,
            database.skills,
            database.sessionExercises,
            database.metricReadings,
            database.metricDefinitions,
            database.mediaAssets,
          },
        )
        .watch()
        .asyncMap((_) => find(id)),
  );

  Stream<List<JournalSummary>> watchTimeline(
    JournalFilter filter,
  ) => guardLocalStream(() {
    if (filter.limit < 1 ||
        filter.limit > 1000 ||
        filter.fromUtc != null &&
            filter.untilUtc != null &&
            !filter.fromUtc!.isBefore(filter.untilUtc!)) {
      throw const LocalFailure(LocalFailureKind.invalid);
    }
    final s = database.sessions;
    final k = database.skills;
    final query = database.select(s).join([
      innerJoin(k, k.id.equalsExp(s.skillId)),
    ])..where(s.status.equals('completed'));
    if (filter.skillId != null) query.where(s.skillId.equals(filter.skillId!));
    if (filter.fromUtc != null)
      query.where(s.endedAtUtc.isBiggerOrEqualValue(filter.fromUtc!));
    if (filter.untilUtc != null)
      query.where(s.endedAtUtc.isSmallerThanValue(filter.untilUtc!));
    if (filter.exerciseTitle != null) {
      final e = database.sessionExercises;
      query.where(
        s.id.isInQuery(
          database.selectOnly(e)
            ..addColumns([e.sessionId])
            ..where(e.exerciseTitleSnapshot.equals(filter.exerciseTitle!)),
        ),
      );
    }
    query.orderBy([OrderingTerm.desc(s.endedAtUtc), OrderingTerm.asc(s.id)]);
    query.limit(filter.limit);
    return query.watch().map(
      (rows) => [
        for (final row in rows)
          JournalSummary(row.readTable(s), row.readTable(k).name),
      ],
    );
  });

  Stream<List<String>> watchExerciseTitles({String? skillId}) =>
      guardLocalStream(() {
        final e = database.sessionExercises;
        final s = database.sessions;
        final query = database.selectOnly(e, distinct: true)
          ..addColumns([e.exerciseTitleSnapshot])
          ..join([innerJoin(s, s.id.equalsExp(e.sessionId))])
          ..where(s.status.equals('completed'));
        if (skillId != null) query.where(s.skillId.equals(skillId));
        query.orderBy([OrderingTerm.asc(e.exerciseTitleSnapshot)]);
        return query.watch().map(
          (rows) => [
            for (final row in rows) row.read(e.exerciseTitleSnapshot)!,
          ],
        );
      });

  Session _reflected(Session session, JournalReflection value) =>
      session.copyWith(
        note: Value(value.note),
        whatGotEasier: Value(value.whatGotEasier),
        nextStep: Value(value.nextStep),
        effortRating: Value(value.effortRating),
      );

  Future<void> _replaceReadings(
    Session session,
    JournalReflection input,
  ) async {
    final prior = await metrics.readings(session.id);
    final definitions = await metrics.definitions(
      session.skillId,
      includeArchived: true,
    );
    for (final reading in input.readings) {
      final definition = definitions
          .where(
            (d) => d.id == reading.definitionId && d.version == reading.version,
          )
          .firstOrNull;
      if (definition == null || !validJournalReading(reading, definition))
        throw const LocalFailure(LocalFailureKind.invalid);
      final old = prior
          .where((r) => r.metricDefinitionId == reading.definitionId)
          .firstOrNull;
      // M07 user entry cannot invent imported/instrument or derived provenance.
      if (reading.sourceType != 'self_reported' &&
          (old == null || !reading.matches(old))) {
        throw const LocalFailure(LocalFailureKind.invalid);
      }
    }
    await (database.delete(
      database.metricReadings,
    )..where((r) => r.sessionId.equals(session.id))).go();
    for (final reading in input.readings) {
      final old = prior
          .where((r) => r.metricDefinitionId == reading.definitionId)
          .firstOrNull;
      await database
          .into(database.metricReadings)
          .insert(
            MetricReadingsCompanion.insert(
              id: old?.id ?? newId(),
              sessionId: session.id,
              metricDefinitionId: reading.definitionId,
              definitionVersion: reading.version,
              numericValue: Value(reading.numericValue),
              textValue: Value(reading.textValue),
              boolValue: Value(reading.boolValue),
              sourceType: reading.sourceType,
              sourceNote: Value(reading.sourceNote),
              measuredAtUtc: old?.measuredAtUtc ?? session.endedAtUtc!,
              createdAtUtc: old?.createdAtUtc ?? utcNow(),
            ),
          );
    }
  }

  Future<PracticeRecord> complete(
    Session value, {
    required int milliseconds,
    required JournalReflection reflection,
    int? manualSeconds,
    String? manualDateLocal,
  }) => guardLocal(
    () => database.transaction(() async {
      reflection.validate();
      final current = await sessions.find(value.id);
      if (current == null) throw const LocalFailure(LocalFailureKind.notFound);
      if (current.status == 'completed') {
        if (!reflection.matches(current, await metrics.readings(value.id)) ||
            milliseconds != (await practice.find(value.id))!.milliseconds ||
            current.entryMode == 'manual' &&
                (value.endedAtUtc?.millisecondsSinceEpoch ?? -1000) ~/ 1000 !=
                    current.endedAtUtc!.millisecondsSinceEpoch ~/ 1000)
          throw const LocalFailure(LocalFailureKind.conflict);
        return (await practice.find(value.id))!;
      }
      if (value.status != 'completed' ||
          !['draft', 'running', 'paused'].contains(current.status) ||
          current.entryMode == 'timed' &&
              !['running', 'paused'].contains(current.status) ||
          current.skillId != value.skillId ||
          current.entryMode != value.entryMode) {
        throw const LocalFailure(LocalFailureKind.invalid);
      }
      final saved = await practice.write(
        _reflected(value, reflection),
        milliseconds: milliseconds,
        manualSeconds: manualSeconds,
        manualDateLocal: manualDateLocal,
      );
      await _replaceReadings(saved.session, reflection);
      await clearDrafts(value.id);
      return saved;
    }),
  );

  Future<Session> amend(
    String id, {
    required int expectedRevision,
    required JournalReflection reflection,
    ManualJournalAmendment? manual,
  }) => guardLocal(
    () => database.transaction(() async {
      reflection.validate();
      final current = await sessions.find(id);
      if (current == null) throw const LocalFailure(LocalFailureKind.notFound);
      if (current.status != 'completed')
        throw const LocalFailure(LocalFailureKind.invalid);
      var value = _reflected(current, reflection);
      if (manual != null) {
        final end = DateTime.fromMillisecondsSinceEpoch(
          manual.endedAtUtc.millisecondsSinceEpoch ~/ 1000 * 1000,
          isUtc: true,
        );
        if (!manual.confirmed ||
            current.entryMode != 'manual' ||
            manual.seconds < 0 ||
            manual.seconds > 604800 ||
            end.isAfter(utcNow()) ||
            end.toLocal().year < 1900 ||
            (current.manualIntent == 'evidence_only') !=
                (manual.seconds == 0)) {
          throw const LocalFailure(LocalFailureKind.invalid);
        }
        value = value.copyWith(
          activeSeconds: manual.seconds,
          endedAtUtc: Value(end),
          startedAtUtc: Value(end.subtract(Duration(seconds: manual.seconds))),
        );
      }
      final same =
          reflection.matches(current, await metrics.readings(id)) &&
          value.activeSeconds == current.activeSeconds &&
          value.endedAtUtc == current.endedAtUtc;
      if (current.revision != expectedRevision) {
        if (same) {
          await clearDrafts(id);
          return current; // Identical retry after a lost response.
        }
        throw const LocalFailure(LocalFailureKind.conflict);
      }
      if (same) {
        await clearDrafts(id);
        return current;
      }
      final saved = await sessions.save(
        value,
        expectedRevision: expectedRevision,
      );
      if (manual != null) {
        await (database.update(
          database.practiceCheckpoints,
        )..where((c) => c.sessionId.equals(id))).write(
          PracticeCheckpointsCompanion(
            activeMilliseconds: Value(manual.seconds * 1000),
            manualSeconds: Value(manual.seconds),
            manualDateLocal: Value(
              manual.endedAtUtc.toLocal().toIso8601String().substring(0, 10),
            ),
            checkpointAtUtc: Value(utcNow()),
          ),
        );
      }
      await _replaceReadings(saved, reflection);
      await clearDrafts(id);
      return saved;
    }),
  );

  Future<JournalDraft?> draft(String id, String purpose) => guardLocal(
    () =>
        (database.select(
              database.journalDrafts,
            )..where((d) => d.sessionId.equals(id) & d.purpose.equals(purpose)))
            .getSingleOrNull(),
  );

  Future<void> saveDraft({
    required String sessionId,
    required String purpose,
    required int baseRevision,
    required Map<String, Object?> form,
  }) => guardLocal(
    () => database.transaction(() async {
      final raw = jsonEncode(form);
      final session = await sessions.find(sessionId);
      if (session == null) throw const LocalFailure(LocalFailureKind.notFound);
      if (!['finish', 'edit'].contains(purpose) ||
          baseRevision < 0 ||
          raw.length > 500000 ||
          form['version'] != 1 ||
          (purpose == 'edit'
              ? session.status != 'completed'
              : !['draft', 'paused'].contains(session.status))) {
        throw const LocalFailure(LocalFailureKind.invalid);
      }
      await database
          .into(database.journalDrafts)
          .insertOnConflictUpdate(
            JournalDraftsCompanion.insert(
              sessionId: sessionId,
              purpose: purpose,
              baseRevision: baseRevision,
              formJson: raw,
              updatedAtUtc: utcNow(),
            ),
          );
    }),
  );

  Future<void> clearDrafts(String id) => guardLocal(() async {
    await (database.delete(
      database.journalDrafts,
    )..where((d) => d.sessionId.equals(id))).go();
  });

  Future<DeletedJournalEntry> deleteConfirmed(
    String id, {
    required int expectedRevision,
  }) => guardLocal(
    () => database.transaction(() async {
      final detail = await find(id);
      if (detail == null) throw const LocalFailure(LocalFailureKind.notFound);
      if (detail.session.status != 'completed' ||
          detail.session.revision != expectedRevision)
        throw const LocalFailure(LocalFailureKind.conflict);
      final record = await practice.find(id);
      final receipt = DeletedJournalEntry(
        session: detail.session,
        exercises: detail.exercises,
        readings: detail.readings,
        checkpoint: record?.checkpoint,
        drafts: await (database.select(
          database.journalDrafts,
        )..where((d) => d.sessionId.equals(id))).get(),
        canUndo: detail.mediaCount == 0,
      );
      await sessions.deleteConfirmed(id);
      return receipt;
    }),
  );

  Future<void> undo(DeletedJournalEntry receipt) => guardLocal(
    () => database.transaction(() async {
      if (!receipt.canUndo || await sessions.find(receipt.session.id) != null)
        throw const LocalFailure(LocalFailureKind.conflict);
      await database
          .into(database.sessions)
          .insert(
            receipt.session.copyWith(
              revision: receipt.session.revision + 1,
              updatedAtUtc: utcNow(),
            ),
          );
      for (final snapshot in receipt.exercises) {
        final exerciseExists =
            snapshot.exerciseId != null &&
            await (database.select(database.exercises)
                      ..where((e) => e.id.equals(snapshot.exerciseId!)))
                    .getSingleOrNull() !=
                null;
        await database
            .into(database.sessionExercises)
            .insert(
              exerciseExists
                  ? snapshot
                  : snapshot.copyWith(exerciseId: const Value(null)),
            );
      }
      for (final reading in receipt.readings)
        await database.into(database.metricReadings).insert(reading);
      if (receipt.checkpoint != null)
        await database
            .into(database.practiceCheckpoints)
            .insert(receipt.checkpoint!);
      for (final draft in receipt.drafts)
        await database.into(database.journalDrafts).insert(draft);
    }),
  );
}
