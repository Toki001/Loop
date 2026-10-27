import 'package:drift/drift.dart';

import '../../../core/data/database/loop_database.dart';
import '../../../core/data/local_failure.dart';
import '../../../core/data/validation.dart';

class MetricsRepository {
  const MetricsRepository(this._db);
  final LoopDatabase _db;

  void _validate(MetricDefinitionsCompanion value) {
    validName(value.label.value, maximum: 120);
    validName(value.unitKey.value, maximum: 80);
    finite(value.targetValue.value);
    finite(value.scaleMin.value);
    finite(value.scaleMax.value);
  }

  Future<MetricDefinition> create(MetricDefinitionsCompanion value) =>
      guardLocal(() async {
        _validate(value);
        return _db
            .into(_db.metricDefinitions)
            .insertReturning(
              value.copyWith(id: Value(newId()), version: const Value(1)),
            );
      });

  Future<MetricDefinition> newVersion(
    MetricDefinitionsCompanion value, {
    required String id,
    required int previousVersion,
  }) => guardLocal(
    () => _db.transaction(() async {
      _validate(value);
      final latest =
          await (_db.select(_db.metricDefinitions)
                ..where((d) => d.id.equals(id))
                ..orderBy([(d) => OrderingTerm.desc(d.version)])
                ..limit(1))
              .getSingleOrNull();
      if (latest == null) throw const LocalFailure(LocalFailureKind.notFound);
      if (latest.version != previousVersion)
        throw const LocalFailure(LocalFailureKind.conflict);
      return _db
          .into(_db.metricDefinitions)
          .insertReturning(
            value.copyWith(id: Value(id), version: Value(previousVersion + 1)),
          );
    }),
  );

  Future<List<MetricDefinition>> definitions(
    String skillId, {
    bool includeArchived = false,
  }) => guardLocal(
    () =>
        (_db.select(_db.metricDefinitions)
              ..where(
                (d) =>
                    d.skillId.equals(skillId) &
                    (includeArchived
                        ? const Constant(true)
                        : d.archivedAtUtc.isNull()),
              )
              ..orderBy([
                (d) => OrderingTerm.asc(d.id),
                (d) => OrderingTerm.asc(d.version),
              ]))
            .get(),
  );

  Future<void> setArchived(String id, int version, bool archived) =>
      guardLocal(() async {
        requireChanged(
          await (_db.update(
            _db.metricDefinitions,
          )..where((d) => d.id.equals(id) & d.version.equals(version))).write(
            MetricDefinitionsCompanion(
              archivedAtUtc: Value(archived ? utcNow() : null),
            ),
          ),
        );
      });

  Future<MetricReading> record(MetricReadingsCompanion value) =>
      guardLocal(() async {
        finite(value.numericValue.value);
        validText(value.textValue.value);
        validText(value.sourceNote.value, maximum: 10000);
        return _db
            .into(_db.metricReadings)
            .insertReturning(
              value.copyWith(id: Value(newId()), createdAtUtc: Value(utcNow())),
            );
      });

  Future<void> edit(MetricReading value) => guardLocal(() async {
    finite(value.numericValue);
    validText(value.textValue);
    validText(value.sourceNote, maximum: 10000);
    requireChanged(
      await (_db.update(_db.metricReadings)..where(
            (r) =>
                r.id.equals(value.id) &
                r.sessionId.equals(value.sessionId) &
                r.metricDefinitionId.equals(value.metricDefinitionId) &
                r.definitionVersion.equals(value.definitionVersion),
          ))
          .write(
            MetricReadingsCompanion(
              numericValue: Value(value.numericValue),
              textValue: Value(value.textValue),
              boolValue: Value(value.boolValue),
              sourceType: Value(value.sourceType),
              sourceNote: Value(value.sourceNote),
              measuredAtUtc: Value(value.measuredAtUtc),
            ),
          ),
    );
  });

  Future<List<MetricReading>> readings(String sessionId) => guardLocal(
    () => (_db.select(
      _db.metricReadings,
    )..where((r) => r.sessionId.equals(sessionId))).get(),
  );

  Future<void> deleteReading(String id) => guardLocal(() async {
    requireChanged(
      await (_db.delete(
        _db.metricReadings,
      )..where((r) => r.id.equals(id))).go(),
    );
  });
}
