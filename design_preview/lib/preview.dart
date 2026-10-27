import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:loop/shared/design_system/components.dart';
import 'package:loop/shared/design_system/tokens.dart';

/// Synthetic, design-only fixtures. This harness is never the product entrypoint.
enum PreviewScene {
  welcome,
  today,
  skills,
  practice,
  reflection,
  progress,
  comparison,
  library,
  settings,
  components,
}

enum PreviewState { content, empty, loading, error, permissionDenied }

class LoopDesignPreview extends StatefulWidget {
  const LoopDesignPreview({
    super.key,
    this.scene = PreviewScene.today,
    this.state = PreviewState.content,
    this.brightness = Brightness.light,
    this.textScale = 1,
    this.reducedMotion = false,
    this.showControls = true,
    this.fontFamily,
    this.textDirection = TextDirection.ltr,
  });
  final PreviewScene scene;
  final PreviewState state;
  final Brightness brightness;
  final double textScale;
  final bool reducedMotion;
  final bool showControls;
  final String? fontFamily;
  final TextDirection textDirection;

  @override
  State<LoopDesignPreview> createState() => _LoopDesignPreviewState();
}

class _LoopDesignPreviewState extends State<LoopDesignPreview> {
  late PreviewScene scene = widget.scene;
  late PreviewState state = widget.state;
  bool paused = true;

  void choose(PreviewScene value) => setState(() {
    scene = value;
    state = PreviewState.content;
  });

