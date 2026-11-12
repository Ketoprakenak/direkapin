import 'package:flutter/material.dart';

import 'tokens.dart';

enum MarkerStyle { icon, dot, bar }

enum NavStyle { pill, line }

enum Animal { turtle, chick, whale, cat, hamster, frog, owl }

/// Bentuk dan gaya per tema (ENG-03, D-63): sudut, penanda kalender, tab aktif, maskot.
class AppStyle extends ThemeExtension<AppStyle> {
  const AppStyle({
    required this.cardRadius,
    required this.dateRadius,
    required this.marker,
    required this.nav,
    required this.animal,
    this.frameWidth = 2,
    this.frameOffset = 4,
  });

  final double cardRadius;

  /// Radius kotak tanggal 24 px di kalender; bulat = 12.
  final double dateRadius;
  final MarkerStyle marker;
  final NavStyle nav;
  final Animal animal;

  /// Garis frame dan bayangan kerasnya; sama di semua tema, warna = onSurface.
  final double frameWidth;
  final double frameOffset;

  static AppStyle of(BuildContext context) =>
      Theme.of(context).extension<AppStyle>()!;

  @override
  AppStyle copyWith() => this;

  @override
  AppStyle lerp(AppStyle? other, double t) =>
      t < 0.5 || other == null ? this : other;
}

/// Satu tema utuh: skema warna, token tambahan, dan gaya.
class AppThemeData {
  const AppThemeData({
    required this.id,
    required this.name,
    required this.brightness,
    required this.scheme,
    required this.colors,
    required this.style,
  });

  final String id;
  final String name;
  final Brightness brightness;
  final ColorScheme scheme;
  final AppColors colors;
  final AppStyle style;

  /// Warna aksen untuk teks/penanda di atas latar (versi tua primary pastel).
  Color get ink => colors.ink;
}

const _pastelMoods = {
  '😄': Color(0xFF7BC79A),
  '🙂': Color(0xFF6FC1B5),
  '😐': Color(0xFFBDB7AE),
  '😕': Color(0xFFE8B96A),
  '😢': Color(0xFF8DB0E0),
};

ColorScheme _pastelScheme({
  required Color surface,
  required Color text,
  required Color textSecondary,
  required Color line,
  required Color primary,
  required Color container,
}) => ColorScheme(
  brightness: Brightness.light,
  primary: primary,
  onPrimary: text,
  primaryContainer: container,
  onPrimaryContainer: text,
  secondary: primary,
  onSecondary: text,
  error: const Color(0xFFB91C1C),
  onError: const Color(0xFFFFFFFF),
  surface: surface,
  onSurface: text,
  surfaceContainerHighest: container,
  onSurfaceVariant: textSecondary,
  outline: line,
);

