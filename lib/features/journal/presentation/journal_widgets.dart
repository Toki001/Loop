import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/database/loop_database.dart';
import '../../../shared/design_system/components.dart';
import '../../skills/presentation/skill_widgets.dart';
import '../domain/journal_entry.dart';
import 'journal_providers.dart';

String journalSource(Session session) => session.entryMode == 'timed'
    ? 'Timed foreground practice'
    : session.manualIntent == 'evidence_only'
    ? 'Journal entry · zero practice minutes'
    : 'Manual duration · entered by you';
String journalDate(BuildContext context, DateTime utc) {
  final date = utc.toLocal();
  final labels = MaterialLocalizations.of(context);
  return '${labels.formatMediumDate(date)} · ${labels.formatTimeOfDay(TimeOfDay.fromDateTime(date))}';
}

String journalDuration(Session session) {
  if (session.manualIntent == 'evidence_only') return 'Zero practice minutes';
  final seconds = session.activeSeconds;
  return seconds < 60
      ? '$seconds seconds'
      : '${seconds ~/ 60} min ${seconds % 60} sec';
}

String journalObservation(MetricReading reading, MetricDefinition? definition) {
  if (reading.boolValue != null)
    return reading.boolValue! ? 'Done' : 'Not done';
  if (reading.textValue != null) return reading.textValue!;
  final number = reading.numericValue!;
  final value = number == number.truncateToDouble()
      ? number.toStringAsFixed(0)
      : number.toString();
  return '$value ${definition?.unitKey ?? ''}'.trim();
}

class JournalRow extends StatelessWidget {
  const JournalRow({super.key, required this.entry, this.showSkill = true});
  final JournalSummary entry;
  final bool showSkill;
  @override
  Widget build(BuildContext context) => LoopListRow(
    title: showSkill
        ? entry.skillName
        : journalDate(context, entry.session.endedAtUtc!),
    subtitle:
        '${showSkill ? '${journalDate(context, entry.session.endedAtUtc!)}\n' : ''}${journalDuration(entry.session)} · ${entry.session.entryMode == 'timed' ? 'timed' : 'manual'}${entry.session.nextStep?.isNotEmpty == true ? '\nNext: ${entry.session.nextStep!.characters.take(160)}${entry.session.nextStep!.characters.length > 160 ? '…' : ''}' : ''}',
    icon: entry.session.manualIntent == 'evidence_only'
        ? Icons.notes_outlined
        : Icons.history,
    onTap: () => context.push('/sessions/${entry.session.id}'),
  );
}

class RecentJournalSection extends ConsumerWidget {
  const RecentJournalSection({super.key, this.skillId});
  final String? skillId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = skillId == null
        ? ref.watch(recentJournalProvider)
        : ref.watch(skillJournalProvider(skillId!));
    return result.when(
      data: (entries) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LoopSectionHeader(
            title: skillId == null ? 'Recent practice' : 'Timeline',
          ),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            const Text(
              'No saved practice yet. A session can be useful with or without a reflection.',
            ),
          for (final entry in entries)
            JournalRow(entry: entry, showSkill: skillId == null),
          const SizedBox(height: 8),
          LoopButton(
            label: 'View practice journal',
            kind: LoopButtonKind.secondary,
            onPressed: () => context.push(
              skillId == null ? '/sessions' : '/sessions?skill=$skillId',
            ),
          ),
        ],
      ),
      loading: () => SkillLoadNotice(
        retry: () => skillId == null
            ? ref.invalidate(recentJournalProvider)
            : ref.invalidate(skillJournalProvider(skillId!)),
      ),
      error: (error, _) => SkillLoadNotice(
        error: error,
        retry: () => skillId == null
            ? ref.invalidate(recentJournalProvider)
            : ref.invalidate(skillJournalProvider(skillId!)),
      ),
    );
  }
}
