import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/design_system/components.dart';
import '../data/skill_management_repository.dart';
import '../domain/skill_kind.dart';
import '../domain/starter_catalog.dart';
import 'skill_providers.dart';
import 'skill_widgets.dart';

class SkillsPage extends ConsumerStatefulWidget {
  const SkillsPage({super.key});
  @override
  ConsumerState<SkillsPage> createState() => _SkillsPageState();
}

class _SkillsPageState extends ConsumerState<SkillsPage> {
  final _search = TextEditingController();
  bool _archived = false;
  bool _reordering = false;
  bool _busy = false;
  String? _error;
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _move(List<SkillCardData> cards, int index, int delta) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final ids = cards.map((card) => card.skill.id).toList();
      final id = ids.removeAt(index);
      ids.insert(index + delta, id);
      await ref.read(skillManagementProvider).skills.reorder(ids);
    } catch (error) {
      if (mounted) setState(() => _error = storageFailureMessage(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cards = ref.watch(skillCardsProvider(_archived));
    final query = _search.text.trim().toLowerCase();
    return LoopScaffold(
      title: 'Skills',
      actions: [
        IconButton(
          tooltip: 'Settings',
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => context.push('/settings'),
        ),
      ],
      children: [
        Text(
          'Make room for what you want to learn',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        LoopButton(
          label: 'Add a skill',
          icon: Icons.add,
          onPressed: () => context.push('/skills/new'),
        ),
        TextField(
          controller: _search,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: 'Search skills',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: query.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(_search.clear),
                  ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Active'),
              selected: !_archived,
              onSelected: (_) => setState(() {
                _archived = false;
                _reordering = false;
              }),
            ),
            ChoiceChip(
              label: const Text('Archived'),
              selected: _archived,
              onSelected: (_) => setState(() {
                _archived = true;
                _reordering = false;
              }),
            ),
            if (!_archived && query.isEmpty && (cards.value?.length ?? 0) > 1)
              FilterChip(
                label: const Text('Reorder'),
                selected: _reordering,
                onSelected: (value) => setState(() => _reordering = value),
              ),
          ],
        ),
        if (_error != null)
          Semantics(
            liveRegion: true,
            child: LoopNotice(
              title: 'Order not saved',
              message: _error!,
              icon: Icons.error_outline,
            ),
          ),
        ...cards.when(
          data: (all) {
            final visible = all
                .where(
                  (c) =>
                      c.skill.name.toLowerCase().contains(query) ||
                      StarterCatalog.label(
                        SkillKind.values.byName(c.skill.kind),
                      ).toLowerCase().contains(query),
                )
                .toList();
            if (all.isEmpty)
              return [
                LoopNotice(
                  title: _archived
                      ? 'No archived skills'
                      : 'Your skills belong here',
                  message: _archived
                      ? 'Archived skills keep their goals, exercises and history. You can restore them whenever you choose.'
                      : 'Choose a category or create your own. Your setup stays on this device.',
                  icon: Icons.layers_outlined,
                ),
              ];
            if (visible.isEmpty)
              return [
                LoopNotice(
                  title: 'No matching skills',
                  message:
                      'Try another name or category, or clear your search.',
                  icon: Icons.search_off,
                  action: LoopButton(
                    label: 'Clear search',
                    kind: LoopButtonKind.secondary,
                    onPressed: () => setState(_search.clear),
                  ),
                ),
              ];
            return [
              for (var i = 0; i < visible.length; i++)
                SkillSummaryCard(
                  data: visible[i],
                  onOpen: () => context.push('/skills/${visible[i].skill.id}'),
                  reorder: !_archived && _reordering && query.isEmpty
                      ? Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            IconButton(
                              tooltip: 'Move ${visible[i].skill.name} earlier',
                              onPressed: _busy || i == 0
                                  ? null
                                  : () => _move(all, i, -1),
                              icon: const Icon(Icons.arrow_upward),
                            ),
                            IconButton(
                              tooltip: 'Move ${visible[i].skill.name} later',
                              onPressed: _busy || i == all.length - 1
                                  ? null
                                  : () => _move(all, i, 1),
                              icon: const Icon(Icons.arrow_downward),
                            ),
                          ],
                        )
                      : null,
                ),
            ];
          },
          loading: () => [
            SkillLoadNotice(
              retry: () => ref.invalidate(skillCardsProvider(_archived)),
            ),
          ],
          error: (error, _) => [
            SkillLoadNotice(
              error: error,
              retry: () => ref.invalidate(skillCardsProvider(_archived)),
            ),
          ],
        ),
      ],
    );
  }
}

class SkillSummaryCard extends StatelessWidget {
  const SkillSummaryCard({
    super.key,
    required this.data,
    required this.onOpen,
    this.reorder,
  });
  final SkillCardData data;
  final VoidCallback onOpen;
  final Widget? reorder;
  @override
  Widget build(BuildContext context) => LoopCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Icon(
                skillIcon(data.skill.iconKey),
                size: 28,
                color: skillAccent(context, data.skill.accentKey),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.skill.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    StarterCatalog.label(
                      SkillKind.values.byName(data.skill.kind),
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          data.lastPracticed == null
              ? 'No recorded practice yet'
              : 'Last practiced ${MaterialLocalizations.of(context).formatMediumDate(data.lastPracticed!.toLocal())}',
        ),
        if (data.goal != null) ...[
          const SizedBox(height: 8),
          Text('Goal: ${data.goal}'),
        ],
        if (data.nextStep != null) ...[
          const SizedBox(height: 8),
          Text('Next: ${data.nextStep}'),
        ],
        const SizedBox(height: 16),
        LoopButton(
          label: 'View skill',
          kind: LoopButtonKind.secondary,
          onPressed: onOpen,
        ),
        if (reorder != null) ...[const SizedBox(height: 8), reorder!],
      ],
    ),
  );
}

/// M05 offers real setup navigation; the practice engine belongs to M06.
class SkillContextPage extends ConsumerWidget {
  const SkillContextPage({super.key, required this.practice});
  final bool practice;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(skillCardsProvider(false));
    return LoopScaffold(
      title: practice ? 'Practice' : 'Today',
      actions: [
        IconButton(
          tooltip: 'Settings',
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => context.push('/settings'),
        ),
      ],
      children: [
        if (!practice)
          Text(
            MaterialLocalizations.of(context).formatFullDate(DateTime.now()),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ...cards.when(
          data: (items) => items.isEmpty
              ? [
                  LoopNotice(
                    title: practice
                        ? 'Choose what to practice'
                        : 'Your practice starts here',
                    message: 'Add a skill and shape your first practice plan.',
                    icon: Icons.layers_outlined,
                    action: LoopButton(
                      label: 'Add a skill',
                      onPressed: () => context.push('/skills/new'),
                    ),
                  ),
                ]
              : [
                  Text(
                    practice
                        ? 'Your practice plans'
                        : 'Ready for your next step',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  for (final card in practice ? items : items.take(1))
                    SkillSummaryCard(
                      data: card,
                      onOpen: () => context.push('/skills/${card.skill.id}'),
                    ),
                  LoopButton(
                    label: 'See skills',
                    kind: LoopButtonKind.text,
                    onPressed: () => context.go('/skills'),
                  ),
                ],
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
    );
  }
}
