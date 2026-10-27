import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/practice/data/sessions_repository.dart';
import '../../features/progress/data/metrics_repository.dart';
import '../../features/reminders/data/reminders_repository.dart';
import '../../features/settings/data/database_preferences_repository.dart';
import '../../features/skills/data/skills_repository.dart';
import '../media/media_repository.dart';
import '../media/private_files.dart';
import 'database/loop_database.dart';
import 'database/open_database.dart';
import 'settings_repository.dart';

final storageProvider = Provider<LoopStorage>(
  (ref) => throw StateError('Storage must be provided at bootstrap'),
);

class LoopStorage {
  LoopStorage._(this.database, this.files, Directory directory)
    : skills = SkillsRepository(database),
      sessions = SessionsRepository(database),
      metrics = MetricsRepository(database),
      reminders = RemindersRepository(database),
      settings = SettingsRepository(database),
      media = MediaRepository(database, files),
      preferences = DatabasePreferencesRepository(database, directory);

  final LoopDatabase database;
  final PrivateFiles files;
  final SkillsRepository skills;
  final SessionsRepository sessions;
  final MetricsRepository metrics;
  final RemindersRepository reminders;
  final SettingsRepository settings;
  final MediaRepository media;
  final DatabasePreferencesRepository preferences;
  ReconcileReport? reconciliation;

  static Future<LoopStorage> open(Directory directory) async {
    final files = await PrivateFiles.open(directory);
    final database = await openDatabase(files);
    final storage = LoopStorage._(database, files, directory);
    try {
      await storage.preferences.importLegacy();
      storage.reconciliation = await FileReconciler(database, files).run();
      return storage;
    } on Object {
      await storage.close();
      rethrow;
    }
  }

  Future<void> close() => database.close();
}
