import 'package:drift/drift.dart';

import '../../../core/data/database/loop_database.dart';
import '../../../core/data/local_failure.dart';
import '../../../core/data/validation.dart';

/// Persists reminder intent only. OS scheduling/permission belongs to M11.
class RemindersRepository {
  const RemindersRepository(this._db);
  final LoopDatabase _db;

  Stream<List<Reminder>> watch() => guardLocalStream(
    () =>
        (_db.select(_db.reminders)..orderBy([
              (r) => OrderingTerm.asc(r.localTimeHHmm),
              (r) => OrderingTerm.asc(r.id),
            ]))
            .watch(),
  );

  Future<Reminder> create(RemindersCompanion value) => guardLocal(
    () => _db
        .into(_db.reminders)
        .insertReturning(
          value.copyWith(id: Value(newId()), updatedAtUtc: Value(utcNow())),
        ),
  );

  Future<void> update(Reminder value) => guardLocal(() async {
    requireChanged(
      await (_db.update(_db.reminders)..where((r) => r.id.equals(value.id)))
          .write(value.copyWith(updatedAtUtc: utcNow()).toCompanion(false)),
    );
  });

  Future<void> delete(String id) => guardLocal(() async {
    requireChanged(
      await (_db.delete(_db.reminders)..where((r) => r.id.equals(id))).go(),
    );
  });
}
