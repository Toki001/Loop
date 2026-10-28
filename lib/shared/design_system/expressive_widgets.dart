import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Static open-loop artwork: ornament, never a progress or ability indicator.
class _LoopArtwork extends CustomPainter {
  const _LoopArtwork();
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * .92, size.height * .24);
    for (var i = 0; i < 3; i++) {
      final radius = 70.0 + i * 42;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        math.pi * .15,
        math.pi * 1.65,
        false,
        Paint()
          ..color = Colors.white.withValues(alpha: .035 + i * .01)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 22
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_LoopArtwork oldDelegate) => false;
}

class LoopHeroCard extends StatelessWidget {
  const LoopHeroCard({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onAction,
    this.secondaryLabel,
    this.onSecondary,
  });
  final String eyebrow, title, description, actionLabel;
  final VoidCallback onAction;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(28),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF173CB7).withValues(alpha: .18),
          blurRadius: 28,
          offset: const Offset(0, 14),
          spreadRadius: -10,
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2A50CD), Color(0xFF18389A), Color(0xFF111D49)],
          ),
        ),
        child: CustomPaint(
          painter: const _LoopArtwork(),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  eyebrow,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: const Color(0xFFD8E4FF),
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -.8,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: const Color(0xFFE0E9FF)),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: onAction,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF17399A),
                    minimumSize: const Size(48, 56),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_arrow_rounded),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(actionLabel, textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                ),
                if (secondaryLabel != null) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: onSecondary,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      minimumSize: const Size(48, 48),
                    ),
                    child: Text(secondaryLabel!, textAlign: TextAlign.center),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class LoopSkillBadge extends StatelessWidget {
  const LoopSkillBadge({super.key, required this.icon, required this.color});
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(icon, color: color, size: 27),
    ),
  );
}

class LoopStudioNav extends StatelessWidget {
  const LoopStudioNav({
    super.key,
    required this.index,
    required this.labels,
    required this.icons,
    required this.onChanged,
  });
  final int index;
  final List<String> labels;
  final List<IconData> icons;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .16),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: const Color(0xFF111B2D),
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Row(
              children: [
                for (var i = 0; i < labels.length; i++)
                  Expanded(
                    child: Semantics(
                      selected: index == i,
                      child: TextButton(
                        onPressed: () => onChanged(i),
                        style: TextButton.styleFrom(
                          minimumSize: const Size(48, 64),
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 2,
                          ),
                          foregroundColor: index == i && i != 2
                              ? const Color(0xFF111B2D)
                              : const Color(0xFFE6EDFC),
                          backgroundColor: i == 2
                              ? const Color(0xFF355BE4)
                              : index == i
                              ? Colors.white
                              : Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              i == 2 ? 24 : 22,
                            ),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              i == 2 ? Icons.play_arrow_rounded : icons[i],
                              size: i == 2 ? 28 : 22,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              labels[i],
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
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
      ),
    ),
  );
}
