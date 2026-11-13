import 'package:flutter/material.dart';

/// Token warna di luar `ColorScheme`. Sumber: docs/DESIGN.md.
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.income,
    required this.expense,
    required this.activity,
    required this.important,
    required this.background,
    required this.textSecondary,
    required this.ink,
    required this.moodTints,
    required this.incomeTint,
    required this.expenseTint,
    required this.importantTint,
    required this.heatmap,
  });

  final Color income;
  final Color expense;
  final Color activity;
  final Color important;
  final Color background;
  final Color textSecondary;

  /// Aksen untuk teks/penanda di atas latar; = primary di Teal/Gelap, versi tua di pastel.
  final Color ink;

  /// Warna latar tanggal di kalender per mood (D-61); dipakai transparan.
  final Map<String, Color> moodTints;

  /// Latar pastel kotak ringkasan Pemasukan/Pengeluaran/Selisih di laporan;
  /// teks di atasnya = onSurface.
  final Color incomeTint;
  final Color expenseTint;
  final Color importantTint;

  /// Latar sel kalender mode Pengeluaran (CAL-06), 4 tingkat hemat ke boros;
  /// opak, teks di atasnya = onSurface.
  final List<Color> heatmap;

  static const light = AppColors(
    income: Color(0xFF15803D),
    expense: Color(0xFFDC2626),
    activity: Color(0xFF2563EB),
    important: Color(0xFFF59E0B),
    background: Color(0xFFFAFAF9),
    textSecondary: Color(0xFF78716C),
    ink: Color(0xFF0F766E),
    moodTints: {
      '😄': Color(0xFF22C55E),
      '🙂': Color(0xFF14B8A6),
      '😐': Color(0xFFA8A29E),
      '😕': Color(0xFFF59E0B),
      '😢': Color(0xFF3B82F6),
    },
    incomeTint: Color(0xFFCDEBD7),
    expenseTint: Color(0xFFF6D3CC),
    importantTint: Color(0xFFF7E3A8),
    heatmap: [
      Color(0xFFD5F5EE),
      Color(0xFFFCE7A8),
      Color(0xFFF9B98A),
      Color(0xFFEF8A7E),
    ],
  );

  static const dark = AppColors(
    income: Color(0xFF4ADE80),
    expense: Color(0xFFF87171),
    activity: Color(0xFF60A5FA),
    important: Color(0xFFFBBF24),
    background: Color(0xFF0C0A09),
    textSecondary: Color(0xFFA8A29E),
    ink: Color(0xFF2DD4BF),
    moodTints: {
      '😄': Color(0xFF22C55E),
      '🙂': Color(0xFF14B8A6),
      '😐': Color(0xFFA8A29E),
      '😕': Color(0xFFF59E0B),
      '😢': Color(0xFF3B82F6),
    },
    incomeTint: Color(0xFF14301F),
    expenseTint: Color(0xFF3B1A18),
    importantTint: Color(0xFF3A2E0C),
    heatmap: [
      Color(0xFF1F2B2A),
      Color(0xFF3A2A1A),
      Color(0xFF552A22),
      Color(0xFF7A2E2A),
    ],
  );

  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!;

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(AppColors? other, double t) =>
      t < 0.5 || other == null ? this : other;
}

const lightScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF0F766E),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFCCFBF1),
  onPrimaryContainer: Color(0xFF1C1917),
  secondary: Color(0xFF0F766E),
  onSecondary: Color(0xFFFFFFFF),
  error: Color(0xFFB91C1C),
  onError: Color(0xFFFFFFFF),
  surface: Color(0xFFFFFFFF),
  onSurface: Color(0xFF1C1917),
  surfaceContainerHighest: Color(0xFFF5F5F4),
  onSurfaceVariant: Color(0xFF78716C),
  outline: Color(0xFFE7E5E4),
);

const darkScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF2DD4BF),
  onPrimary: Color(0xFF042F2E),
  primaryContainer: Color(0xFF134E4A),
  onPrimaryContainer: Color(0xFFFAFAF9),
  secondary: Color(0xFF2DD4BF),
  onSecondary: Color(0xFF042F2E),
  error: Color(0xFFFCA5A5),
  onError: Color(0xFF1C1917),
  surface: Color(0xFF1C1917),
  onSurface: Color(0xFFFAFAF9),
  surfaceContainerHighest: Color(0xFF292524),
  onSurfaceVariant: Color(0xFFA8A29E),
  outline: Color(0xFF44403C),
);

/// Palet warna kategori dan dompet.
const categoryPalette = [
  Color(0xFFEF4444),
  Color(0xFFF97316),
  Color(0xFFEAB308),
  Color(0xFF22C55E),
  Color(0xFF14B8A6),
  Color(0xFF3B82F6),
  Color(0xFF8B5CF6),
  Color(0xFFEC4899),
];

/// Warna kategori/dompet dari API (`#RRGGBB`).
Color colorFromHex(String hex) =>
    Color(int.parse(hex.substring(1), radix: 16) | 0xFF000000);

String colorToHex(Color color) =>
    '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

abstract final class Spacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

abstract final class Radii {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
}

abstract final class Motion {
  static const duration = Duration(milliseconds: 200);
  static const curve = Curves.easeOutCubic;
}
