import 'package:flutter/material.dart';

import 'app_tokens.dart';

ThemeData buildAppTheme() {
  const family = 'NotoSansSC';
  const fallback = <String>[family];
  final base = ColorScheme.fromSeed(
    seedColor: AppColors.coral,
    brightness: Brightness.light,
  );
  final scheme = base.copyWith(
    primary: AppColors.coral,
    onPrimary: AppColors.ink,
    secondary: AppColors.green,
    onSecondary: AppColors.ink,
    surface: AppColors.card,
    onSurface: AppColors.ink,
    error: AppColors.danger,
    onError: Colors.white,
  );
  final typography = Typography.material2021(platform: TargetPlatform.android);
  final text = typography.black.apply(
    fontFamily: family,
    fontFamilyFallback: fallback,
    bodyColor: AppColors.ink,
    displayColor: AppColors.ink,
  );
  final primaryText = typography.white.apply(
    fontFamily: family,
    fontFamilyFallback: fallback,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: family,
    fontFamilyFallback: fallback,
    textTheme: text,
    primaryTextTheme: primaryText,
    splashFactory: InkRipple.splashFactory,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.coral,
        foregroundColor: AppColors.ink,
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(
          fontFamily: family,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        minimumSize: const Size(0, 48),
        side: const BorderSide(color: AppColors.line, width: 1.2),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(
          fontFamily: family,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.olive),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cream,
      hintStyle: const TextStyle(fontFamily: family, color: AppColors.muted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.m),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.m),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.m),
        borderSide: const BorderSide(color: AppColors.coralDeep, width: 1.4),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.l),
      ),
    ),
    dividerColor: AppColors.line,
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.xl),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.ink,
      contentTextStyle: text.bodyMedium?.copyWith(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.m)),
    ),
  );
}
