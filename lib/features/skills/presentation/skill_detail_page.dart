import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/screens/foundation_pages.dart';
import '../../../core/data/database/loop_database.dart';
import '../../../shared/design_system/components.dart';
import '../data/skill_management_repository.dart';
import '../domain/goal_rules.dart';
import '../domain/skill_kind.dart';
import '../domain/starter_catalog.dart';
import 'skill_providers.dart';
import '../../journal/presentation/journal_widgets.dart';
import 'skill_widgets.dart';

class SkillDetailPage extends ConsumerStatefulWidget {
  const SkillDetailPage({
    super.key,
    required this.id,
    this.initialSection = 'timeline',
  });
  final String id;
  final String initialSection;
  @override
  ConsumerState<SkillDetailPage> createState() => _SkillDetailPageState();
}

class _SkillDetailPageState extends ConsumerState<SkillDetailPage> {
  String _validSection(String value) =>
      ['timeline', 'goals', 'exercises'].contains(value) ? value : 'timeline';
  late String _section = _validSection(widget.initialSection);
  @override
  void didUpdateWidget(covariant SkillDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSection != widget.initialSection)
      _section = _validSection(widget.initialSection);
  }

  bool _busy = false;
  bool _archivedGoals = false;
  bool _archivedExercises = false;
  bool _reorder = false;
  String? _error;
  Future<void> _perform(
    Future<void> Function(SkillManagementRepository) operation,
  ) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await operation(ref.read(skillManagementProvider));
    } catch (error) {
      if (mounted) setState(() => _error = storageFailureMessage(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _archiveSkill(Skill skill) async {
    if (_busy) return;
    final archive = skill.archivedAtUtc == null;
    if (!await confirmSkillAction(
          context,
          title: archive ? 'Archive this skill?' : 'Restore this skill?',
          message: archive
              ? 'Your goals, exercises, sessions and evidence stay saved. The skill moves to Archived and can be restored.'
              : 'This skill returns to your active list with its saved goals, exercises and history.',
          action: archive ? 'Archive skill' : 'Restore skill',
        ) ||
        !mounted)
      return;
    await _perform((repo) => repo.skills.setArchived(skill.id, archive));
  }

  Future<void> _goalAction(Goal goal, String action) async {
    if (_busy) return;
    if (action == 'edit') {
      context.push('/skills/${widget.id}/goals/${goal.id}/edit');
      return;
    }
    if (action == 'archived' &&
        !await confirmSkillAction(
          context,
          title: 'Archive goal?',
          message: 'The goal and its completion history stay visible in Archived goals.',
          action: 'Archive goal',
        ))
      return;
    if (!mounted) return;
    await _perform(
      (repo) => repo.setGoalStatus(
        goal.id,
        action == 'restore'
            ? goal.completedAtUtc == null
                  ? 'active'
                  : 'completed'
            : action,
      ),
    );
  }

  Future<void> _exerciseAction(Exercise exercise, String action) async {
    if (_busy) return;
    if (action == 'edit') {
      context.push('/skills/${widget.id}/exercises/${exercise.id}/edit');
      return;
    }
    if (action == 'archive' &&
        !await confirmSkillAction(
          context,
          title: 'Archive exercise?',
          message: 'Past practice keeps its exercise reference and saved title. You can restore this exercise later.',
          action: 'Archive exercise',
        ))
      return;
    if (!mounted) return;
    await _perform((repo) async {
      if (action == 'duplicate') {
        final created = await repo.duplicateExercise(exercise.id);
        if (mounted)
          context.push('/skills/${widget.id}/exercises/${created.id}/edit');
      } else {
        await repo.setExerciseArchived(exercise.id, action == 'archive');
      }
    });
  }

  Future<void> _moveExercise(List<Exercise> exercises, int index, int delta) =>
      _perform((repo) {
        final ids = exercises.map((e) => e.id).toList();
        final id = ids.removeAt(index);
        ids.insert(index + delta, id);
        return repo.reorderExercises(widget.id, ids);
      });
  @override
  Widget build(BuildContext context) => ref
      .watch(skillDetailProvider(widget.id))
      .when(
        data: (data) => data == null ? const MissingItemPage() : _content(data),
        loading: () => LoopScaffold(
          children: [
            SkillLoadNotice(
              retry: () => ref.invalidate(skillDetailProvider(widget.id)),
            ),
          ],
        ),
        error: (error, _) => LoopScaffold(
          children: [
            SkillLoadNotice(
              error: error,
              retry: () => ref.invalidate(skillDetailProvider(widget.id)),
            ),
          ],
        ),
      );
  Widget _content(SkillDetailData data) {
    final skill = data.skill;
    final goals = data.goals
        .where((g) => (g.status == 'archived') == _archivedGoals)
        .toList();
    final exercises = data.exercises
        .where((e) => e.isArchived == _archivedExercises)
        .toList();
    return LoopScaffold(
      title: 'Skill',
      actions: [
        IconButton(
          tooltip: 'Edit skill',
          onPressed: _busy
              ? null
              : () => context.push('/skills/${skill.id}/edit'),
          icon: const Icon(Icons.edit_outlined),
        ),
      ],
      children: [
        LoopCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                skillIcon(skill.iconKey),
                size: 32,
                color: skillAccent(context, skill.accentKey),
              ),
              const SizedBox(height: 16),
              Text(
                skill.name,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(StarterCatalog.label(SkillKind.values.byName(skill.kind))),
              const SizedBox(height: 16),
              Text(
                skill.defaultPracticeMinutes == null
                    ? 'Untimed plan'
                    : 'Suggested plan: ${skill.defaultPracticeMinutes} minutes',
              ),
              if (skill.description?.isNotEmpty == true) ...[
                const SizedBox(height: 16),
                Text(skill.description!),
              ],
              if (skill.archivedAtUtc != null) ...[
                const SizedBox(height: 16),
                const Text('Archived · your history stays saved'),
              ],
              const SizedBox(height: 8),
              LoopButton(
                label: skill.archivedAtUtc == null
                    ? 'Archive skill'
                    : 'Restore skill',
                kind: LoopButtonKind.text,
                onPressed: _busy ? null : () => _archiveSkill(skill),
              ),
            ],
          ),
        ),
        if (_error != null)
          Semantics(
            liveRegion: true,
            child: LoopNotice(
              title: 'Change not saved',
              message: _error!,
              icon: Icons.error_outline,
            ),
          ),
        if (skill.archivedAtUtc == null)
          LoopButton(
            label: 'Practice this skill',
            onPressed: () => context.go('/practice/setup?skill=${skill.id}'),
          ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final section in ['timeline', 'goals', 'exercises'])
              ChoiceChip(
                label: Text(section[0].toUpperCase() + section.substring(1)),
                selected: _section == section,
                onSelected: (_) => setState(() => _section = section),
              ),
          ],
        ),
        if (_section == 'timeline') RecentJournalSection(skillId: skill.id),
        if (_section == 'goals') ...[
          const LoopSectionHeader(title: 'Goals'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Current goals'),
                selected: !_archivedGoals,
                onSelected: (_) => setState(() => _archivedGoals = false),
              ),
              ChoiceChip(
                label: const Text('Archived goals'),
                selected: _archivedGoals,
                onSelected: (_) => setState(() => _archivedGoals = true),
              ),
            ],
          ),
          if (goals.isEmpty)
            Text(
              _archivedGoals ? 'No archived goals.' : 'No goals yet. Add one when it helps give your practice direction.',
            ),
          for (final goal in goals)
            GoalSummaryCard(
              goal: goal,
              data: data,
              actions: PopupMenuButton<String>(
                tooltip: 'Actions for goal ${goal.title}',
                enabled: !_busy,
                onSelected: (action) => _goalAction(goal, action),
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit goal')),
                  if (goal.status == 'archived')
                    const PopupMenuItem(
                      value: 'restore',
                      child: Text('Restore goal'),
                    )
                  else ...[
                    if (goal.status != 'completed')
                      const PopupMenuItem(
                        value: 'completed',
                        child: Text('Mark complete'),
                      ),
                    if (goal.status == 'completed' || goal.status == 'paused')
                      const PopupMenuItem(
                        value: 'active',
                        child: Text('Make active'),
                      ),
                    if (goal.status == 'active')
                      const PopupMenuItem(
                        value: 'paused',
                        child: Text('Pause goal'),
                      ),
                    const PopupMenuItem(
                      value: 'archived',
                      child: Text('Archive goal'),
                    ),
                  ],
                ],
              ),
            ),
          LoopButton(
            label: 'Add goal',
            icon: Icons.add,
            kind: LoopButtonKind.secondary,
            onPressed: _busy
                ? null
                : () => context.push('/skills/${skill.id}/goals/new'),
          ),
        ],
        if (_section == 'exercises') ...[
          const LoopSectionHeader(title: 'Exercises'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Current exercises'),
                selected: !_archivedExercises,
                onSelected: (_) => setState(() {
                  _archivedExercises = false;
                  _reorder = false;
                }),
              ),
              ChoiceChip(
                label: const Text('Archived exercises'),
                selected: _archivedExercises,
                onSelected: (_) => setState(() {
                  _archivedExercises = true;
                  _reorder = false;
                }),
              ),
              if (!_archivedExercises && exercises.length > 1)
                FilterChip(
                  label: const Text('Reorder exercises'),
                  selected: _reorder,
                  onSelected: (value) => setState(() => _reorder = value),
                ),
            ],
          ),
          if (exercises.isEmpty)
            Text(
              _archivedExercises
                  ? 'No archived exercises.'
                  : 'Choose your own small, repeatable exercise.',
            ),
          for (var i = 0; i < exercises.length; i++)
            LoopCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          exercises[i].title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      PopupMenuButton<String>(
                        tooltip: 'Actions for exercise ${exercises[i].title}',
                        enabled: !_busy,
                        onSelected: (action) =>
                            _exerciseAction(exercises[i], action),
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit exercise'),
                          ),
                          const PopupMenuItem(
                            value: 'duplicate',
                            child: Text('Duplicate exercise'),
                          ),
                          if (exercises[i].isArchived)
                            const PopupMenuItem(
                              value: 'restore',
                              child: Text('Restore exercise'),
                            )
                          else
                            const PopupMenuItem(
                              value: 'archive',
                              child: Text('Archive exercise'),
                            ),
                        ],
                      ),
                    ],
                  ),
                  if (exercises[i].instructions.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(exercises[i].instructions),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    exercises[i].defaultSeconds == null
                        ? 'No suggested duration'
                        : '${exercises[i].defaultSeconds} suggested seconds',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (_reorder && !_archivedExercises)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        IconButton(
                          tooltip: 'Move ${exercises[i].title} earlier',
                          onPressed: _busy || i == 0
                              ? null
                              : () => _moveExercise(exercises, i, -1),
                          icon: const Icon(Icons.arrow_upward),
                        ),
                        IconButton(
                          tooltip: 'Move ${exercises[i].title} later',
                          onPressed: _busy || i == exercises.length - 1
                              ? null
                              : () => _moveExercise(exercises, i, 1),
                          icon: const Icon(Icons.arrow_downward),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          LoopButton(
            label: 'Add exercise',
            icon: Icons.add,
            kind: LoopButtonKind.secondary,
            onPressed: _busy
                ? null
                : () => context.push('/skills/${skill.id}/exercises/new'),
          ),
        ],
      ],
    );
  }
}