  void explain(BuildContext context, String behavior) => showDialog<void>(
    context: context,
    animationStyle: AnimationStyle(
      duration: LoopMotion.duration(context, LoopMotion.navigation),
      reverseDuration: LoopMotion.duration(context, LoopMotion.navigation),
    ),
    builder: (context) => AlertDialog(
      title: const Text('Design interaction'),
      content: Text(
        '$behavior\n\nThis is a design preview. No journal, file or setting is saved.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: LoopTheme.build(
      widget.brightness,
      fontFamily: widget.fontFamily,
      fontFamilyFallback: widget.fontFamily == 'LoopReviewRoboto'
          ? const ['LoopReviewCJK']
          : null,
    ),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(widget.textScale),
        disableAnimations: widget.reducedMotion,
      ),
      child: Directionality(textDirection: widget.textDirection, child: child!),
    ),
    home: Builder(
      builder: (context) {
        final p = LoopPalette.of(context);
        final navScenes = [
          PreviewScene.today,
          PreviewScene.skills,
          PreviewScene.practice,
          PreviewScene.progress,
          PreviewScene.library,
        ];
        final navIndex = navScenes.indexOf(scene);
        return LoopScaffold(
          title: scene == PreviewScene.welcome ? 'Loop' : _title(scene),
          previewLabel: 'Design preview — synthetic data',
          actions: [
            if (scene != PreviewScene.settings)
              IconButton(
                tooltip: 'Settings',
                onPressed: () => choose(PreviewScene.settings),
                icon: const Icon(Icons.settings_outlined),
              ),
          ],
          bottomNavigationBar: scene == PreviewScene.welcome
              ? LoopActionBar(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LoopButton(
                        label: 'Choose a skill',
                        icon: Icons.arrow_forward,
                        onPressed: () => choose(PreviewScene.skills),
                      ),
                      const SizedBox(height: 8),
                      LoopButton(
                        label: 'Skip for now',
                        kind: LoopButtonKind.text,
                        onPressed: () => choose(PreviewScene.today),
                      ),
                    ],
                  ),
                )
              : scene == PreviewScene.reflection
              ? LoopActionBar(
                  child: LoopButton(
                    label: 'Save and finish',
                    onPressed: () => explain(
                      context,
                      'Save is atomic. Only a successful repository commit produces a completion state; error retains the draft.',
                    ),
                  ),
                )
              : scene == PreviewScene.practice
              ? PracticeControls(
                  paused: paused,
                  onPauseResume: () => setState(() => paused = !paused),
                  onFinish: () => choose(PreviewScene.reflection),
                )
              : navIndex < 0
              ? null
              : LoopBottomNav(
                  index: navIndex,
                  onChanged: (i) => choose(navScenes[i]),
                ),
          children: [
            if (widget.showControls) ...[
              DropdownButtonFormField<PreviewScene>(
                key: ValueKey(scene),
                initialValue: scene,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Preview screen'),
                items: [
                  for (final value in PreviewScene.values)
                    DropdownMenuItem(value: value, child: Text(_title(value))),
                ],
                onChanged: (value) {
                  if (value != null) choose(value);
                },
              ),
              DropdownButtonFormField<PreviewState>(
                key: ValueKey(state),
                initialValue: state,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Preview state'),
                items: [
                  for (final value in PreviewState.values)
                    DropdownMenuItem(value: value, child: Text(value.name)),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => state = value);
                },
              ),
            ],
            if (state != PreviewState.content)
              _state(context)
            else
              ..._content(context, p),
          ],
        );
      },
    ),
  );

  String _title(PreviewScene value) => switch (value) {
    PreviewScene.welcome => 'Welcome',
    PreviewScene.today => 'Today',
    PreviewScene.skills => 'Skills',
    PreviewScene.practice => 'Practice',
    PreviewScene.reflection => 'Finish practice',
    PreviewScene.progress => 'Progress',
    PreviewScene.comparison => 'Then vs Now',
    PreviewScene.library => 'Library',
    PreviewScene.settings => 'Settings',
    PreviewScene.components => 'Components',
  };

  Widget _state(BuildContext context) => switch (state) {
    PreviewState.empty => LoopNotice(
      title: 'Your practice starts here',
      message: 'Add a skill and make your first session count.',
      icon: Icons.add_circle_outline,
      action: LoopButton(
        label: 'Add first skill',
        onPressed: () => choose(PreviewScene.skills),
      ),
    ),
    PreviewState.loading => const LoopNotice(
      title: 'Opening your journal',
      message:
          'Loading your saved practice. Your history stays on this device.',
      icon: Icons.hourglass_empty,
    ),
    PreviewState.error => LoopNotice(
      title: 'Your session could not be saved',
      message:
          'Your draft is still here. Free some device space and try again.',
      icon: Icons.error_outline,
      action: LoopButton(
        label: 'Review retry behavior',
        onPressed: () => explain(
          context,
          'A real retry keeps the draft until the repository confirms a successful save.',
        ),
      ),
    ),
    PreviewState.permissionDenied => LoopNotice(
      title: 'Keep practicing without a recording',
      message: 'You can still save notes and measures. Allow microphone access only when you want to record.',
      icon: Icons.mic_off_outlined,
      action: LoopButton(
        label: 'Continue with a note',
        onPressed: () => choose(PreviewScene.reflection),
      ),
    ),
    PreviewState.content => const SizedBox.shrink(),
  };

  List<Widget> _content(BuildContext context, LoopPalette p) {
    final text = Theme.of(context).textTheme;
    switch (scene) {
      case PreviewScene.welcome:
        return [
          const SizedBox(height: 24),
          Text(
            'Practice with intention.\nSee your progress.',
            style: text.displaySmall,
          ),
          Text(
            'A quiet place for your skills, the work you make, and what you want to try next.',
            style: text.bodyLarge,
          ),
          LoopCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lock_outline),
                const SizedBox(height: 12),
                Text('Your practice, on your device', style: text.titleMedium),
                const SizedBox(height: 8),
                const Text(
                  'No account. No feed. Start with a note; add photos or audio when they help.',
                ),
              ],
            ),
          ),
        ];
      case PreviewScene.today:
        return [
          Text('Tuesday, October 27', style: text.bodySmall),
          Text(
            'A little practice.\nSomething to build on.',
            style: text.displaySmall,
          ),
          LoopCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const LoopListRow(
                  title: 'Drawing',
                  subtitle: 'Perspective & everyday objects',
                  icon: Icons.edit_outlined,
                ),
                const SizedBox(height: 12),
                Text(
                  'Next: slow down and look at the spaces between shapes.',
                  style: text.bodyLarge,
                ),
                const SizedBox(height: 20),
                LoopButton(
                  label: 'Start practice',
                  icon: Icons.play_arrow_outlined,
                  onPressed: () => choose(PreviewScene.practice),
                ),
              ],
            ),
          ),
          const LoopSectionHeader(title: 'This week, in context'),
          Wrap(
            spacing: 24,
            runSpacing: 16,
            children: [
              _stat(context, '38 min', 'Recorded practice'),
              _stat(context, '4', 'Sessions'),
            ],
          ),
          const LoopSectionHeader(title: 'A note from last time'),
          LoopCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'The outline felt easier when I started with the negative space.',
                  style: text.bodyLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  'Drawing · Oct 25 · self-observation',
                  style: text.bodySmall,
                ),
              ],
            ),
          ),
        ];
      case PreviewScene.skills:
        return [
          Text(
            'Make room for what\nyou want to learn.',
            style: text.headlineMedium,
          ),
          const Text('Your next step, one skill at a time.'),
          LoopCard(
            child: Column(
              children: [
                LoopListRow(
                  title: 'Drawing',
                  subtitle: 'Next: study negative space',
                  icon: Icons.edit_outlined,
                  onTap: () => choose(PreviewScene.practice),
                ),
                const Divider(),
                LoopListRow(
                  title: 'Guitar',
                  subtitle: 'Next: two clean chord changes',
                  icon: Icons.music_note_outlined,
                  onTap: () => explain(
                    context,
                    'Skill detail opens its goals, editable exercises and retained session timeline.',
                  ),
                ),
                const Divider(),
                LoopListRow(
                  title: '日本語 • a long language practice name',
                  subtitle: 'Custom names remain readable and editable.',
                  icon: Icons.chat_bubble_outline,
                  onTap: () => explain(
                    context,
                    'Full Unicode names are preserved; a skill is identified by its immutable ID.',
                  ),
                ),
              ],
            ),
          ),
          LoopButton(
            label: 'Add a skill',
            icon: Icons.add,
            onPressed: () => explain(
              context,
              'Choose a built-in category or Custom, edit its name, then save locally. No account or permission needed.',
            ),
          ),
          LoopButton(
            label: 'View archived skills',
            kind: LoopButtonKind.text,
            onPressed: () => explain(
              context,
              'Archiving retains sessions, measures and evidence.',
            ),
          ),
        ];
      case PreviewScene.practice:
        return [
          Text('Drawing · perspective study', style: text.bodySmall),
          TimerDisplay(
            seconds: 516,
            caption: paused
                ? 'Paused layout preview'
                : 'Running layout preview — clock is a fixture',
          ),
          Text('Look at the spaces between shapes.', style: text.titleLarge),
          Text(
            'On background, practice auto-pauses. Returning never adds time you were away.',
            style: text.bodySmall,
          ),
          LoopButton(
            label: 'Discard session',
            kind: LoopButtonKind.text,
            onPressed: () => explain(
              context,
              'Confirm discarding this draft. No completed history is deleted.',
            ),
          ),
        ];
      case PreviewScene.reflection:
        return [
          Text(
            'What will you take\ninto next time?',
            style: text.headlineMedium,
          ),
          Text(
            '8 min 36 sec · Drawing · design fixture',
            style: text.bodySmall,
          ),
          const LoopTextField(
            label: 'What got easier?',
            helper: 'Optional. A sentence is enough.',
            maxLines: 4,
          ),
          const LoopTextField(
            label: 'What should you try next?',
            helper: 'Optional. This can be your next starting point.',
            maxLines: 4,
          ),
          const LoopSectionHeader(title: 'Keep a moment'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final action in [
                ('Photo', Icons.add_photo_alternate_outlined),
                ('Audio', Icons.mic_none),
                ('Measure', Icons.straighten),
              ])
                LoopButton(
                  label: action.$1,
                  icon: action.$2,
                  kind: LoopButtonKind.secondary,
                  onPressed: () => explain(
                    context,
                    'Attachment/measure capture is optional and permission is requested only on explicit action.',
                  ),
                ),
            ],
          ),
          Text(
            'Everything here is optional. A timed practice record can be saved without a reflection.',
            style: text.bodySmall,
          ),
        ];
      case PreviewScene.progress:
        return [
          Text('Look back.\nFind your next step.', style: text.headlineMedium),
          Text('Drawing · last 30 days', style: text.bodySmall),
          LoopCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Practice is part of the picture.',
                  style: text.titleLarge,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 24,
                  runSpacing: 16,
                  children: [
                    _stat(context, '12', 'Sessions'),
                    _stat(context, '2h 8m', 'Recorded practice'),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Time records effort. Your notes and evidence show what changed.',
                ),
              ],
            ),
          ),
          const LoopSectionHeader(title: 'Two moments, one skill'),
          _artPair(context),
          LoopButton(
            label: 'Choose a comparison',
            kind: LoopButtonKind.secondary,
            onPressed: () => choose(PreviewScene.comparison),
          ),
          const LoopNotice(
            title: 'Add a measure when it helps',
            message:
                'There are not enough comparable measurements for a trend yet.',
            icon: Icons.insights_outlined,
          ),
        ];
      case PreviewScene.comparison:
        return [
          Text(
            'See what changed.\nKeep your own perspective.',
            style: text.headlineMedium,
          ),
          Text('Drawing · two synthetic studies', style: text.bodySmall),
          _artPair(context),
          LoopCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your observation', style: text.titleLarge),
                const SizedBox(height: 8),
                const Text(
                  'The second study uses fewer lines. What do you notice?',
                ),
                const SizedBox(height: 12),
                Text(
                  'Unedited artwork. No automated skill rating.',
                  style: text.bodySmall,
                ),
              ],
            ),
          ),
          LoopButton(
            label: 'Choose different moments',
            kind: LoopButtonKind.secondary,
            onPressed: () => explain(
              context,
              'Choose two readable assets from the same skill and media type, with dates and source sessions.',
            ),
          ),
          LoopButton(
            label: 'View source sessions',
            kind: LoopButtonKind.text,
            onPressed: () => explain(
              context,
              'Each image links to its original dated session, measures and notes.',
            ),
          ),
        ];
      case PreviewScene.library:
        return [
          Text('The work you\ncan come back to.', style: text.headlineMedium),
          Text('Private to this device', style: text.bodySmall),
          const LoopTextField(
            label: 'Search your evidence',
            helper: 'Notes, skill or exercise. Search stays offline.',
          ),
          _artPair(context),
          LoopCard(
            child: LoopListRow(
              title: 'Two clean chord changes',
              subtitle: 'Audio · Oct 24 · 24 seconds',
              icon: Icons.graphic_eq,
              onTap: () => explain(
                context,
                'Audio never autoplays; playback is exclusive and stops on exit/background.',
              ),
            ),
          ),
          Text(
            'Export includes your evidence. Deleting the app can remove unexported history.',
            style: text.bodySmall,
          ),
        ];
      case PreviewScene.settings:
        return [
          Text('Your practice.\nYour choices.', style: text.headlineMedium),
          LoopCard(
            child: Column(
              children: [
                LoopListRow(
                  title: 'Appearance',
                  subtitle: 'Follow system, light or dark',
                  icon: Icons.brightness_6_outlined,
                  onTap: () => explain(
                    context,
                    'A real appearance preference is persisted locally at M03.',
                  ),
                ),
                const Divider(),
                LoopListRow(
                  title: 'Reminders',
                  subtitle: 'Optional. Quiet hours respected.',
                  icon: Icons.notifications_none,
                  onTap: () => explain(
                    context,
                    'Local best-effort schedules, pause-all and contextual OS permission.',
                  ),
                ),
              ],
            ),
          ),
          const LoopSectionHeader(title: 'Your data'),
          LoopCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'No account. No hidden uploads.\nExport when you want a portable copy.',
                ),
                const SizedBox(height: 16),
                LoopButton(
                  label: 'Export data',
                  kind: LoopButtonKind.secondary,
                  onPressed: () => explain(
                    context,
                    'Review content counts, archive sensitivity and the actual encryption mode before export.',
                  ),
                ),
                const SizedBox(height: 8),
                LoopButton(
                  label: 'Restore from an archive',
                  kind: LoopButtonKind.text,
                  onPressed: () => explain(
                    context,
                    'Validate first; preview counts/collisions; merge atomically or leave the journal unchanged.',
                  ),
                ),
              ],
            ),
          ),
          LoopButton(
            label: 'Clear all local data',
            kind: LoopButtonKind.destructiveText,
            onPressed: () => explain(
              context,
              'A destructive confirmation states affected records/files/schedules and excludes external backups/exports.',
            ),
          ),
          Text('Loop · local-first practice', style: text.bodySmall),
        ];
      case PreviewScene.components:
        return [
          Text('Calm Momentum', style: text.displaySmall),
          const Text('Native controls, deliberate spacing, clear recovery.'),
          LoopButton(
            label: 'Primary action',
            icon: Icons.play_arrow_outlined,
            onPressed: () => explain(
              context,
              'Immediate native pressed/focus feedback; activation on release.',
            ),
          ),
          LoopButton(
            label: 'Secondary action',
            kind: LoopButtonKind.secondary,
            onPressed: () => explain(
              context,
              'A secondary action keeps its label and minimum hit target.',
            ),
          ),
          const LoopButton(label: 'Unavailable action', onPressed: null),
          const LoopTextField(
            label: 'Skill name',
            helper: '1–60 characters; duplicate names are allowed.',
          ),
          const LoopTextField(
            label: 'Measure',
            error: 'Enter a finite number in the selected unit.',
          ),
          const TimerDisplay(
            seconds: 516,
            caption: 'Timer semantics describe duration; no every-second announcement.',
          ),
          LoopButton(
            label: 'Delete selected entry',
            kind: LoopButtonKind.destructive,
            onPressed: () => explain(
              context,
              'Confirm the explicit irreversible scope before deletion.',
            ),
          ),
        ];
    }
  }

  Widget _stat(BuildContext context, String value, String label) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(value, style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 4),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
    ],
  );

  Widget _artPair(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final stack =
          box.maxWidth < 340 || MediaQuery.textScalerOf(context).scale(14) > 21;
      final children = [
        _study(context, 'Then · Oct 4', 0),
        _study(context, 'Now · Oct 25', 1),
      ];
      return stack
          ? Column(
              children: [children[0], const SizedBox(height: 16), children[1]],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: children[0]),
                const SizedBox(width: 12),
                Expanded(child: children[1]),
              ],
            );
    },
  );

  Widget _study(BuildContext context, String label, int variant) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Semantics(
        image: true,
        label: 'Synthetic line drawing study, $label',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 1.12,
            child: CustomPaint(painter: _StudyPainter(variant)),
          ),
        ),
      ),
      const SizedBox(height: 8),
      Text(label, style: Theme.of(context).textTheme.titleMedium),
      Text(
        'Drawing · design fixture',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ],
  );
}

