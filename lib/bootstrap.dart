import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'app/app.dart';
import 'app/l10n/app_localizations.dart';
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
  const _BootstrapData(this.repository, this.preferences);
  final FilePreferencesRepository repository;
  final Preferences preferences;
}

class _BootstrapFailure extends _BootstrapResult {
  const _BootstrapFailure(this.kind);
  final PreferencesFailureKind kind;
}

class _BootstrapHostState extends State<BootstrapHost> {
  late Future<_BootstrapResult> _loading = _load();
  FilePreferencesRepository? _repository;
  bool _resetting = false;
  bool _resetFailed = false;

  Future<_BootstrapResult> _load() async {
    _repository = null;
    try {
      final directory =
          await (widget.directoryProvider?.call() ??
              getApplicationSupportDirectory());
      final repository = FilePreferencesRepository(directory);
      _repository = repository;
      return _BootstrapData(repository, await repository.load());
    } on PreferencesFailure catch (failure) {
      return _BootstrapFailure(failure.kind);
    } on Object {
      return const _BootstrapFailure(PreferencesFailureKind.unavailable);
    }
  }

  void _retry() => setState(() {
    _loading = _load();
    _resetFailed = false;
  });

  Future<void> _reset() async {
    if (_resetting || _repository == null) return;
    setState(() => _resetting = true);
    try {
      await _repository!.resetCorruptPreferences();
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
  Widget build(BuildContext context) => FutureBuilder<_BootstrapResult>(
    future: _loading,
    builder: (context, snapshot) {
      final data = snapshot.data;
      if (data is _BootstrapData) {
        return ProviderScope(
          overrides: [
            preferencesRepositoryProvider.overrideWithValue(data.repository),
            initialPreferencesProvider.overrideWithValue(data.preferences),
          ],
          child: const LoopApp(),
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
                      ? strings.recoveryTitle
                      : strings.openingTitle,
                  message: kind != null
                      ? kind == PreferencesFailureKind.unsupportedVersion
                            ? strings.unsupportedPreferences
                            : strings.recoveryBody
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
                if (kind == PreferencesFailureKind.corrupt)
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
