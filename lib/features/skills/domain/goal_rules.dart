import '../../../core/data/database/loop_database.dart';
import '../../../core/data/local_failure.dart';
import '../../../core/data/validation.dart';

enum GoalType {
  cumulative('cumulative'),
  threshold('threshold'),
  weeklyTarget('weekly_target'),
  deliverable('deliverable'),
  qualitative('qualitative');

  const GoalType(this.stored);
  final String stored;
}

class GoalDraft {
  const GoalDraft({
    required this.title,
    required this.type,
    this.definition,
    this.target,
    this.unit,
    this.dateLocal,
    this.motivation,
  });
  final String title;
  final GoalType type;
  final MetricDefinition? definition;
  final double? target;
  final String? unit;
  final String? dateLocal;
  final String? motivation;

  static bool validLocalDate(String value) {
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) return false;
    final parts = value.split('-').map(int.parse).toList();
    final parsed = DateTime.utc(parts[0], parts[1], parts[2]);
    return parts[0] >= 1900 &&
        parsed.year == parts[0] &&
        parsed.month == parts[1] &&
        parsed.day == parts[2];
  }

  void validate(String skillId, {Goal? existing}) {
    validName(title, maximum: 120);
    validText(motivation, maximum: 4000);
    finite(target);
    if (dateLocal != null && !validLocalDate(dateLocal!)) _invalid();
    final metric = definition;
    if (metric != null &&
        (metric.skillId != skillId ||
            metric.valueType != 'numeric' ||
            metric.archivedAtUtc != null &&
                !(existing?.metricDefinitionId == metric.id &&
                    existing?.definitionVersion == metric.version))) {
      _invalid();
    }
    switch (type) {
      case GoalType.qualitative || GoalType.deliverable:
        if (target != null || unit != null || metric != null) _invalid();
      case GoalType.weeklyTarget:
        if (metric != null ||
            unit != 'days_per_week' ||
            target == null ||
            target! < 1 ||
            target! > 7 ||
            target! != target!.roundToDouble())
          _invalid();
      case GoalType.cumulative:
        if (target == null || target! <= 0) _invalid();
        if (metric == null) {
          if (!['practice_sessions', 'practice_seconds'].contains(unit))
            _invalid();
        } else if (!['count', 'seconds'].contains(metric.unitKey) ||
            unit != metric.unitKey ||
            (metric.scaleMin ?? 0) < 0 ||
            metric.direction != 'up') {
          _invalid();
        }
        if ((unit == 'count' || unit == 'practice_sessions') &&
            target! != target!.roundToDouble())
          _invalid();
      case GoalType.threshold:
        if (metric == null ||
            target == null ||
            unit != metric.unitKey ||
            !['up', 'down', 'toward_target'].contains(metric.direction) ||
            metric.unitKey == 'rating_1_5')
          _invalid();
        if ((metric.scaleMin != null && target! < metric.scaleMin!) ||
            (metric.scaleMax != null && target! > metric.scaleMax!))
          _invalid();
        if (metric.unitKey == 'count' && target! != target!.roundToDouble())
          _invalid();
    }
  }

  Never _invalid() => throw const LocalFailure(LocalFailureKind.invalid);
}

class GoalProgress {
  const GoalProgress({
    required this.label,
    required this.scope,
    this.observed,
    this.fraction,
    this.targetMet,
    this.sampleCount = 0,
    this.source,
  });
  final String label;
  final String scope;
  final double? observed;
  final double? fraction;
  final bool? targetMet;
  final int sampleCount;
  final String? source;

