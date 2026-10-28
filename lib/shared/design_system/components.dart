import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'tokens.dart';
import 'expressive_widgets.dart';

class LoopScaffold extends StatelessWidget {
  const LoopScaffold({
    super.key,
    required this.children,
    this.title = 'Loop',
    this.actions,
    this.bottomNavigationBar,
    this.previewLabel,
  });
  final List<Widget> children;
  final String title;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final String? previewLabel;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: title == 'Loop' ? const LoopWordmark() : Text(title),
      actions: actions,
    ),
    bottomNavigationBar: bottomNavigationBar,
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: LoopSpace.maxContent),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                constraints.maxWidth < 360 ? 16 : 20,
                12,
                constraints.maxWidth < 360 ? 16 : 20,
                32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (previewLabel != null) ...[
                    Text(
                      previewLabel!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                  ],
                  for (var i = 0; i < children.length; i++) ...[
                    children[i],
                    if (i != children.length - 1) const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class LoopListRow extends StatelessWidget {
  const LoopListRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (LoopVisuals.enabled(context)) {
      final p = LoopPalette.of(context);
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: p.surface,
          borderRadius: BorderRadius.circular(22),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(22),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LoopSkillBadge(icon: icon, color: p.brand),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (onTap != null) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_outward_rounded,
                      size: 18,
                      color: p.inkMuted,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      leading: ExcludeSemantics(
        child: Icon(icon, color: LoopPalette.of(context).brand),
      ),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      onTap: onTap,
    );
  }
}

enum LoopButtonKind { primary, secondary, text, destructive, destructiveText }

class LoopActionBar extends StatelessWidget {
  const LoopActionBar({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Material(
    color: LoopPalette.of(context).surface,
    child: Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: LoopSpace.maxContent),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(width: double.infinity, child: child),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Session controls remain reachable while large exercise text scrolls.
class PracticeControls extends StatelessWidget {
  const PracticeControls({
    super.key,
    required this.paused,
    required this.onPauseResume,
    required this.onFinish,
  });
  final bool paused;
  final VoidCallback onPauseResume;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final buttons = [
      LoopButton(
        label: paused ? 'Resume' : 'Pause',
        icon: paused ? Icons.play_arrow_outlined : Icons.pause,
        onPressed: onPauseResume,
      ),
      LoopButton(
        label: 'Finish practice',
        kind: LoopButtonKind.secondary,
        onPressed: onFinish,
      ),
    ];
    return Material(
      color: LoopPalette.of(context).surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: MediaQuery.textScalerOf(context).scale(14) > 21
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [buttons[0], const SizedBox(height: 8), buttons[1]],
                )
              : Row(
                  children: [
                    Expanded(child: buttons[0]),
                    const SizedBox(width: 8),
                    Expanded(child: buttons[1]),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Native focus, keyboard, pressed and disabled behavior; never a gesture-only button.
class LoopButton extends StatelessWidget {
  const LoopButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.kind = LoopButtonKind.primary,
    this.busy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final LoopButtonKind kind;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final p = LoopPalette.of(context);
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (busy) ...[
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
        ] else if (icon != null) ...[
          Icon(icon, size: 20),
          const SizedBox(width: 8),
        ],
        Flexible(child: Text(label, textAlign: TextAlign.center)),
      ],
    );
    final style = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(48, 52)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            LoopVisuals.enabled(context) ? 18 : LoopSpace.controlRadius,
          ),
        ),
      ),
      animationDuration: LoopMotion.duration(context, LoopMotion.press),
      side: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.focused)) {
          return BorderSide(
            color:
                kind == LoopButtonKind.primary ||
                    kind == LoopButtonKind.destructive
                ? p.onBrand
                : p.focus,
            width: 2,
          );
        }
        return kind == LoopButtonKind.secondary
            ? BorderSide(color: p.inkMuted)
            : BorderSide.none;
      }),
    );
    final action = busy ? null : onPressed;
    final Widget button;
    switch (kind) {
      case LoopButtonKind.primary:
        button = FilledButton(onPressed: action, style: style, child: content);
      case LoopButtonKind.destructive:
        button = FilledButton(
          onPressed: action,
          style: style.copyWith(
            backgroundColor: WidgetStatePropertyAll(p.danger),
            foregroundColor: WidgetStatePropertyAll(
              Theme.of(context).brightness == Brightness.dark
                  ? p.background
                  : p.surface,
            ),
          ),
          child: content,
        );
      case LoopButtonKind.secondary:
        button = OutlinedButton(
          onPressed: action,
          style: style,
          child: content,
        );
      case LoopButtonKind.text:
        button = TextButton(onPressed: action, style: style, child: content);
      case LoopButtonKind.destructiveText:
        button = TextButton(
          onPressed: action,
          style: style.copyWith(
            foregroundColor: WidgetStateProperty.resolveWith(
              (states) =>
                  states.contains(WidgetState.disabled) ? p.inkMuted : p.danger,
            ),
          ),
          child: content,
        );
    }
    return Semantics(liveRegion: busy, child: button);
  }
}

class LoopCard extends StatelessWidget {
  const LoopCard({super.key, required this.child, this.padding = 20});
  final Widget child;
  final double padding;

  @override
  Widget build(BuildContext context) {
    final p = LoopPalette.of(context);
    final expressive = LoopVisuals.enabled(context);
    return Container(
      decoration: expressive
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: p.ink.withValues(
                    alpha: Theme.of(context).brightness == Brightness.dark
                        ? .06
                        : .05,
                  ),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                  spreadRadius: -10,
                ),
              ],
            )
          : null,
      child: Material(
        color: p.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          side: expressive ? BorderSide.none : BorderSide(color: p.line),
          borderRadius: BorderRadius.circular(
            expressive ? 26 : LoopSpace.cardRadius,
          ),
        ),
        child: Padding(padding: EdgeInsets.all(padding), child: child),
      ),
    );
  }
}

