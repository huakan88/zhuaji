import 'package:flutter/material.dart';

/// Light green and white by day, deep gray-green at night.
///
/// Hex values live only in this file. Pages read them with [AppColors.of].
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.brightness,
    required this.background,
    required this.card,
    required this.ink,
    required this.muted,
    required this.line,
    required this.brand,
    required this.brandDeep,
    required this.brandTint,
    required this.accent,
    required this.sage,
    required this.olive,
    required this.warm,
    required this.field,
    required this.danger,
    required this.warning,
    required this.low,
    required this.tintDanger,
    required this.tintWarning,
    required this.tintLow,
    required this.tintOlive,
    required this.tintWarm,
    required this.onBrand,
    required this.onDanger,
    required this.scrim,
    required this.onScrim,
    required this.onScrimMuted,
    required this.scrimSoft,
    required this.snackAction,
    required this.shadow,
  });

  final Brightness brightness;
  final Color background;
  final Color card;
  final Color ink;
  final Color muted;
  final Color line;
  final Color brand;
  final Color brandDeep;
  final Color brandTint;
  final Color accent;
  final Color sage;
  final Color olive;
  final Color warm;
  final Color field;
  final Color danger;
  final Color warning;
  final Color low;
  final Color tintDanger;
  final Color tintWarning;
  final Color tintLow;
  final Color tintOlive;
  final Color tintWarm;
  final Color onBrand;
  final Color onDanger;
  final Color scrim;
  final Color onScrim;
  final Color onScrimMuted;
  final Color scrimSoft;
  final Color snackAction;
  final Color shadow;

  static const clear = Color(0x00000000);

  static const light = AppColors(
    brightness: Brightness.light,
    background: Color(0xFFF4F7F3),
    card: Color(0xFFFFFFFF),
    ink: Color(0xFF1A2A22),
    muted: Color(0xFF3E5348),
    line: Color(0xFFD5E3D8),
    brand: Color(0xFF2F7D57),
    brandDeep: Color(0xFF1B5C3C),
    brandTint: Color(0xFFE5F4EB),
    accent: Color(0xFF3E9A6A),
    sage: Color(0xFF7FA08C),
    olive: Color(0xFF2F6A45),
    warm: Color(0xFF8A5A28),
    field: Color(0xFFEAF3EC),
    danger: Color(0xFFB42318),
    warning: Color(0xFF8A4B08),
    low: Color(0xFF155E80),
    tintDanger: Color(0xFFF8E4E1),
    tintWarning: Color(0xFFF8F1E4),
    tintLow: Color(0xFFE4F2F8),
    tintOlive: Color(0xFFE7F3EB),
    tintWarm: Color(0xFFF6F0E6),
    onBrand: Color(0xFFFFFFFF),
    onDanger: Color(0xFFFFFFFF),
    scrim: Color(0xFF121A16),
    onScrim: Color(0xFFF7FBF8),
    onScrimMuted: Color(0xFFC5D0C8),
    scrimSoft: Color(0x8C121A16),
    snackAction: Color(0xFFD8F3E4),
    shadow: Color(0x141A2A22),
  );

  static const dark = AppColors(
    brightness: Brightness.dark,
    background: Color(0xFF121A16),
    card: Color(0xFF1C2822),
    ink: Color(0xFFE8F2EC),
    muted: Color(0xFFB7C7BE),
    line: Color(0xFF314239),
    brand: Color(0xFF8FD4AE),
    brandDeep: Color(0xFFC6EBD4),
    brandTint: Color(0xFF24382C),
    accent: Color(0xFF7DCEA0),
    sage: Color(0xFF8EAE9A),
    olive: Color(0xFFA9D4B8),
    warm: Color(0xFFE4C7A2),
    field: Color(0xFF24302A),
    danger: Color(0xFFFFB4A8),
    warning: Color(0xFFF0C27A),
    low: Color(0xFF9AD4EE),
    tintDanger: Color(0xFF3A2422),
    tintWarning: Color(0xFF3A3020),
    tintLow: Color(0xFF1A2C36),
    tintOlive: Color(0xFF1E3328),
    tintWarm: Color(0xFF2C241C),
    onBrand: Color(0xFF102018),
    onDanger: Color(0xFF2A1210),
    scrim: Color(0xFF121A16),
    onScrim: Color(0xFFF7FBF8),
    onScrimMuted: Color(0xFFC5D0C8),
    scrimSoft: Color(0x8C121A16),
    snackAction: Color(0xFF1B5C3C),
    shadow: Color(0x66000000),
  );

  static AppColors of(BuildContext context) {
    return Theme.of(context).extension<AppColors>() ??
        (Theme.of(context).brightness == Brightness.dark ? dark : light);
  }

  List<BoxShadow> get softShadow => [
    BoxShadow(color: shadow, blurRadius: 12, offset: const Offset(0, 4)),
  ];

  @override
  AppColors copyWith({
    Brightness? brightness,
    Color? background,
    Color? card,
    Color? ink,
    Color? muted,
    Color? line,
    Color? brand,
    Color? brandDeep,
    Color? brandTint,
    Color? accent,
    Color? sage,
    Color? olive,
    Color? warm,
    Color? field,
    Color? danger,
    Color? warning,
    Color? low,
    Color? tintDanger,
    Color? tintWarning,
    Color? tintLow,
    Color? tintOlive,
    Color? tintWarm,
    Color? onBrand,
    Color? onDanger,
    Color? scrim,
    Color? onScrim,
    Color? onScrimMuted,
    Color? scrimSoft,
    Color? snackAction,
    Color? shadow,
  }) {
    return AppColors(
      brightness: brightness ?? this.brightness,
      background: background ?? this.background,
      card: card ?? this.card,
      ink: ink ?? this.ink,
      muted: muted ?? this.muted,
      line: line ?? this.line,
      brand: brand ?? this.brand,
      brandDeep: brandDeep ?? this.brandDeep,
      brandTint: brandTint ?? this.brandTint,
      accent: accent ?? this.accent,
      sage: sage ?? this.sage,
      olive: olive ?? this.olive,
      warm: warm ?? this.warm,
      field: field ?? this.field,
      danger: danger ?? this.danger,
      warning: warning ?? this.warning,
      low: low ?? this.low,
      tintDanger: tintDanger ?? this.tintDanger,
      tintWarning: tintWarning ?? this.tintWarning,
      tintLow: tintLow ?? this.tintLow,
      tintOlive: tintOlive ?? this.tintOlive,
      tintWarm: tintWarm ?? this.tintWarm,
      onBrand: onBrand ?? this.onBrand,
      onDanger: onDanger ?? this.onDanger,
      scrim: scrim ?? this.scrim,
      onScrim: onScrim ?? this.onScrim,
      onScrimMuted: onScrimMuted ?? this.onScrimMuted,
      scrimSoft: scrimSoft ?? this.scrimSoft,
      snackAction: snackAction ?? this.snackAction,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      brightness: t < 0.5 ? brightness : other.brightness,
      background: mix(background, other.background),
      card: mix(card, other.card),
      ink: mix(ink, other.ink),
      muted: mix(muted, other.muted),
      line: mix(line, other.line),
      brand: mix(brand, other.brand),
      brandDeep: mix(brandDeep, other.brandDeep),
      brandTint: mix(brandTint, other.brandTint),
      accent: mix(accent, other.accent),
      sage: mix(sage, other.sage),
      olive: mix(olive, other.olive),
      warm: mix(warm, other.warm),
      field: mix(field, other.field),
      danger: mix(danger, other.danger),
      warning: mix(warning, other.warning),
      low: mix(low, other.low),
      tintDanger: mix(tintDanger, other.tintDanger),
      tintWarning: mix(tintWarning, other.tintWarning),
      tintLow: mix(tintLow, other.tintLow),
      tintOlive: mix(tintOlive, other.tintOlive),
      tintWarm: mix(tintWarm, other.tintWarm),
      onBrand: mix(onBrand, other.onBrand),
      onDanger: mix(onDanger, other.onDanger),
      scrim: mix(scrim, other.scrim),
      onScrim: mix(onScrim, other.onScrim),
      onScrimMuted: mix(onScrimMuted, other.onScrimMuted),
      scrimSoft: mix(scrimSoft, other.scrimSoft),
      snackAction: mix(snackAction, other.snackAction),
      shadow: mix(shadow, other.shadow),
    );
  }
}

