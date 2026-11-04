import 'package:intl/intl.dart';

final _thousands = NumberFormat('#,##0', 'id_ID');

/// `Rp25.000`, negatif `−Rp25.000`; dengan [showPlus] positif jadi `+Rp25.000`.
String formatRupiah(int amount, {bool showPlus = false}) {
  final sign = amount < 0 ? '−' : (showPlus ? '+' : '');
  return '${sign}Rp${_thousands.format(amount.abs())}';
}

/// Bentuk ringkas untuk grafik dan kalender: `25rb`, `1,2jt`.
/// Dipotong, bukan dibulatkan, supaya tidak pernah terlihat lebih besar.
String formatCompact(int amount) {
  final sign = amount < 0 ? '−' : '';
  final value = amount.abs();
  if (value >= 1000000) return '$sign${_short(value, 1000000)}jt';
  if (value >= 1000) return '$sign${_short(value, 1000)}rb';
  return '$sign$value';
}

String _short(int value, int unit) {
  final tenths = value * 10 ~/ unit;
  final decimal = tenths % 10;
  return decimal == 0 ? '${tenths ~/ 10}' : '${tenths ~/ 10},$decimal';
}
