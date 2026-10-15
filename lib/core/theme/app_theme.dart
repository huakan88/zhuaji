import 'package:flutter/material.dart';

import 'app_fonts.dart';
import 'app_tokens.dart';

ThemeData buildAppTheme(AppColors colors) {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: colors.brand,
        brightness: colors.brightness,
      ).copyWith(
        primary: colors.brand,
        onPrimary: colors.onBrand,
        secondary: colors.accent,
        onSecondary: colors.onBrand,
        surface: colors.card,
        onSurface: colors.ink,
        error: colors.danger,
        onError: colors.onDanger,
      );
  final typography = Typography.material2021(platform: TargetPlatform.android);
  final faces = colors.brightness == Brightness.dark
      ? typography.white
      : typography.black;
  final text = faces.apply(
    fontFamily: zhuajiFamily,
    fontFamilyFallback: zhuajiFallback,
    bodyColor: colors.ink,
    displayColor: colors.ink,
  );
  final primaryText =
      (colors.brightness == Brightness.dark
              ? typography.black
              : typography.white)
          .apply(fontFamily: zhuajiFamily, fontFamilyFallback: zhuajiFallback);
  final body = zhuajiOf(text.bodyMedium);
  final title = zhuajiOf(text.titleLarge)
      .copyWith(fontWeight: FontWeight.w700, fontSize: 22);
  final label = zhuaji.copyWith(fontWeight: FontWeight.w700, fontSize: 15);
  return ThemeData(
    useMaterial3: true,
    brightness: colors.brightness,
    colorScheme: scheme,
    extensions: [colors],
    scaffoldBackgroundColor: colors.background,
    canvasColor: colors.background,
    dividerColor: colors.line,
    fontFamily: zhuajiFamily,
    fontFamilyFallback: zhuajiFallback,
    textTheme: _faces(text),
    primaryTextTheme: _faces(primaryText),
    splashFactory: InkRipple.splashFactory,
    appBarTheme: AppBarTheme(
      backgroundColor: colors.background,
      foregroundColor: colors.ink,
      surfaceTintColor: AppColors.clear,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: title,
      toolbarTextStyle: body,
      toolbarHeight: 56,
    ),
    dividerTheme: DividerThemeData(color: colors.line, thickness: 1, space: 1),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: colors.brandDeep),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colors.brand,
        foregroundColor: colors.onBrand,
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: const StadiumBorder(),
        textStyle: label.copyWith(color: colors.onBrand),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.ink,
        minimumSize: const Size(0, 48),
        side: BorderSide(color: colors.line, width: 1.2),
        shape: const StadiumBorder(),
        textStyle: label,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colors.olive,
        minimumSize: const Size(48, 48),
        textStyle: label,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.field,
      labelStyle: body,
      hintStyle: body.copyWith(color: colors.muted),
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
        borderSide: BorderSide(color: colors.brandDeep, width: 1.4),
      ),
    ),
    listTileTheme: ListTileThemeData(
      titleTextStyle: zhuaji.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 16,
        color: colors.ink,
      ),
      subtitleTextStyle: body.copyWith(color: colors.muted),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: colors.card,
      selectedColor: colors.brandTint,
      disabledColor: colors.field,
      labelStyle: zhuaji.copyWith(fontSize: 13, color: colors.ink),
      secondaryLabelStyle: zhuaji.copyWith(fontSize: 13, color: colors.ink),
      showCheckmark: false,
      side: WidgetStateBorderSide.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return BorderSide(color: selected ? colors.brandDeep : colors.line);
      }),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colors.card,
      titleTextStyle: title.copyWith(fontSize: 18),
      contentTextStyle: body,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.xl),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: colors.ink,
      contentTextStyle: body.copyWith(color: colors.background),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.m),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 68,
      backgroundColor: colors.card,
      indicatorColor: colors.brandTint,
      elevation: 0,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return zhuaji.copyWith(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          color: selected ? colors.brandDeep : colors.muted,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? colors.brandDeep : colors.muted,
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
