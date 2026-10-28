import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop/core/data/database/loop_database.dart';
import 'package:loop/core/data/local_failure.dart';
import 'package:loop/features/journal/data/journal_repository.dart';
import 'package:loop/features/journal/domain/journal_entry.dart';
import 'package:loop/features/practice/data/practice_repository.dart';
import 'package:loop/features/journal/presentation/journal_providers.dart';
import 'package:loop/features/practice/presentation/practice_providers.dart';

import 'helpers/drive_async.dart';
import 'practice_widgets_test.dart' show PracticeTestContext, pumpPractice;
import 'skill_widgets_test.dart' show field, tapSkillWidget, waitForSkillWidget;

class _LoseFinishResponse extends JournalRepository {
  _LoseFinishResponse(super.database, {super.practice});
  bool lose = true;
  @override
  Future<PracticeRecord> complete(
    Session value, {
    required int milliseconds,
    required JournalReflection reflection,
    int? manualSeconds,
    String? manualDateLocal,
  }) async {
    final saved = await super.complete(
      value,
      milliseconds: milliseconds,
      reflection: reflection,
      manualSeconds: manualSeconds,
      manualDateLocal: manualDateLocal,
    );
    if (lose) {
      lose = false;
      throw const LocalFailure(LocalFailureKind.unavailable);
    }
    return saved;
  }
}

Future<MetricDefinition> addMeasure(
  WidgetTester tester,
  PracticeTestContext context,
) => driveAsync(
  tester,
  context.container
      .read(journalRepositoryProvider)
      .metrics
      .create(
        MetricDefinitionsCompanion(
          skillId: Value(context.skillId),
          label: const Value('Words per minute'),
          unitKey: const Value('wpm'),
          valueType: const Value('numeric'),
          direction: const Value('up'),
          sourceHint: const Value('manual'),
          scaleMin: const Value(0),
        ),
      ),
);
Future<void> openReflection(
  WidgetTester tester,
  PracticeTestContext context,
) async {
  await tapSkillWidget(tester, find.text('Start practice'));
  await waitForSkillWidget(tester, find.text('Pause'));
  context.clock.advance(const Duration(milliseconds: 30123));
  await tapSkillWidget(tester, find.text('Finish'));
  await waitForSkillWidget(tester, field('What got easier? · optional'));
}

Future<void> addReading(WidgetTester tester) async {
  await tester.drag(
    find.byType(SingleChildScrollView).last,
    const Offset(0, -220),
  );
  await tester.pumpAndSettle();
  await tapSkillWidget(tester, find.text('Add a reading'));
  await tapSkillWidget(tester, find.text('Words per minute · wpm'));
  await waitForSkillWidget(tester, field('Words per minute reading'));
}

