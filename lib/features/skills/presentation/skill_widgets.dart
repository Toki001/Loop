import 'package:flutter/material.dart';

import '../../../core/data/local_failure.dart';
import '../../../shared/design_system/components.dart';
import '../../../shared/design_system/tokens.dart';
import '../domain/goal_rules.dart';

String? nameError(String? value, int maximum) {
  final count = (value ?? '').trim().characters.length;
  return count < 1 || count > maximum
      ? 'Use 1–$maximum characters.'
      : (value?.length ?? 0) > 4096
      ? 'This name takes too much storage. Shorten it and try again.'
      : null;
}

String goalTypeLabel(GoalType type) => switch (type) {
  GoalType.cumulative => 'Cumulative count or duration',
  GoalType.threshold => 'Reach a measured value',
  GoalType.weeklyTarget => 'Weekly practice suggestion',
  GoalType.deliverable => 'Deliverable milestone',
  GoalType.qualitative => 'Qualitative goal',
};

String goalUnitLabel(String? unit) => switch (unit) {
  'practice_sessions' => 'practice sessions',
  'practice_seconds' => 'practice seconds',
  'days_per_week' => 'days per week',
  'percent' => '%',
  _ => unit ?? '',
};

IconData skillIcon(String key) => switch (key) {
  'music' => Icons.music_note_outlined,
  'drawing' => Icons.draw_outlined,
  'language' => Icons.translate_outlined,
  'programming' => Icons.code_outlined,
  'voice' => Icons.mic_none_outlined,
  'typing' => Icons.keyboard_outlined,
  'movement' => Icons.accessibility_new_outlined,
  _ => Icons.auto_awesome_motion_outlined,
};

Color skillAccent(BuildContext context, String key) => switch (key) {
  'amber' => LoopPalette.of(context).warning,
  'plum' =>
    Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFD4B8F1)
        : const Color(0xFF78539D),
  'teal' => LoopPalette.of(context).success,
  'coral' => LoopPalette.of(context).danger,
  _ => LoopPalette.of(context).brand,
};

String storageFailureMessage(Object error) =>
    switch (localFailure(error).kind) {
      LocalFailureKind.full => 'Your device storage is full. Free some space, then try again. Your draft is still here.',
      LocalFailureKind.conflict => 'This item changed or cannot be saved in its current state. Review the values and try again.',
      LocalFailureKind.invalid =>
        'Check the name, target, unit and duration. Your draft has been kept.',
      LocalFailureKind.notFound =>
        'This item is no longer available. Go back to your skills to continue.',
      _ => 'We could not save this change. Your draft has been kept. Try again when private storage is available.',
    };

class SkillLoadNotice extends StatelessWidget {
  const SkillLoadNotice({super.key, this.error, required this.retry});
  final Object? error;
  final VoidCallback retry;
  @override
  Widget build(BuildContext context) => LoopNotice(
    title: error == null
        ? 'Opening your skills'
        : 'We could not load this data',
    message: error == null ? 'Reading your saved setup on this device.' : 'Your saved data has not been reset. Try again when private storage is available.',
    icon: error == null ? Icons.hourglass_empty : Icons.error_outline,
    action: error == null
        ? null
        : LoopButton(label: 'Try again', onPressed: retry),
  );
}

Future<bool> confirmSkillAction(
  BuildContext context, {
  required String title,
  required String message,
  required String action,
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        scrollable: true,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
          ),
        ],
      ),
    ) ??
    false;

class SkillEditorFrame extends StatefulWidget {
  const SkillEditorFrame({
    super.key,
    required this.title,
    required this.children,
    required this.saveLabel,
    required this.onSave,
    required this.dirty,
    required this.busy,
    this.error,
  });
  final String title;
  final List<Widget> children;
  final String saveLabel;
  final VoidCallback onSave;
  final bool dirty;
  final bool busy;
  final String? error;

  @override
  State<SkillEditorFrame> createState() => _SkillEditorFrameState();
}

class _SkillEditorFrameState extends State<SkillEditorFrame> {
  bool _allowPop = false;
  bool _asking = false;

  Future<void> _requestPop() async {
    if (_asking || widget.busy) return;
    _asking = true;
    // Let pending field changes reach this frame before deciding to discard.
    // Back in the same frame as an edit must not bypass the dirty guard.
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted || widget.busy) {
      _asking = false;
      return;
    }
    final discard =
        !widget.dirty ||
        await confirmSkillAction(
          context,
          title: 'Leave without saving?',
          message: 'Your unsaved changes will be discarded. Your saved data stays as it is.',
          action: 'Discard changes',
        );
    _asking = false;
    if (!discard || !mounted) return;
    setState(() => _allowPop = true);
    await WidgetsBinding.instance.endOfFrame;
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: _allowPop,
    onPopInvokedWithResult: (didPop, result) async {
      if (!didPop) await _requestPop();
    },
    child: Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: Theme.of(context).inputDecorationTheme
            .copyWith(helperMaxLines: 8, errorMaxLines: 8),
      ),
      child: LoopScaffold(
        title: widget.title,
        bottomNavigationBar: LoopActionBar(
          child: LoopButton(
            label: widget.saveLabel,
            onPressed: widget.onSave,
            busy: widget.busy,
          ),
        ),
        children: [
          AbsorbPointer(
            absorbing: widget.busy,
            child: FocusScope(
              canRequestFocus: !widget.busy,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < widget.children.length; i++) ...[
                    widget.children[i],
                    if (i != widget.children.length - 1)
                      const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ),
          if (widget.error != null)
            Semantics(
              liveRegion: true,
              child: LoopNotice(
                title: 'Not saved yet',
                message: widget.error!,
                icon: Icons.error_outline,
              ),
            ),
        ],
      ),
    ),
  );
}
