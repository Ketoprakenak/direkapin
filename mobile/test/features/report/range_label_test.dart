import 'package:direkapin/features/report/presentation/report_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('range axis labels are never closer than step', () {
    for (final days in [8, 10, 15, 17, 21, 366]) {
      final last = days - 1;
      final step = (last / 5).ceil();
      final shown = [
        for (var i = 0; i <= last; i++)
          if (showRangeLabel(i, last)) i,
      ];
      expect(shown.first, 0);
      expect(shown.last, last);
      for (var i = 1; i < shown.length; i++) {
        expect(
          shown[i] - shown[i - 1],
          greaterThanOrEqualTo(step),
          reason: '$days days',
        );
      }
    }
  });
}
