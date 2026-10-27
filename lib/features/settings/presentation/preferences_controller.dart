import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/preferences.dart';

final preferencesRepositoryProvider = Provider<PreferencesRepository>(
  (ref) =>
      throw StateError('Preferences repository must be provided at bootstrap'),
);
final initialPreferencesProvider = Provider<Preferences>(
  (ref) => const Preferences(),
);
final preferencesProvider =
    NotifierProvider<PreferencesController, PreferencesState>(
      PreferencesController.new,
    );

class PreferencesState {
  const PreferencesState(
    this.value, {
    this.saving = false,
    this.saveFailed = false,
  });
  final Preferences value;
  final bool saving;
  final bool saveFailed;
}

class PreferencesController extends Notifier<PreferencesState> {
  Preferences? _failedValue;

  @override
  PreferencesState build() =>
      PreferencesState(ref.read(initialPreferencesProvider));

  Future<bool> _persist(Preferences next) async {
    if (state.saving) return false;
    final previous = state.value;
    state = PreferencesState(previous, saving: true);
    try {
      await ref.read(preferencesRepositoryProvider).save(next);
      if (!ref.mounted) return false;
      _failedValue = null;
      state = PreferencesState(next);
      return true;
    } on Object {
      if (!ref.mounted) return false;
      _failedValue = next;
      state = PreferencesState(previous, saveFailed: true);
      return false;
    }
  }

  Future<bool> setAppearance(Appearance appearance) =>
      _persist(state.value.copyWith(appearance: appearance));

  Future<bool> completeOnboarding() =>
      _persist(state.value.copyWith(onboardingSeen: true));

  Future<bool> retry() async =>
      _failedValue == null ? false : _persist(_failedValue!);
}
