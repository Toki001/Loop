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

  static const studioLight = LoopPalette(
    background: Color(0xFFF0F2F7),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFE7ECF6),
    ink: Color(0xFF111B30),
    inkMuted: Color(0xFF536078),
    line: Color(0xFFD6DEEC),
    brand: Color(0xFF3155DC),
    brandSoft: Color(0xFFE5ECFF),
    onBrand: Color(0xFFFFFFFF),
    success: Color(0xFF08745F),
    warning: Color(0xFF915600),
    danger: Color(0xFFB62544),
    focus: Color(0xFF2044CD),
  );
  static const studioDark = LoopPalette(
    background: Color(0xFF080F1A),
    surface: Color(0xFF121D2D),
    surfaceAlt: Color(0xFF1B2B41),
    ink: Color(0xFFF3F6FC),
    inkMuted: Color(0xFFAFBED4),
    line: Color(0xFF31445E),
    brand: Color(0xFFA4BCFF),
    brandSoft: Color(0xFF263C68),
    onBrand: Color(0xFF0B162B),
    success: Color(0xFF6EE7C2),
    warning: Color(0xFFFFD48C),
    danger: Color(0xFFFFA7BA),
    focus: Color(0xFFB4CAFF),
  );
  static LoopPalette of(BuildContext context) {
    final darkMode = Theme.of(context).brightness == Brightness.dark;
    return LoopVisuals.enabled(context)
        ? (darkMode ? studioDark : studioLight)
        : (darkMode ? dark : light);
  }
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

/// The separate M02 gallery explicitly opts into its frozen historical styling.
@immutable
class LoopVisuals extends ThemeExtension<LoopVisuals> {
  const LoopVisuals({required this.expressive});
  final bool expressive;
  static bool enabled(BuildContext context) =>
      Theme.of(context).extension<LoopVisuals>()?.expressive ?? false;
  @override
  LoopVisuals copyWith({bool? expressive}) =>
      LoopVisuals(expressive: expressive ?? this.expressive);
  @override
  LoopVisuals lerp(covariant LoopVisuals? other, double t) =>
      t < 0.5 ? this : (other ?? this);
}

abstract final class LoopTheme {
  static ThemeData build(
    Brightness brightness, {
    bool expressive = true,
    String? fontFamily,
    List<String>? fontFamilyFallback,
  }) {
    final p = expressive
        ? (brightness == Brightness.dark
              ? LoopPalette.studioDark
              : LoopPalette.studioLight)
        : (brightness == Brightness.dark
              ? LoopPalette.dark
              : LoopPalette.light);
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
      extensions: [LoopVisuals(expressive: expressive)],
      chipTheme: expressive
          ? base.chipTheme.copyWith(
              backgroundColor: p.surface,
              selectedColor: p.brandSoft,
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              labelStyle: text.labelLarge?.copyWith(color: p.ink),
            )
          : base.chipTheme,
      iconButtonTheme: expressive
          ? IconButtonThemeData(
              style: IconButton.styleFrom(
                backgroundColor: p.surface,
                foregroundColor: p.ink,
                minimumSize: const Size(48, 48),
              ),
            )
          : base.iconButtonTheme,
      textTheme: text.copyWith(
        displaySmall: text.displaySmall?.copyWith(
          fontSize: expressive ? 38 : 34,
          height: 1.12,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.8,
        ),
        headlineMedium: text.headlineMedium?.copyWith(
          fontSize: expressive ? 30 : 28,
          height: 1.18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        titleLarge: text.titleLarge?.copyWith(
          fontSize: expressive ? 21 : 20,
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
          borderRadius: BorderRadius.circular(
            expressive ? 18 : LoopSpace.controlRadius,
          ),
          borderSide: BorderSide(color: p.inkMuted),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            expressive ? 18 : LoopSpace.controlRadius,
          ),
          borderSide: BorderSide(color: p.inkMuted),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            expressive ? 18 : LoopSpace.controlRadius,
          ),
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
        toolbarHeight: expressive ? 72 : null,
        titleSpacing: expressive ? 20 : null,
        titleTextStyle: expressive
            ? text.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.6,
              )
            : null,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.ink,
        contentTextStyle: text.bodyMedium?.copyWith(color: p.background),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
