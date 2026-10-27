import 'package:flutter/material.dart';

/// Calm Momentum semantic palette. Essential states never rely on color alone.
@immutable
class LoopPalette {
  const LoopPalette({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.ink,
    required this.inkMuted,
    required this.line,
    required this.brand,
    required this.brandSoft,
    required this.onBrand,
    required this.success,
    required this.warning,
    required this.danger,
    required this.focus,
  });

  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color ink;
  final Color inkMuted;
  final Color line;
  final Color brand;
  final Color brandSoft;
  final Color onBrand;
  final Color success;
  final Color warning;
  final Color danger;
  final Color focus;

  static const light = LoopPalette(
    background: Color(0xFFF6F7FA),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFEEF1F6),
    ink: Color(0xFF171C28),
    inkMuted: Color(0xFF667085),
    line: Color(0xFFDCE1E9),
    brand: Color(0xFF365CF5),
    brandSoft: Color(0xFFE9EEFF),
    onBrand: Color(0xFFFFFFFF),
    success: Color(0xFF17795E),
    warning: Color(0xFF9A5C13),
    danger: Color(0xFFBA3140),
    focus: Color(0xFF1652DF),
  );

  static const dark = LoopPalette(
    background: Color(0xFF10131B),
    surface: Color(0xFF1A1F2A),
    surfaceAlt: Color(0xFF252B37),
    ink: Color(0xFFF2F4F8),
    inkMuted: Color(0xFFAEB8CA),
    line: Color(0xFF3A4250),
    brand: Color(0xFF86A0FF),
    brandSoft: Color(0xFF27345C),
    onBrand: Color(0xFF10131B),
    success: Color(0xFF6EE7B7),
    warning: Color(0xFFF8CD88),
    danger: Color(0xFFFF9BA6),
    focus: Color(0xFFB7C8FF),
  );

  static LoopPalette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

abstract final class LoopSpace {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double page = 20;
  static const double section = 24;
  static const double xl = 32;
  static const double xxl = 40;
  static const double maxContent = 720;
  static const double target = 48;
  static const double cardRadius = 16;
  static const double controlRadius = 12;
}

abstract final class LoopMotion {
  static const press = Duration(milliseconds: 120);
  static const navigation = Duration(milliseconds: 200);
  static const sheet = Duration(milliseconds: 240);

  static Duration duration(BuildContext context, Duration normal) =>
      MediaQuery.disableAnimationsOf(context) ||
          WidgetsBinding
              .instance
              .platformDispatcher
              .accessibilityFeatures
              .reduceMotion
      ? Duration.zero
      : normal;
}

abstract final class LoopTheme {
  static ThemeData build(
    Brightness brightness, {
    String? fontFamily,
    List<String>? fontFamilyFallback,
  }) {
    final p = brightness == Brightness.dark
        ? LoopPalette.dark
        : LoopPalette.light;
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: p.brand,
            brightness: brightness,
          ).copyWith(
            primary: p.brand,
            onPrimary: p.onBrand,
            surface: p.surface,
            onSurface: p.ink,
            onSurfaceVariant: p.inkMuted,
            error: p.danger,
            outline: p.inkMuted,
            outlineVariant: p.line,
          ),
      scaffoldBackgroundColor: p.background,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
    );
    final text = base.textTheme.apply(bodyColor: p.ink, displayColor: p.ink);
    return base.copyWith(
      textTheme: text.copyWith(
        displaySmall: text.displaySmall?.copyWith(
          fontSize: 34,
          height: 1.12,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.8,
        ),
        headlineMedium: text.headlineMedium?.copyWith(
          fontSize: 28,
          height: 1.18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        titleLarge: text.titleLarge?.copyWith(
          fontSize: 20,
          height: 1.3,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        titleMedium: text.titleMedium?.copyWith(
          fontSize: 16,
          height: 1.4,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: text.bodyLarge?.copyWith(fontSize: 16, height: 1.5),
        bodyMedium: text.bodyMedium?.copyWith(fontSize: 15, height: 1.45),
        bodySmall: text.bodySmall?.copyWith(
          fontSize: 13,
          height: 1.45,
          color: p.inkMuted,
          letterSpacing: 0.1,
        ),
        labelLarge: text.labelLarge?.copyWith(
          fontSize: 15,
          height: 1.4,
          fontWeight: FontWeight.w600,
        ),
      ),
      dividerColor: p.line,
      focusColor: p.brandSoft,
      iconTheme: IconThemeData(color: p.ink, size: 24),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LoopSpace.controlRadius),
          borderSide: BorderSide(color: p.inkMuted),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LoopSpace.controlRadius),
          borderSide: BorderSide(color: p.inkMuted),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LoopSpace.controlRadius),
          borderSide: BorderSide(color: p.focus, width: 2),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        foregroundColor: p.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.ink,
        contentTextStyle: text.bodyMedium?.copyWith(color: p.background),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
