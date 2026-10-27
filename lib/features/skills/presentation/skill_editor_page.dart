import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/screens/foundation_pages.dart';
import '../../../core/data/database/loop_database.dart';
import '../../../shared/design_system/components.dart';
import '../domain/skill_draft.dart';
import '../domain/skill_kind.dart';
import '../domain/starter_catalog.dart';
import 'skill_providers.dart';
import 'skill_widgets.dart';

class SkillCategoryPage extends StatefulWidget {
  const SkillCategoryPage({super.key});
  @override
  State<SkillCategoryPage> createState() => _SkillCategoryPageState();
}

class _SkillCategoryPageState extends State<SkillCategoryPage> {
  SkillKind _kind = SkillKind.music;
  @override
  Widget build(BuildContext context) => LoopScaffold(
    title: 'Choose a skill',
    bottomNavigationBar: LoopActionBar(
      child: LoopButton(
        label: 'Continue',
        onPressed: () => context.push('/skills/new/setup?kind=${_kind.name}'),
      ),
    ),
    children: [
      Text(
        'What would you like to practice?',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const Text(
        'Start with a category or make it your own. Everything in your setup is editable.',
      ),
      for (final kind in SkillKind.values)
        Semantics(
          selected: _kind == kind,
          child: LoopCard(
            padding: 4,
            child: ListTile(
              leading: Icon(skillIcon(kind.name)),
              title: Text(StarterCatalog.label(kind)),
              subtitle: kind == SkillKind.custom
                  ? const Text('Your own discipline and exercises')
                  : null,
              trailing: Icon(
                _kind == kind
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
              ),
              onTap: () => setState(() => _kind = kind),
            ),
          ),
        ),
    ],
  );
}

class SkillEditorPage extends ConsumerWidget {
  const SkillEditorPage({super.key, this.id, this.kind = SkillKind.custom});
  final String? id;
  final SkillKind kind;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (id == null) return _SkillForm(kind: kind);
    final data = ref.watch(skillDetailProvider(id!));
    return data.when(
      skipError: true,
      skipLoadingOnReload: true,
      data: (detail) => detail == null
          ? const MissingItemPage()
          : _SkillForm(
              key: ValueKey(id),
              kind: SkillKind.values.byName(detail.skill.kind),
              existing: detail.skill,
            ),
      loading: () => LoopScaffold(
        children: [
          SkillLoadNotice(
            retry: () => ref.invalidate(skillDetailProvider(id!)),
          ),
        ],
      ),
      error: (error, _) => LoopScaffold(
        children: [
          SkillLoadNotice(
            error: error,
            retry: () => ref.invalidate(skillDetailProvider(id!)),
          ),
        ],
      ),
    );
  }
}

class _SkillForm extends ConsumerStatefulWidget {
  const _SkillForm({super.key, required this.kind, this.existing});
  final SkillKind kind;
  final Skill? existing;
  @override
  ConsumerState<_SkillForm> createState() => _SkillFormState();
}