  static GoalProgress calculate(
    Goal goal, {
    required List<Session> sessions,
    required List<MetricDefinition> definitions,
    required List<MetricReading> readings,
    required DateTime todayLocal,
    int weekStartsOn = DateTime.monday,
    DateTime Function(DateTime)? localize,
  }) {
    const scope = 'All recorded completed sessions';
    if (goal.type == 'qualitative' || goal.type == 'deliverable') {
      return GoalProgress(
        label: goal.completedAtUtc != null
            ? 'Marked complete by you'
            : 'Not marked complete',
        scope: 'Your own milestone; no percentage',
      );
    }
    final completed = {
      for (final s in sessions)
        if (s.skillId == goal.skillId && s.status == 'completed') s.id: s,
    };
    final target = goal.targetValue;
    if (target == null || !target.isFinite) {
      return const GoalProgress(
        label: 'Choose a valid target to show progress',
        scope: scope,
      );
    }
    if (goal.type == 'weekly_target') {
      if (goal.targetUnit != 'days_per_week' ||
          goal.metricDefinitionId != null ||
          target != target.roundToDouble()) {
        return const GoalProgress(
          label: 'This weekly measure needs review',
          scope: 'Only whole practice days per week are comparable here',
        );
      }
      if (weekStartsOn < 1 || weekStartsOn > 7 || target < 1 || target > 7) {
        return const GoalProgress(
          label: 'Choose a valid weekly target',
          scope: 'Current local calendar week',
        );
      }
      final offset = (todayLocal.weekday - weekStartsOn) % 7;
      final start = DateTime(
        todayLocal.year,
        todayLocal.month,
        todayLocal.day - offset,
      );
      final end = DateTime(start.year, start.month, start.day + 7);
      int day(DateTime d) => d.year * 10000 + d.month * 100 + d.day;
      final dates = <int>{};
      for (final s in completed.values) {
        // Evidence-only entries are journal context, not practiced days here.
        if (s.endedAtUtc == null || s.activeSeconds == 0) continue;
        final date = (localize ?? (value) => value.toLocal())(s.endedAtUtc!);
        if (day(date) >= day(start) &&
            day(date) < day(end) &&
            day(date) <= day(todayLocal))
          dates.add(day(date));
      }
      return GoalProgress(
        label: '${dates.length} of ${target.toInt()} practice days',
        scope: 'Current local calendar week; a suggestion, not a score',
        observed: dates.length.toDouble(),
        fraction: (dates.length / target).clamp(0, 1),
        targetMet: dates.length >= target,
        sampleCount: dates.length,
      );
    }
    if (goal.metricDefinitionId == null) {
      if (goal.type != 'cumulative' ||
          target <= 0 ||
          ![
            'practice_sessions',
            'practice_seconds',
          ].contains(goal.targetUnit)) {
        return const GoalProgress(
          label: 'Choose a compatible measure',
          scope: scope,
        );
      }
      final practice = completed.values.where((s) => s.activeSeconds > 0);
      final value = goal.targetUnit == 'practice_sessions'
          ? practice.length.toDouble()
          : practice.fold<double>(0, (sum, s) => sum + s.activeSeconds);
      return GoalProgress(
        label: 'Recorded practice',
        scope: scope,
        observed: value,
        fraction: (value / target).clamp(0, 1),
        targetMet: value >= target,
        sampleCount: practice.length,
        source: 'Recorded timed or explicitly entered duration',
      );
    }
    final matches = definitions.where(
      (d) =>
          d.id == goal.metricDefinitionId &&
          d.version == goal.definitionVersion &&
          d.skillId == goal.skillId,
    );
    if (matches.length != 1 ||
        matches.single.unitKey != goal.targetUnit ||
        matches.single.valueType != 'numeric') {
      return const GoalProgress(
        label: 'This measure cannot be compared',
        scope: scope,
      );
    }
    final definition = matches.single;
    final values = readings
        .where(
          (r) =>
              completed.containsKey(r.sessionId) &&
              r.metricDefinitionId == definition.id &&
              r.definitionVersion == definition.version,
        )
        .toList();
    if (values.isEmpty) {
      return const GoalProgress(
        label: 'No qualifying measurements yet',
        scope: scope,
      );
    }
    if (values.map((r) => r.sessionId).toSet().length != values.length) {
      return const GoalProgress(
        label: 'Repeated readings need review before aggregation',
        scope: scope,
      );
    }
    if (values.any(
      (r) =>
          r.numericValue == null ||
          !r.numericValue!.isFinite ||
          (definition.unitKey == 'count' &&
              r.numericValue != r.numericValue!.roundToDouble()),
    )) {
      return const GoalProgress(
        label: 'Measurements need compatible values',
        scope: scope,
      );
    }
    final methods = values
        .map((r) => (r.sourceType, r.sourceNote?.trim() ?? ''))
        .toSet();
    if (methods.length != 1) {
      return const GoalProgress(
        label: 'Measurement methods differ; progress is unavailable',
        scope: scope,
      );
    }
    final source =
        '${values.first.sourceType == 'self_reported' ? 'Self-reported' : values.first.sourceType}: ${methods.single.$2.isEmpty ? 'method not specified' : methods.single.$2}';
    if (goal.type == 'cumulative') {
      if (target <= 0 ||
          !['count', 'seconds'].contains(definition.unitKey) ||
          definition.direction != 'up' ||
          values.any((r) => r.numericValue! < 0)) {
        return const GoalProgress(
          label: 'This measure is not additive',
          scope: scope,
        );
      }
      final value = values.fold<double>(0, (sum, r) => sum + r.numericValue!);
      if (!value.isFinite)
        return const GoalProgress(
          label: 'The recorded total is too large',
          scope: scope,
        );
      return GoalProgress(
        label: 'Recorded total',
        scope: scope,
        observed: value,
        fraction: (value / target).clamp(0, 1),
        targetMet: value >= target,
        sampleCount: values.length,
        source: source,
      );
    }
    if (goal.type != 'threshold' ||
        definition.unitKey == 'rating_1_5' ||
        !['up', 'down', 'toward_target'].contains(definition.direction)) {
      return const GoalProgress(
        label: 'This measure has no numeric target progress',
        scope: scope,
      );
    }
    values.sort((a, b) {
      final date = b.measuredAtUtc.compareTo(a.measuredAtUtc);
      return date != 0 ? date : a.id.compareTo(b.id);
    });
    final latest = values.first.numericValue!;
    if (values
            .takeWhile((r) => r.measuredAtUtc == values.first.measuredAtUtc)
            .map((r) => r.numericValue)
            .toSet()
            .length >
        1) {
      return const GoalProgress(
        label: 'Latest measurements share a time but differ; no single latest value',
        scope: scope,
      );
    }
    final met = switch (definition.direction) {
      'up' => latest >= target,
      'down' => latest <= target,
      _ => latest == target,
    };
    return GoalProgress(
      label: 'Latest comparable value',
      scope: scope,
      observed: latest,
      targetMet: met,
      sampleCount: values.length,
      source: source,
    );
  }
}
