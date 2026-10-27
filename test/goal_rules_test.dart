import 'package:flutter_test/flutter_test.dart';
import 'package:loop/core/data/database/loop_database.dart';
import 'package:loop/core/data/local_failure.dart';
import 'package:loop/features/skills/domain/goal_rules.dart';

final instant = DateTime.utc(2026, 10, 27, 12);

Goal goal({
  String type = 'cumulative',
  String? metric = 'metric',
  String unit = 'count',
  double target = 10,
  String status = 'active',
  DateTime? completed,
}) => Goal(
  id: 'goal',
  skillId: 'skill',
  title: 'Synthetic goal',
  type: type,
  metricDefinitionId: metric,
  definitionVersion: metric == null ? null : 1,
  targetValue: target,
  targetUnit: unit,
  status: status,
  completedAtUtc: completed,
  createdAtUtc: instant,
  updatedAtUtc: instant,
);

MetricDefinition definition({
  String unit = 'count',
  String direction = 'up',
  int version = 1,
}) => MetricDefinition(
  id: 'metric',
  version: version,
  skillId: 'skill',
  label: 'Synthetic measure',
  unitKey: unit,
  valueType: 'numeric',
  direction: direction,
  sourceHint: 'manual',
  scaleMin: 0,
);

Session session(
  String id, {
  DateTime? ended,
  int seconds = 60,
  String status = 'completed',
}) => Session(
  id: id,
  skillId: 'skill',
  activeSeconds: seconds,
  entryMode: 'timed',
  status: status,
  createdAtUtc: instant,
  updatedAtUtc: instant,
  revision: 0,
  startedAtUtc: instant,
  endedAtUtc: ended ?? instant,
);

MetricReading reading(
  String id,
  String sessionId,
  double value, {
  int version = 1,
  String source = 'self_reported',
  String? method = 'Same test',
  DateTime? at,
}) => MetricReading(
  id: id,
  sessionId: sessionId,
  metricDefinitionId: 'metric',
  definitionVersion: version,
  numericValue: value,
  sourceType: source,
  sourceNote: method,
  measuredAtUtc: at ?? instant,
  createdAtUtc: instant,
);

GoalProgress calculate(
  Goal value, {
  List<Session>? sessions,
  List<MetricDefinition>? definitions,
  List<MetricReading>? readings,
}) => GoalProgress.calculate(
  value,
  sessions: sessions ?? [session('a'), session('b')],
  definitions: definitions ?? [definition()],
  readings: readings ?? [],
  todayLocal: DateTime(2026, 10, 27),
);

