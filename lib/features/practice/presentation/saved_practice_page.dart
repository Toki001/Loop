import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/design_system/components.dart';
import '../../skills/presentation/skill_widgets.dart';
import '../../../app/screens/foundation_pages.dart';
import '../../skills/presentation/skill_providers.dart';
import '../data/practice_repository.dart';
import 'practice_providers.dart';

final practiceRecordProvider = FutureProvider.autoDispose
    .family<PracticeRecord?, String>(
      (ref, id) => ref.watch(practiceRepositoryProvider).find(id),
    );

class SavedPracticePage extends ConsumerWidget {
  const SavedPracticePage({super.key, required this.id});
  final String id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(practiceRecordProvider(id));
    return result.when(
      data: (record) {
        if (record == null || record.session.status != 'completed')
          return const MissingItemPage();
        final detail = ref.watch(skillDetailProvider(record.session.skillId));
        final session = record.session;
        return LoopScaffold(
          title: 'Practice record',
          children: [
            Semantics(
              liveRegion: true,
              child: Text(
                'Saved on this device',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            TimerDisplay(
              seconds: session.activeSeconds,
              caption: session.entryMode == 'timed'
                  ? 'Timed foreground practice'
                  : session.manualIntent == 'evidence_only'
                  ? 'Journal entry · zero practice minutes'
                  : 'Manual duration · entered by you',
            ),
            Text(
              detail.value?.skill.name ?? 'Saved practice',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              'Finished ${MaterialLocalizations.of(context).formatFullDate(session.endedAtUtc!.toLocal())} · ${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(session.endedAtUtc!.toLocal()))}',
            ),
            if (session.interruptionReason == 'clock_adjusted')
              const LoopNotice(
                title: 'Device clock changed',
                message: 'The device clock moved backward during practice. The displayed finish date is kept at the start date; active time still comes from the practice clock.',
                icon: Icons.schedule,
              ),
            if (session.note?.isNotEmpty == true) SelectableText(session.note!),
            for (final exercise in record.exercises)
              Text(exercise.exerciseTitleSnapshot),
            LoopButton(
              label: 'Back to Today',
              onPressed: () => context.go('/today'),
            ),
            LoopButton(
              label: 'View skill',
              kind: LoopButtonKind.secondary,
              onPressed: () => context.go('/skills/${session.skillId}'),
            ),
          ],
        );
      },
      loading: () => LoopScaffold(
        title: 'Practice record',
        children: [
          SkillLoadNotice(
            retry: () => ref.invalidate(practiceRecordProvider(id)),
          ),
        ],
      ),
      error: (error, _) => LoopScaffold(
        title: 'Practice record',
        children: [
          SkillLoadNotice(
            error: error,
            retry: () => ref.invalidate(practiceRecordProvider(id)),
          ),
        ],
      ),
    );
  }
}