/// Original procedural fixture artwork. No user media or generated improvement.
class _StudyPainter extends CustomPainter {
  const _StudyPainter(this.variant);
  final int variant;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFF0EADD),
    );
    final ink = Paint()
      ..color = const Color(0xFF686354)
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke;
    final center = Offset(size.width * .52, size.height * .50);
    for (var i = 0; i < (variant == 0 ? 3 : 2); i++) {
      final shift = i * 2.2;
      canvas.drawOval(
        Rect.fromCenter(
          center: center + Offset(shift, -shift),
          width: size.width * .43,
          height: size.height * .51,
        ),
        ink,
      );
    }
    canvas.drawArc(
      Rect.fromCenter(
        center: center + Offset(size.width * .23, 0),
        width: size.width * .25,
        height: size.height * .30,
      ),
      -math.pi / 2,
      math.pi,
      false,
      ink,
    );
    canvas.drawLine(
      Offset(size.width * .16, size.height * .78),
      Offset(size.width * .87, size.height * .73),
      ink,
    );
    for (var i = 0; i < 9; i++) {
      final x = size.width * (.32 + i * .025);
      canvas.drawLine(
        Offset(x, size.height * .56),
        Offset(x + size.width * .08, size.height * .69),
        ink,
      );
    }
  }

  @override
  bool shouldRepaint(_StudyPainter oldDelegate) =>
      oldDelegate.variant != variant;
}