/// Saved as the `themeMode` setting. Default is the phone's setting.
enum ZhuajiThemeMode {
  system,
  light,
  dark;

  static ZhuajiThemeMode fromStorage(String? raw) {
    return switch (raw) {
      'light' => ZhuajiThemeMode.light,
      'dark' => ZhuajiThemeMode.dark,
      _ => ZhuajiThemeMode.system,
    };
  }

  String get storage => name;

  String get label => switch (this) {
    ZhuajiThemeMode.system => '跟随系统',
    ZhuajiThemeMode.light => '浅色',
    ZhuajiThemeMode.dark => '深色',
  };

  ThemeMode get material => switch (this) {
    ZhuajiThemeMode.system => ThemeMode.system,
    ZhuajiThemeMode.light => ThemeMode.light,
    ZhuajiThemeMode.dark => ThemeMode.dark,
  };
}

class Space {
  const Space._();

  static const x1 = 4.0;
  static const x2 = 8.0;
  static const x3 = 12.0;
  static const x4 = 16.0;
  static const x5 = 20.0;
  static const x6 = 24.0;
  static const x8 = 32.0;
}

class Radii {
  const Radii._();

  static const s = 14.0;
  static const m = 16.0;
  static const l = 20.0;
  static const xl = 24.0;
}