void main() {
  test(
    'qualitative and deliverable use explicit completion without a fraction',
    () {
      for (final type in ['qualitative', 'deliverable']) {
        final pending = calculate(goal(type: type));
        final complete = calculate(
          goal(type: type, completed: instant, status: 'completed'),
        );
        expect(pending.fraction, isNull);
        expect(pending.observed, isNull);
        expect(complete.fraction, isNull);
        expect(complete.label, 'Marked complete by you');
      }
    },
  );

  test(
    'absent observations remain absent; true recorded zero remains zero',
    () {
      expect(calculate(goal()).observed, isNull);
      expect(calculate(goal()).fraction, isNull);
      final zero = calculate(goal(), readings: [reading('1', 'a', 0)]);
      expect(zero.observed, 0);
      expect(zero.fraction, 0);
    },
  );

  test(
    'additive count overachievement retains raw total and clamps fraction',
    () {
      final progress = calculate(
        goal(),
        readings: [reading('1', 'a', 8), reading('2', 'b', 7)],
      );
      expect(progress.observed, 15);
      expect(progress.fraction, 1);
      expect(progress.targetMet, true);
      expect(progress.sampleCount, 2);
      expect(progress.source, contains('Self-reported'));
    },
  );

  test(
    'amended value replaces its record; duplicate attempts do not double count',
    () {
      final updated = reading('1', 'a', 5);
      expect(calculate(goal(), readings: [updated]).observed, 5);
      expect(calculate(goal(), readings: [updated, updated]).observed, isNull);
    },
  );

  test(
    'wrong version, wrong session and unfinished records cannot contribute',
    () {
      final data = [
        reading('1', 'a', 4),
        reading('2', 'b', 9),
        reading('3', 'unknown', 100),
        reading('4', 'a', 200, version: 2),
      ];
      final progress = calculate(
        goal(),
        sessions: [
          session('a'),
          session('b', status: 'paused'),
        ],
        readings: data,
      );
      expect(progress.observed, 4);
      expect(progress.sampleCount, 1);
    },
  );

  test(
    'source/method mismatch and fractional counts do not produce progress',
    () {
      for (final readings in [
        [reading('1', 'a', 4), reading('2', 'b', 4, method: 'Different test')],
        [
          reading('1', 'a', 4),
          reading('2', 'b', 4, source: 'instrument_import'),
        ],
        [reading('1', 'a', 4.5)],
      ]) {
        expect(calculate(goal(), readings: readings).observed, isNull);
        expect(calculate(goal(), readings: readings).fraction, isNull);
      }
    },
  );

  test(
    'WPM, percentage and ordinal values cannot be summed into achievement',
    () {
      for (final unit in ['wpm', 'percent', 'rating_1_5']) {
        final progress = calculate(
          goal(unit: unit),
          definitions: [definition(unit: unit)],
          readings: [reading('1', 'a', 4)],
        );
        expect(progress.observed, isNull);
        expect(progress.fraction, isNull);
      }
    },
  );

  test('threshold uses latest compatible raw value, direction and no mastery fraction', () {
    final records = [
      reading('1', 'a', 40, at: instant.subtract(const Duration(days: 1))),
      reading('2', 'b', 60),
    ];
    final up = calculate(
      goal(type: 'threshold', unit: 'wpm', target: 50),
      definitions: [definition(unit: 'wpm')],
      readings: records,
    );
    expect(up.observed, 60);
    expect(up.targetMet, true);
    expect(up.fraction, isNull);
    final down = calculate(
      goal(type: 'threshold', target: 70),
      definitions: [definition(direction: 'down')],
      readings: records,
    );
    expect(down.observed, 60);
    expect(down.targetMet, true);
    expect(down.fraction, isNull);
  });

  test(
    'equal-time differing observations do not invent a latest measurement',
    () {
      final result = calculate(
        goal(type: 'threshold'),
        readings: [reading('1', 'a', 4), reading('2', 'b', 8)],
      );
      expect(result.observed, isNull);
      expect(result.targetMet, isNull);
    },
  );

  test(
    'practice context uses unique completed positive-duration entries only',
    () {
      final data = [
        session('a', seconds: 30),
        session('b', seconds: 90),
        session('a', seconds: 30),
        session('zero', seconds: 0),
        session('draft', status: 'draft'),
      ];
      expect(
        calculate(
          goal(metric: null, unit: 'practice_sessions'),
          sessions: data,
        ).observed,
        2,
      );
      expect(
        calculate(
          goal(metric: null, unit: 'practice_seconds', target: 600),
          sessions: data,
        ).observed,
        120,
      );
    },
  );

  test(
    'legacy weekly session targets are never relabeled as practice days',
    () {
      final result = GoalProgress.calculate(
        goal(type: 'weekly_target', metric: null, unit: 'sessions', target: 3),
        sessions: [],
        definitions: [],
        readings: [],
        todayLocal: DateTime(2026, 10, 27),
      );
      expect(result.observed, isNull);
      expect(result.fraction, isNull);
      expect(result.label, 'This weekly measure needs review');
    },
  );

  test('weekly suggestion uses distinct local days, not entries, future dates or wall time', () {
    final result = GoalProgress.calculate(
      goal(
        type: 'weekly_target',
        metric: null,
        unit: 'days_per_week',
        target: 3,
      ),
      sessions: [
        session('mon1', ended: DateTime.utc(2026, 10, 26, 1)),
        session('mon2', ended: DateTime.utc(2026, 10, 26, 2)),
        session('tue', ended: DateTime.utc(2026, 10, 27)),
        session('before', ended: DateTime.utc(2026, 10, 25)),
        session('future', ended: DateTime.utc(2026, 10, 28)),
        session('zero', seconds: 0),
      ],
      definitions: [],
      readings: [],
      todayLocal: DateTime(2026, 10, 27),
      localize: (utc) => utc,
    );
    expect(result.observed, 2);
    expect(result.fraction, closeTo(2 / 3, 0.00001));
    expect(result.targetMet, false);
  });

  test('invalid goals, normalized date rollover and cross-skill measures are rejected', () {
    expect(GoalDraft.validLocalDate('2028-02-29'), true);
    for (final date in [
      '2027-02-29',
      '2026-13-01',
      '2026-01-32',
      '2026-1-01',
    ]) {
      expect(GoalDraft.validLocalDate(date), false);
    }
    for (final draft in [
      const GoalDraft(
        title: 'Bad',
        type: GoalType.weeklyTarget,
        unit: 'days_per_week',
        target: 0,
      ),
      const GoalDraft(
        title: 'Bad',
        type: GoalType.cumulative,
        unit: 'practice_sessions',
        target: double.nan,
      ),
      GoalDraft(
        title: 'Bad',
        type: GoalType.cumulative,
        definition: definition(unit: 'wpm'),
        unit: 'wpm',
        target: 10,
      ),
      GoalDraft(
        title: 'Bad',
        type: GoalType.threshold,
        definition: definition().copyWith(skillId: 'other'),
        unit: 'count',
        target: 10,
      ),
    ]) {
      expect(() => draft.validate('skill'), throwsA(isA<LocalFailure>()));
    }
  });
}
