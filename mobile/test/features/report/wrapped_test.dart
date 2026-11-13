import 'dart:math';

import 'package:direkapin/core/router/router.dart';
import 'package:direkapin/features/activity/data/activity_models.dart';
import 'package:direkapin/features/dashboard/data/dashboard_models.dart';
import 'package:direkapin/features/report/presentation/wrapped_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../helpers/fake_server.dart';
import 'report_test.dart' show reportJson, server;

Activity _activity(String id, int photos, {String date = '2026-11-04'}) =>
    Activity.fromJson({
      'id': id,
      'title': 'Kegiatan $id',
      'date': date,
      'isImportant': false,
      'attachments': [
        for (var i = 0; i < photos; i++)
          {
            'id': '$id-$i',
            'thumbUrl': '/x',
            'isArchived': false,
            'width': 1,
            'height': 1,
            'sizeBytes': 1,
            'createdAt': '2026-11-04T02:30:00.000Z',
          },
      ],
    });

void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));

  test(
    'busiestDay: pengeluaran terbesar, seri ambil paling awal, kosong null',
    () {
      SeriesPoint p(String label, int expense) =>
          SeriesPoint(label: label, income: 0, expense: expense);
      expect(busiestDay([p('a', 0), p('b', 0)]), isNull);
      expect(busiestDay([p('a', 5), p('b', 9), p('c', 9)])?.label, 'b');
    },
  );

  test('pickPhotos: maks. 4 foto acak dari semua kegiatan', () {
    expect(pickPhotos([_activity('a', 0)], Random(1)), isEmpty);
    final picked = pickPhotos([
      _activity('a', 1),
      _activity('b', 3),
      _activity('c', 2),
    ], Random(1));
    expect(picked, hasLength(4));
    expect(picked.map((p) => p.id).toSet(), hasLength(4));
    expect(
      pickPhotos([_activity('a', 2)], Random(1)).map((p) => p.id).toSet(),
      {'a-0', 'a-1'},
    );
  });

  Future<void> swipe(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('wrappedCards')));
    await tester.pumpAndSettle();
  }

  testWidgets('Laporan Bulanan membuka rekap, 6 kartu, Selesai menutup', (
    tester,
  ) async {
    await pumpRoutedApp(
      tester,
      server(
        extra: {
          '/reports/monthly': reportJson(
            income: 100000,
            expense: 30000,
            comparison: {'previousExpense': 40000, 'changePct': -25},
            series: [
              {'label': '2026-11-03', 'income': 0, 'expense': 10000},
              {'label': '2026-11-07', 'income': 0, 'expense': 20000},
            ],
          ),
          '/activities': {
            'items': [_activity('k1', 0).toJson()],
          },
        },
      ),
      routeName: Routes.reports,
    );

    await tester.ensureVisible(find.text('Lihat rekap November 2026'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lihat rekap November 2026'));
    await tester.pumpAndSettle();

    expect(find.text('Rekap November 2026'), findsOneWidget);
    expect(find.text('30rb'), findsOneWidget);
    expect(find.text('Rp30.000'), findsOneWidget);
    expect(find.text('Turun 25% dari bulan lalu'), findsOneWidget);

    await swipe(tester);
    expect(find.text('Makan'), findsOneWidget);
    expect(find.text('100% dari semua pengeluaran'), findsOneWidget);

    await swipe(tester);
    expect(find.text('Sabtu, 7 November 2026'), findsOneWidget);
    expect(find.text('Keluar Rp20.000'), findsOneWidget);

    await swipe(tester);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('kegiatan, belum ada yang berfoto.'), findsOneWidget);

    await swipe(tester);
    expect(find.text('+70rb'), findsOneWidget);
    expect(find.textContaining('Masih surplus'), findsOneWidget);

    // Kartu 6: ringkasan 5 kartu mini; tap tidak lewat ke kartu 1.
    await swipe(tester);
    expect(find.text('6 / 6'), findsOneWidget);
    expect(find.text('Makan'), findsOneWidget);
    expect(find.text('0 foto'), findsOneWidget);
    await tester.tap(find.text('Selesai'));
    await tester.pumpAndSettle();
    expect(find.text('Lihat rekap November 2026'), findsOneWidget);
  });

  testWidgets('kartu mini membuka kartu aslinya', (tester) async {
    await pumpRoutedApp(
      tester,
      FakeServer({
        '/reports/monthly': reportJson(expense: 30000),
        '/activities': {'items': <Object>[]},
      }),
      routeName: Routes.wrapped,
      extra: '2026-11',
    );
    for (var i = 0; i < 5; i++) {
      await swipe(tester);
    }
    await tester.tap(find.text('Terboros'));
    await tester.pumpAndSettle();
    expect(find.text('2 / 6'), findsOneWidget);
    expect(find.text('Kategori terboros'), findsOneWidget);
  });

  testWidgets('bulan kosong: kalimat pengganti, bukan layar kosong', (
    tester,
  ) async {
    await pumpRoutedApp(
      tester,
      FakeServer({
        '/reports/monthly': reportJson(income: 0, expense: 0, count: 0),
        '/activities': {'items': <Object>[]},
      }),
      routeName: Routes.wrapped,
      extra: '2026-11',
    );
    expect(find.text('Belum ada pengeluaran. Hemat banget!'), findsOneWidget);
    await swipe(tester);
    expect(
      find.text('Belum ada pengeluaran, jadi belum ada juaranya.'),
      findsOneWidget,
    );
    await swipe(tester);
    expect(find.text('Nggak ada hari yang boros bulan ini.'), findsOneWidget);
  });

  testWidgets('gagal dimuat: bisa dicoba lagi', (tester) async {
    await pumpRoutedApp(
      tester,
      FakeServer({
        '/reports/monthly': 500,
        '/activities': {'items': <Object>[]},
      }),
      routeName: Routes.wrapped,
      extra: '2026-11',
    );
    expect(find.text('Coba lagi'), findsOneWidget);
  });
}
