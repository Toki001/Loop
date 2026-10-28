import 'dart:convert';

import '../../../core/data/database/loop_database.dart';
import '../../../core/data/local_failure.dart';
import 'journal_entry.dart';

class JournalFormValidation implements Exception {
  const JournalFormValidation(this.message);
  final String message;
}

class JournalReadingForm {
  JournalReadingForm({
    required this.definitionId,
    required this.version,
    this.value = '',
    this.checked = false,
    this.sourceNote = '',
    this.sourceType = 'self_reported',
  });
  final String definitionId;
  final int version;
  String value;
  bool checked;
  String sourceNote;
  String sourceType;
  Map<String, Object?> toJson() => {
    'definitionId': definitionId,
    'version': version,
    'value': value,
    'checked': checked,
    'sourceNote': sourceNote,
    'sourceType': sourceType,
  };
  factory JournalReadingForm.fromJson(Map<String, Object?> json) =>
      JournalReadingForm(
        definitionId: json['definitionId']! as String,
        version: json['version']! as int,
        value: json['value']! as String,
        checked: json['checked']! as bool,
        sourceNote: json['sourceNote']! as String,
        sourceType: json['sourceType']! as String,
      );
}

/// Raw, bounded text persists even while a number or sentence is unfinished.
class JournalFormData {
  JournalFormData({
    this.note = '',
    this.whatGotEasier = '',
    this.nextStep = '',
    this.effortRating,
    this.minutes = '',
    this.seconds = '',
    required this.dateLocal,
    this.manualConfirmed = false,
    List<JournalReadingForm>? readings,
  }) : readings = readings ?? [];
  String note;
  String whatGotEasier;
  String nextStep;
  int? effortRating;
  String minutes;
  String seconds;
  String dateLocal;
  bool manualConfirmed;
  final List<JournalReadingForm> readings;
  static String dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  factory JournalFormData.fromDetail(
    JournalDetail detail, {
    PracticeCheckpoint? checkpoint,
  }) {
    final session = detail.session;
    final duration = session.status == 'completed'
        ? session.activeSeconds
        : checkpoint?.manualSeconds ?? 0;
    return JournalFormData(
      note: session.note ?? '',
      whatGotEasier: session.whatGotEasier ?? '',
      nextStep: session.nextStep ?? '',
      effortRating: session.effortRating,
      minutes: duration == 0 ? '' : '${duration ~/ 60}',
      seconds: duration % 60 == 0 ? '' : '${duration % 60}',
      dateLocal: session.status == 'completed'
          ? dateKey(session.endedAtUtc!.toLocal())
          : checkpoint?.manualDateLocal ?? dateKey(DateTime.now()),
      readings: [
        for (final reading in detail.readings)
          JournalReadingForm(
            definitionId: reading.metricDefinitionId,
            version: reading.definitionVersion,
            value: reading.numericValue?.toString() ?? reading.textValue ?? '',
            checked: reading.boolValue ?? false,
            sourceNote: reading.sourceNote ?? '',
            sourceType: reading.sourceType,
          ),
      ],
    );
  }
  bool get withinDraftLimit => jsonEncode(toJson()).length <= 500000;
  Map<String, Object?> toJson() => {
    'version': 1,
    'note': note,
    'whatGotEasier': whatGotEasier,
    'nextStep': nextStep,
    'effortRating': effortRating,
    'minutes': minutes,
    'seconds': seconds,
    'dateLocal': dateLocal,
    'manualConfirmed': manualConfirmed,
    'readings': [for (final r in readings) r.toJson()],
  };
  factory JournalFormData.decode(String raw) {
    try {
      if (raw.length > 500000) throw const FormatException();
      final map = jsonDecode(raw) as Map<String, dynamic>;
      if (map['version'] != 1) throw const FormatException();
      final rows = map['readings'] as List<dynamic>;
      if (rows.length > 100) throw const FormatException();
      final form = JournalFormData(
        note: map['note'] as String,
        whatGotEasier: map['whatGotEasier'] as String,
        nextStep: map['nextStep'] as String,
        effortRating: map['effortRating'] as int?,
        minutes: map['minutes'] as String,
        seconds: map['seconds'] as String,
        dateLocal: map['dateLocal'] as String,
        manualConfirmed: map['manualConfirmed'] as bool,
        readings: [
          for (final row in rows)
            JournalReadingForm.fromJson(Map<String, Object?>.from(row as Map)),
        ],
      );
      if (form.note.length > 100000 ||
          form.whatGotEasier.length > 100000 ||
          form.nextStep.length > 10000)
        throw const FormatException();
      return form;
    } on Object {
      throw const LocalFailure(LocalFailureKind.corrupt);
    }
  }
  JournalReflection reflection(List<MetricDefinition> definitions) {
    final values = <JournalReadingInput>[];
    for (final reading in readings) {
      final definition = definitions
          .where(
            (d) => d.id == reading.definitionId && d.version == reading.version,
          )
          .firstOrNull;
      if (definition == null)
        throw const JournalFormValidation(
          'A selected measure is no longer available. Remove it or reload this record.',
        );
      final number = double.tryParse(reading.value.trim());
      if (definition.valueType == 'numeric' &&
          (number == null ||
              !number.isFinite ||
              definition.scaleMin != null && number < definition.scaleMin! ||
              definition.scaleMax != null && number > definition.scaleMax!))
        throw JournalFormValidation(
          'Enter a finite value in the allowed range for ${definition.label}, or remove that reading.',
        );
      if (definition.valueType == 'text' && reading.value.trim().isEmpty)
        throw JournalFormValidation(
          'Enter an observation for ${definition.label}, or remove that reading.',
        );
      values.add(
        JournalReadingInput(
          definitionId: definition.id,
          version: definition.version,
          numericValue: definition.valueType == 'numeric' ? number : null,
          textValue: definition.valueType == 'text' ? reading.value : null,
          boolValue: definition.valueType == 'checklist'
              ? reading.checked
              : null,
          sourceType: reading.sourceType,
          sourceNote: reading.sourceNote.isEmpty ? null : reading.sourceNote,
        ),
      );
    }
    for (final reading in values) {
      final definition = definitions.firstWhere(
        (d) => d.id == reading.definitionId && d.version == reading.version,
      );
      if (!validJournalReading(reading, definition))
        throw JournalFormValidation(
          'Check ${definition.label}: counts and ratings use whole numbers in their defined range; percentages use 0–100.',
        );
    }
    final value = JournalReflection(
      note: note,
      whatGotEasier: whatGotEasier,
      nextStep: nextStep,
      effortRating: effortRating,
      readings: values,
    );
    value.validate();
    return value;
  }

  int duration({required bool journalOnly}) {
    if (journalOnly) return 0;
    final m = minutes.trim().isEmpty ? 0 : int.tryParse(minutes.trim());
    final s = seconds.trim().isEmpty ? 0 : int.tryParse(seconds.trim());
    if (m == null ||
        s == null ||
        m < 0 ||
        s < 0 ||
        s > 59 ||
        m * 60 + s < 1 ||
        m * 60 + s > 604800)
      throw const JournalFormValidation(
        'Enter at least one second and at most 7 days, with additional seconds from 0 to 59.',
      );
    return m * 60 + s;
  }

  DateTime date() {
    final date = DateTime.tryParse(dateLocal);
    if (date == null ||
        dateKey(date) != dateLocal ||
        date.isBefore(DateTime(1900)) ||
        date.isAfter(
          DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
          ),
        ))
      throw const JournalFormValidation(
        'Choose a valid date from 1900 through today.',
      );
    return date;
  }
}