/// Nilai terang pastel dari mockup owner; masuk/keluar digelapkan seperlunya agar
/// kontras >= 4.5:1 (lihat docs/DESIGN.md).
final appThemes = <AppThemeData>[
  const AppThemeData(
    id: 'teal',
    name: 'Teal',
    brightness: Brightness.light,
    scheme: lightScheme,
    colors: AppColors.light,
    style: AppStyle(
      cardRadius: 16,
      dateRadius: 12,
      marker: MarkerStyle.icon,
      nav: NavStyle.pill,
      animal: Animal.turtle,
    ),
  ),
  AppThemeData(
    id: 'yellow',
    name: 'Kuning pastel',
    brightness: Brightness.light,
    scheme: _pastelScheme(
      surface: const Color(0xFFFFFFFF),
      text: const Color(0xFF3B3218),
      textSecondary: const Color(0xFF8A7E5C),
      line: const Color(0xFFF1E8C8),
      primary: const Color(0xFFF5DE8C),
      container: const Color(0xFFFBF3D5),
    ),
    colors: const AppColors(
      income: Color(0xFF407E57),
      expense: Color(0xFFAB5C4E),
      activity: Color(0xFF7FA6C9),
      important: Color(0xFFD9A92E),
      background: Color(0xFFFFFBEF),
      textSecondary: Color(0xFF8A7E5C),
      ink: Color(0xFF6B5410),
      incomeTint: Color(0xFFCDE8CF),
      expenseTint: Color(0xFFF6D3C8),
      importantTint: Color(0xFFF7E19A),
      moodTints: _pastelMoods,
    ),
    style: const AppStyle(
      cardRadius: 22,
      dateRadius: 8,
      marker: MarkerStyle.dot,
      nav: NavStyle.pill,
      animal: Animal.chick,
    ),
  ),
  AppThemeData(
    id: 'sky',
    name: 'Biru langit',
    brightness: Brightness.light,
    scheme: _pastelScheme(
      surface: const Color(0xFFFFFFFF),
      text: const Color(0xFF16263A),
      textSecondary: const Color(0xFF6B7F96),
      line: const Color(0xFFDCE7F3),
      primary: const Color(0xFFA7C7E7),
      container: const Color(0xFFE3EEF8),
    ),
    colors: const AppColors(
      income: Color(0xFF347E62),
      expense: Color(0xFFB05555),
      activity: Color(0xFF5B82CF),
      important: Color(0xFFE2AC45),
      background: Color(0xFFF5F9FD),
      textSecondary: Color(0xFF6B7F96),
      ink: Color(0xFF1E4A75),
      incomeTint: Color(0xFFC9E8D6),
      expenseTint: Color(0xFFF4D0CF),
      importantTint: Color(0xFFF6E3AC),
      moodTints: _pastelMoods,
    ),
    style: const AppStyle(
      cardRadius: 12,
      dateRadius: 12,
      marker: MarkerStyle.bar,
      nav: NavStyle.line,
      animal: Animal.whale,
    ),
  ),
  AppThemeData(
    id: 'lavender',
    name: 'Lavender',
    brightness: Brightness.light,
    scheme: _pastelScheme(
      surface: const Color(0xFFFFFFFF),
      text: const Color(0xFF2A2140),
      textSecondary: const Color(0xFF7C7393),
      line: const Color(0xFFE9E3F3),
      primary: const Color(0xFFC3B1E1),
      container: const Color(0xFFEEE8F7),
    ),
    colors: const AppColors(
      income: Color(0xFF3C7D66),
      expense: Color(0xFFAE5472),
      activity: Color(0xFF8776D2),
      important: Color(0xFFE2AC45),
      background: Color(0xFFFAF8FD),
      textSecondary: Color(0xFF7C7393),
      ink: Color(0xFF4B3478),
      incomeTint: Color(0xFFCAE8DA),
      expenseTint: Color(0xFFF2CEDA),
      importantTint: Color(0xFFF6E3AC),
      moodTints: _pastelMoods,
    ),
    style: const AppStyle(
      cardRadius: 20,
      dateRadius: 8,
      marker: MarkerStyle.dot,
      nav: NavStyle.pill,
      animal: Animal.cat,
    ),
  ),
  AppThemeData(
    id: 'peach',
    name: 'Peach',
    brightness: Brightness.light,
    scheme: _pastelScheme(
      surface: const Color(0xFFFFFFFF),
      text: const Color(0xFF3A221B),
      textSecondary: const Color(0xFF93766C),
      line: const Color(0xFFF4E2DB),
      primary: const Color(0xFFF7C5B5),
      container: const Color(0xFFFDECE6),
    ),
    colors: const AppColors(
      income: Color(0xFF407E57),
      expense: Color(0xFFBA503D),
      activity: Color(0xFF7FA6C9),
      important: Color(0xFFDFA13F),
      background: Color(0xFFFFF8F5),
      textSecondary: Color(0xFF93766C),
      ink: Color(0xFF7A3B28),
      incomeTint: Color(0xFFCDE9D2),
      expenseTint: Color(0xFFF8CFC2),
      importantTint: Color(0xFFF7E0A4),
      moodTints: _pastelMoods,
    ),
    style: const AppStyle(
      cardRadius: 24,
      dateRadius: 12,
      marker: MarkerStyle.icon,
      nav: NavStyle.pill,
      animal: Animal.hamster,
    ),
  ),
  AppThemeData(
    id: 'mint',
    name: 'Mint',
    brightness: Brightness.light,
    scheme: _pastelScheme(
      surface: const Color(0xFFFFFFFF),
      text: const Color(0xFF15302A),
      textSecondary: const Color(0xFF6A8A80),
      line: const Color(0xFFDCEFE7),
      primary: const Color(0xFFA8D8C8),
      container: const Color(0xFFE3F3EE),
    ),
    colors: const AppColors(
      income: Color(0xFF287F5E),
      expense: Color(0xFFB25656),
      activity: Color(0xFF5E92CF),
      important: Color(0xFFE2AC45),
      background: Color(0xFFF5FBF8),
      textSecondary: Color(0xFF6A8A80),
      ink: Color(0xFF1F5C4A),
      incomeTint: Color(0xFFC4E9D6),
      expenseTint: Color(0xFFF4D0CF),
      importantTint: Color(0xFFF6E3AC),
      moodTints: _pastelMoods,
    ),
    style: const AppStyle(
      cardRadius: 14,
      dateRadius: 6,
      marker: MarkerStyle.bar,
      nav: NavStyle.line,
      animal: Animal.frog,
    ),
  ),
  const AppThemeData(
    id: 'dark',
    name: 'Gelap',
    brightness: Brightness.dark,
    scheme: darkScheme,
    colors: AppColors.dark,
    style: AppStyle(
      cardRadius: 16,
      dateRadius: 12,
      marker: MarkerStyle.icon,
      nav: NavStyle.pill,
      animal: Animal.owl,
    ),
  ),
];

/// Id tak dikenal atau null = Teal (bawaan).
AppThemeData themeById(String? id) =>
    appThemes.firstWhere((t) => t.id == id, orElse: () => appThemes.first);
