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
import 'package:loop/core/data/database/loop_database.dart';
import 'package:loop/core/data/storage.dart';
import 'package:loop/core/data/storage_protection.dart';
import 'package:loop/core/data/validation.dart';
import 'package:loop/features/journal/presentation/journal_providers.dart';
import 'package:loop/features/practice/presentation/practice_providers.dart';
import 'package:loop/features/settings/presentation/preferences_controller.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'foundation_test.dart' show waitFor;

const _scope = 'loop-m07-native-verification-v1';
const _name = 'M07 journal verification · synthetic';
const _stage = String.fromEnvironment('M07_STAGE', defaultValue: 'setup');
Finder _field(String label) => find.byWidgetPredicate(
  (w) => w is TextField && w.decoration?.labelText == label,
);
Future<void> _tap(WidgetTester tester, Finder finder) async {
  await waitFor(tester, finder);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _text(WidgetTester tester, String label, String value) async {
  await tester.ensureVisible(_field(label));
  await tester.enterText(_field(label), value);
  await tester.testTextInput.receiveAction(TextInputAction.done);
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
}

Future<String> _hash(LoopStorage storage) async {
  final rows = <String, List<String>>{};
  for (final table in storage.database.allTables) {
    rows[table.actualTableName] =
        (await storage.database
                .customSelect('SELECT * FROM "${table.actualTableName}"')
                .get())
            .map((r) => jsonEncode(r.data))
            .toList()
          ..sort();
  }
  return sha256.convert(utf8.encode(jsonEncode(rows))).toString();
}

Future<void> _capture(GlobalKey frame, Directory root, String name) async {
  final boundary =
      frame.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: 1);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  await File(p.join(root.path, 'm07-$name.png'))
      .writeAsBytes(bytes!.buffer.asUint8List(), flush: true);
  image.dispose();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'M07 native $_stage: fresh journal and distinct-process retention',
    (tester) async {
      expect(['setup', 'resume', 'cleanup'], contains(_stage));
      await const StorageProtection().configure();
      final support = await getApplicationSupportDirectory();
      final root = Directory(await support.resolveSymbolicLinks());
      final marker = File(p.join(root.path, '.m07-verification.json'));
      final product = await LoopStorage.open(root);
      final productHash = await _hash(product);
      final settings = await product.preferences.load();
      await product.close();
      late Map<String, dynamic> metadata;
      if (_stage == 'setup') {
        expect(
          await marker.exists(),
          false,
          reason:
              'Resume/clean the existing owned test before creating another.',
        );
        metadata = {
          'scope': _scope,
          'storeName': '.m07-store-${newId()}',
          'productHash': productHash,
          'setupPid': pid,
        };
        await marker.writeAsString(jsonEncode(metadata), flush: true);
      } else {
        expect(await marker.length(), lessThan(8192));
        metadata =
            jsonDecode(await marker.readAsString()) as Map<String, dynamic>;
        expect(metadata['scope'], _scope);
        expect(
          metadata['productHash'],
          productHash,
          reason: 'Normal journal data must remain unchanged.',
        );
      }
      final storeName = metadata['storeName'] as String;
      expect(
        RegExp(
          r'^\.m07-store-[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ).hasMatch(storeName),
        true,
      );
      final directory = Directory(p.join(root.path, storeName));
      expect(
        await FileSystemEntity.type(directory.path, followLinks: false),
        isNot(FileSystemEntityType.link),
      );
      if (_stage != 'setup') expect(await directory.exists(), true);
      final storage = await LoopStorage.open(directory);
      ProviderContainer? container;
      var success = false;
      final frame = GlobalKey();
      try {
        if (_stage == 'cleanup') {
          success = true;
          return;
        }
        container = ProviderContainer(
          overrides: [
            storageProvider.overrideWithValue(storage),
            preferencesRepositoryProvider.overrideWithValue(
              storage.preferences,
            ),
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
        if (_stage == 'setup') {
          await waitFor(tester, find.text('Skip for now'));
          await _tap(tester, find.text('Skip for now'));
          await waitFor(tester, find.text('Your practice starts here'));
          await _tap(tester, find.text('Add a skill'));
          await _tap(tester, find.text('Continue'));
          await _text(tester, 'Skill name', _name);
          await _text(
            tester,
            'Why this skill? (optional)',
            'Disposable synthetic native test. No observed improvement.',
          );
          await _tap(tester, find.text('Create skill'));
          await waitFor(tester, find.text('Practice this skill'));
          final skill =
              (await storage.skillManagement.watchCards().first).single.skill;
          metadata['skillId'] = skill.id;
          await _tap(tester, find.text('Practice this skill'));
          await waitFor(tester, find.text('Start practice'));
          await _tap(tester, find.byType(CheckboxListTile).first);
          await _tap(tester, find.text('Start practice'));
          await waitFor(tester, find.text('Pause'));
          await Future<void>.delayed(const Duration(seconds: 3));
          await _tap(tester, find.text('Pause'));
          final engine = container.read(practiceEngineProvider);
          final paused = engine.milliseconds;
          expect(paused, greaterThanOrEqualTo(3000));
          await _tap(tester, find.text('Finish'));
          await waitFor(tester, _field('What got easier? · optional'));
          await _text(
            tester,
            'What got easier? · optional',
            'Synthetic observation: lighter touch.',
          );
          await _text(
            tester,
            'What should you try next? · optional',
            'Repeat a short phrase.',
          );
          await _text(
            tester,
            'Notes · optional',
            'Verification note retained locally.',
          );
          await _tap(tester, find.text('3 / 5'));
          await _tap(tester, find.text('Add a reading'));
          await waitFor(tester, find.text('Tempo · bpm'));
          await _tap(tester, find.text('Tempo · bpm'));
          await _text(tester, 'Tempo reading', '72');
          await _text(
            tester,
            'Method or source note · optional',
            'Synthetic self-report, no instrument used.',
          );
          await _capture(frame, root, 'reflection');
          await _tap(tester, find.text('Save and finish'));
          await waitFor(tester, find.text('Saved on this device'));
          final id = engine.record!.session.id;
          metadata['sessionId'] = id;
          metadata['milliseconds'] = paused;
          final beforeEdit = (await container
              .read(journalRepositoryProvider)
              .find(id))!;
          metadata['initialRevision'] = beforeEdit.session.revision;
          await _tap(tester, find.byTooltip('Edit practice'));
          await waitFor(tester, _field('What got easier? · optional'));
          await _text(
            tester,
            'What got easier? · optional',
            'Synthetic observation amended once.',
          );
          await _tap(tester, find.text('Save changes'));
          await waitFor(tester, find.text('Saved on this device'));
          await _tap(tester, find.text('Back to Today'));
          await waitFor(
            tester,
            find.textContaining('Next: Repeat a short phrase.'),
          );
          await _capture(frame, root, 'today');
          await _tap(tester, find.text('View practice journal'));
          await waitFor(tester, find.text('Practice journal'));
          await _capture(frame, root, 'timeline');
          metadata['storeHash'] = await _hash(storage);
          await marker.writeAsString(jsonEncode(metadata), flush: true);
        } else {
          expect(
            pid,
            isNot(metadata['setupPid']),
            reason: 'Resume must run in a distinct native process.',
          );
          await waitFor(
            tester,
            find.textContaining('Next: Repeat a short phrase.'),
          );
          await _tap(tester, find.text('View practice journal'));
          await waitFor(tester, find.text('Practice journal'));
        }
        final id = metadata['sessionId'] as String;
        await _tap(tester, find.text(_name));
        await waitFor(tester, find.text('Saved on this device'));
        final detail = (await container
            .read(journalRepositoryProvider)
            .find(id))!;
        expect(detail.session.status, 'completed');
        expect(detail.session.entryMode, 'timed');
        expect(
          detail.session.activeSeconds,
          (metadata['milliseconds'] as int) ~/ 1000,
        );
        expect(
          detail.session.whatGotEasier,
          'Synthetic observation amended once.',
        );
        expect(detail.session.note, 'Verification note retained locally.');
        expect(detail.session.nextStep, 'Repeat a short phrase.');
        expect(detail.session.effortRating, 3);
        expect(
          detail.session.revision,
          (metadata['initialRevision'] as int) + 1,
        );
        expect(detail.exercises, hasLength(1));
        expect(detail.exercises.single.exerciseTitleSnapshot, isNotEmpty);
        expect(detail.readings, hasLength(1));
        expect(detail.readings.single.numericValue, 72);
        expect(detail.readings.single.sourceType, 'self_reported');
        expect(
          detail.readings.single.sourceNote,
          'Synthetic self-report, no instrument used.',
        );
        expect(
          await storage.database.select(storage.database.sessions).get(),
          hasLength(1),
        );
        expect(
          await storage.database.select(storage.database.journalDrafts).get(),
          isEmpty,
        );
        expect(await _hash(storage), metadata['storeHash']);
        expect(
          await storage.database.customSelect('PRAGMA foreign_key_check').get(),
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
        await _capture(frame, root, '$_stage-detail');
        expect(tester.takeException(), isNull);
        debugPrint(
          'LOOP_M07_EVIDENCE:${jsonEncode({'stage': _stage, 'platform': Platform.operatingSystem, 'pid': pid, 'setupPid': metadata['setupPid'], 'schema': LoopDatabase.currentVersion, 'freshStore': _stage == 'setup', 'sessionCount': 1, 'readingCount': 1, 'exerciseSnapshotCount': 1, 'activeMilliseconds': metadata['milliseconds'], 'revision': detail.session.revision, 'retainedAppearance': settings.appearance.name, 'retainedOnboarding': settings.onboardingSeen, 'hashRetained': true, 'foreignKeys': 'ok', 'integrity': 'ok', 'productionDataUnchanged': true})}',
        );
        success = true;
      } finally {
        if (container != null) {
          final writer = container.read(journalDraftWriterProvider);
          final engine = container.read(practiceEngineProvider);
          await tester.pumpWidget(const SizedBox.shrink());
          await writer.close();
          await engine.idle;
          container.dispose();
        }
        await storage.close();
        final retained = await LoopStorage.open(root);
        try {
          expect(await _hash(retained), productHash);
        } finally {
          await retained.close();
        }
        if (success && _stage != 'setup') {
          expect(await directory.resolveSymbolicLinks(), directory.path);
          await directory.delete(recursive: true);
          await marker.delete();
        }
      }
    },
    timeout: const Timeout(Duration(minutes: 15)),
  );
}
