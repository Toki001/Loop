import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:loop/app/app.dart';
import 'package:loop/app/routing.dart';
import 'package:loop/core/data/database/loop_database.dart';
import 'package:loop/core/data/storage.dart';
import 'package:loop/core/data/storage_protection.dart';
import 'package:loop/core/data/validation.dart';
import 'package:loop/features/practice/presentation/practice_providers.dart';
import 'package:loop/features/settings/domain/preferences.dart';
import 'package:loop/features/settings/presentation/preferences_controller.dart';
import 'package:loop/features/skills/domain/skill_draft.dart';
import 'package:loop/features/skills/domain/skill_kind.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'foundation_test.dart' show waitFor;

const _scope = 'loop-m06-native-verification-v1';
const _stage = String.fromEnvironment('M06_STAGE', defaultValue: 'smoke');

Future<String> _hash(LoopStorage storage) async {
  final values = <String, List<String>>{};
  for (final table in storage.database.allTables) {
    values[table.actualTableName] =
        (await storage.database
                .customSelect('SELECT * FROM "${table.actualTableName}"')
                .get())
            .map((r) => jsonEncode(r.data))
            .toList()
          ..sort();
  }
  return sha256.convert(utf8.encode(jsonEncode(values))).toString();
}

Future<void> _tap(WidgetTester tester, String label) async {
  final finder = find.text(label);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('M06 native $_stage: foreground time and durable recovery', (
    tester,
  ) async {
    expect([
      'smoke',
      'background',
      'lock',
      'kill_prepare',
      'recovery',
      'cleanup',
    ], contains(_stage));
    await const StorageProtection().configure();
    final root = Directory(
      await (await getApplicationSupportDirectory()).resolveSymbolicLinks(),
    );
    final marker = File(p.join(root.path, '.m06-verification.json'));
    final product = await LoopStorage.open(root);
    final productHash = await _hash(product);
    final productVersion =
        (await product.database.customSelect('PRAGMA user_version').getSingle())
            .data
            .values
            .single;
    expect(productVersion, LoopDatabase.currentVersion);
    await product.close();
    final continuing = _stage == 'recovery' || _stage == 'cleanup';
    Map<String, dynamic> metadata;
    if (continuing) {
      expect(await marker.length(), lessThan(4096));
      metadata =
          jsonDecode(await marker.readAsString()) as Map<String, dynamic>;
      expect(metadata['scope'], _scope);
      expect(metadata['productHash'], productHash);
    } else {
      expect(
        await marker.exists(),
        false,
        reason:
            'An existing owned M06 probe must be recovered or cleaned first.',
      );
      metadata = {
        'scope': _scope,
        'storeName': '.m06-store-${newId()}',
        'productHash': productHash,
        'setupPid': pid,
        'stage': _stage,
      };
      await marker.writeAsString(jsonEncode(metadata), flush: true);
    }
    final name = metadata['storeName'] as String;
    expect(
      RegExp(
        r'^\.m06-store-[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      ).hasMatch(name),
      true,
    );
    final directory = Directory(p.join(root.path, name));
    expect(
      await FileSystemEntity.type(directory.path, followLinks: false),
      isNot(FileSystemEntityType.link),
    );
    if (continuing) expect(await directory.exists(), true);
    final storage = await LoopStorage.open(directory);
    ProviderContainer? container;
    final boundary = GlobalKey();
    var removeProbe = false;
    try {
      if (_stage == 'cleanup') {
        removeProbe = true;
        return;
      }
      String skillId;
      if (!continuing) {
        skillId = (await storage.skillManagement.create(
          const SkillDraft(
            name: 'Timer verification · synthetic',
            kind: SkillKind.custom,
            includeStarters: false,
          ),
        )).id;
        metadata['skillId'] = skillId;
        await storage.preferences.save(const Preferences(onboardingSeen: true));
      } else {
        skillId = metadata['skillId'] as String;
        expect(pid, isNot(metadata['setupPid']));
      }
      container = ProviderContainer(
        overrides: [
          storageProvider.overrideWithValue(storage),
          preferencesRepositoryProvider.overrideWithValue(storage.preferences),
          initialPreferencesProvider.overrideWithValue(
            await storage.preferences.load(),
          ),
          initialLocationProvider.overrideWithValue(
            '/practice/setup?skill=$skillId',
          ),
        ],
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: RepaintBoundary(
            key: boundary,
            child: const PracticeLifecycleHost(child: LoopApp()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final engine = container.read(practiceEngineProvider);
      await engine.idle;
      await tester.pumpAndSettle();
      if (_stage == 'recovery') {
        expect(engine.record!.session.id, metadata['sessionId']);
        expect(engine.record!.session.status, 'paused');
        expect(engine.record!.session.interruptionReason, 'recovered');
        expect(engine.milliseconds, metadata['savedMilliseconds']);
        expect(engine.running, false);
        await _tap(tester, 'Open practice');
        await waitFor(tester, find.text('Your saved practice was recovered'));
        final before = engine.milliseconds;
        await tester.pump(const Duration(seconds: 2));
        expect(engine.milliseconds, before);
        expect(
          await Future.wait(List.generate(10, (_) => engine.finish())),
          everyElement(true),
        );
        expect(
          (await storage.database.select(storage.database.sessions).get())
              .single
              .status,
          'completed',
        );
        container
            .read(routerProvider)
            .go('/sessions/${engine.record!.session.id}');
        await waitFor(tester, find.text('Saved on this device'));
        metadata['recoveredMilliseconds'] = before;
        removeProbe = true;
      } else {
        await waitFor(tester, find.text('Start practice'));
        final elapsed = Stopwatch()..start();
        await _tap(tester, 'Start practice');
        await waitFor(tester, find.text('Pause'));
        expect(engine.running, true);
        final foregroundTarget = _stage == 'background'
            ? 120000
            : _stage == 'kill_prepare'
            ? 7000
            : 4000;
        final sourceWatch = Stopwatch()..start();
        final initialMs = engine.milliseconds;
        while (engine.milliseconds < foregroundTarget) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        metadata['foregroundMilliseconds'] = engine.milliseconds;
        metadata['referenceMilliseconds'] =
            sourceWatch.elapsedMilliseconds + initialMs;
        metadata['clockDifferenceMilliseconds'] =
            (engine.milliseconds -
                    (sourceWatch.elapsedMilliseconds + initialMs))
                .abs();
        expect(metadata['clockDifferenceMilliseconds'] as int, lessThan(100));
        if (_stage == 'background' || _stage == 'lock') {
          debugPrint(
            'LOOP_M06_REQUEST_BACKGROUND:${jsonEncode({'platform': Platform.operatingSystem, 'pid': pid, 'foregroundMilliseconds': engine.milliseconds})}',
          );
          final deadline = DateTime.now().add(const Duration(seconds: 30));
          while (engine.foreground && DateTime.now().isBefore(deadline)) {
            await Future<void>.delayed(const Duration(milliseconds: 50));
          }
          expect(
            engine.foreground,
            false,
            reason:
                'The external native harness must actually background the app.',
          );
          await engine.idle;
          final pausedMs = engine.milliseconds;
          metadata['pausedMilliseconds'] = pausedMs;
          debugPrint(
            'LOOP_M06_PAUSED:${jsonEncode({'platform': Platform.operatingSystem, 'pid': pid, 'milliseconds': pausedMs, 'status': engine.record!.session.status})}',
          );
          // No frame pump: the real OS can suspend rendering while hidden.
          while (!engine.foreground) {
            await Future<void>.delayed(const Duration(milliseconds: 100));
          }
          await engine.idle;
          await tester.pumpAndSettle();
          expect(engine.running, false);
          expect(engine.milliseconds, pausedMs);
          expect(engine.record!.session.status, 'paused');
          metadata['afterBackgroundMilliseconds'] = engine.milliseconds;
          await waitFor(tester, find.text('Paused while you were away'));
        }
        if (_stage == 'kill_prepare') {
          engine.tick();
          await engine.idle;
          metadata['sessionId'] = engine.record!.session.id;
          metadata['savedMilliseconds'] = (await engine.repository.find(
            engine.record!.session.id,
          ))!.milliseconds;
          await marker.writeAsString(jsonEncode(metadata), flush: true);
          debugPrint(
            'LOOP_M06_KILL_READY:${jsonEncode({'platform': Platform.operatingSystem, 'pid': pid, 'savedMilliseconds': metadata['savedMilliseconds']})}',
          );
          // Intentionally terminated by the external OS harness. Completion is
          // proved by a separate new-process recovery test, not this wait.
          await Completer<void>().future;
        }
        if (engine.running) {
          await _tap(tester, 'Pause');
          await engine.idle;
        }
        await _tap(tester, 'Finish');
        await waitFor(tester, find.text('Save and finish'));
        await _tap(tester, 'Save and finish');
        await waitFor(tester, find.text('Saved on this device'));
        expect(
          await Future.wait(List.generate(10, (_) => engine.finish())),
          everyElement(true),
        );
        final sessions = await storage.database
            .select(storage.database.sessions)
            .get();
        expect(sessions, hasLength(1));
        expect(sessions.single.status, 'completed');
        metadata['savedMilliseconds'] = engine.milliseconds;
        metadata['completedCount'] = 1;
        metadata['elapsedHarnessMilliseconds'] = elapsed.elapsedMilliseconds;
        removeProbe = true;
      }
      expect(
        await storage.database.customSelect('PRAGMA foreign_key_check').get(),
        isEmpty,
      );
      expect(
        (await storage.database.customSelect('PRAGMA quick_check').getSingle())
            .data
            .values
            .single,
        'ok',
      );
      await tester.pumpAndSettle();
      final render =
          boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final frame = await render.toImage(pixelRatio: 1);
      final png = await frame.toByteData(format: ui.ImageByteFormat.png);
      await File(p.join(root.path, 'm06-$_stage.png'))
          .writeAsBytes(png!.buffer.asUint8List(), flush: true);
      frame.dispose();
      debugPrint(
        'LOOP_M06_EVIDENCE:${jsonEncode({
          'stage': _stage,
          'platform': Platform.operatingSystem,
          'pid': pid,
          'setupPid': metadata['setupPid'],
          'schema': productVersion,
          'productionDataUnchanged': true,
          'foreignKeys': 'ok',
          'integrity': 'ok',
          'syntheticStoreIsolated': true,
          'results': {...metadata}
            ..remove('storeName')
            ..remove('productHash')
            ..remove('skillId')
            ..remove('sessionId'),
        })}',
      );
      expect(tester.takeException(), isNull);
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      container?.dispose();
      await storage.close();
      final retained = await LoopStorage.open(root);
      try {
        expect(await _hash(retained), productHash);
      } finally {
        await retained.close();
      }
      if (removeProbe) {
        expect(await directory.resolveSymbolicLinks(), directory.path);
        await directory.delete(recursive: true);
        await marker.delete();
      }
    }
  }, timeout: const Timeout(Duration(minutes: 45)));
}
