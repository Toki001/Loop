import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'app/app.dart';
import 'app/l10n/app_localizations.dart';
import 'core/data/local_failure.dart';
import 'core/data/storage.dart';
import 'core/data/storage_protection.dart';
import 'features/practice/presentation/practice_providers.dart';
import 'features/practice/domain/practice_engine.dart';
import 'features/settings/data/file_preferences_repository.dart';
import 'features/settings/domain/preferences.dart';
import 'features/settings/presentation/preferences_controller.dart';
import 'shared/design_system/components.dart';
import 'shared/design_system/tokens.dart';

class BootstrapHost extends StatefulWidget {
  const BootstrapHost({super.key, this.directoryProvider});
  final Future<Directory> Function()? directoryProvider;

  @override
  State<BootstrapHost> createState() => _BootstrapHostState();
}

sealed class _BootstrapResult {
  const _BootstrapResult();
}

class _BootstrapData extends _BootstrapResult {
  const _BootstrapData(this.storage, this.preferences);
  final LoopStorage storage;
  final Preferences preferences;
}

class _BootstrapFailure extends _BootstrapResult {
  const _BootstrapFailure(this.kind, {this.legacy = false});
  final LocalFailureKind kind;
  final bool legacy;
}

class _BootstrapHostState extends State<BootstrapHost> {
  late Future<_BootstrapResult> _loading = _load();
  FilePreferencesRepository? _legacyRepository;
  LoopStorage? _storage;
  PracticeEngine? _practiceEngine;

  Future<void> _closeStorage() async {
    final storage = _storage;
    final engine = _practiceEngine;
    _storage = null;
    _practiceEngine = null;
    // Provider disposal stops new work. Existing transactions must finish before
    // their database is closed, including recovery during the first frame.
    await engine?.idle;
    await storage?.close();
  }

  bool _resetting = false;
  bool _resetFailed = false;

  Future<_BootstrapResult> _load() async {
    _legacyRepository = null;
    try {
      await _closeStorage();
      final directory =
          await (widget.directoryProvider?.call() ??
              getApplicationSupportDirectory());
      _legacyRepository = FilePreferencesRepository(directory);
      await const StorageProtection().configure();
      final storage = await LoopStorage.open(directory);
      try {
        final preferences = await storage.preferences.load();
        if (!mounted) {
          await storage.close();
          return const _BootstrapFailure(LocalFailureKind.unavailable);
        }
        _storage = storage;
        return _BootstrapData(storage, preferences);
      } on Object {
        await storage.close();
        rethrow;
      }
    } on PreferencesFailure catch (failure) {
      return _BootstrapFailure(switch (failure.kind) {
        PreferencesFailureKind.corrupt => LocalFailureKind.corrupt,
        PreferencesFailureKind.unsupportedVersion =>
          LocalFailureKind.unsupportedVersion,
        PreferencesFailureKind.unavailable => LocalFailureKind.unavailable,
      }, legacy: true);
    } on Object catch (error) {
      // Map typed failures without rendering raw SQL, paths or user content.
      return _BootstrapFailure(localFailure(error).kind);
    }
  }

  void _retry() => setState(() {
    _loading = _load();
    _resetFailed = false;
  });

  Future<void> _reset() async {
    if (_resetting || _legacyRepository == null) return;
    setState(() => _resetting = true);
    try {
      await _legacyRepository!.resetCorruptPreferences();
      if (!mounted) return;
      setState(() {
        _loading = _load();
        _resetFailed = false;
        _resetting = false;
      });
    } on Object {
      if (mounted)
        setState(() {
          _resetFailed = true;
          _resetting = false;
        });
    }
  }

  @override
  void dispose() {
    unawaited(_closeStorage());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<_BootstrapResult>(
    future: _loading,
    builder: (context, snapshot) {
      final data = snapshot.connectionState == ConnectionState.done
          ? snapshot.data
          : null;
      if (data is _BootstrapData) {
        return ProviderScope(
          overrides: [
            storageProvider.overrideWithValue(data.storage),
            preferencesRepositoryProvider.overrideWithValue(
              data.storage.preferences,
            ),
            initialPreferencesProvider.overrideWithValue(data.preferences),
          ],
          child: PracticeLifecycleHost(
            onEngineReady: (engine) => _practiceEngine = engine,
            child: const LoopApp(),
          ),
        );
      }
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: LoopTheme.build(Brightness.light),
        darkTheme: LoopTheme.build(Brightness.dark),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            final strings = AppLocalizations.of(context)!;
            final kind = data is _BootstrapFailure ? data.kind : null;
            return LoopScaffold(
              children: [
                LoopNotice(
                  title: kind != null
                      ? data is _BootstrapFailure && data.legacy
                            ? strings.recoveryTitle
                            : strings.storageRecoveryTitle
                      : strings.openingTitle,
                  message: kind != null
                      ? kind == LocalFailureKind.unsupportedVersion
                            ? strings.unsupportedStorage
                            : data is _BootstrapFailure && data.legacy
                            ? strings.recoveryBody
                            : strings.storageRecoveryBody
                      : strings.openingBody,
                  icon: kind != null
                      ? Icons.error_outline
                      : Icons.hourglass_empty,
                  action: kind != null
                      ? LoopButton(
                          label: strings.retry,
                          onPressed: _resetting ? null : _retry,
                        )
                      : null,
                ),
                if (kind == LocalFailureKind.corrupt &&
                    data is _BootstrapFailure &&
                    data.legacy)
                  LoopButton(
                    label: strings.resetPreferences,
                    kind: LoopButtonKind.secondary,
                    busy: _resetting,
                    onPressed: _reset,
                  ),
                if (_resetFailed) Text(strings.resetFailed),
              ],
            );
          },
        ),
      );
    },
  );
}
