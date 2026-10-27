enum Appearance { system, light, dark }

class Preferences {
  const Preferences({
    this.appearance = Appearance.system,
    this.onboardingSeen = false,
    this.extensions = const {},
  });

  final Appearance appearance;
  final bool onboardingSeen;
  final Map<String, Object?> extensions;

  Preferences copyWith({Appearance? appearance, bool? onboardingSeen}) =>
      Preferences(
        appearance: appearance ?? this.appearance,
        onboardingSeen: onboardingSeen ?? this.onboardingSeen,
        extensions: extensions,
      );
}

enum PreferencesFailureKind { corrupt, unsupportedVersion, unavailable }

class PreferencesFailure implements Exception {
  const PreferencesFailure(this.kind);
  final PreferencesFailureKind kind;

  @override
  String toString() => 'Local preferences failure: ${kind.name}';
}

abstract interface class PreferencesRepository {
  Future<Preferences> load();
  Future<void> save(Preferences value);
  Future<void> resetCorruptPreferences();
}
