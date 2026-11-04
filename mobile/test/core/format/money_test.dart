import 'package:direkapin/core/format/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatRupiah', () {
    test('titik ribuan tanpa desimal dan spasi', () {
      expect(formatRupiah(25000), 'Rp25.000');
      expect(formatRupiah(999999999), 'Rp999.999.999');
      expect(formatRupiah(0), 'Rp0');
    });

    test('negatif memakai tanda minus', () {
      expect(formatRupiah(-25000), '−Rp25.000');
    });

    test('showPlus hanya untuk nilai positif', () {
      expect(formatRupiah(25000, showPlus: true), '+Rp25.000');
      expect(formatRupiah(-25000, showPlus: true), '−Rp25.000');
    });
  });

  group('formatCompact', () {
    test('ribuan dan jutaan', () {
      expect(formatCompact(25000), '25rb');
      expect(formatCompact(1200000), '1,2jt');
      expect(formatCompact(1500), '1,5rb');
      expect(formatCompact(1000000), '1jt');
    });

    test('di bawah seribu tetap utuh', () {
      expect(formatCompact(500), '500');
      expect(formatCompact(0), '0');
    });

    test('dipotong, bukan dibulatkan, dan negatif tetap bertanda', () {
      expect(formatCompact(999999), '999,9rb');
      expect(formatCompact(-1250000), '−1,2jt');
    });
  });
}