class LoopSectionHeader extends StatelessWidget {
  const LoopSectionHeader({super.key, required this.title, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Expanded(
        child: Semantics(
          header: true,
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
      ),
      if (trailing != null) trailing!,
    ],
  );
}

class LoopWordmark extends StatelessWidget {
  const LoopWordmark({super.key});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      ExcludeSemantics(
        child: CustomPaint(
          size: const Size(28, 28),
          painter: _LoopMarkPainter(LoopPalette.of(context).brand),
        ),
      ),
      const SizedBox(width: 8),
      Text('Loop', style: Theme.of(context).textTheme.titleLarge),
    ],
  );
}

class _LoopMarkPainter extends CustomPainter {
  const _LoopMarkPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Offset.zero & size,
      -math.pi / 3,
      math.pi * 1.67,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_LoopMarkPainter oldDelegate) =>
      color != oldDelegate.color;
}

class TimerDisplay extends StatelessWidget {
  const TimerDisplay({super.key, required this.seconds, this.caption});
  final int seconds;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final minutes = seconds ~/ 60;
    final remainder = seconds % 60;
    final digits = Text(
      '${minutes.toString().padLeft(2, '0')}:${remainder.toString().padLeft(2, '0')}',
      style: Theme.of(context).textTheme.displaySmall?.copyWith(
        fontSize: LoopVisuals.enabled(context) ? 72 : 56,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
    final display = Semantics(
      label:
          '$minutes minutes $remainder seconds${caption == null ? '' : ', $caption'}',
      child: ExcludeSemantics(
        child: Column(
          children: [
            if (minutes >= 100 || LoopVisuals.enabled(context))
              SizedBox(
                width: double.infinity,
                child: FittedBox(fit: BoxFit.scaleDown, child: digits),
              )
            else
              digits,
            if (caption != null) ...[
              const SizedBox(height: 8),
              Text(caption!, style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
    if (!LoopVisuals.enabled(context)) return display;
    final p = LoopPalette.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [p.brandSoft, p.surface],
        ),
      ),
      child: display,
    );
  }
}

class LoopNotice extends StatelessWidget {
  const LoopNotice({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.action,
  });
  final String title;
  final String message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) => LoopCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: LoopPalette.of(context).brand, size: 28),
        const SizedBox(height: 16),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(message, style: Theme.of(context).textTheme.bodyMedium),
        if (action != null) ...[const SizedBox(height: 16), action!],
      ],
    ),
  );
}

class LoopTextField extends StatelessWidget {
  const LoopTextField({
    super.key,
    required this.label,
    this.controller,
    this.helper,
    this.error,
    this.maxLines = 1,
    this.keyboardType,
    this.onChanged,
  });
  final String label;
  final String? helper;
  final String? error;
  final TextEditingController? controller;
  final int maxLines;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    minLines: maxLines == 1 ? 1 : 3,
    maxLines: maxLines,
    keyboardType: keyboardType,
    onChanged: onChanged,
    decoration: InputDecoration(
      labelText: label,
      helperText: helper,
      helperMaxLines: 4,
      errorText: error,
      errorMaxLines: 4,
      alignLabelWithHint: maxLines > 1,
    ),
  );
}

const loopDestinations = ['Today', 'Skills', 'Practice', 'Progress', 'Library'];
const _destinationIcons = [
  Icons.today_outlined,
  Icons.layers_outlined,
  Icons.play_circle_outline,
  Icons.insights_outlined,
  Icons.photo_library_outlined,
];

class LoopBottomNav extends StatelessWidget {
  const LoopBottomNav({
    super.key,
    required this.index,
    required this.onChanged,
    this.labels = loopDestinations,
    this.navigateLabel = 'Navigate',
  });
  final int index;
  final ValueChanged<int> onChanged;
  final List<String> labels;
  final String navigateLabel;

  @override
  Widget build(BuildContext context) {
    final p = LoopPalette.of(context);
    final largeType = MediaQuery.textScalerOf(context).scale(14) > 17.5;
    if (LoopVisuals.enabled(context) && !largeType)
      return LoopStudioNav(
        index: index,
        labels: labels,
        icons: _destinationIcons,
        onChanged: onChanged,
      );
    return Material(
      color: p.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: largeType
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LoopButton(
                      label: navigateLabel,
                      kind: LoopButtonKind.text,
                      onPressed: () => showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        sheetAnimationStyle: AnimationStyle(
                          duration: LoopMotion.duration(
                            context,
                            LoopMotion.sheet,
                          ),
                          reverseDuration: LoopMotion.duration(
                            context,
                            LoopMotion.navigation,
                          ),
                        ),
                        builder: (sheetContext) => SafeArea(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Go to'),
                                for (var i = 0; i < labels.length; i++)
                                  LoopButton(
                                    label: labels[i],
                                    kind: LoopButtonKind.text,
                                    onPressed: () {
                                      Navigator.pop(sheetContext);
                                      onChanged(i);
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    LoopButton(label: labels[2], onPressed: () => onChanged(2)),
                  ],
                )
              : Row(
                  children: [
                    for (var i = 0; i < labels.length; i++)
                      Expanded(
                        child: Semantics(
                          selected: index == i,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              minimumSize: const Size(48, 64),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              foregroundColor: index == i
                                  ? p.brand
                                  : p.inkMuted,
                              backgroundColor: index == i
                                  ? p.brandSoft
                                  : Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => onChanged(i),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_destinationIcons[i]),
                                const SizedBox(height: 4),
                                Text(
                                  labels[i],
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
