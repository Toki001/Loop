import 'dart:convert';
import 'dart:io';

import '../domain/preferences.dart';

/// Versioned, atomic bootstrap preferences. Journal data never lives in this file.
/// M04 will preserve/migrate this contract when the settings table is introduced.
class FilePreferencesRepository implements PreferencesRepository {
  FilePreferencesRepository(this.directory);
  final Directory directory;
  Future<void> _pending = Future<void>.value();
  File get _file => File('${directory.path}/preferences.json');
  File get _temporary => File('${directory.path}/preferences.json.tmp');

  Future<void> _ordinary(File file) async {
    final type = await FileSystemEntity.type(file.path, followLinks: false);
    if (type != FileSystemEntityType.notFound &&
        type != FileSystemEntityType.file) {
      throw const PreferencesFailure(PreferencesFailureKind.unavailable);
    }
  }

  @override
  Future<Preferences> load() async {
    try {
      await _ordinary(_file);
      if (!await _file.exists()) return const Preferences();
      if (await _file.length() > 65536) {
        throw const PreferencesFailure(PreferencesFailureKind.corrupt);
      }
      final Object? decoded = jsonDecode(await _file.readAsString());
      if (decoded is! Map<String, dynamic>) {
        throw const PreferencesFailure(PreferencesFailureKind.corrupt);
      }
      final schema = decoded['schema'];
      if (schema is! int) {
        throw const PreferencesFailure(PreferencesFailureKind.corrupt);
      }
      if (schema != 1) {
        throw const PreferencesFailure(
          PreferencesFailureKind.unsupportedVersion,
        );
      }
      final theme = decoded['appearance'];
      final seen = decoded['onboardingSeen'];
      if (theme is! String ||
          seen is! bool ||
          !Appearance.values.any((value) => value.name == theme)) {
        throw const PreferencesFailure(PreferencesFailureKind.corrupt);
      }
      // Validate that unknown fields remain portable JSON before preserving them.
      jsonEncode(decoded);
      return Preferences(
        appearance: Appearance.values.byName(theme),
        onboardingSeen: seen,
        extensions: Map.unmodifiable({
          for (final entry in decoded.entries)
            if (!{'schema', 'appearance', 'onboardingSeen'}.contains(entry.key))
              entry.key: entry.value,
        }),
      );
    } on PreferencesFailure {
      rethrow;
    } on FormatException {
      throw const PreferencesFailure(PreferencesFailureKind.corrupt);
    } on JsonUnsupportedObjectError {
      throw const PreferencesFailure(PreferencesFailureKind.corrupt);
    } on FileSystemException {
      throw const PreferencesFailure(PreferencesFailureKind.unavailable);
    }
  }

  Future<void> _serialize(Future<void> Function() action) {
    final next = _pending
        .onError((Object _, StackTrace __) {})
        .then((_) => action());
    _pending = next;
    return next;
  }

  Future<void> _write(Preferences value) async {
    try {
      await directory.create(recursive: true);
      await _ordinary(_file);
      await _ordinary(_temporary);
      final text = jsonEncode({
        ...value.extensions,
        'schema': 1,
        'appearance': value.appearance.name,
        'onboardingSeen': value.onboardingSeen,
      });
      if (utf8.encode(text).length > 65536) {
        throw const PreferencesFailure(PreferencesFailureKind.unavailable);
      }
      await _temporary.writeAsString(text, flush: true);
      await _temporary.rename(_file.path);
    } on PreferencesFailure {
      rethrow;
    } on FileSystemException {
      throw const PreferencesFailure(PreferencesFailureKind.unavailable);
    } on JsonUnsupportedObjectError {
      throw const PreferencesFailure(PreferencesFailureKind.unavailable);
    }
  }

  @override
  Future<void> save(Preferences value) => _serialize(() => _write(value));

  @override
  Future<void> resetCorruptPreferences() => _serialize(() async {
    try {
      await load();
      return; // Another attempt may already have repaired the preferences.
    } on PreferencesFailure catch (failure) {
      if (failure.kind != PreferencesFailureKind.corrupt) rethrow;
    }
    try {
      final recovery =
          '${directory.path}/preferences-recovery-${DateTime.now().toUtc().microsecondsSinceEpoch}.json';
      await _file.copy(recovery);
      await _write(const Preferences());
    } on FileSystemException {
      throw const PreferencesFailure(PreferencesFailureKind.unavailable);
    }
  });
}
