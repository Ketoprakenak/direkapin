import 'package:direkapin/core/format/dates.dart';
import 'package:direkapin/core/router/router.dart';
import 'package:direkapin/core/theme/app_themes.dart';
import 'package:direkapin/features/calendar/presentation/widgets/calendar_cell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../helpers/fake_server.dart';

Map<String, Object> _me({
  String mode = 'AUTO',
  List<int> thresholds = const [50000, 100000, 200000],
}) => {
  'id': 'u1',
  'name': 'Desta',
  'email': 'd@x.com',
  'timezone': 'Asia/Jakarta',
  'reminderTime': '21:00',
  'hasAvatar': false,
  'heatmap': {'mode': mode, 'thresholds': thresholds},
  'createdAt': '2026-11-01T00:00:00.000Z',
};

Finder _colored(Color color) => find.byWidgetPredicate(
  (w) =>
      w is Container &&
      w.decoration is BoxDecoration &&
      (w.decoration! as BoxDecoration).color == color,
);

void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));

  test('fixedHeatLevel: batas inklusif, di atas batas 3 = tingkat 4', () {
    const limits = [10000, 20000, 30000];
    expect(fixedHeatLevel(0, limits), isNull);
    expect(fixedHeatLevel(10000, limits), 0);
    expect(fixedHeatLevel(10001, limits), 1);
    expect(fixedHeatLevel(30000, limits), 2);
    expect(fixedHeatLevel(30001, limits), 3);
  });

  testWidgets('Kalender mode Nominal tetap memakai batas user', (tester) async {
    final now = DateTime.now();
    await pumpRoutedApp(
      tester,
      FakeServer({
        '/me': _me(mode: 'FIXED', thresholds: [10000, 20000, 30000]),
        '/calendar': {
          'month': monthKey(now),
          'days': [
            {
              'date': dateKey(now),
              'income': 0,
              'expense': 25000,
              'activityCount': 0,
              'hasImportant': false,
            },
          ],
        },
        '/dashboard': dashboardJson(),
      }),
      routeName: Routes.calendar,
    );
    final heatmap = themeById('teal').colors.heatmap;
    // Satu-satunya hari = paling boros, tapi mode tetap: 25rb jatuh di tingkat 3.
    // Sel + kotak legenda.
    expect(_colored(heatmap[2]), findsNWidgets(2));
    expect(_colored(heatmap[3]), findsOneWidget);
  });

  group('Skala heatmap di Profil', () {
    Future<FakeServer> openSheet(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 3000);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);
      final server = FakeServer({'/me': _me()});
      await pumpRoutedApp(tester, server, routeName: Routes.profile);
      expect(find.text('Otomatis'), findsOneWidget);
      await tester.tap(find.text('Skala heatmap'));
      await tester.pumpAndSettle();
      return server;
    }

    testWidgets('ikon info: balon muncul, hilang saat tap di luar', (
      tester,
    ) async {
      await openSheet(tester);
      const message =
          'Warna dari 3 batas Rupiah yang kamu atur. Sama di semua bulan.';

      await tester.tap(find.bySemanticsLabel('Info Nominal tetap'));
      await tester.pumpAndSettle();
      expect(find.text(message), findsOneWidget);

      // Tetap tampil, tidak hilang sendiri.
      await tester.pump(const Duration(seconds: 10));
      expect(find.text(message), findsOneWidget);

      await tester.tap(find.text('Skala heatmap').last);
      await tester.pumpAndSettle();
      expect(find.text(message), findsNothing);
    });

    testWidgets('Nominal tetap: batas tidak naik ditolak, benar tersimpan', (
      tester,
    ) async {
      final server = await openSheet(tester);
      await tester.tap(find.text('Nominal tetap'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Batas 2'),
        '40000',
      );
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();
      expect(find.text('Batas harus naik'), findsOneWidget);
      expect(server.writes, isEmpty);

      await tester.enterText(
        find.widgetWithText(TextField, 'Batas 1'),
        '20000',
      );
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();
      expect(server.writes.single.path, '/me');
      expect(server.writes.single.body, {
        'heatmap': {
          'mode': 'FIXED',
          'thresholds': [20000, 40000, 200000],
        },
      });
      expect(find.text('Simpan'), findsNothing);
    });
  });
}
