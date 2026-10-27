import 'dart:convert';

import 'database/loop_database.dart';
import 'local_failure.dart';
import 'validation.dart';

class SettingsRepository {
  const SettingsRepository(this._db);
  final LoopDatabase _db;

  Future<Object?> read(String key) => guardLocal(() async {
    final row = await (_db.select(
      _db.settings,
    )..where((s) => s.key.equals(key))).getSingleOrNull();
    if (row == null) return null;
    try {
      return jsonDecode(row.valueJson);
    } on FormatException {
      throw const LocalFailure(LocalFailureKind.corrupt);
    }
  });

  Future<void> putAll(Map<String, Object?> values) => guardLocal(
    () => _db.transaction(() async {
      for (final entry in values.entries) {
        String text;
        try {
          text = jsonEncode(entry.value);
        } on Object {
          throw const LocalFailure(LocalFailureKind.invalid);
        }
        if (utf8.encode(text).length > 65536)
          throw const LocalFailure(LocalFailureKind.invalid);
        await _db
            .into(_db.settings)
            .insertOnConflictUpdate(
              SettingsCompanion.insert(
                key: entry.key,
                valueJson: text,
                updatedAtUtc: utcNow(),
              ),
            );
      }
    }),
  );

  Future<void> remove(String key) => guardLocal(() async {
    await (_db.delete(_db.settings)..where((s) => s.key.equals(key))).go();
  });
}
