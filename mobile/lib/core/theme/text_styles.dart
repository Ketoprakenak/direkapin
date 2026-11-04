import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Token tipografi dari docs/DESIGN.md, dipetakan ke slot `TextTheme`:
/// `displayAmount` = `displayMedium`, `amount` = `titleSmall`.
abstract final class AppText {
  static TextStyle _style(
    double size,
    double lineHeight,
    FontWeight weight, {
    bool tabular = false,
  }) => GoogleFonts.plusJakartaSans(
    fontSize: size,
    height: lineHeight / size,
    fontWeight: weight,
    fontFeatures: tabular ? const [FontFeature.tabularFigures()] : null,
  );

  static TextTheme get textTheme => TextTheme(
    displayMedium: _style(32, 40, FontWeight.w700, tabular: true),
    titleSmall: _style(16, 24, FontWeight.w600, tabular: true),
    titleLarge: _style(22, 28, FontWeight.w700),
    titleMedium: _style(17, 24, FontWeight.w600),
    bodyLarge: _style(16, 24, FontWeight.w400),
    bodyMedium: _style(14, 20, FontWeight.w400),
    labelLarge: _style(14, 20, FontWeight.w600),
    labelSmall: _style(12, 16, FontWeight.w500),
  );
}
