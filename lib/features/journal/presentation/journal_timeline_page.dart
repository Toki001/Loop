import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/design_system/components.dart';
import '../../../shared/design_system/tokens.dart';
import '../../skills/presentation/skill_widgets.dart';
import '../domain/journal_entry.dart';
import 'journal_providers.dart';
import 'journal_widgets.dart';

class JournalTimelinePage extends ConsumerStatefulWidget {
  const JournalTimelinePage({super.key, this.skillId});
  final String? skillId;
  @override
  ConsumerState<JournalTimelinePage> createState() =>
      _JournalTimelinePageState();
}

class _JournalTimelinePageState extends ConsumerState<JournalTimelinePage> {
  late String? _skillId = widget.skillId;
  DateTime? _from, _to;
  String? _exercise;
  int _limit = 50;
  bool get _filtered =>
      _skillId != null || _from != null || _to != null || _exercise != null;
  void _clear() => setState(() {
    _skillId = null;
    _from = null;
    _to = null;
    _exercise = null;
    _limit = 50;
  });
  Future<void> _chooseSkill() async {
    final skills = ref.read(journalSkillsProvider).value;
    if (skills == null) return;
    final picked = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Filter by skill'),
        children: [
          SimpleDialogOption(
            padding: const EdgeInsets.all(16),
            onPressed: () => Navigator.pop(context, ''),
            child: const Text('All skills'),
          ),
          for (final skill in skills)
            SimpleDialogOption(
              padding: const EdgeInsets.all(16),
              onPressed: () => Navigator.pop(context, skill.id),
              child: Text(
                '${skill.name}${skill.archivedAtUtc == null ? '' : ' · archived'}',
              ),
            ),
          SimpleDialogOption(
            padding: const EdgeInsets.all(16),
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    if (picked != null && mounted)
      setState(() {
        _skillId = picked.isEmpty ? null : picked;
        _exercise = null;
        _limit = 50;
      });
  }

  Future<void> _chooseExercise() async {
    final titles = ref.read(journalExerciseTitlesProvider(_skillId)).value;
    if (titles == null) return;
    final picked = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Filter by saved exercise title'),
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Titles are the snapshots saved with each session, including archived or renamed exercises.',
            ),
          ),
          SimpleDialogOption(
            padding: const EdgeInsets.all(16),
            onPressed: () => Navigator.pop(context, ''),
            child: const Text('All exercises'),
          ),
          for (final title in titles)
            SimpleDialogOption(
              padding: const EdgeInsets.all(16),
              onPressed: () => Navigator.pop(context, title),
              child: Text(title),
            ),
          SimpleDialogOption(
            padding: const EdgeInsets.all(16),
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    if (picked != null && mounted)
      setState(() {
        _exercise = picked.isEmpty ? null : picked;
        _limit = 50;
      });
  }

  Future<void> _date(bool start) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final chosen = await showDatePicker(
      context: context,
      initialDate: (start ? _from : _to) ?? today,
      firstDate: DateTime(1900),
      lastDate: today,
    );
    if (chosen != null && mounted)
      setState(() {
        if (start)
          _from = chosen;
        else
          _to = chosen;
        _limit = 50;
      });
  }

