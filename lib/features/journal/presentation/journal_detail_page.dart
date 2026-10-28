import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/screens/foundation_pages.dart';
import '../../../shared/design_system/components.dart';
import '../../skills/presentation/skill_widgets.dart';
import '../domain/journal_entry.dart';
import 'journal_providers.dart';
import 'journal_widgets.dart';

class JournalDetailPage extends ConsumerStatefulWidget {
  const JournalDetailPage({super.key, required this.id});
  final String id;
  @override
  ConsumerState<JournalDetailPage> createState() => _JournalDetailPageState();
}

class _JournalDetailPageState extends ConsumerState<JournalDetailPage> {
  bool _busy = false;
  String? _error;
  Future<void> _delete(JournalDetail detail) async {
    if (_busy) return;
    if (!await confirmSkillAction(
          context,
          title: 'Delete this practice?',
          message: detail.mediaCount == 0
              ? 'Remove this session, reflection and readings. Immediate Undo is available while the message remains visible.'
              : 'Remove this session, reflection, readings and ${detail.mediaCount} private attachment(s). Attachment deletion cannot be undone.',
          action: 'Delete practice',
        ) ||
        !mounted)
      return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final repository = ref.read(journalRepositoryProvider);
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final receipt = await repository.deleteConfirmed(
        widget.id,
        expectedRevision: detail.session.revision,
      );
      router.go('/sessions');
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Practice deleted'),
          duration: const Duration(seconds: 10),
          action: receipt.canUndo
              ? SnackBarAction(
                  label: 'Undo',
                  onPressed: () async {
                    try {
                      await repository.undo(receipt);
                      router.go('/sessions/${receipt.session.id}');
                    } on Object {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Undo could not restore this record. No partial restore was saved.',
                          ),
                        ),
                      );
                    }
                  },
                )
              : null,
        ),
      );
    } on Object catch (error) {
      if (mounted) setState(() => _error = storageFailureMessage(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => ref
      .watch(journalDetailProvider(widget.id))
      .when(
        data: (detail) {
          if (detail == null || detail.session.status != 'completed')
            return const MissingItemPage();
          final session = detail.session;
          return LoopScaffold(
            title: 'Practice record',
            actions: [
              IconButton(
                tooltip: 'Edit practice',
                onPressed: _busy
                    ? null
                    : () => context.push('/sessions/${widget.id}/edit'),
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
            children: [
              Text(
                'Saved on this device',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TimerDisplay(
                seconds: session.activeSeconds,
                caption: journalSource(session),
              ),
              Text(
                detail.skill.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text('Finished ${journalDate(context, session.endedAtUtc!)}'),
              const Text('Dates are shown in your current device timezone.'),
              if (session.interruptionReason == 'clock_adjusted')
                const LoopNotice(
                  title: 'Device clock changed',
                  message: 'The finish date is kept at the start date after a backward clock change. Active duration still comes from the practice clock.',
                  icon: Icons.schedule,
                ),
              if (detail.skill.archivedAtUtc != null)
                const Text('Archived skill · history retained'),
              if (session.whatGotEasier?.isNotEmpty == true) ...[
                const LoopSectionHeader(title: 'What got easier?'),
                SelectableText(session.whatGotEasier!),
              ],
              if (session.nextStep?.isNotEmpty == true) ...[
                const LoopSectionHeader(title: 'Next step'),
                SelectableText(session.nextStep!),
              ],
              if (session.note?.isNotEmpty == true) ...[
                const LoopSectionHeader(title: 'Notes'),
                SelectableText(session.note!),
              ],
              if (session.effortRating != null)
                Text(
                  'Effort: ${session.effortRating} / 5 · self-rated, separate from ability',
                ),
              if (detail.exercises.isNotEmpty) ...[
                const LoopSectionHeader(title: 'Selected exercises'),
                for (final exercise in detail.exercises)
                  Text(exercise.exerciseTitleSnapshot),
              ],
              if (detail.readings.isNotEmpty) ...[
                const LoopSectionHeader(title: 'Recorded observations'),
                for (final reading in detail.readings)
                  Builder(
                    builder: (context) {
                      final definition = detail.definitions
                          .where(
                            (d) =>
                                d.id == reading.metricDefinitionId &&
                                d.version == reading.definitionVersion,
                          )
                          .firstOrNull;
                      return LoopCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              definition?.label ?? 'Saved measurement',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            SelectableText(
                              journalObservation(reading, definition),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${reading.sourceType == 'self_reported'
                                  ? 'Self-reported · entered by you'
                                  : reading.sourceType == 'instrument_import'
                                  ? 'Imported instrument reading'
                                  : 'Derived observation'} · definition version ${reading.definitionVersion}',
                            ),
                            Text(
                              'Recorded for ${journalDate(context, reading.measuredAtUtc)}',
                            ),
                            if (reading.sourceNote?.isNotEmpty == true) ...[
                              const SizedBox(height: 8),
                              SelectableText(reading.sourceNote!),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
              ],
              Text(
                'Revision ${session.revision} · updated ${journalDate(context, session.updatedAtUtc)}',
                style: Theme.of(context).textTheme.bodySmall,
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
              LoopButton(
                label: 'Edit practice',
                kind: LoopButtonKind.secondary,
                onPressed: _busy
                    ? null
                    : () => context.push('/sessions/${widget.id}/edit'),
              ),
              LoopButton(
                label: 'Back to Today',
                onPressed: () => context.go('/today'),
              ),
              LoopButton(
                label: 'View skill',
                kind: LoopButtonKind.secondary,
                onPressed: () => context.go('/skills/${session.skillId}'),
              ),
              LoopButton(
                label: 'View practice journal',
                kind: LoopButtonKind.text,
                onPressed: () => context.go('/sessions'),
              ),
              LoopButton(
                label: 'Delete practice',
                kind: LoopButtonKind.destructiveText,
                busy: _busy,
                onPressed: () => _delete(detail),
              ),
            ],
          );
        },
        loading: () => LoopScaffold(
          title: 'Practice record',
          children: [
            SkillLoadNotice(
              retry: () => ref.invalidate(journalDetailProvider(widget.id)),
            ),
          ],
        ),
        error: (error, _) => LoopScaffold(
          title: 'Practice record',
          children: [
            SkillLoadNotice(
              error: error,
              retry: () => ref.invalidate(journalDetailProvider(widget.id)),
            ),
          ],
        ),
      );
}
