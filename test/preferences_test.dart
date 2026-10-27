import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop/features/settings/data/file_preferences_repository.dart';
import 'package:loop/features/settings/domain/preferences.dart';
import 'package:loop/features/settings/presentation/preferences_controller.dart';

Matcher failure(PreferencesFailureKind kind) =>
    isA<PreferencesFailure>().having((value) => value.kind, 'kind', kind);

class ControlledPreferencesRepository implements PreferencesRepository {
  Preferences value = const Preferences();
  bool fail = false;
  Completer<void>? pending;
  int writes = 0;

  @override
  Future<Preferences> load() async => value;
  @override
  Future<void> save(Preferences next) async {
    writes++;
    await pending?.future;
    if (fail) {
      throw const PreferencesFailure(PreferencesFailureKind.unavailable);
    }
    value = next;
  }

  @override
  Future<void> resetCorruptPreferences() async => value = const Preferences();
}

void main() {
  late Directory directory;
  late File file;
  late FilePreferencesRepository repository;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('loop-preferences-test-');
    file = File('${directory.path}/preferences.json');
    repository = FilePreferencesRepository(directory);
  });
  tearDown(() async => directory.delete(recursive: true));

  test(
    'first install is empty and does not fabricate persisted records',
    () async {
      final preferences = await repository.load();
      expect(preferences.appearance, Appearance.system);
      expect(preferences.onboardingSeen, false);
      expect(preferences.extensions, isEmpty);
      expect(await directory.list().toList(), isEmpty);
    },
  );

  test(
    'atomic preferences survive a new repository/process boundary',
    () async {
      await repository.save(
        const Preferences(appearance: Appearance.dark, onboardingSeen: true),
      );
      final reopened = await FilePreferencesRepository(directory).load();
      expect(reopened.appearance, Appearance.dark);
      expect(reopened.onboardingSeen, true);
      expect(await File('${file.path}.tmp').exists(), false);
    },
  );

  test(
    'unknown version-one fields survive changing known preferences',
    () async {
      await file.writeAsString(
        jsonEncode({
          'schema': 1,
          'appearance': 'system',
          'onboardingSeen': false,
          'future': {
            'nested': ['保留', 2, null],
          },
        }),
      );
      final loaded = await repository.load();
      await repository.save(loaded.copyWith(appearance: Appearance.light));
      expect((jsonDecode(await file.readAsString()) as Map)['future'], {
        'nested': ['保留', 2, null],
      });
    },
  );

  test(
    'concurrent saves are serialized and latest complete value wins',
    () async {
      await Future.wait([
        repository.save(const Preferences(appearance: Appearance.light)),
        repository.save(const Preferences(appearance: Appearance.dark)),
        repository.save(const Preferences(onboardingSeen: true)),
      ]);
      final loaded = await repository.load();
      expect(loaded.appearance, Appearance.system);
      expect(loaded.onboardingSeen, true);
    },
  );

  for (final input in [
    '{',
    '[]',
    '{}',
    '{"schema":1,"appearance":"unknown","onboardingSeen":true}',
    '{"schema":1,"appearance":"dark","onboardingSeen":"yes"}',
    'x' * 65537,
  ]) {
    test(
      'invalid preferences fail without changing original (${input.length})',
      () async {
        await file.writeAsString(input);
        await expectLater(
          repository.load(),
          throwsA(failure(PreferencesFailureKind.corrupt)),
        );
        expect(await file.readAsString(), input);
      },
    );
  }

  test(
    'corrupt reset retains exact original and no other data is changed',
    () async {
      const original = '{damaged\n私';
      final journal = File('${directory.path}/unrelated-journal');
      await journal.writeAsString('keep');
      await file.writeAsString(original);
      await repository.resetCorruptPreferences();
      expect((await repository.load()).onboardingSeen, false);
      final backups = await directory
          .list()
          .where(
            (entry) =>
                entry.path.split('/').last.startsWith('preferences-recovery-'),
          )
          .toList();
      expect(backups, hasLength(1));
      expect(await File(backups.single.path).readAsString(), original);
      expect(await journal.readAsString(), 'keep');
    },
  );

  test('unsupported schema cannot be reset by an older app', () async {
    const original = '{"schema":2,"appearance":"dark","onboardingSeen":true}';
    await file.writeAsString(original);
    await expectLater(
      repository.load(),
      throwsA(failure(PreferencesFailureKind.unsupportedVersion)),
    );
    await expectLater(
      repository.resetCorruptPreferences(),
      throwsA(failure(PreferencesFailureKind.unsupportedVersion)),
    );
    expect(await file.readAsString(), original);
  });

  test(
    'failed atomic write preserves old file and permits later retry',
    () async {
      await repository.save(const Preferences(appearance: Appearance.dark));
      final original = await file.readAsString();
      final obstruction = Directory('${file.path}.tmp');
      await obstruction.create();
      await expectLater(
        repository.save(const Preferences(appearance: Appearance.light)),
        throwsA(failure(PreferencesFailureKind.unavailable)),
      );
      expect(await file.readAsString(), original);
      await obstruction.delete();
      await repository.save(const Preferences(appearance: Appearance.light));
      expect((await repository.load()).appearance, Appearance.light);
    },
  );

  test('oversized update is rejected without replacing saved data', () async {
    await repository.save(const Preferences(appearance: Appearance.dark));
    await expectLater(
      repository.save(Preferences(extensions: {'large': 'a' * 65536})),
      throwsA(failure(PreferencesFailureKind.unavailable)),
    );
    expect((await repository.load()).appearance, Appearance.dark);
  });

  test('symlinks are refused and their targets remain untouched', () async {
    final target = File('${directory.path}/target');
    await target.writeAsString('keep');
    final link = Link(file.path);
    await link.create(target.path);
    await expectLater(
      repository.load(),
      throwsA(failure(PreferencesFailureKind.unavailable)),
    );
    await expectLater(
      repository.save(const Preferences()),
      throwsA(failure(PreferencesFailureKind.unavailable)),
    );
    expect(await target.readAsString(), 'keep');
  });

  test(
    'controller publishes success only after durable save; blocks duplicates',
    () async {
      final controlled = ControlledPreferencesRepository()
        ..pending = Completer<void>();
      final container = ProviderContainer(
        overrides: [
          preferencesRepositoryProvider.overrideWithValue(controlled),
        ],
      );
      addTearDown(container.dispose);
      final controller = container.read(preferencesProvider.notifier);
      final saving = controller.setAppearance(Appearance.dark);
      expect(container.read(preferencesProvider).saving, true);
      expect(
        container.read(preferencesProvider).value.appearance,
        Appearance.system,
      );
      expect(await controller.completeOnboarding(), false);
      controlled.pending!.complete();
      expect(await saving, true);
      expect(
        container.read(preferencesProvider).value.appearance,
        Appearance.dark,
      );
      expect(controlled.writes, 1);
    },
  );

  test('controller retains committed preference on failure and retries exact intent', () async {
    final controlled = ControlledPreferencesRepository()..fail = true;
    final container = ProviderContainer(
      overrides: [preferencesRepositoryProvider.overrideWithValue(controlled)],
    );
    addTearDown(container.dispose);
    final controller = container.read(preferencesProvider.notifier);
    expect(await controller.completeOnboarding(), false);
    expect(container.read(preferencesProvider).saveFailed, true);
    expect(container.read(preferencesProvider).value.onboardingSeen, false);
    controlled.fail = false;
    expect(await controller.retry(), true);
    expect(container.read(preferencesProvider).value.onboardingSeen, true);
    expect(container.read(preferencesProvider).saveFailed, false);
  });
}
