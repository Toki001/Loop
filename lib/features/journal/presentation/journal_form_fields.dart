import 'package:flutter/material.dart';

import '../../../shared/design_system/components.dart';
import '../../skills/presentation/skill_widgets.dart';
import '../domain/journal_draft_writer.dart';
import '../domain/journal_entry.dart';
import '../domain/journal_form.dart';

/// Input composition stays separate from loading, saving and route ownership.
class JournalFormFields extends StatefulWidget {
  const JournalFormFields({
    super.key,
    required this.id,
    required this.editing,
    required this.detail,
    required this.form,
    required this.writer,
    required this.note,
    required this.easier,
    required this.next,
    required this.hasStaged,
    required this.restored,
    required this.onChanged,
    required this.onSaveDraft,
    required this.onAddReading,
    required this.onLeave,
    required this.onDiscard,
  });
  final String id;
  final bool editing;
  final JournalDetail detail;
  final JournalFormData form;
  final JournalDraftWriter writer;
  final TextEditingController note, easier, next;
  final bool Function() hasStaged;
  final bool restored;
  final VoidCallback onChanged, onSaveDraft, onAddReading, onLeave, onDiscard;
  @override
  State<JournalFormFields> createState() => _JournalFormFieldsState();
}

class _JournalFormFieldsState extends State<JournalFormFields> {
  bool get _manual => widget.detail.session.entryMode == 'manual';
  bool get _journalOnly =>
      widget.detail.session.manualIntent == 'evidence_only';
  String get _purpose => widget.editing ? 'edit' : 'finish';
  TextEditingController get _note => widget.note;
  TextEditingController get _easier => widget.easier;
  TextEditingController get _next => widget.next;
  bool get _hasStaged => widget.hasStaged();
  bool get _draftRestored => widget.restored;
  @override
  Widget build(BuildContext context) {
    final detail = widget.detail, form = widget.form;
    final writer = widget.writer;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!_manual)
          TimerDisplay(
            seconds: detail.session.activeSeconds,
            caption: widget.editing
                ? 'Timed foreground practice · duration preserved'
                : 'Timed foreground practice · paused while reflecting',
          ),
        if (_manual) ..._manualFields(form),
        const SizedBox(height: 20),
        const Text(
          'Reflection is optional. Save a useful observation, or finish with these fields blank.',
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _easier,
          minLines: 2,
          maxLines: 6,
          maxLength: 100000,
          onChanged: (_) => widget.onChanged(),
          decoration: const InputDecoration(
            labelText: 'What got easier? · optional',
            helperText: 'A personal observation, without a score.',
            counterText: '',
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _next,
          minLines: 2,
          maxLines: 5,
          maxLength: 10000,
          onChanged: (_) => widget.onChanged(),
          decoration: const InputDecoration(
            labelText: 'What should you try next? · optional',
            counterText: '',
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _note,
          minLines: 3,
          maxLines: 8,
          maxLength: 100000,
          onChanged: (_) => widget.onChanged(),
          decoration: const InputDecoration(
            labelText: 'Notes · optional',
            counterText: '',
          ),
        ),
        const SizedBox(height: 20),
        const Text('Effort · optional self-rating, separate from ability'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Not rated'),
              selected: form.effortRating == null,
              onSelected: (_) {
                setState(() => form.effortRating = null);
                widget.onChanged();
              },
            ),
            for (var i = 1; i <= 5; i++)
              ChoiceChip(
                label: Text('$i / 5'),
                selected: form.effortRating == i,
                onSelected: (_) {
                  setState(() => form.effortRating = i);
                  widget.onChanged();
                },
              ),
          ],
        ),
        const SizedBox(height: 20),
        const LoopSectionHeader(title: 'Readings · optional'),
        const Text(
          'Enter observations from this practice. Values you enter are self-reported; Loop does not verify a tool result or infer your ability.',
        ),
        for (final reading in form.readings) ...[
          const SizedBox(height: 20),
          _readingField(reading),
        ],
        const SizedBox(height: 12),
        LoopButton(
          label: 'Add a reading',
          kind: LoopButtonKind.secondary,
          onPressed: form.readings.length >= 100 ? null : widget.onAddReading,
        ),
        if (form.readings.length >= 100)
          const Text('This entry has the maximum 100 readings.'),
        if (detail.exercises.isNotEmpty) ...[
          const SizedBox(height: 20),
          const LoopSectionHeader(title: 'Selected exercises'),
          for (final exercise in detail.exercises)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(exercise.exerciseTitleSnapshot),
            ),
        ],
        const SizedBox(height: 20),
        ListenableBuilder(
          listenable: writer,
          builder: (context, _) {
            final error = writer.failures[writer.key(widget.id, _purpose)];
            return Semantics(
              liveRegion: true,
              child: Text(
                error != null
                    ? storageFailureMessage(error)
                    : writer.hasPendingFor(widget.id, _purpose)
                    ? 'Draft changes waiting to save'
                    : _hasStaged || _draftRestored
                    ? 'Draft changes are saved on this device'
                    : 'Reflection fields are optional.',
              ),
            );
          },
        ),
        LoopButton(
          label: 'Save reflection draft',
          kind: LoopButtonKind.secondary,
          onPressed: widget.onSaveDraft,
        ),
        LoopButton(
          label: widget.editing
              ? 'Keep draft and return'
              : _manual
              ? 'Keep draft and return to Today'
              : 'Keep draft and return to practice',
          kind: LoopButtonKind.text,
          onPressed: widget.onLeave,
        ),
        LoopButton(
          label: widget.editing ? 'Discard edits' : 'Discard entry',
          kind: LoopButtonKind.destructiveText,
          onPressed: widget.onDiscard,
        ),
      ],
    );
  }

  List<Widget> _manualFields(JournalFormData form) => [
    Text(
      _journalOnly ? 'Zero practice minutes' : 'Duration entered by you',
      style: Theme.of(context).textTheme.titleLarge,
    ),
    const SizedBox(height: 12),
    Text(
      _journalOnly ? 'This journal entry adds no practice time.' : 'Enter active practice, excluding breaks. The source remains manual.',
    ),
    if (!_journalOnly) ...[
      const SizedBox(height: 16),
      TextFormField(
        initialValue: form.minutes,
        keyboardType: TextInputType.number,
        onChanged: (v) {
          form.minutes = v;
          widget.onChanged();
        },
        decoration: const InputDecoration(
          labelText: 'Practice minutes',
          helperText: '0–10080 minutes, with seconds below.',
        ),
      ),
      const SizedBox(height: 16),
      TextFormField(
        initialValue: form.seconds,
        keyboardType: TextInputType.number,
        onChanged: (v) {
          form.seconds = v;
          widget.onChanged();
        },
        decoration: const InputDecoration(
          labelText: 'Additional seconds',
          helperText: '0–59 seconds. At least one second in total.',
        ),
      ),
    ],
    const SizedBox(height: 16),
    LoopButton(
      label: 'Date: ${form.dateLocal}',
      kind: LoopButtonKind.secondary,
      onPressed: () async {
        final today = DateUtils.dateOnly(DateTime.now());
        var date = DateTime.tryParse(form.dateLocal) ?? today;
        if (date.isAfter(today)) date = today;
        if (date.isBefore(DateTime(1900))) date = DateTime(1900);
        final chosen = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(1900),
          lastDate: today,
        );
        if (chosen != null && mounted) {
          setState(() => form.dateLocal = JournalFormData.dateKey(chosen));
          widget.onChanged();
        }
      },
    ),
    const SizedBox(height: 12),
    const Text(
      'For a new manual entry or changed date, finish time uses the current local time on that date; start is inferred from your entered duration. Unchanged saved dates stay intact.',
    ),
    CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      value: form.manualConfirmed,
      title: Text(
        _journalOnly
            ? 'I intend to save a journal entry with no practice time.'
            : 'I confirm this duration and date are my own entry.',
      ),
      onChanged: (v) {
        setState(() => form.manualConfirmed = v ?? false);
        widget.onChanged();
      },
    ),
  ];
  Widget _readingField(JournalReadingForm reading) {
    final definition = widget.detail.definitions
        .where(
          (d) => d.id == reading.definitionId && d.version == reading.version,
        )
        .firstOrNull;
    if (definition == null)
      return LoopNotice(
        title: 'Measure unavailable',
        message: 'The draft is kept. Remove this reading before saving.',
        icon: Icons.error_outline,
        action: LoopButton(
          label: 'Remove unavailable reading',
          onPressed: () {
            setState(() => widget.form.readings.remove(reading));
            widget.onChanged();
          },
        ),
      );
    return LoopCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${definition.label} · ${definition.unitKey}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Definition version ${definition.version} · ${reading.sourceType == 'self_reported' ? 'entered by you' : reading.sourceType}',
          ),
          const SizedBox(height: 12),
          if (definition.valueType == 'checklist')
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Completed · self-reported'),
              value: reading.checked,
              onChanged: (v) {
                setState(() {
                  reading.checked = v ?? false;
                  reading.sourceType = 'self_reported';
                });
                widget.onChanged();
              },
            )
          else
            TextFormField(
              key: ObjectKey(reading),
              initialValue: reading.value,
              keyboardType: definition.valueType == 'numeric'
                  ? const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    )
                  : TextInputType.multiline,
              minLines: 1,
              maxLines: definition.valueType == 'text' ? 6 : 1,
              maxLength: definition.valueType == 'numeric' ? 100 : 100000,
              onChanged: (v) {
                reading.value = v;
                reading.sourceType = 'self_reported';
                widget.onChanged();
              },
              decoration: InputDecoration(
                labelText: '${definition.label} reading',
                counterText: '',
                helperText: definition.valueType == 'numeric'
                    ? 'Use a decimal point. ${definition.scaleMin == null ? '' : 'Minimum ${definition.scaleMin}. '}${definition.scaleMax == null ? '' : 'Maximum ${definition.scaleMax}.'}'
                    : 'Your observation, entered by you.',
              ),
            ),
          const SizedBox(height: 12),
          TextFormField(
            key: ValueKey(reading),
            initialValue: reading.sourceNote,
            minLines: 1,
            maxLines: 4,
            maxLength: 10000,
            onChanged: (v) {
              reading.sourceNote = v;
              reading.sourceType = 'self_reported';
              widget.onChanged();
            },
            decoration: const InputDecoration(
              labelText: 'Method or source note · optional',
              counterText: '',
              helperText: 'For example, the passage or external tool you used. This remains your report.',
            ),
          ),
          const SizedBox(height: 8),
          LoopButton(
            label: 'Remove ${definition.label} reading',
            kind: LoopButtonKind.text,
            onPressed: () {
              setState(() => widget.form.readings.remove(reading));
              widget.onChanged();
            },
          ),
        ],
      ),
    );
  }
}