class _SkillFormState extends ConsumerState<_SkillForm> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _note;
  late final TextEditingController _minutes;
  final _goal = TextEditingController();
  late SkillKind _kind;
  late String _icon;
  late String _accent;
  late bool _untimed;
  bool _starters = true;
  bool _dirty = false;
  bool _busy = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    final skill = widget.existing;
    _kind = widget.kind;
    _name = TextEditingController(
      text: skill?.name ?? StarterCatalog.suggestedName(_kind),
    );
    _note = TextEditingController(text: skill?.description ?? '');
    _minutes = TextEditingController(
      text: '${skill?.defaultPracticeMinutes ?? 10}',
    );
    _untimed = skill != null && skill.defaultPracticeMinutes == null;
    _icon =
        skill?.iconKey ?? (_kind == SkillKind.custom ? 'practice' : _kind.name);
    _accent = StarterCatalog.accents.contains(skill?.accentKey)
        ? skill!.accentKey
        : 'indigo';
  }

  @override
  void dispose() {
    for (final controller in [_name, _note, _minutes, _goal]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy || !_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final draft = SkillDraft(
        name: _name.text,
        kind: _kind,
        iconKey: _icon,
        accentKey: _accent,
        description: _note.text.trim().isEmpty ? null : _note.text,
        practiceMinutes: _untimed ? null : int.parse(_minutes.text.trim()),
        includeStarters: _starters,
        firstGoal: widget.existing == null ? _goal.text : null,
      );
      final repo = ref.read(skillManagementProvider);
      final id = widget.existing?.id;
      if (id == null) {
        final saved = await repo.create(draft);
        if (mounted) context.go('/skills/${saved.id}');
      } else {
        await repo.update(id, draft);
        if (mounted) context.go('/skills/$id');
      }
    } catch (error) {
      if (mounted)
        setState(() {
          _busy = false;
          _error = storageFailureMessage(error);
        });
    }
  }

  @override
  Widget build(BuildContext context) => SkillEditorFrame(
    title: widget.existing == null ? 'Make it yours' : 'Edit skill',
    saveLabel: widget.existing == null ? 'Create skill' : 'Save skill',
    onSave: _save,
    dirty: _dirty,
    busy: _busy,
    error: _error,
    children: [
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
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Skill name',
                helperText: '1–60 characters. Names can repeat.',
              ),
              validator: (value) => nameError(value, 60),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<SkillKind>(
              itemHeight: null,
              initialValue: _kind,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Category'),
              items: [
                for (final kind in SkillKind.values)
                  DropdownMenuItem(
                    value: kind,
                    child: Text(StarterCatalog.label(kind)),
                  ),
              ],
              onChanged: (value) {
                if (value != null)
                  setState(() {
                    _kind = value;
                    _dirty = true;
                  });
              },
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              itemHeight: null,
              initialValue: _icon,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Icon'),
              items: [
                for (final key in StarterCatalog.iconKeys)
                  DropdownMenuItem(
                    value: key,
                    child: Row(
                      children: [
                        Icon(skillIcon(key)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            key == 'practice'
                                ? 'Practice'
                                : StarterCatalog.label(
                                    SkillKind.values.byName(key),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
              onChanged: (value) {
                if (value != null)
                  setState(() {
                    _icon = value;
                    _dirty = true;
                  });
              },
            ),
            const SizedBox(height: 24),
            const Text('Accent'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final accent in StarterCatalog.accents)
                  ChoiceChip(
                    label: Text(
                      '${accent[0].toUpperCase()}${accent.substring(1)}',
                    ),
                    avatar: Icon(
                      Icons.circle,
                      size: 14,
                      color: skillAccent(context, accent),
                    ),
                    selected: _accent == accent,
                    onSelected: (_) => setState(() {
                      _accent = accent;
                      _dirty = true;
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Untimed plan'),
              subtitle: const Text(
                'A suggestion for your next practice, not a requirement.',
              ),
              value: _untimed,
              onChanged: (value) => setState(() {
                _untimed = value;
                _dirty = true;
              }),
            ),
            if (!_untimed)
              TextFormField(
                controller: _minutes,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Suggested minutes',
                  helperText: 'Choose 1–180 minutes.',
                ),
                validator: (value) {
                  final minutes = int.tryParse((value ?? '').trim());
                  return minutes == null || minutes < 1 || minutes > 180
                      ? 'Enter a whole number from 1 to 180.'
                      : null;
                },
              ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _note,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Why this skill? (optional)',
              ),
              validator: (value) => (value?.length ?? 0) > 4000
                  ? 'Keep the note within 4,000 characters.'
                  : null,
            ),
            if (widget.existing == null) ...[
              const SizedBox(height: 24),
              TextFormField(
                controller: _goal,
                minLines: 1,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'First goal (optional)',
                  helperText: 'A milestone you mark complete yourself. Add measured goals later.',
                  helperMaxLines: 4,
                ),
                validator: (value) =>
                    (value ?? '').trim().isEmpty ? null : nameError(value, 120),
              ),
              const SizedBox(height: 16),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Include starter exercises'),
                subtitle: const Text(
                  'Editable suggestions, copied once into your skill. No practice history is added.',
                ),
                value: _starters,
                onChanged: (value) => setState(() {
                  _starters = value;
                  _dirty = true;
                }),
              ),
            ] else ...[
              const SizedBox(height: 24),
              const Text(
                'Changing the category keeps your exercises, goals and recorded history.',
              ),
            ],
          ],
        ),
      ),
    ],
  );
}
