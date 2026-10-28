import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/screens/foundation_pages.dart';
import '../../../core/data/database/loop_database.dart';
import '../../../shared/design_system/components.dart';
import 'skill_providers.dart';
import 'skill_widgets.dart';

class ExerciseEditorPage extends ConsumerWidget {
  const ExerciseEditorPage({super.key, required this.skillId, this.id});
  final String skillId;
  final String? id;
  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(skillDetailProvider(skillId))
      .when(
        skipError: true,
        skipLoadingOnReload: true,
        data: (data) {
          final existing = data?.exercises
              .where((exercise) => exercise.id == id)
              .firstOrNull;
          if (data == null || id != null && existing == null)
            return const MissingItemPage();
          return _ExerciseForm(
            key: ValueKey(id ?? 'new'),
            skillId: skillId,
            existing: existing,
          );
        },
        loading: () => LoopScaffold(
          children: [
            SkillLoadNotice(
              retry: () => ref.invalidate(skillDetailProvider(skillId)),
            ),
          ],
        ),
        error: (error, _) => LoopScaffold(
          children: [
            SkillLoadNotice(
              error: error,
              retry: () => ref.invalidate(skillDetailProvider(skillId)),
            ),
          ],
        ),
      );
}

class _ExerciseForm extends ConsumerStatefulWidget {
  const _ExerciseForm({super.key, required this.skillId, this.existing});
  final String skillId;
  final Exercise? existing;
  @override
  ConsumerState<_ExerciseForm> createState() => _ExerciseFormState();
}

class _ExerciseFormState extends ConsumerState<_ExerciseForm> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _instructions;
  late final TextEditingController _seconds;
  bool _dirty = false;
  bool _busy = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.existing?.title ?? '');
    _instructions = TextEditingController(
      text: widget.existing?.instructions ?? '',
    );
    _seconds = TextEditingController(
      text: widget.existing?.defaultSeconds?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _title.dispose();
    _instructions.dispose();
    _seconds.dispose();
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
      await ref
          .read(skillManagementProvider)
          .saveExercise(
            skillId: widget.skillId,
            id: widget.existing?.id,
            title: _title.text,
            instructions: _instructions.text,
            seconds: int.tryParse(_seconds.text.trim()),
          );
      if (mounted) context.go('/skills/${widget.skillId}?section=exercises');
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
    title: widget.existing == null ? 'Add exercise' : 'Edit exercise',
    saveLabel: 'Save exercise',
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
              controller: _title,
              minLines: 1,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Exercise title'),
              validator: (value) => nameError(value, 120),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _instructions,
              minLines: 5,
              maxLines: 12,
              decoration: const InputDecoration(
                labelText: 'Instructions (optional)',
                alignLabelWithHint: true,
              ),
              validator: (value) => (value?.length ?? 0) > 10000
                  ? 'Keep instructions within 10,000 characters.'
                  : null,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _seconds,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Suggested seconds (optional)',
                helperText: '1–10,800 seconds, or leave empty for no suggested duration.',
                helperMaxLines: 4,
              ),
              validator: (value) {
                if ((value ?? '').trim().isEmpty) return null;
                final seconds = int.tryParse(value!.trim());
                return seconds != null && seconds >= 1 && seconds <= 10800
                    ? null
                    : 'Enter a whole number from 1 to 10,800, or leave empty.';
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'This exercise is yours to adapt. Edits keep its identity and any recorded practice references.',
            ),
          ],
        ),
      ),
    ],
  );
}
