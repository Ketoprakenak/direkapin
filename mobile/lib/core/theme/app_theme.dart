import 'package:flutter/material.dart';

import 'app_themes.dart';
import 'text_styles.dart';
import 'tokens.dart';

/// Layar baru masuk dari kanan sejauh fraksi lebar ini.
const _pageEnterSlide = 0.15;

/// Layar di bawahnya bergeser sedikit ke kiri saat tertutup layar baru.
const _pageUnderSlide = 0.1;

/// Layar dalam: geser dari kanan + fade; kembali = kebalikannya.
class HorizontalPageTransitionsBuilder extends PageTransitionsBuilder {
  const HorizontalPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    final curve = CurveTween(curve: Motion.curve);
    return SlideTransition(
      position: secondaryAnimation.drive(
        Tween(
          begin: Offset.zero,
          end: const Offset(-_pageUnderSlide, 0),
        ).chain(curve),
      ),
      child: FadeTransition(
        opacity: animation.drive(curve),
        child: SlideTransition(
          position: animation.drive(
            Tween(
              begin: const Offset(_pageEnterSlide, 0),
              end: Offset.zero,
            ).chain(curve),
          ),
          child: child,
        ),
      ),
    );
  }
}

ThemeData buildTheme(AppThemeData t) {
  final scheme = t.scheme;
  final colors = t.colors;
  final ink = t.ink;
  final pill = t.style.nav == NavStyle.pill;

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: colors.background,
    textTheme: AppText.textTheme.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    ),
    dividerColor: scheme.outline,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {TargetPlatform.android: HorizontalPageTransitionsBuilder()},
    ),
    extensions: [colors, t.style],
    appBarTheme: AppBarTheme(
      backgroundColor: colors.background,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    tabBarTheme: TabBarThemeData(labelColor: ink, indicatorColor: ink),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: ink,
      selectionHandleColor: ink,
      selectionColor: ink.withValues(alpha: 0.3),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: ink),
    datePickerTheme: DatePickerThemeData(
      todayForegroundColor: WidgetStatePropertyAll(ink),
      todayBorder: BorderSide(color: ink),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surface,
      indicatorColor: pill ? scheme.primaryContainer : Colors.transparent,
      indicatorShape: pill
          ? null
          : UnderlineInputBorder(borderSide: BorderSide(color: ink, width: 2)),
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.sm),
        borderSide: BorderSide(color: scheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.sm),
        borderSide: BorderSide(color: scheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Radii.sm),
        borderSide: BorderSide(color: ink, width: 2),
      ),
      floatingLabelStyle: TextStyle(color: ink),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(Spacing.xxl + Spacing.lg),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.md),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: ink),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ink,
        minimumSize: const Size.fromHeight(Spacing.xxl + Spacing.lg),
        side: BorderSide(color: scheme.outline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.md),
        ),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.xl)),
      ),
    ),
    cardTheme: CardThemeData(
      color: scheme.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(t.style.cardRadius),
        side: BorderSide(color: scheme.outline),
      ),
    ),
  );
}
