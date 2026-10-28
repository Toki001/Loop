import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/design_system/components.dart';
import '../../skills/presentation/skill_widgets.dart';
import '../../skills/presentation/skill_providers.dart';
import '../data/sessions_repository.dart';
import '../domain/practice_engine.dart';
import 'practice_providers.dart';
import 'practice_widgets.dart';

enum _PracticeMode { planned, untimed, manual, evidence }

class PracticeSetupPage extends ConsumerStatefulWidget {
  const PracticeSetupPage({super.key, this.skillId});
  final String? skillId;
  @override
  ConsumerState<PracticeSetupPage> createState() => _PracticeSetupPageState();
}

class _PracticeSetupPageState extends ConsumerState<PracticeSetupPage> {
  final _minutes = TextEditingController(text: '10');
  final _exercises = <String>{};
  String? _skillId;
  String? _configuredSkillId;
  String? _error;
  _PracticeMode _mode = _PracticeMode.planned;
  bool _busy = false;
  @override
  void initState() {
    super.initState();
    _skillId = widget.skillId;
  }

  @override
  void didUpdateWidget(covariant PracticeSetupPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.skillId != widget.skillId && widget.skillId != null) {
      _skillId = widget.skillId;
      _exercises.clear();
    }
  }

  @override
  void dispose() {
    _minutes.dispose();
    super.dispose();
  }

  Future<void> _start(PracticeEngine engine, String skillId) async {
    if (_busy || engine.busy) return;
    final minutes = int.tryParse(_minutes.text.trim());
    if (_mode == _PracticeMode.planned &&
        (minutes == null || minutes < 1 || minutes > 180)) {
      setState(
        () => _error = 'Choose a plan from 1 to 180 minutes, or practice without a target.',
      );
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final manual =
        _mode == _PracticeMode.manual || _mode == _PracticeMode.evidence;
    final saved = await engine.create(
      skillId: skillId,
      exerciseIds: _exercises.toList(),
      plannedSeconds: _mode == _PracticeMode.planned ? minutes! * 60 : null,
      mode: manual ? EntryMode.manual : EntryMode.timed,
      manualIntent: !manual
          ? null
          : _mode == _PracticeMode.evidence
          ? ManualIntent.evidenceOnly
          : ManualIntent.duration,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (saved ||
        engine.record != null &&
            [
              'draft',
              'paused',
              'running',
            ].contains(engine.record!.session.status))
      context.push('/practice/active');
  }

  @override
  Widget build(BuildContext context) {
    final engine = ref.watch(practiceEngineProvider);
    final cards = ref.watch(skillCardsProvider(false));
    return ListenableBuilder(
      listenable: engine,
      builder: (context, _) {
        final hasPending = engine.hasUnfinished;
        final items = cards.value;
        final selectedSkill = items == null || items.isEmpty
            ? null
            : items.where((c) => c.skill.id == _skillId).firstOrNull?.skill ??
                  items.first.skill;
        if (selectedSkill != null && _configuredSkillId != selectedSkill.id) {
          _configuredSkillId = selectedSkill.id;
          _minutes.text = '${selectedSkill.defaultPracticeMinutes ?? 10}';
          _mode = selectedSkill.defaultPracticeMinutes == null
              ? _PracticeMode.untimed
              : _PracticeMode.planned;
        }
        return Theme(
          data: Theme.of(context).copyWith(
            inputDecorationTheme: Theme.of(context).inputDecorationTheme
                .copyWith(helperMaxLines: 8, errorMaxLines: 8),
          ),
          child: LoopScaffold(
            title: 'Practice',
            bottomNavigationBar:
                !hasPending && selectedSkill != null && engine.ready
                ? LoopActionBar(
                    child: LoopButton(
                      label:
                          _mode == _PracticeMode.manual ||
                              _mode == _PracticeMode.evidence
                          ? 'Continue to entry'
                          : 'Start practice',
                      icon:
                          _mode == _PracticeMode.manual ||
                              _mode == _PracticeMode.evidence
                          ? Icons.edit_note
                          : Icons.play_arrow,
                      busy: _busy,
                      onPressed: !engine.ready || engine.busy
                          ? null
                          : () => _start(engine, selectedSkill.id),
                    ),
                  )
                : null,
            actions: [
              IconButton(
                tooltip: 'Settings',
                onPressed: () => context.push('/settings'),
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
            children: [
              if (!engine.ready)
                LoopNotice(
                  title: engine.failure == null
                      ? 'Opening your practice'
                      : 'Practice could not open',
                  message: engine.failure == null
                      ? 'Checking for an unfinished session.'
                      : storageFailureMessage(engine.failure!),
                  icon: Icons.timer_outlined,
                  action: engine.failure == null
                      ? null
                      : LoopButton(
                          label: 'Retry',
                          onPressed: engine.initialize,
                        ),
                ),
              if (hasPending) ...[
                LoopNotice(
                  title: 'Your practice is still here',
                  message: 'Open your saved draft before starting another session. Time never resumes automatically.',
                  icon: Icons.pause_circle_outline,
                  action: LoopButton(
                    label: 'Open practice',
                    onPressed: engine.busy
                        ? null
                        : () async {
                            if (await engine.openPending() && context.mounted) {
                              context.push('/practice/active');
                            }
                          },
                  ),
                ),
                if (engine.pending.length > 1) ...[
                  const Text(
                    'Older unfinished entries were preserved. Choose one to finish or discard.',
                  ),
                  if (engine.running)
                    const Text(
                      'Pause your current practice before choosing another draft.',
                    ),
                  for (final pending in engine.pending)
                    LoopButton(
                      label:
                          'Open draft from ${MaterialLocalizations.of(context).formatMediumDate(pending.session.createdAtUtc.toLocal())}',
                      kind: LoopButtonKind.secondary,
                      onPressed: engine.busy || engine.running
                          ? null
                          : () async {
                              if (await engine.select(pending.session.id) &&
                                  context.mounted)
                                context.push('/practice/active');
                            },
                    ),
                ],
              ] else
                ...cards.when(
                  data: (items) {
                    if (items.isEmpty)
                      return [
                        LoopNotice(
                          title: 'Choose what to practice',
                          message:
                              'Add a skill and shape your first practice plan.',
                          icon: Icons.layers_outlined,
                          action: LoopButton(
                            label: 'Add a skill',
                            onPressed: () => context.push('/skills/new'),
                          ),
                        ),
                      ];
                    final selected = selectedSkill!;
                    final detail = ref.watch(skillDetailProvider(selected.id));
                    return [
                      Text(
                        selected.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      LoopButton(
                        label: 'Change skill',
                        kind: LoopButtonKind.secondary,
                        icon: Icons.swap_horiz,
                        onPressed: _busy
                            ? null
                            : () async {
                                final id = await showModalBottomSheet<String>(
                                  context: context,
                                  useSafeArea: true,
                                  isScrollControlled: true,
                                  showDragHandle: true,
                                  sheetAnimationStyle:
                                      MediaQuery.disableAnimationsOf(context)
                                      ? AnimationStyle.noAnimation
                                      : const AnimationStyle(
                                          duration: Duration(milliseconds: 200),
                                          reverseDuration: Duration(
                                            milliseconds: 160,
                                          ),
                                        ),
                                  builder: (sheetContext) => SizedBox(
                                    height:
                                        MediaQuery.sizeOf(sheetContext).height *
                                        .65,
                                    child: ListView(
                                      padding: const EdgeInsets.all(20),
                                      children: [
                                        Text(
                                          'Choose a skill',
                                          style: Theme.of(sheetContext)
                                              .textTheme
                                              .titleLarge,
                                        ),
                                        for (final item in items)
                                          ListTile(
                                            title: Text(item.skill.name),
                                            selected:
                                                item.skill.id == selected.id,
                                            onTap: () =>
                                                Navigator.of(sheetContext)
                                                    .pop(item.skill.id),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                                if (id != null && mounted)
                                  setState(() {
                                    _skillId = id;
                                    _exercises.clear();
                                  });
                              },
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final mode in _PracticeMode.values)
                            ChoiceChip(
                              label: Text(switch (mode) {
                                _PracticeMode.planned => 'With a plan',
                                _PracticeMode.untimed => 'No target',
                                _PracticeMode.manual => 'Log past practice',
                                _PracticeMode.evidence => 'Journal only',
                              }),
                              selected: _mode == mode,
                              onSelected: _busy
                                  ? null
                                  : (_) => setState(() {
                                      _mode = mode;
                                      _error = null;
                                    }),
                            ),
                        ],
                      ),
                      if (_mode == _PracticeMode.planned)
                        TextField(
                          controller: _minutes,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Planned minutes',
                            errorText: _error,
                            helperText: '1–180 minutes. A guide, not a countdown or a limit.',
                          ),
                        ),
                      Text(switch (_mode) {
                        _PracticeMode.planned || _PracticeMode.untimed => 'Only foreground practice counts. Switching apps or locking the screen pauses the timer. Resume when you are ready.',
                        _PracticeMode.manual => 'Enter the duration and date yourself. The saved record is labeled manual.',
                        _PracticeMode.evidence => 'A deliberate journal entry with zero practice minutes. Add a note without starting a timer.',
                      }),
                      ...detail.when(
                        data: (data) => [
                          if (data != null &&
                              data.exercises.any((e) => !e.isArchived)) ...[
                            Text(
                              'Exercises · optional',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            for (final exercise in data.exercises.where(
                              (e) => !e.isArchived,
                            ))
                              CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(exercise.title),
                                value: _exercises.contains(exercise.id),
                                onChanged: _busy
                                    ? null
                                    : (value) => setState(() {
                                        if (value == true) {
                                          _exercises.add(exercise.id);
                                        } else {
                                          _exercises.remove(exercise.id);
                                        }
                                      }),
                              ),
                          ],
                        ],
                        loading: () => [
                          const Text('Loading optional exercises…'),
                        ],
                        error: (error, _) => [
                          SkillLoadNotice(
                            error: error,
                            retry: () => ref.invalidate(
                              skillDetailProvider(selected.id),
                            ),
                          ),
                        ],
                      ),
                      if (engine.failure != null)
                        PracticeFailure(engine: engine),
                    ];
                  },
                  loading: () => [
                    SkillLoadNotice(
                      retry: () => ref.invalidate(skillCardsProvider(false)),
                    ),
                  ],
                  error: (error, _) => [
                    SkillLoadNotice(
                      error: error,
                      retry: () => ref.invalidate(skillCardsProvider(false)),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
