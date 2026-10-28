import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/screens/foundation_pages.dart';
import '../../../core/data/database/loop_database.dart';
import '../../../shared/design_system/components.dart';
import '../data/skill_management_repository.dart';
import '../domain/goal_measure.dart';
import '../domain/goal_rules.dart';
import 'skill_providers.dart';
import 'skill_widgets.dart';

class GoalEditorPage extends ConsumerWidget {
  const GoalEditorPage({super.key, required this.skillId, this.id});
  final String skillId;
  final String? id;
  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(skillDetailProvider(skillId))
      .when(
        skipError: true,
        skipLoadingOnReload: true,
        data: (data) {
          final existing = data?.goals
              .where((goal) => goal.id == id)
              .firstOrNull;
          if (data == null || id != null && existing == null)
            return const MissingItemPage();
          return _GoalForm(
            key: ValueKey(id ?? 'new'),
            data: data,
            existing: existing,
          );
        },
        loading: () => LoopScaffold(
          children: [
            SkillLoadNotice(
              retry: () => ref.invalidate(skillDetailProvider(skillId)),
            ),
          ],
        ),
        error: (error, _) => LoopScaffold(
          children: [
            SkillLoadNotice(
              error: error,
              retry: () => ref.invalidate(skillDetailProvider(skillId)),
            ),
          ],
        ),
      );
}

class _GoalForm extends ConsumerStatefulWidget {
  const _GoalForm({super.key, required this.data, this.existing});
  final SkillDetailData data;
  final Goal? existing;
  @override
  ConsumerState<_GoalForm> createState() => _GoalFormState();
}

