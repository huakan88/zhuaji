import 'package:flutter/material.dart';

import 'app_fonts.dart';
import 'app_tokens.dart';

ThemeData buildAppTheme() {
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
    fontFamily: zhuajiFamily,
    fontFamilyFallback: zhuajiFallback,
    bodyColor: AppColors.ink,
    displayColor: AppColors.ink,
  );
  final primaryText = typography.white.apply(
    fontFamily: zhuajiFamily,
    fontFamilyFallback: zhuajiFallback,
  );
  final body = zhuajiOf(text.bodyMedium);
  final title = zhuajiOf(text.titleLarge)
      .copyWith(fontWeight: FontWeight.w700, fontSize: 22);
  final label = zhuaji.copyWith(fontWeight: FontWeight.w700, fontSize: 15);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: zhuajiFamily,
    fontFamilyFallback: zhuajiFallback,
    textTheme: _faces(text),
    primaryTextTheme: _faces(primaryText),
    splashFactory: InkRipple.splashFactory,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: title,
      toolbarTextStyle: body,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.coral,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: const StadiumBorder(),
        textStyle: label.copyWith(color: Colors.white),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        minimumSize: const Size(0, 48),
        side: const BorderSide(color: AppColors.line, width: 1.2),
        shape: const StadiumBorder(),
        textStyle: label,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.olive,
        textStyle: label,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cream,
      labelStyle: body,
      hintStyle: body.copyWith(color: AppColors.muted),
      floatingLabelStyle: body,
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
    listTileTheme: ListTileThemeData(
      titleTextStyle: zhuaji.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 16,
        color: AppColors.ink,
      ),
      subtitleTextStyle: body.copyWith(color: AppColors.muted),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.card,
      selectedColor: AppColors.tintCoral,
      disabledColor: AppColors.cream,
      labelStyle: zhuaji.copyWith(fontSize: 13, color: AppColors.ink),
      secondaryLabelStyle: zhuaji.copyWith(fontSize: 13, color: AppColors.ink),
      showCheckmark: false,
      side: WidgetStateBorderSide.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return BorderSide(
          color: selected ? AppColors.coralDeep : AppColors.line,
        );
      }),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.card,
      titleTextStyle: title.copyWith(fontSize: 18),
      contentTextStyle: body,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.xl),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.ink,
      contentTextStyle: body.copyWith(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.m),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 68,
      backgroundColor: Colors.white,
      indicatorColor: AppColors.tintCoral,
      elevation: 0,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return zhuaji.copyWith(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          color: selected ? AppColors.coralDeep : AppColors.muted,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? AppColors.coralDeep : AppColors.muted,
          size: 24,
        );
      }),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: SoftPageTransition(),
        TargetPlatform.iOS: SoftPageTransition(),
        TargetPlatform.linux: SoftPageTransition(),
        TargetPlatform.macOS: SoftPageTransition(),
        TargetPlatform.windows: SoftPageTransition(),
        TargetPlatform.fuchsia: SoftPageTransition(),
      },
    ),
  );
}

class SoftPageTransition extends PageTransitionsBuilder {
  const SoftPageTransition();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

TextTheme _faces(TextTheme theme) {
  TextStyle? face(TextStyle? style) => style == null ? null : zhuajiOf(style);
  return theme.copyWith(
    displayLarge: face(theme.displayLarge),
    displayMedium: face(theme.displayMedium),
    displaySmall: face(theme.displaySmall),
    headlineLarge: face(theme.headlineLarge),
    headlineMedium: face(theme.headlineMedium),
    headlineSmall: face(theme.headlineSmall),
    titleLarge: face(theme.titleLarge),
    titleMedium: face(theme.titleMedium),
    titleSmall: face(theme.titleSmall),
    bodyLarge: face(theme.bodyLarge),
    bodyMedium: face(theme.bodyMedium),
    bodySmall: face(theme.bodySmall),
    labelLarge: face(theme.labelLarge),
    labelMedium: face(theme.labelMedium),
    labelSmall: face(theme.labelSmall),
  );
}