class GoalSummaryCard extends StatelessWidget {
  const GoalSummaryCard({
    super.key,
    required this.goal,
    required this.data,
    this.actions,
  });
  final Goal goal;
  final SkillDetailData data;
  final Widget? actions;
  @override
  Widget build(BuildContext context) {
    final progress = GoalProgress.calculate(
      goal,
      sessions: data.sessions,
      definitions: data.definitions,
      readings: data.readings,
      todayLocal: DateTime.now(),
    );
    final type = GoalType.values
        .where((t) => t.stored == goal.type)
        .firstOrNull;
    String number(double value) => value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toString();
    final definition = data.definitions
        .where(
          (d) =>
              d.id == goal.metricDefinitionId &&
              d.version == goal.definitionVersion,
        )
        .firstOrNull;
    final targetLabel = goal.type == 'threshold'
        ? switch (definition?.direction) {
            'down' => 'target at most',
            'toward_target' => 'target exactly',
            _ => 'target at least',
          }
        : 'target';
    return LoopCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  goal.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              if (actions != null) actions!,
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${type == null ? goal.type : goalTypeLabel(type)} · ${goal.status}',
          ),
          if (definition != null) ...[
            const SizedBox(height: 8),
            Text('${definition.label} · ${goalUnitLabel(definition.unitKey)}'),
          ],
          const SizedBox(height: 16),
          Text(progress.label),
          if (progress.observed != null && goal.targetValue != null) ...[
            const SizedBox(height: 8),
            Text(
              '${number(progress.observed!)} recorded · $targetLabel ${number(goal.targetValue!)} ${goalUnitLabel(goal.targetUnit)}',
            ),
          ] else if (goal.targetValue != null) ...[
            const SizedBox(height: 8),
            Text(
              '${targetLabel[0].toUpperCase()}${targetLabel.substring(1)} ${number(goal.targetValue!)} ${goalUnitLabel(goal.targetUnit)}',
            ),
          ],
          if (progress.fraction != null) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress.fraction,
              semanticsLabel: 'Recorded amount toward this goal',
              semanticsValue: '${(progress.fraction! * 100).round()}%',
            ),
          ],
          const SizedBox(height: 8),
          Text(progress.scope, style: Theme.of(context).textTheme.bodySmall),
          if (progress.source != null) ...[
            const SizedBox(height: 8),
            Text(
              '${progress.source} · ${progress.sampleCount} samples',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (goal.targetDateLocal != null) ...[
            const SizedBox(height: 12),
            Text('Target date: ${goal.targetDateLocal}'),
          ],
          if (goal.motivation?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            Text(goal.motivation!),
          ],
        ],
      ),
    );
  }
}
