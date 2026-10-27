import '../../../core/data/local_failure.dart';
import '../../../core/data/validation.dart';

/// A user-owned measurement definition. Creating a goal creates no readings.
class GoalMeasure {
  const GoalMeasure({
    required this.label,
    required this.unit,
    required this.direction,
  });
  final String label;
  final String unit;
  final String direction;
  void validate() {
    validName(label, maximum: 120);
    validName(unit, maximum: 80);
    if (!RegExp(r'^[a-z][a-z0-9_]{0,79}$').hasMatch(unit) ||
        !['up', 'down', 'toward_target'].contains(direction) ||
        [
          'rating_1_5',
          'practice_sessions',
          'practice_seconds',
          'days_per_week',
        ].contains(unit)) {
      throw const LocalFailure(LocalFailureKind.invalid);
    }
  }
}