class _GoalFormState extends ConsumerState<_GoalForm> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _target;
  late final TextEditingController _date;
  late final TextEditingController _motivation;
  final _measureName = TextEditingController();
  final _customUnit = TextEditingController();
  late GoalType _type;
  late String _measure;
  String _unit = 'count';
  String _direction = 'up';
  bool _dirty = false;
  bool _busy = false;
  String? _error;
  String _key(MetricDefinition definition) =>
      '${definition.id}:${definition.version}';
  bool get _numeric =>
      _type == GoalType.cumulative || _type == GoalType.threshold;
  bool get _newMeasure => _numeric && _measure == 'new';
  List<MetricDefinition> get _definitions => widget.data.definitions
      .where(
        (definition) =>
            (definition.archivedAtUtc == null ||
                widget.existing?.metricDefinitionId == definition.id &&
                    widget.existing?.definitionVersion == definition.version) &&
            definition.valueType == 'numeric' &&
            (_type == GoalType.cumulative
                ? ['count', 'seconds'].contains(definition.unitKey) &&
                      definition.direction == 'up' &&
                      (definition.scaleMin ?? 0) >= 0
                : [
                        'up',
                        'down',
                        'toward_target',
                      ].contains(definition.direction) &&
                      definition.unitKey != 'rating_1_5'),
      )
      .toList();
  MetricDefinition? get _definition => _definitions
      .where((definition) => _key(definition) == _measure)
      .firstOrNull;
  String get _selectedUnit => _newMeasure
      ? (_unit == 'custom' ? _customUnit.text.trim() : _unit)
      : _definition?.unitKey ?? _measure;

  @override
  void initState() {
    super.initState();
    final goal = widget.existing;
    _type =
        GoalType.values
            .where((type) => type.stored == goal?.type)
            .firstOrNull ??
        GoalType.qualitative;
    _title = TextEditingController(text: goal?.title ?? '');
    _target = TextEditingController(text: goal?.targetValue?.toString() ?? '');
    _date = TextEditingController(text: goal?.targetDateLocal ?? '');
    _motivation = TextEditingController(text: goal?.motivation ?? '');
    _measure = goal?.metricDefinitionId != null
        ? '${goal!.metricDefinitionId}:${goal.definitionVersion}'
        : goal?.targetUnit ?? 'practice_sessions';
    if (_numeric && _type == GoalType.threshold && _definition == null)
      _measure = 'new';
  }

  @override
  void dispose() {
    for (final controller in [
      _title,
      _target,
      _date,
      _motivation,
      _measureName,
      _customUnit,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _targetError(String? text) {
    final value = double.tryParse((text ?? '').trim());
    if (value == null || !value.isFinite)
      return 'Enter a finite numeric target.';
    if (_type == GoalType.weeklyTarget)
      return value >= 1 && value <= 7 && value == value.roundToDouble()
          ? null
          : 'Choose a whole number from 1 to 7 days.';
    if (_type == GoalType.cumulative && value <= 0)
      return 'Choose a target greater than zero.';
    if ((_selectedUnit == 'count' || _selectedUnit == 'practice_sessions') &&
        value != value.roundToDouble())
      return 'Use a whole number for this count.';
    final minimum = _newMeasure ? 0.0 : _definition?.scaleMin;
    final maximum = _newMeasure && _unit == 'percent'
        ? 100.0
        : _definition?.scaleMax;
    if (minimum != null && value < minimum)
      return 'The minimum for this measure is $minimum.';
    if (maximum != null && value > maximum)
      return 'The maximum for this measure is $maximum.';
    return null;
  }

  Future<void> _pickDate() async {
    final current = _date.text.trim();
    final selected = await showDatePicker(
      context: context,
      initialDate: GoalDraft.validLocalDate(current)
          ? DateTime.parse(current)
          : DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(9999, 12, 31),
    );
    if (selected != null && mounted)
      setState(() {
        _date.text =
            '${selected.year.toString().padLeft(4, '0')}-${selected.month.toString().padLeft(2, '0')}-${selected.day.toString().padLeft(2, '0')}';
        _dirty = true;
      });
  }

  Future<void> _save() async {
    if (_busy || !_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final repo = ref.read(skillManagementProvider);
      await repo.saveGoal(
        widget.data.skill.id,
        GoalDraft(
          title: _title.text,
          type: _type,
          definition: _numeric ? _definition : null,
          target: _numeric || _type == GoalType.weeklyTarget
              ? double.parse(_target.text.trim())
              : null,
          unit: _numeric
              ? _selectedUnit
              : _type == GoalType.weeklyTarget
              ? 'days_per_week'
              : null,
          dateLocal: _date.text.trim().isEmpty ? null : _date.text.trim(),
          motivation: _motivation.text.trim().isEmpty ? null : _motivation.text,
        ),
        id: widget.existing?.id,
        newMeasure: _newMeasure
            ? GoalMeasure(
                label: _measureName.text.trim(),
                unit: _selectedUnit,
                direction: _type == GoalType.cumulative ? 'up' : _direction,
              )
            : null,
      );
      if (mounted) context.go('/skills/${widget.data.skill.id}?section=goals');
    } catch (error) {
      if (mounted)
        setState(() {
          _busy = false;
          _error = storageFailureMessage(error);
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final measures = <DropdownMenuItem<String>>[
      if (_type == GoalType.cumulative) ...[
        const DropdownMenuItem(
          value: 'practice_sessions',
          child: Text('Recorded practice sessions'),
        ),
        const DropdownMenuItem(
          value: 'practice_seconds',
          child: Text('Recorded practice seconds'),
        ),
      ],
      for (final definition in _definitions)
        DropdownMenuItem(
          value: _key(definition),
          child: Text(
            '${definition.label} · ${goalUnitLabel(definition.unitKey)} · v${definition.version}',
          ),
        ),
      const DropdownMenuItem(value: 'new', child: Text('Create a measure')),
    ];
    return SkillEditorFrame(
      title: widget.existing == null ? 'Add goal' : 'Edit goal',
      saveLabel: 'Save goal',
      onSave: _save,
      dirty: _dirty,
      busy: _busy,
      error: _error,
      children: [
        Text(
          widget.data.skill.name,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Form(
          key: _form,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: () {
            if (!_dirty) setState(() => _dirty = true);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _title,
                minLines: 1,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Goal title'),
                validator: (value) => nameError(value, 120),
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<GoalType>(
                itemHeight: null,
                initialValue: _type,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Goal type'),
                items: [
                  for (final type in GoalType.values)
                    DropdownMenuItem(
                      value: type,
                      child: Text(goalTypeLabel(type)),
                    ),
                ],
                onChanged: (value) {
                  if (value != null)
                    setState(() {
                      _type = value;
                      if (value == GoalType.cumulative &&
                          !['count', 'seconds'].contains(_unit))
                        _unit = 'count';
                      _measure = value == GoalType.threshold
                          ? 'new'
                          : 'practice_sessions';
                      _dirty = true;
                    });
                },
              ),
              const SizedBox(height: 24),
              if (_numeric) ...[
                DropdownButtonFormField<String>(
                  itemHeight: null,
                  key: ValueKey(_type),
                  initialValue: measures.any((m) => m.value == _measure)
                      ? _measure
                      : null,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Measure'),
                  items: measures,
                  validator: (_) => measures.any((m) => m.value == _measure)
                      ? null
                      : 'Choose a compatible measure.',
                  onChanged: (value) {
                    if (value != null)
                      setState(() {
                        _measure = value;
                        _dirty = true;
                      });
                  },
                ),
                const SizedBox(height: 24),
              ],
              if (_newMeasure) ...[
                const Text(
                  'This measure uses non-negative numbers entered by you. Percentages range from 0 to 100. Use the same measurement method when comparing sessions.',
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _measureName,
                  decoration: const InputDecoration(
                    labelText: 'Measure name',
                    helperText:
                        'For example, studies completed or reading speed.',
                  ),
                  validator: (value) => nameError(value, 120),
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  itemHeight: null,
                  key: ValueKey('unit-$_type'),
                  initialValue:
                      _type == GoalType.cumulative &&
                          !['count', 'seconds'].contains(_unit)
                      ? 'count'
                      : _unit,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Unit'),
                  items: [
                    for (final unit
                        in _type == GoalType.cumulative
                            ? ['count', 'seconds']
                            : ['count', 'seconds', 'wpm', 'percent', 'custom'])
                      DropdownMenuItem(
                        value: unit,
                        child: Text(
                          unit == 'custom'
                              ? 'Custom unit'
                              : goalUnitLabel(unit),
                        ),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null)
                      setState(() {
                        _unit = value;
                        _dirty = true;
                      });
                  },
                ),
                if (_unit == 'custom' && _type == GoalType.threshold) ...[
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _customUnit,
                    decoration: const InputDecoration(
                      labelText: 'Custom unit',
                      helperText: 'Lowercase letters, numbers or underscores, for example pages.',
                    ),
                    validator: (value) =>
                        RegExp(r'^[a-z][a-z0-9_]{0,79}$')
                                .hasMatch((value ?? '').trim()) &&
                            ![
                              'rating_1_5',
                              'practice_sessions',
                              'practice_seconds',
                              'days_per_week',
                            ].contains(value?.trim())
                        ? null
                        : 'Choose a unit such as pages or metres.',
                  ),
                ],
                if (_type == GoalType.threshold) ...[
                  const SizedBox(height: 24),
                  DropdownButtonFormField<String>(
                    itemHeight: null,
                    initialValue: _direction,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Target direction',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'up',
                        child: Text('At least the target'),
                      ),
                      DropdownMenuItem(
                        value: 'down',
                        child: Text('At most the target'),
                      ),
                      DropdownMenuItem(
                        value: 'toward_target',
                        child: Text('Exactly the target'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null)
                        setState(() {
                          _direction = value;
                          _dirty = true;
                        });
                    },
                  ),
                ],
                const SizedBox(height: 24),
              ],
              if (_numeric || _type == GoalType.weeklyTarget) ...[
                if (_definition != null) ...[
                  Text(
                    'Target direction: ${switch (_definition!.direction) {
                      'down' => 'at most',
                      'toward_target' => 'exactly',
                      _ => 'at least',
                    }} the target. Unit: ${goalUnitLabel(_definition!.unitKey)}. Measurement source: ${_definition!.sourceHint}.',
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _target,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  decoration: InputDecoration(
                    labelText: _type == GoalType.weeklyTarget
                        ? 'Practice days per week'
                        : 'Target (${goalUnitLabel(_selectedUnit)})',
                    helperText: _type == GoalType.weeklyTarget
                        ? '1–7 distinct practice days. A suggestion, not a streak.'
                        : _type == GoalType.cumulative
                        ? 'Counts or durations only. Rates and self-ratings are never added.'
                        : 'Uses the latest compatible measurement, with its source.',
                    helperMaxLines: 4,
                  ),
                  validator: _targetError,
                ),
              ] else
                const Text(
                  'You decide when this goal is complete. No percentage or automated skill score.',
                ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _date,
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(
                  labelText: 'Target date (optional)',
                  helperText: 'YYYY-MM-DD, using your local calendar.',
                  suffixIcon: IconButton(
                    tooltip: 'Choose target date',
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today_outlined),
                  ),
                ),
                validator: (value) =>
                    (value ?? '').trim().isEmpty ||
                        GoalDraft.validLocalDate(value!.trim())
                    ? null
                    : 'Enter a valid date as YYYY-MM-DD.',
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _motivation,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Why this goal? (optional)',
                ),
                validator: (value) => (value?.length ?? 0) > 4000
                    ? 'Keep this within 4,000 characters.'
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