  @override
  Widget build(BuildContext context) {
    final skills = ref.watch(journalSkillsProvider);
    final titles = ref.watch(journalExerciseTitlesProvider(_skillId));
    final selected = skills.value?.where((s) => s.id == _skillId).firstOrNull;
    final invalid = _from != null && _to != null && _from!.isAfter(_to!);
    final filter = JournalFilter(
      skillId: _skillId,
      fromUtc: _from?.toUtc(),
      untilUtc: _to == null ? null : JournalFilter.nextLocalDay(_to!).toUtc(),
      exerciseTitle: _exercise,
      limit: _limit,
    );
    final result = invalid ? null : ref.watch(journalTimelineProvider(filter));
    final rows = result?.value ?? const <JournalSummary>[];
    final labels = MaterialLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice journal'),
        actions: [
          IconButton(
            tooltip: 'Back to Today',
            onPressed: () => context.go('/today'),
            icon: const Icon(Icons.today_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: LoopSpace.maxContent),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Practice, collected.',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Newest first · dates in your current timezone',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ActionChip(
                              avatar: const Icon(
                                Icons.layers_outlined,
                                size: 18,
                              ),
                              label: Text(
                                _skillId == null
                                    ? 'Skill: All skills'
                                    : 'Skill: ${selected?.name ?? 'Selected skill unavailable'}',
                              ),
                              onPressed: skills.hasValue ? _chooseSkill : null,
                            ),
                            ActionChip(
                              avatar: const Icon(Icons.tune_rounded, size: 18),
                              label: Text(
                                _exercise == null
                                    ? 'Exercise: All saved titles'
                                    : 'Exercise: $_exercise',
                              ),
                              onPressed: titles.hasValue
                                  ? _chooseExercise
                                  : null,
                            ),
                            ActionChip(
                              avatar: const Icon(
                                Icons.calendar_today_outlined,
                                size: 18,
                              ),
                              label: Text(
                                'From: ${_from == null ? 'Any date' : labels.formatMediumDate(_from!)}',
                              ),
                              onPressed: () => _date(true),
                            ),
                            ActionChip(
                              label: Text(
                                'Through: ${_to == null ? 'Any date' : labels.formatMediumDate(_to!)}',
                              ),
                              onPressed: () => _date(false),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_filtered)
                          LoopButton(
                            label: 'Clear filters',
                            kind: LoopButtonKind.text,
                            onPressed: _clear,
                          ),
                        if (skills.hasError || titles.hasError)
                          SkillLoadNotice(
                            error: skills.error ?? titles.error,
                            retry: () {
                              ref.invalidate(journalSkillsProvider);
                              ref.invalidate(
                                journalExerciseTitlesProvider(_skillId),
                              );
                            },
                          ),
                        if (invalid)
                          const LoopNotice(
                            title: 'Choose a valid date range',
                            message: 'The From date must be on or before the Through date.',
                            icon: Icons.date_range,
                          ),
                        if (result?.isLoading == true)
                          SkillLoadNotice(
                            retry: () =>
                                ref.invalidate(journalTimelineProvider(filter)),
                          ),
                        if (result?.hasError == true)
                          SkillLoadNotice(
                            error: result!.error,
                            retry: () =>
                                ref.invalidate(journalTimelineProvider(filter)),
                          ),
                        if (result?.hasValue == true && rows.isEmpty)
                          LoopNotice(
                            title: _filtered
                                ? 'No practice matches these filters'
                                : 'No saved practice yet',
                            message: _filtered
                                ? 'Your other records stay saved. Change or clear the filters to see them.'
                                : 'Start a session or make a manual journal entry. Reflection and readings are optional.',
                            icon: Icons.history,
                            action: LoopButton(
                              label: _filtered
                                  ? 'Clear filters'
                                  : 'Practice now',
                              onPressed: _filtered
                                  ? _clear
                                  : () => context.go('/practice/setup'),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList.builder(
                    itemCount: rows.length,
                    itemBuilder: (context, index) => Column(
                      children: [
                        JournalRow(entry: rows[index]),
                        const Divider(height: 1),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (rows.length == _limit && _limit < 1000)
                          LoopButton(
                            label: 'Show 50 more',
                            kind: LoopButtonKind.secondary,
                            onPressed: () => setState(() => _limit += 50),
                          ),
                        if (rows.length == 1000)
                          const Text(
                            'Showing the latest 1,000 matches. Filter by date, skill or exercise to reach older records.',
                          ),
                        LoopButton(
                          label: 'Back to Today',
                          kind: LoopButtonKind.text,
                          onPressed: () => context.go('/today'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
