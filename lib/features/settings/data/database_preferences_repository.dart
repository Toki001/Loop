import 'dart:io';

import '../../../core/data/database/loop_database.dart';
import '../../../core/data/local_failure.dart';
import '../../../core/data/settings_repository.dart';
import '../../../core/data/validation.dart';
import '../domain/preferences.dart';
import 'file_preferences_repository.dart';

/// The legacy file is retained unchanged. The import marker and values commit
/// together, so interruption/retry never overwrites later SQL preferences.
class DatabasePreferencesRepository implements PreferencesRepository {
  DatabasePreferencesRepository(this._db, this.legacyDirectory)
    : _settings = SettingsRepository(_db);
  final LoopDatabase _db;
  final SettingsRepository _settings;
  final Directory legacyDirectory;

  Future<void> importLegacy() async {
    try {
      await _db.transaction(() async {
        final imported =
            await (_db.select(_db.settings)
                  ..where((s) => s.key.equals('m03PreferencesImported')))
                .getSingleOrNull();
        if (imported != null) return;
        // Loading may raise a typed legacy preference error. Bootstrap can offer
        // its narrowly scoped, copy-preserving reset; the database is never reset.
        final preferences = await FilePreferencesRepository(legacyDirectory)
            .load();
        // An internal prior SQLite schema may already own a setting. Never replace
        // it with a legacy-file default merely because its import marker is absent.
        final missing = <String, Object?>{};
        for (final entry in _values(preferences).entries) {
          final existing = await (_db.select(
            _db.settings,
          )..where((s) => s.key.equals(entry.key))).getSingleOrNull();
          if (existing == null) missing[entry.key] = entry.value;
        }
        await _settings.putAll(missing);
        await _db
            .into(_db.settings)
            .insert(
              SettingsCompanion.insert(
                key: 'm03PreferencesImported',
                valueJson: 'true',
                updatedAtUtc: utcNow(),
              ),
            );
      });
    } on PreferencesFailure {
      rethrow;
    } on Object catch (error) {
      throw localFailure(error);
    }
  }

  Map<String, Object?> _values(Preferences value) => {
    'theme': value.appearance.name,
    'onboardingVersion': value.onboardingSeen ? 1 : 0,
    'legacyPreferenceExtensions': value.extensions,
  };

  Future<void> _save(Preferences value) => _settings.putAll(_values(value));

  @override
  Future<Preferences> load() async {
    final theme = await _settings.read('theme');
    final onboarding = await _settings.read('onboardingVersion');
    final extensions = await _settings.read('legacyPreferenceExtensions');
    if (theme is! String ||
        !Appearance.values.any((a) => a.name == theme) ||
        onboarding is! int ||
        onboarding < 0 ||
        extensions is! Map<String, dynamic>) {
      throw const LocalFailure(LocalFailureKind.corrupt);
    }
    return Preferences(
      appearance: Appearance.values.byName(theme),
      onboardingSeen: onboarding > 0,
      extensions: Map.unmodifiable(extensions),
    );
  }

  @override
  Future<void> save(Preferences value) => _save(value);

  @override
  Future<void> resetCorruptPreferences() async {
    // SQL settings damage is a storage recovery case, not legacy-file reset.
    throw const LocalFailure(LocalFailureKind.corrupt);
  }
}
