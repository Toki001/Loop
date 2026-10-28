import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/design_system/components.dart';
import '../../skills/presentation/skill_widgets.dart';
import '../../skills/presentation/skill_providers.dart';
import '../domain/practice_engine.dart';
import 'practice_providers.dart';
import 'practice_widgets.dart';
import 'manual_practice_page.dart';

class ActivePracticePage extends ConsumerStatefulWidget {
  const ActivePracticePage({super.key});
  @override
  ConsumerState<ActivePracticePage> createState() => _ActivePracticePageState();
}

class _ActivePracticePageState extends ConsumerState<ActivePracticePage> {
  final _note = TextEditingController();
  String? _loadedId;
  bool _busy = false;
  bool _allowPop = false;
  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<bool> _pauseAndSave(PracticeEngine engine) async {
    if (!await engine.pause(reason: 'navigation')) return false;
    if (_note.text != (engine.record?.session.note ?? ''))
      return engine.saveNote(_note.text);
    return true;
  }

  Future<void> _leave(PracticeEngine engine) async {
    if (_busy || engine.busy) return;
    setState(() => _busy = true);
    final saved =
        engine.record?.session.entryMode == 'manual' ||
        await _pauseAndSave(engine);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _allowPop = saved;
    });
    if (saved) context.go('/today');
  }

  Future<void> _finish(PracticeEngine engine) async {
    if (_busy || engine.busy) return;
    setState(() => _busy = true);
    if (!await _pauseAndSave(engine) || !mounted) {
      if (mounted) setState(() => _busy = false);
      return;
    }
    if (mounted) context.go('/practice/review/${engine.record!.session.id}');
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _discard(PracticeEngine engine) async {
    if (_busy || engine.busy) return;
    if (!await confirmSkillAction(
          context,
          title: 'Discard this practice?',
          message: 'This unfinished entry will not count as practice. Its note and timer cannot be resumed after discarding.',
          action: 'Discard practice',
        ) ||
        !mounted)
      return;
    setState(() => _busy = true);
    if (await engine.discard() && mounted) context.go('/practice/setup');
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final engine = ref.watch(practiceEngineProvider);
    return ListenableBuilder(
      listenable: engine,
      builder: (context, _) {
        final record = engine.record;
        if (!engine.ready)
          return LoopScaffold(
            title: 'Practice',
            children: [
              if (engine.failure != null) PracticeFailure(engine: engine),
              LoopButton(
                label: 'Retry opening practice',
                onPressed: engine.initialize,
              ),
            ],
          );
        if (record == null ||
            !['draft', 'running', 'paused'].contains(record.session.status))
          return LoopScaffold(
            title: 'Practice',
            children: [
              LoopNotice(
                title: 'No unfinished practice',
                message: 'Choose a skill when you are ready.',
                icon: Icons.timer_outlined,
                action: LoopButton(
                  label: 'Choose practice',
                  onPressed: () => context.go('/practice/setup'),
                ),
              ),
            ],
          );
        if (record.session.entryMode == 'manual')
          return ManualPracticePage(record: record);
        if (_loadedId != record.session.id) {
          _loadedId = record.session.id;
          _note.text = record.session.note ?? '';
        }
        final detail = ref.watch(skillDetailProvider(record.session.skillId));
        final busy = _busy || engine.busy;
        return PopScope(
          canPop: _allowPop,
          onPopInvokedWithResult: (popped, result) {
            if (!popped) _leave(engine);
          },
          child: Theme(
            data: Theme.of(context).copyWith(
              inputDecorationTheme: Theme.of(context).inputDecorationTheme
                  .copyWith(helperMaxLines: 8, errorMaxLines: 8),
            ),
            child: LoopScaffold(
              title: 'Practice',
              bottomNavigationBar: LoopActionBar(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LoopButton(
                      label: engine.running
                          ? 'Pause'
                          : record.session.status == 'draft'
                          ? 'Start practice'
                          : 'Resume',
                      icon: engine.running ? Icons.pause : Icons.play_arrow,
                      onPressed: busy || !engine.foreground
                          ? null
                          : () => engine.running
                                ? engine.pause()
                                : engine.resume(),
                    ),
                    const SizedBox(height: 8),
                    LoopButton(
                      label: 'Finish',
                      kind: LoopButtonKind.secondary,
                      onPressed: busy || record.session.status == 'draft'
                          ? null
                          : () => _finish(engine),
                    ),
                  ],
                ),
              ),
              children: [
                Text(
                  detail.value?.skill.name ?? 'Your practice',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                TimerDisplay(
                  seconds: engine.seconds,
                  caption: engine.running
                      ? 'Foreground practice'
                      : 'Paused · resume when you are ready',
                ),
                if (record.checkpoint?.plannedSeconds != null)
                  Text(
                    'Plan: ${record.checkpoint!.plannedSeconds! ~/ 60} minutes${engine.seconds >= record.checkpoint!.plannedSeconds! ? ' · target reached, keep going if useful' : ''}',
                  ),
                if (record.session.interruptionReason == 'background')
                  const LoopNotice(
                    title: 'Paused while you were away',
                    message: 'Time outside Loop has not been added. Resume whenever you choose.',
                    icon: Icons.pause_circle_outline,
                  ),
                if (record.session.interruptionReason == 'recovered')
                  const LoopNotice(
                    title: 'Your saved practice was recovered',
                    message: 'Only the last saved checkpoint is included. A sudden stop can lose time since that checkpoint; background time is never added.',
                    icon: Icons.restore,
                  ),
                if (engine.failure != null) ...[
                  PracticeFailure(engine: engine),
                  LoopButton(
                    label: 'Retry saving pause',
                    kind: LoopButtonKind.secondary,
                    onPressed: busy ? null : engine.pause,
                  ),
                ],
                for (final exercise in record.exercises)
                  LoopCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.exerciseTitleSnapshot,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (detail.value?.exercises
                                .where((e) => e.id == exercise.exerciseId)
                                .firstOrNull
                                ?.instructions
                            case final String instructions
                            when instructions.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(instructions),
                        ],
                      ],
                    ),
                  ),
                TextField(
                  controller: _note,
                  onChanged: (note) {
                    engine.stageDraft(note);
                    setState(() {});
                  },
                  enabled: !engine.running && !busy,
                  minLines: 2,
                  maxLines: 6,
                  maxLength: 100000,
                  decoration: const InputDecoration(
                    labelText: 'Practice note · optional',
                    counterText: '',
                    helperText:
                        'Pause to write. Notes save when you leave or finish.',
                  ),
                ),
                if (_note.text.isNotEmpty && _note.text == record.session.note)
                  Semantics(
                    liveRegion: true,
                    child: const Text('Note saved on this device'),
                  ),
                LoopButton(
                  label: 'Save note',
                  kind: LoopButtonKind.secondary,
                  onPressed: engine.running || busy
                      ? null
                      : () => engine.saveNote(_note.text),
                ),
                LoopButton(
                  label: 'Pause and return to Today',
                  kind: LoopButtonKind.text,
                  onPressed: busy ? null : () => _leave(engine),
                ),
                LoopButton(
                  label: 'Discard practice',
                  kind: LoopButtonKind.destructiveText,
                  onPressed: busy ? null : () => _discard(engine),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