void main() {
  testWidgets(
    'finish saves optional reflection and a real self-reported reading once',
    (tester) async {
      final context = await pumpPractice(tester);
      await addMeasure(tester, context);
      await openReflection(tester, context);
      await tester.enterText(
        field('What got easier? · optional'),
        'Lighter touch',
      );
      await tester.ensureVisible(field('What should you try next? · optional'));
      await tester.enterText(
        field('What should you try next? · optional'),
        'Repeat the same passage',
      );
      await tapSkillWidget(tester, find.text('3 / 5'));
      await addReading(tester);
      await tester.ensureVisible(field('Words per minute reading'));
      await tester.enterText(field('Words per minute reading'), '45');
      await tester.ensureVisible(field('Method or source note · optional'));
      await tester.enterText(
        field('Method or source note · optional'),
        'External test, entered by me',
      );
      await tapSkillWidget(tester, find.text('Save and finish'));
      await waitForSkillWidget(tester, find.text('Saved on this device'));
      final engine = context.container.read(practiceEngineProvider);
      final detail = (await driveAsync(
        tester,
        context.container
            .read(journalRepositoryProvider)
            .find(engine.record!.session.id),
      ))!;
      expect(detail.session.whatGotEasier, 'Lighter touch');
      expect(detail.session.nextStep, 'Repeat the same passage');
      expect(detail.session.effortRating, 3);
      expect(detail.session.activeSeconds, 30);
      expect(detail.readings.single.numericValue, 45);
      expect(detail.readings.single.sourceType, 'self_reported');
      expect(
        find.text('Self-reported · entered by you · definition version 1'),
        findsOneWidget,
      );
      await tapSkillWidget(tester, find.text('Back to Today'));
      await waitForSkillWidget(tester, find.text('Recent practice'));
      expect(find.textContaining('Repeat the same passage'), findsWidgets);
      await tapSkillWidget(tester, find.text('View practice journal'));
      await waitForSkillWidget(tester, find.text('Practice journal'));
      await tapSkillWidget(tester, find.text('Skill: All skills'));
      await tapSkillWidget(
        tester,
        find.descendant(
          of: find.byType(SimpleDialog),
          matching: find.text('Studio practice · 練習'),
        ),
      );
      await waitForSkillWidget(
        tester,
        find.text('Skill: Studio practice · 練習'),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'invalid numeric text is durable and restored before validation or completion',
    (tester) async {
      final context = await pumpPractice(tester);
      await addMeasure(tester, context);
      await openReflection(tester, context);
      await tester.enterText(
        field('What got easier? · optional'),
        'Unfinished observation',
      );
      await addReading(tester);
      await tester.ensureVisible(field('Words per minute reading'));
      await tester.enterText(field('Words per minute reading'), '4..');
      await tapSkillWidget(tester, find.text('Save reflection draft'));
      await tapSkillWidget(
        tester,
        find.text('Keep draft and return to practice'),
      );
      await waitForSkillWidget(tester, find.text('Resume'));
      await tapSkillWidget(tester, find.text('Finish'));
      await waitForSkillWidget(
        tester,
        find.text('Your unfinished reflection was restored from this device.'),
      );
      expect(
        tester
            .widget<TextField>(field('What got easier? · optional'))
            .controller!
            .text,
        'Unfinished observation',
      );
      expect(
        tester
            .widget<TextField>(field('Words per minute reading'))
            .controller!
            .text,
        '4..',
      );
      await tapSkillWidget(tester, find.text('Save and finish'));
      expect(find.textContaining('Enter a finite value'), findsOneWidget);
      final id = context.container
          .read(practiceEngineProvider)
          .record!
          .session
          .id;
      final detail = (await driveAsync(
        tester,
        context.container.read(journalRepositoryProvider).find(id),
      ))!;
      expect(detail.session.status, 'paused');
      expect(detail.readings, isEmpty);
      expect(
        await driveAsync(
          tester,
          context.container.read(journalRepositoryProvider).draft(id, 'finish'),
        ),
        isNotNull,
      );
    },
  );

  testWidgets(
    'failed amendment keeps input and retries with one revision increment',
    (tester) async {
      final context = await pumpPractice(tester);
      await openReflection(tester, context);
      await tapSkillWidget(tester, find.text('Save and finish'));
      await waitForSkillWidget(tester, find.text('Saved on this device'));
      final id = context.container
          .read(practiceEngineProvider)
          .record!
          .session
          .id;
      final original = (await driveAsync(
        tester,
        context.container.read(journalRepositoryProvider).find(id),
      ))!;
      await tapSkillWidget(tester, find.byTooltip('Edit practice'));
      await waitForSkillWidget(tester, field('What got easier? · optional'));
      await tester.enterText(
        field('What got easier? · optional'),
        'Amended observation',
      );
      await driveAsync(
        tester,
        context.db.customStatement(
          "CREATE TRIGGER fail_journal_edit BEFORE UPDATE ON sessions WHEN NEW.what_got_easier = 'Amended observation' BEGIN SELECT RAISE(ABORT,'synthetic'); END",
        ),
      );
      await tapSkillWidget(tester, find.text('Save changes'));
      await waitForSkillWidget(tester, find.text('Not saved yet'));
      expect(
        tester
            .widget<TextField>(field('What got easier? · optional'))
            .controller!
            .text,
        'Amended observation',
      );
      expect(
        (await driveAsync(
          tester,
          context.container.read(journalRepositoryProvider).find(id),
        ))!.session.revision,
        original.session.revision,
      );
      await driveAsync(
        tester,
        context.db.customStatement('DROP TRIGGER fail_journal_edit'),
      );
      await tapSkillWidget(tester, find.text('Save changes'));
      await waitForSkillWidget(tester, find.text('Saved on this device'));
      final edited = (await driveAsync(
        tester,
        context.container.read(journalRepositoryProvider).find(id),
      ))!;
      expect(edited.session.whatGotEasier, 'Amended observation');
      expect(edited.session.revision, original.session.revision + 1);
      expect(edited.session.activeSeconds, original.session.activeSeconds);
    },
  );

  testWidgets(
    'compact 200 percent keyboard retains pinned Save and long reflection',
    (tester) async {
      final context = await pumpPractice(
        tester,
        size: const Size(320, 640),
        scale: 2,
      );
      await openReflection(tester, context);
      await tester.ensureVisible(field('What got easier? · optional'));
      await tester.enterText(
        field('What got easier? · optional'),
        List.filled(500, '練習 🌿').join(),
      );
      tester.view.viewInsets = const FakeViewPadding(bottom: 240);
      await tester.showKeyboard(field('What got easier? · optional'));
      await tester.pumpAndSettle();
      expect(find.text('Save and finish').hitTestable(), findsOneWidget);
      expect(
        tester.getRect(find.text('Save and finish')).height,
        greaterThan(20),
      );
      expect(tester.takeException(), isNull);
      tester.view.resetViewInsets();
      await tester.pumpAndSettle();
      await tapSkillWidget(tester, find.text('Save and finish'));
      await waitForSkillWidget(tester, find.text('Saved on this device'));
      final id = context.container
          .read(practiceEngineProvider)
          .record!
          .session
          .id;
      expect(
        (await driveAsync(
          tester,
          context.container.read(journalRepositoryProvider).find(id),
        ))!.session.whatGotEasier,
        List.filled(500, '練習 🌿').join(),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'metadata deletion shows real Undo and restores the same session identity',
    (tester) async {
      final context = await pumpPractice(tester);
      await openReflection(tester, context);
      await tester.enterText(
        field('What got easier? · optional'),
        'Keep this observation',
      );
      await tapSkillWidget(tester, find.text('Save and finish'));
      await waitForSkillWidget(tester, find.text('Saved on this device'));
      final id = context.container
          .read(practiceEngineProvider)
          .record!
          .session
          .id;
      await tapSkillWidget(tester, find.text('Delete practice'));
      await tapSkillWidget(tester, find.text('Delete practice').last);
      await waitForSkillWidget(tester, find.text('Practice deleted'));
      expect(
        await driveAsync(
          tester,
          context.container.read(journalRepositoryProvider).find(id),
        ),
        isNull,
      );
      await tapSkillWidget(tester, find.text('Undo'));
      await waitForSkillWidget(tester, find.text('Saved on this device'));
      expect(
        (await driveAsync(
          tester,
          context.container.read(journalRepositoryProvider).find(id),
        ))!.session.whatGotEasier,
        'Keep this observation',
      );
    },
  );
  testWidgets(
    'custom checklist definition creates no reading until selected and saved',
    (tester) async {
      final context = await pumpPractice(tester);
      await openReflection(tester, context);
      await tapSkillWidget(tester, find.text('Add a reading'));
      await tapSkillWidget(tester, find.text('Create a measure'));
      await waitForSkillWidget(tester, field('Measure label'));
      await tester.enterText(field('Measure label'), 'Short phrase completed');
      await tapSkillWidget(tester, find.text('Done / not done'));
      await tapSkillWidget(tester, find.text('Save measure'));
      await waitForSkillWidget(
        tester,
        find.text('Short phrase completed · completed'),
      );
      final id = context.container
          .read(practiceEngineProvider)
          .record!
          .session
          .id;
      expect(
        (await driveAsync(
          tester,
          context.container.read(journalRepositoryProvider).find(id),
        ))!.readings,
        isEmpty,
      );
      await tapSkillWidget(
        tester,
        find.text('Short phrase completed · completed'),
      );
      await tapSkillWidget(tester, find.text('Save and finish'));
      await waitForSkillWidget(tester, find.text('Saved on this device'));
      final detail = (await driveAsync(
        tester,
        context.container.read(journalRepositoryProvider).find(id),
      ))!;
      expect(detail.readings.single.boolValue, false);
      expect(detail.readings.single.sourceType, 'self_reported');
      await tester.ensureVisible(find.text('Not done'));
      expect(find.text('Not done'), findsOneWidget);
      expect(find.text('Not done completed'), findsNothing);
    },
  );

  for (final manual in [false, true]) {
    testWidgets(
      'lost finish response retries the committed ${manual ? 'manual' : 'timed'} intent once',
      (tester) async {
        final context = await pumpPractice(
          tester,
          journalFactory: (r) => _LoseFinishResponse(r.database, practice: r),
        );
        if (manual) {
          await tapSkillWidget(tester, find.text('Log past practice'));
          await tapSkillWidget(tester, find.text('Continue to entry'));
          await waitForSkillWidget(tester, field('Practice minutes'));
          await tester.enterText(field('Practice minutes'), '2');
          await tapSkillWidget(
            tester,
            find.text('I confirm this duration and date are my own entry.'),
          );
        } else {
          await openReflection(tester, context);
        }
        await tester.ensureVisible(field('What got easier? · optional'));
        await tester.enterText(
          field('What got easier? · optional'),
          'Committed once',
        );
        await tapSkillWidget(tester, find.text('Save and finish'));
        await waitForSkillWidget(tester, find.text('Not saved yet'));
        final engine = context.container.read(practiceEngineProvider);
        final id = engine.record!.session.id;
        final committed = (await driveAsync(
          tester,
          context.container.read(journalRepositoryProvider).find(id),
        ))!;
        expect(committed.session.status, 'completed');
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 1100)),
        );
        await tapSkillWidget(tester, find.text('Save and finish'));
        await waitForSkillWidget(tester, find.text('Saved on this device'));
        final retried = (await driveAsync(
          tester,
          context.container.read(journalRepositoryProvider).find(id),
        ))!;
        expect(retried.session, committed.session);
        expect(
          await driveAsync(
            tester,
            context.db.select(context.db.sessions).get(),
          ),
          hasLength(1),
        );
        expect(
          await driveAsync(
            tester,
            context.container
                .read(journalRepositoryProvider)
                .draft(id, 'finish'),
          ),
          isNull,
        );
      },
    );
  }
}
