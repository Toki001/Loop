import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop/core/data/database/loop_database.dart';
import 'package:loop/features/practice/data/sessions_repository.dart';
import 'package:loop/features/practice/presentation/practice_providers.dart';
import 'package:loop/features/practice/presentation/practice_pages.dart';
import 'package:loop/features/skills/data/skill_management_repository.dart';
import 'package:loop/features/skills/domain/skill_draft.dart';
import 'package:loop/features/skills/domain/skill_kind.dart';

import 'app_test.dart' show pumpApp;
import 'practice_engine_test.dart'
    show TestPracticeClock, ControlledPracticeRepository;
import 'skill_widgets_test.dart' show field, waitForSkillWidget, tapSkillWidget;

class PracticeTestContext {
  const PracticeTestContext(
    this.db,
    this.repository,
    this.clock,
    this.container,
    this.skillId,
  );
  final LoopDatabase db;
  final ControlledPracticeRepository repository;
  final TestPracticeClock clock;
  final ProviderContainer container;
  final String skillId;
}

Future<PracticeTestContext> pumpPractice(
  WidgetTester tester, {
  String route = '/practice/setup',
  double scale = 1,
  Size size = const Size(390, 844),
  Future<void> Function(
    ControlledPracticeRepository repository,
    String skillId,
  )?
  prepare,
}) async {
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  final directory = (await tester.runAsync(
    () => Directory.systemTemp.createTemp('loop-practice-widget-'),
  ))!;
  final db = LoopDatabase(
    NativeDatabase(
      File('${directory.path}/loop.sqlite'),
      setup: (raw) => raw.execute('PRAGMA foreign_keys=ON'),
    ),
  );
  final skills = SkillManagementRepository(db);
  final skill = (await tester.runAsync(
    () => skills.create(
      const SkillDraft(
        name: 'Studio practice · 練習',
        kind: SkillKind.music,
        description: 'Synthetic verification fixture.',
      ),
    ),
  ))!;
  final repository = ControlledPracticeRepository(db);
  if (prepare != null)
    await tester.runAsync(() => prepare(repository, skill.id));
  final clock = TestPracticeClock();
  final container = await pumpApp(
    tester,
    route: route,
    scale: scale,
    size: size,
    skillRepository: skills,
    practiceRepository: repository,
    practiceClock: clock,
  );
  await tester.runAsync(() => container.read(practiceEngineProvider).idle);
  await tester.pumpAndSettle();
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
    await tester.runAsync(() async {
      await db.close();
      await directory.delete(recursive: true);
    });
  });
  return PracticeTestContext(db, repository, clock, container, skill.id);
}

