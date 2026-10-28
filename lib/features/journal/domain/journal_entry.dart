import '../../../core/data/database/loop_database.dart';
import '../../../core/data/local_failure.dart';
import '../../../core/data/validation.dart';

class JournalReadingInput {
  const JournalReadingInput({
    required this.definitionId,
    required this.version,
    this.numericValue,
    this.textValue,
    this.boolValue,
    this.sourceType = 'self_reported',
    this.sourceNote,
  });
  factory JournalReadingInput.fromReading(MetricReading reading) =>
      JournalReadingInput(
        definitionId: reading.metricDefinitionId,
        version: reading.definitionVersion,
        numericValue: reading.numericValue,
        textValue: reading.textValue,
        boolValue: reading.boolValue,
        sourceType: reading.sourceType,
        sourceNote: reading.sourceNote,
      );
  final String definitionId;
  final int version;
  final double? numericValue;
  final String? textValue;
  final bool? boolValue;
  final String sourceType;
  final String? sourceNote;

  bool matches(MetricReading value) =>
      definitionId == value.metricDefinitionId &&
      version == value.definitionVersion &&
      numericValue == value.numericValue &&
      textValue == value.textValue &&
      boolValue == value.boolValue &&
      sourceType == value.sourceType &&
      (sourceNote ?? '') == (value.sourceNote ?? '');
}

class JournalReflection {
  JournalReflection({
    this.note = '',
    this.whatGotEasier = '',
    this.nextStep = '',
    this.effortRating,
    List<JournalReadingInput> readings = const [],
  }) : readings = List.unmodifiable(readings);
  factory JournalReflection.fromSession(
    Session session, [
    List<MetricReading> readings = const [],
  ]) => JournalReflection(
    note: session.note ?? '',
    whatGotEasier: session.whatGotEasier ?? '',
    nextStep: session.nextStep ?? '',
    effortRating: session.effortRating,
    readings: readings.map(JournalReadingInput.fromReading).toList(),
  );
  final String note;
  final String whatGotEasier;
  final String nextStep;
  final int? effortRating;
  final List<JournalReadingInput> readings;

  void validate() {
    validText(note);
    validText(whatGotEasier);
    validText(nextStep, maximum: 10000);
    if (effortRating != null && (effortRating! < 1 || effortRating! > 5) ||
        readings.length > 100 ||
        readings.map((r) => r.definitionId).toSet().length != readings.length) {
      throw const LocalFailure(LocalFailureKind.invalid);
    }
    for (final reading in readings) {
      finite(reading.numericValue);
      validText(reading.textValue);
      validText(reading.sourceNote, maximum: 10000);
    }
  }

  bool matches(Session session, List<MetricReading> values) =>
      note == (session.note ?? '') &&
      whatGotEasier == (session.whatGotEasier ?? '') &&
      nextStep == (session.nextStep ?? '') &&
      effortRating == session.effortRating &&
      values.length == readings.length &&
      readings.every((r) => values.any(r.matches));
}

class JournalDetail {
  const JournalDetail({
    required this.session,
    required this.skill,
    required this.exercises,
    required this.readings,
    required this.definitions,
    required this.mediaCount,
  });
  final Session session;
  final Skill skill;
  final List<SessionExercise> exercises;
  final List<MetricReading> readings;
  final List<MetricDefinition> definitions;
  final int mediaCount;
}

class JournalSummary {
  const JournalSummary(this.session, this.skillName);
  final Session session;
  final String skillName;
}

class JournalFilter {
  const JournalFilter({
    this.skillId,
    this.fromUtc,
    this.untilUtc,
    this.exerciseTitle,
    this.limit = 50,
  });
  final String? skillId;
  final DateTime? fromUtc;
  final DateTime? untilUtc;
  final String? exerciseTitle;
  final int limit;

  @override
  bool operator ==(Object other) =>
      other is JournalFilter &&
      skillId == other.skillId &&
      fromUtc == other.fromUtc &&
      untilUtc == other.untilUtc &&
      exerciseTitle == other.exerciseTitle &&
      limit == other.limit;
  @override
  int get hashCode =>
      Object.hash(skillId, fromUtc, untilUtc, exerciseTitle, limit);

  /// Construct next calendar midnight before UTC conversion (DST-safe).
  static DateTime nextLocalDay(DateTime date) =>
      DateTime(date.year, date.month, date.day + 1);
}

class ManualJournalAmendment {
  const ManualJournalAmendment({
    required this.seconds,
    required this.endedAtUtc,
    required this.confirmed,
  });
  final int seconds;
  final DateTime endedAtUtc;
  final bool confirmed;
}

/// Only metadata-only deletion can safely offer immediate in-memory Undo.
class DeletedJournalEntry {
  const DeletedJournalEntry({
    required this.session,
    required this.exercises,
    required this.readings,
    required this.checkpoint,
    required this.drafts,
    required this.canUndo,
  });
  final Session session;
  final List<SessionExercise> exercises;
  final List<MetricReading> readings;
  final PracticeCheckpoint? checkpoint;
  final List<JournalDraft> drafts;
  final bool canUndo;
}

bool validJournalReading(
  JournalReadingInput reading,
  MetricDefinition definition,
) {
  final number = reading.numericValue;
  if (reading.version != definition.version ||
      reading.definitionId != definition.id)
    return false;
  switch (definition.valueType) {
    case 'numeric':
      if (number == null ||
          !number.isFinite ||
          reading.textValue != null ||
          reading.boolValue != null ||
          definition.scaleMin != null && number < definition.scaleMin! ||
          definition.scaleMax != null && number > definition.scaleMax!)
        return false;
      return switch (definition.unitKey) {
        'count' => number >= 0 && number == number.truncateToDouble(),
        'rating_1_5' =>
          number >= 1 && number <= 5 && number == number.truncateToDouble(),
        'percent' => number >= 0 && number <= 100,
        'bpm' => number > 0,
        'wpm' || 'clean_changes_per_min' || 'seconds' => number >= 0,
        _ => true,
      };
    case 'text':
      return reading.textValue != null &&
          number == null &&
          reading.boolValue == null;
    case 'checklist':
      return reading.boolValue != null &&
          number == null &&
          reading.textValue == null;
    default:
      return false;
  }
}

class JournalOverview {
  const JournalOverview({required this.sessions, required this.seconds});
  final int sessions;
  final int seconds;
}
