import 'package:direkapin/core/format/rupiah_input.dart';
import 'package:flutter_test/flutter_test.dart';

String type(String text, {String old = '', bool allowNegative = false}) =>
    RupiahInputFormatter(allowNegative: allowNegative)
        .formatEditUpdate(
          TextEditingValue(text: old),
          TextEditingValue(text: text),
        )
        .text;

void main() {
  test('pemisah ribuan otomatis, karakter lain dibuang', () {
    expect(type('25000'), '25.000');
    expect(type('1.2345'), '12.345');
    expect(type('12a3'), '123');
    expect(type(''), '');
  });

  test('di atas 9 digit ditolak, nilai lama dipertahankan', () {
    expect(type('1000000000', old: '100.000.000'), '100.000.000');
    expect(type('999999999'), '999.999.999');
  });

  test('negatif hanya jika diizinkan', () {
    expect(type('-5000'), '5.000');
    expect(type('-5000', allowNegative: true), '-5.000');
    expect(type('-', allowNegative: true), '-');
  });

  test('parseRupiah', () {
    expect(parseRupiah('25.000'), 25000);
    expect(parseRupiah('-25.000'), -25000);
    expect(parseRupiah(''), isNull);
    expect(parseRupiah('-'), isNull);
    expect(parseRupiah('999.999.999'), maxAmount);
  });
}