Future<void> settlePractice(
  WidgetTester tester,
  PracticeTestContext context,
) async {
  await tester.runAsync(
    () => context.container.read(practiceEngineProvider).idle,
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'real setup validates plan, selects exercises and saves one completed session',
    (tester) async {
      final context = await pumpPractice(tester);
      await waitForSkillWidget(tester, field('Planned minutes'));
      await tester.enterText(field('Planned minutes'), '181');
      await tapSkillWidget(tester, find.text('Start practice'));
      expect(find.textContaining('Choose a plan from'), findsOneWidget);
      await tester.enterText(field('Planned minutes'), '10');
      final selected = find.byType(CheckboxListTile).first;
      await tapSkillWidget(tester, selected);
      await tapSkillWidget(tester, find.text('Start practice'));
      await waitForSkillWidget(tester, find.text('Pause'));
      final engine = context.container.read(practiceEngineProvider);
      expect(engine.running, true);
      expect(engine.record!.exercises, hasLength(1));
      context.clock.advance(const Duration(milliseconds: 65432));
      await tapSkillWidget(tester, find.text('Pause'));
      await settlePractice(tester, context);
      await tester.ensureVisible(field('Practice note · optional'));
      await tester.enterText(
        field('Practice note · optional'),
        'A real saved observation',
      );
      await tapSkillWidget(tester, find.text('Finish'));
      await waitForSkillWidget(tester, find.text('Save and finish'));
      await tapSkillWidget(tester, find.text('Save and finish'));
      await waitForSkillWidget(tester, find.text('Saved on this device'));
      final rows = (await tester.runAsync(
        () => context.db.select(context.db.sessions).get(),
      ))!;
      expect(rows, hasLength(1));
      expect(rows.single.status, 'completed');
      expect(rows.single.activeSeconds, 65);
      expect(rows.single.note, 'A real saved observation');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'long skill names remain readable and selection uses immutable identity',
    (tester) async {
      final longName = List.filled(55, 'A').join() + ' · 練習';
      late String secondId;
      final context = await pumpPractice(
        tester,
        scale: 2,
        size: const Size(320, 640),
        prepare: (repository, _) async {
          secondId =
              (await SkillManagementRepository(repository.database).create(
                SkillDraft(
                  name: longName,
                  kind: SkillKind.custom,
                  includeStarters: false,
                ),
              )).id;
        },
      );
      await tapSkillWidget(tester, find.text('Change skill'));
      await tapSkillWidget(tester, find.text(longName));
      await tapSkillWidget(tester, find.text('Start practice'));
      await waitForSkillWidget(tester, find.text('Pause'));
      expect(
        context.container.read(practiceEngineProvider).record!.session.skillId,
        secondId,
      );
      await tapSkillWidget(tester, find.text('Pause'));
      await settlePractice(tester, context);
      expect(find.text(longName), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'native lifecycle adapter pauses and never resumes after ten minutes away',
    (tester) async {
      final context = await pumpPractice(tester);
      await tapSkillWidget(tester, find.text('Start practice'));
      await waitForSkillWidget(tester, find.text('Pause'));
      final engine = context.container.read(practiceEngineProvider);
      context.clock.advance(const Duration(minutes: 2));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      context.clock.advance(const Duration(minutes: 10));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await settlePractice(tester, context);
      expect(engine.seconds, 120);
      expect(engine.running, false);
      expect(find.text('Paused while you were away'), findsOneWidget);
      expect(find.text('Resume').hitTestable(), findsOneWidget);
      await tapSkillWidget(tester, find.text('Resume'));
      await settlePractice(tester, context);
      context.clock.advance(const Duration(seconds: 3));
      await tapSkillWidget(tester, find.text('Pause'));
      await settlePractice(tester, context);
      expect(engine.seconds, 123);
    },
  );

  testWidgets(
    'storage failure retains paused draft and permits real save retry',
    (tester) async {
      final context = await pumpPractice(tester);
      await tapSkillWidget(tester, find.text('Start practice'));
      await waitForSkillWidget(tester, find.text('Pause'));
      context.clock.advance(const Duration(seconds: 9));
      context.repository.fail = true;
      await tapSkillWidget(tester, find.text('Pause'));
      await settlePractice(tester, context);
      final engine = context.container.read(practiceEngineProvider);
      expect(engine.running, false);
      expect(find.text('Practice needs your attention'), findsOneWidget);
      expect(engine.seconds, 9);
      context.repository.fail = false;
      await tapSkillWidget(tester, find.text('Retry saving pause'));
      await settlePractice(tester, context);
      expect(engine.failure, isNull);
      expect(engine.record!.session.status, 'paused');
    },
  );

  testWidgets(
    'manual duration and confirmation persist accurate source and note',
    (tester) async {
      final context = await pumpPractice(tester);
      await tapSkillWidget(tester, find.text('Log past practice'));
      await tapSkillWidget(tester, find.text('Continue to entry'));
      await waitForSkillWidget(tester, field('Practice minutes'));
      await tester.enterText(field('Practice minutes'), '15');
      await tapSkillWidget(tester, find.text('Save manual practice'));
      expect(
        find.textContaining('Confirm the date and source'),
        findsOneWidget,
      );
      await tester.ensureVisible(field('Note · optional'));
      await tester.enterText(
        field('Note · optional'),
        'Manual practice, no timer',
      );
      await tapSkillWidget(
        tester,
        find.text('I confirm this duration and date are my own entry.'),
      );
      await tapSkillWidget(tester, find.text('Save manual practice'));
      await waitForSkillWidget(tester, find.text('Saved on this device'));
      final rows = (await tester.runAsync(
        () => context.db.select(context.db.sessions).get(),
      ))!;
      expect(rows.single.entryMode, 'manual');
      expect(rows.single.manualIntent, 'duration');
      expect(rows.single.activeSeconds, 900);
      expect(rows.single.note, 'Manual practice, no timer');
    },
  );

  testWidgets('short manual entries and future-date recovery are usable', (
    tester,
  ) async {
    final context = await pumpPractice(
      tester,
      route: '/practice/active',
      prepare: (repository, skillId) async {
        final draft = await repository.create(
          skillId: skillId,
          exerciseIds: [],
          mode: EntryMode.manual,
          manualIntent: ManualIntent.duration,
        );
        await repository.write(
          draft.session,
          milliseconds: 0,
          manualSeconds: 30,
          manualDateLocal: '2099-12-31',
        );
      },
    );
    await waitForSkillWidget(tester, field('Additional seconds'));
    expect(
      tester.widget<TextField>(field('Additional seconds')).controller!.text,
      '30',
    );
    await tapSkillWidget(tester, find.textContaining('Date:'));
    expect(find.byType(DatePickerDialog), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tapSkillWidget(tester, find.text('OK'));
    await tester.ensureVisible(field('Additional seconds'));
    await tester.enterText(field('Additional seconds'), '60');
    await tapSkillWidget(
      tester,
      find.text('I confirm this duration and date are my own entry.'),
    );
    await tapSkillWidget(tester, find.text('Save manual practice'));
    expect(find.textContaining('at least one second'), findsWidgets);
    await tester.ensureVisible(field('Additional seconds'));
    await tester.enterText(field('Additional seconds'), '30');
    await tapSkillWidget(tester, find.text('Save manual practice'));
    await waitForSkillWidget(tester, find.text('Saved on this device'));
    final rows = (await tester.runAsync(
      () => context.db.select(context.db.sessions).get(),
    ))!;
    expect(rows.single.activeSeconds, 30);
    expect(rows.single.entryMode, 'manual');
  });

  testWidgets('landscape at 200 percent retains Pause and Finish', (
    tester,
  ) async {
    final context = await pumpPractice(
      tester,
      size: const Size(600, 360),
      scale: 2,
    );
    await tapSkillWidget(tester, find.text('Start practice'));
    await waitForSkillWidget(tester, find.text('Pause'));
    expect(find.text('Pause').hitTestable(), findsOneWidget);
    expect(find.text('Finish').hitTestable(), findsOneWidget);
    await tapSkillWidget(tester, find.text('Pause'));
    await settlePractice(tester, context);
    expect(find.text('Resume').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('maximum manual duration remains readable at 200 percent', (
    tester,
  ) async {
    final context = await pumpPractice(
      tester,
      size: const Size(320, 640),
      scale: 2,
    );
    await tapSkillWidget(tester, find.text('Log past practice'));
    await tapSkillWidget(tester, find.text('Continue to entry'));
    await waitForSkillWidget(tester, field('Practice minutes'));
    await tester.enterText(field('Practice minutes'), '10080');
    await tester.drag(
      find.byType(SingleChildScrollView).last,
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    await tapSkillWidget(
      tester,
      find.text('I confirm this duration and date are my own entry.'),
    );
    await tapSkillWidget(tester, find.text('Save manual practice'));
    await waitForSkillWidget(tester, find.text('Saved on this device'));
    await tester.ensureVisible(find.text('10080:00'));
    await tester.pumpAndSettle();
    expect(tester.getRect(find.text('10080:00')).width, lessThanOrEqualTo(289));
    expect(
      context.container
          .read(practiceEngineProvider)
          .record!
          .session
          .activeSeconds,
      604800,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'finishing one preserved legacy draft leaves the next draft accessible',
    (tester) async {
      final context = await pumpPractice(
        tester,
        prepare: (repository, skillId) async {
          await repository.sessions.createDraft(skillId);
          await repository.sessions.createDraft(skillId);
        },
      );
      final engine = context.container.read(practiceEngineProvider);
      final firstId = engine.record!.session.id;
      await tapSkillWidget(tester, find.text('Open practice'));
      await waitForSkillWidget(tester, find.text('Start practice'));
      await tapSkillWidget(tester, find.text('Start practice'));
      await settlePractice(tester, context);
      context.clock.advance(const Duration(seconds: 1));
      await tapSkillWidget(tester, find.text('Finish'));
      await tapSkillWidget(tester, find.text('Save and finish'));
      await waitForSkillWidget(tester, find.text('Saved on this device'));
      await tapSkillWidget(tester, find.text('Back to Today'));
      await waitForSkillWidget(tester, find.text('Your unfinished practice'));
      await tapSkillWidget(tester, find.text('Open practice'));
      await waitForSkillWidget(tester, find.text('Start practice'));
      expect(engine.record!.session.id, isNot(firstId));
      expect(engine.record!.session.status, 'draft');
      final rows = (await tester.runAsync(
        () => context.db.select(context.db.sessions).get(),
      ))!;
      expect(rows, hasLength(2));
      expect(rows.where((s) => s.status == 'completed'), hasLength(1));
    },
  );

  testWidgets('journal-only zero duration is deliberate and labeled', (
    tester,
  ) async {
    final context = await pumpPractice(tester);
    await tapSkillWidget(tester, find.text('Journal only'));
    await tapSkillWidget(tester, find.text('Continue to entry'));
    await waitForSkillWidget(tester, find.text('Zero practice minutes'));
    expect(field('Practice minutes'), findsNothing);
    await tapSkillWidget(
      tester,
      find.text('I intend to save a journal entry with no practice time.'),
    );
    await tapSkillWidget(tester, find.text('Save journal entry'));
    await waitForSkillWidget(tester, find.text('Saved on this device'));
    expect(find.text('Journal entry · zero practice minutes'), findsOneWidget);
    final rows = (await tester.runAsync(
      () => context.db.select(context.db.sessions).get(),
    ))!;
    expect(rows.single.manualIntent, 'evidence_only');
    expect(rows.single.activeSeconds, 0);
  });

  testWidgets(
    '200 percent text keyboard controls and accessible timer remain usable',
    (tester) async {
      final context = await pumpPractice(
        tester,
        size: const Size(320, 640),
        scale: 2,
      );
      await tapSkillWidget(tester, find.text('Start practice'));
      await waitForSkillWidget(tester, find.text('Pause'));
      final semantics = tester.ensureSemantics();
      expect(
        find.bySemanticsLabel(RegExp('0 minutes 0 seconds')),
        findsOneWidget,
      );
      expect(find.text('Pause').hitTestable(), findsOneWidget);
      expect(find.text('Finish').hitTestable(), findsOneWidget);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      semantics.dispose();
      await tapSkillWidget(tester, find.text('Pause'));
      await settlePractice(tester, context);
      await tester.ensureVisible(field('Practice note · optional'));
      await tester.showKeyboard(field('Practice note · optional'));
      tester.view.viewInsets = const FakeViewPadding(bottom: 220);
      await tester.pumpAndSettle();
      expect(find.text('Resume').hitTestable(), findsOneWidget);
      expect(find.text('Finish').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
      tester.view.resetViewInsets();
    },
  );

  testWidgets('back saves paused note and Today opens the same draft', (
    tester,
  ) async {
    final context = await pumpPractice(tester);
    await tapSkillWidget(tester, find.text('Start practice'));
    await waitForSkillWidget(tester, find.text('Pause'));
    context.clock.advance(const Duration(seconds: 8));
    await tapSkillWidget(tester, find.text('Pause'));
    await settlePractice(tester, context);
    await tester.ensureVisible(field('Practice note · optional'));
    await tester.enterText(
      field('Practice note · optional'),
      'Retained on leaving',
    );
    await tester.pageBack();
    await settlePractice(tester, context);
    await waitForSkillWidget(tester, find.text('Your unfinished practice'));
    await tapSkillWidget(tester, find.text('Open practice'));
    await waitForSkillWidget(tester, field('Practice note · optional'));
    expect(
      tester
          .widget<TextField>(field('Practice note · optional'))
          .controller!
          .text,
      'Retained on leaving',
    );
    expect(find.byType(ActivePracticePage), findsOneWidget);
  });
}
