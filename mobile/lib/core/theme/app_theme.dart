import 'package:flutter/material.dart';

import 'text_styles.dart';
import 'tokens.dart';

ThemeData buildTheme(Brightness brightness) {
  final isLight = brightness == Brightness.light;
  final scheme = isLight ? lightScheme : darkScheme;
  final colors = isLight ? AppColors.light : AppColors.dark;

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: colors.background,
    textTheme: AppText.textTheme.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    ),
    dividerColor: scheme.outline,
    extensions: [colors],
    appBarTheme: AppBarTheme(
      backgroundColor: colors.background,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surface,
      indicatorColor: scheme.primaryContainer,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: scheme.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.lg),
        side: BorderSide(color: scheme.outline),
      ),
    ),
  );
}
