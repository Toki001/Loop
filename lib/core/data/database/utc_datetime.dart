import 'package:drift/drift.dart';

/// SQLite stores UTC epoch seconds; Drift otherwise returns local DateTime.
/// Keep repository DTO timestamps explicitly UTC across timezone changes.
class UtcDateTimeConverter extends TypeConverter<DateTime, DateTime> {
  const UtcDateTimeConverter();
  @override
  DateTime fromSql(DateTime fromDb) => fromDb.toUtc();
  @override
  DateTime toSql(DateTime value) => value.toUtc();
}
