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
import 'package:loop/core/data/storage.dart';
import 'package:loop/core/data/storage_protection.dart';
import 'package:loop/core/data/validation.dart';
import 'package:loop/features/settings/presentation/preferences_controller.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'foundation_test.dart' show waitFor;

const _scope = 'loop-m05-native-verification-v1';
const _skillName = 'M05 verification · synthetic';
const _stage = String.fromEnvironment('M05_STAGE', defaultValue: 'setup');

Finder _field(String label) => find.byWidgetPredicate(
  (w) => w is TextField && w.decoration?.labelText == label,
);

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pump();
  final deadline = DateTime.now().add(const Duration(seconds: 20));
  while (find.byType(CircularProgressIndicator).evaluate().isNotEmpty &&
      DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  await tester.pumpAndSettle();
}

Future<String> _databaseHash(LoopStorage storage) async {
  final rows = <String, List<String>>{};
  for (final table in storage.database.allTables) {
    rows[table.actualTableName] =
        (await storage.database
                .customSelect('SELECT * FROM "${table.actualTableName}"')
                .get())
            .map((row) => jsonEncode(row.data))
            .toList()
          ..sort();
  }
  return sha256.convert(utf8.encode(jsonEncode(rows))).toString();
}

Future<ProviderContainer> _show(
  WidgetTester tester,
  LoopStorage storage,
  GlobalKey frame,
) async {
  final container = ProviderContainer(
    overrides: [
      storageProvider.overrideWithValue(storage),
      preferencesRepositoryProvider.overrideWithValue(storage.preferences),
      initialPreferencesProvider.overrideWithValue(
        await storage.preferences.load(),
      ),
    ],
  );
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: RepaintBoundary(key: frame, child: const LoopApp()),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'M05 native $_stage: owned setup, retained data and process reopen',
    (tester) async {
      expect(['setup', 'resume', 'cleanup'], contains(_stage));
      await const StorageProtection().configure();
      final support = await getApplicationSupportDirectory();
      final root = Directory(await support.resolveSymbolicLinks());
      final marker = File(p.join(root.path, '.m05-verification.json'));
      final product = await LoopStorage.open(
        root,
      ); // Real retained M04→M05 upgrade.
      final productHash = await _databaseHash(product);
      final productVersion =
          (await product.database
                  .customSelect('PRAGMA user_version')
                  .getSingle())
              .data
              .values
              .single;
      final productSettings = await product.preferences.load();
      await product.close();
      expect(productVersion, 3);

      Map<String, dynamic> metadata;
      if (_stage == 'setup') {
        expect(
          await marker.exists(),
          false,
          reason: 'Resume/clean the existing owned experiment before creating another.',
        );
        metadata = {
          'scope': _scope,
          'storeName': '.m05-store-${newId()}',
          'productHash': productHash,
          'setupPid': pid,
        };
        await marker.writeAsString(jsonEncode(metadata), flush: true);
      } else {
        expect(await marker.length(), lessThan(4096));
        metadata =
            jsonDecode(await marker.readAsString()) as Map<String, dynamic>;
        expect(metadata['scope'], _scope);
        expect(
          metadata['productHash'],
          productHash,
          reason: 'The normal journal must remain unchanged.',
        );
      }
      final storeName = metadata['storeName'] as String;
      expect(
        RegExp(
          r'^\.m05-store-[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ).hasMatch(storeName),
        true,
      );
      final directory = Directory(p.join(root.path, storeName));
      expect(
        await FileSystemEntity.type(directory.path, followLinks: false),
        isNot(FileSystemEntityType.link),
      );
      if (_stage != 'setup') expect(await directory.exists(), true);
      var storage = await LoopStorage.open(directory);
      ProviderContainer? container;
      var success = false;
      final frame = GlobalKey();
      try {
        if (_stage == 'cleanup') {
          success = true;
          return;
        }
        container = await _show(tester, storage, frame);
        if (_stage == 'setup') {
          await waitFor(tester, find.text('Skip for now'));
          await _tap(tester, find.text('Skip for now'));
          await waitFor(tester, find.text('Your practice starts here'));
          await _tap(tester, find.text('Add a skill'));
          await _tap(tester, find.text('Continue'));
          await tester.enterText(_field('Skill name'), _skillName);
          await tester.ensureVisible(_field('Why this skill? (optional)'));
          await tester.enterText(
            _field('Why this skill? (optional)'),
            'Disposable synthetic native verification; no observed practice.',
          );
          await tester.ensureVisible(_field('First goal (optional)'));
          await tester.enterText(
            _field('First goal (optional)'),
            'Verification milestone',
          );
          await _tap(tester, find.text('Create skill'));
          await waitFor(tester, find.text('Current goals'));
          final skill =
              (await storage.skillManagement.watchCards().first).single.skill;
          final detail = (await storage.skillManagement.detail(skill.id))!;
          metadata['skillId'] = skill.id;
          await _tap(
            tester,
            find.byTooltip(
              'Actions for exercise ${detail.exercises.first.title}',
            ),
          );
          await _tap(tester, find.text('Edit exercise'));
          await waitFor(tester, _field('Exercise title'));
          await tester.enterText(
            _field('Exercise title'),
            'Verification exercise',
          );
          await tester.enterText(
            _field('Instructions (optional)'),
            'Synthetic instructions retained across processes.',
          );
          await tester.ensureVisible(_field('Suggested seconds (optional)'));
          await tester.enterText(_field('Suggested seconds (optional)'), '30');
          await _tap(tester, find.text('Save exercise'));
          await waitFor(tester, find.text('Verification exercise'));
          metadata['storeHash'] = await _databaseHash(storage);
          await marker.writeAsString(jsonEncode(metadata), flush: true);
          // Explicitly close and reopen actual production repositories/providers.
          await tester.pumpWidget(const SizedBox.shrink());
          container.dispose();
          container = null;
          await storage.close();
          storage = await LoopStorage.open(directory);
          container = await _show(tester, storage, frame);
        } else {
          expect(
            pid,
            isNot(metadata['setupPid']),
            reason: 'Resume must be a new native process.',
          );
        }
        await waitFor(tester, find.text(_skillName));
        await _tap(tester, find.text('View skill'));
        await waitFor(tester, find.text('Verification exercise'));
        final detail = (await storage.skillManagement.detail(
          metadata['skillId'] as String,
        ))!;
        expect(detail.skill.name, _skillName);
        expect(detail.exercises, hasLength(3));
        expect(
          detail.exercises.first.instructions,
          'Synthetic instructions retained across processes.',
        );
        expect(detail.exercises.first.defaultSeconds, 30);
        expect(detail.goals.single.title, 'Verification milestone');
        expect(detail.goals.single.type, 'qualitative');
        expect(detail.sessions, isEmpty);
        expect(detail.readings, isEmpty);
        expect(await _databaseHash(storage), metadata['storeHash']);
        expect(
          (await storage.database
              .customSelect('PRAGMA foreign_key_check')
              .get()),
          isEmpty,
        );
        expect(
          (await storage.database
                  .customSelect('PRAGMA quick_check')
                  .getSingle())
              .data
              .values
              .single,
          'ok',
        );
        await const StorageProtection().configure();
        await tester.pumpAndSettle();
        final boundary =
            frame.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 1);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await File(p.join(root.path, 'm05-$_stage.png'))
            .writeAsBytes(bytes!.buffer.asUint8List(), flush: true);
        image.dispose();
        debugPrint(
          'LOOP_M05_EVIDENCE:${jsonEncode({'stage': _stage, 'platform': Platform.operatingSystem, 'pid': pid, 'setupPid': metadata['setupPid'], 'schema': productVersion, 'retainedAppearance': productSettings.appearance.name, 'retainedOnboarding': productSettings.onboardingSeen, 'freshStore': _stage == 'setup', 'skillCount': 1, 'exerciseCount': 3, 'goalCount': 1, 'sessionCount': 0, 'readingCount': 0, 'hashRetained': true, 'foreignKeys': 'ok', 'integrity': 'ok', 'productionDataUnchanged': true})}',
        );
        expect(tester.takeException(), isNull);
        success = true;
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        container?.dispose();
        await storage.close();
        final retained = await LoopStorage.open(root);
        try {
          expect(await _databaseHash(retained), productHash);
        } finally {
          await retained.close();
        }
        if (success && _stage != 'setup') {
          // Delete only the strict UUID-named, marker-owned synthetic store.
          expect(await directory.resolveSymbolicLinks(), directory.path);
          await directory.delete(recursive: true);
          await marker.delete();
        }
      }
    },
  );
}
