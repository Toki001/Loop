import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/design_system/components.dart';
import '../../../shared/design_system/expressive_widgets.dart';
import '../../../shared/design_system/tokens.dart';
import '../../skills/presentation/skill_widgets.dart';
import 'journal_providers.dart';

/// Counts all completed records, including explicitly entered manual duration.
/// Journal-only entries contribute a session and zero seconds. This is activity,
/// not an inference about ability or improvement.
class JournalOverviewSection extends ConsumerWidget {
  const JournalOverviewSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(journalOverviewProvider)
      .when(
        data: (value) {
          final cards = [
            _ActivityCard(
              icon: Icons.timer_outlined,
              label: 'Time recorded',
              value: value.seconds < 60
                  ? '${value.seconds} sec'
                  : '${value.seconds ~/ 60} min',
              color: LoopPalette.of(context).brand,
            ),
            _ActivityCard(
              icon: Icons.book_outlined,
              label: 'Saved sessions',
              value: '${value.sessions}',
              color: LoopPalette.of(context).success,
            ),
          ];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const LoopSectionHeader(title: 'Your practice, so far'),
              const SizedBox(height: 12),
              if (MediaQuery.textScalerOf(context).scale(14) > 21)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [cards[0], const SizedBox(height: 12), cards[1]],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: cards[0]),
                    const SizedBox(width: 12),
                    Expanded(child: cards[1]),
                  ],
                ),
              const SizedBox(height: 8),
              Text(
                'Saved on this device · includes manual entries',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (error, _) => SkillLoadNotice(
          error: error,
          retry: () => ref.invalidate(journalOverviewProvider),
        ),
      );
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label, value;
  final Color color;
  @override
  Widget build(BuildContext context) => LoopCard(
    padding: 16,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LoopSkillBadge(icon: icon, color: color),
        const SizedBox(height: 16),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    ),
  );
}
