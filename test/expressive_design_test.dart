import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop/shared/design_system/tokens.dart';

double contrast(Color a, Color b) {
  final x = a.computeLuminance(), y = b.computeLuminance();
  return ((x > y ? x : y) + .05) / ((x < y ? x : y) + .05);
}

void main() {
  test(
    'expressive themes retain AA text contrast and navigation/hero legibility',
    () {
      for (final p in [LoopPalette.studioLight, LoopPalette.studioDark]) {
        for (final surface in [p.surface, p.background, p.surfaceAlt]) {
          for (final ink in [p.ink, p.inkMuted, p.brand, p.danger, p.success]) {
            expect(
              contrast(ink, surface),
              greaterThanOrEqualTo(4.5),
              reason: '$ink on $surface',
            );
          }
        }
        expect(contrast(p.onBrand, p.brand), greaterThanOrEqualTo(4.5));
      }
      for (final ink in [
        Colors.white,
        const Color(0xFFE0E9FF),
        const Color(0xFFD8E4FF),
      ]) {
        expect(
          contrast(ink, const Color(0xFF2A50CD)),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          contrast(
            ink,
            Color.alphaBlend(
              Colors.white.withValues(alpha: .055),
              const Color(0xFF2A50CD),
            ),
          ),
          greaterThanOrEqualTo(4.5),
        );
      }
      expect(
        contrast(Colors.white, const Color(0xFF355BE4)),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrast(const Color(0xFFE6EDFC), const Color(0xFF111B2D)),
        greaterThanOrEqualTo(4.5),
      );
    },
  );
}
