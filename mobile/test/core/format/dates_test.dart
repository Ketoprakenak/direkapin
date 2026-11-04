import 'package:direkapin/core/format/dates.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));

  final date = DateTime(2026, 11, 4, 21);

  test('format tanggal dan jam sesuai DESIGN.md', () {
    expect(formatLongDate(date), 'Rabu, 4 November 2026');
    expect(formatShortDate(date), '4 Nov');
    expect(formatMonth(date), 'November 2026');
    expect(formatTime(date), '21.00');
  });
}
