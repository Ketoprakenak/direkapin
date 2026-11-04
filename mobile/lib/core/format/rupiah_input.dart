import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

const maxAmount = 999999999;

final _thousands = NumberFormat('#,##0', 'id_ID');

/// Nilai dari teks input, atau null jika kosong. `−` dan `-` sama-sama berarti negatif.
int? parseRupiah(String text) {
  final digits = text.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return null;
  final value = int.parse(digits);
  return text.trimLeft().startsWith(RegExp('[-−]')) ? -value : value;
}

/// Pemisah ribuan otomatis saat mengetik.
class RupiahInputFormatter extends TextInputFormatter {
  const RupiahInputFormatter({this.allowNegative = false});

  final bool allowNegative;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final negative = allowNegative && newValue.text.trimLeft().startsWith('-');
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return negative ? _at('-') : _at('');
    }
    if (digits.length > 9) return oldValue;
    final text = '${negative ? '-' : ''}${_thousands.format(int.parse(digits))}';
    return _at(text);
  }

  TextEditingValue _at(String text) => TextEditingValue(
    text: text,
    selection: TextSelection.collapsed(offset: text.length),
  );
}
