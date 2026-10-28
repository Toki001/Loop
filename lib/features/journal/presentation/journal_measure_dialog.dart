import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../../core/data/database/loop_database.dart';
import '../../../core/data/validation.dart';
import '../../../shared/design_system/components.dart';
import '../../progress/data/metrics_repository.dart';
import '../../skills/presentation/skill_widgets.dart';

class JournalMeasureDialog extends StatefulWidget {
  const JournalMeasureDialog({
    super.key,
    required this.skillId,
    required this.repository,
  });
  final String skillId;
  final MetricsRepository repository;
  @override
  State<JournalMeasureDialog> createState() => _JournalMeasureDialogState();
}

class _JournalMeasureDialogState extends State<JournalMeasureDialog> {
  final _label = TextEditingController();
  final _unit = TextEditingController(text: 'count');
  String _type = 'numeric';
  String _direction = 'none';
  bool _busy = false;
  String? _error;
  @override
  void dispose() {
    _label.dispose();
    _unit.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy) return;
    if (nameError(_label.text, 120) != null ||
        _type == 'numeric' &&
            !RegExp(r'^[a-z][a-z0-9_]{0,79}$').hasMatch(_unit.text.trim())) {
      setState(
        () => _error = 'Use a label of 1–120 characters and a unit key starting with a letter, using lowercase letters, numbers or underscores.',
      );
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final saved = await widget.repository.create(
        MetricDefinitionsCompanion(
          skillId: Value(widget.skillId),
          label: Value(validName(_label.text, maximum: 120)),
          unitKey: Value(
            _type == 'numeric'
                ? _unit.text.trim()
                : _type == 'text'
                ? 'observation'
                : 'completed',
          ),
          valueType: Value(_type),
          direction: Value(
            _type == 'numeric' && _unit.text.trim() != 'rating_1_5'
                ? _direction
                : 'none',
          ),
          sourceHint: Value(
            _type == 'numeric' && _unit.text.trim() == 'rating_1_5'
                ? 'self_rating'
                : 'manual',
          ),
          scaleMin: Value(
            _type != 'numeric'
                ? null
                : _unit.text.trim() == 'rating_1_5'
                ? 1.0
                : [
                    'count',
                    'percent',
                    'wpm',
                    'clean_changes_per_min',
                    'seconds',
                    'bpm',
                  ].contains(_unit.text.trim())
                ? 0.0
                : null,
          ),
          scaleMax: Value(
            _type != 'numeric'
                ? null
                : _unit.text.trim() == 'rating_1_5'
                ? 5.0
                : _unit.text.trim() == 'percent'
                ? 100.0
                : null,
          ),
        ),
      );
      if (mounted) Navigator.pop(context, saved);
    } on Object catch (error) {
      if (mounted) setState(() => _error = storageFailureMessage(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: AlertDialog(
      title: const Text('Create a measure'),
      scrollable: true,
      content: AbsorbPointer(
        absorbing: _busy,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Choose something useful for this skill. Saving creates a reusable measure; it does not create a reading.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _label,
              maxLength: 120,
              decoration: const InputDecoration(labelText: 'Measure label'),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final type in ['numeric', 'text', 'checklist'])
                  ChoiceChip(
                    label: Text(switch (type) {
                      'numeric' => 'Number',
                      'text' => 'Observation',
                      _ => 'Done / not done',
                    }),
                    selected: _type == type,
                    onSelected: (_) => setState(() => _type = type),
                  ),
              ],
            ),
            if (_type == 'numeric') ...[
              const SizedBox(height: 16),
              TextField(
                controller: _unit,
                maxLength: 80,
                decoration: const InputDecoration(
                  labelText: 'Unit key',
                  helperText: 'For example: wpm, bpm, count or percent. Units stay fixed for past readings.',
                ),
              ),
              const SizedBox(height: 16),
              const Text('What direction is useful?'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final direction in ['none', 'up', 'down'])
                    ChoiceChip(
                      label: Text(switch (direction) {
                        'up' => 'Higher',
                        'down' => 'Lower',
                        _ => 'No direction',
                      }),
                      selected: _direction == direction,
                      onSelected: (_) => setState(() => _direction = direction),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            const Text(
              'Readings you enter are self-reported. Loop does not measure or score your ability.',
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Semantics(liveRegion: true, child: Text(_error!)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        LoopButton(label: 'Save measure', busy: _busy, onPressed: _save),
      ],
    ),
  );
}
