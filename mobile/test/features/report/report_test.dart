import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:direkapin/core/router/router.dart';
import 'package:direkapin/features/report/data/report_models.dart';
import 'package:direkapin/features/report/presentation/report_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../helpers/fake_server.dart';

const _category = {
  'id': 'c1',
  'name': 'Makan',
  'icon': 'restaurant_rounded',
  'color': '#F97316',
};

Map<String, Object?> reportJson({
  int income = 100000,
  int expense = 25000,
  int count = 2,
  List<Map<String, Object?>> series = const [],
  Map<String, Object?>? comparison,
}) => {
  'period': {'type': 'monthly', 'start': '2026-11-01', 'end': '2026-11-30'},
  'totals': {
    'income': income,
    'expense': expense,
    'net': income - expense,
    'transactionCount': count,
  },
  'series': series,
  'byCategory': expense == 0
      ? <Object>[]
      : [
          {'category': _category, 'amount': expense, 'share': 1},
        ],
  'comparison': comparison,
};

Map<String, Object?> transactionJson(String note) => {
  'id': 't-$note',
  'type': 'EXPENSE',
  'amount': 25000,
  'occurredAt': '2026-11-04T02:30:00.000Z',
  'note': note,
  'wallet': {'id': 'w1', 'name': 'Cash', 'icon': 'x', 'color': '#14B8A6'},
  'category': _category,
  'attachments': <Object>[],
};

/// Mencatat query param setiap GET supaya test bisa memeriksa periode dan dompet.
class RecordingServer extends FakeServer {
  RecordingServer(super.responses);

  final queries = <String, Map<String, dynamic>>{};

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    queries[options.path] = options.queryParameters;
    return super.fetch(options, requestStream, cancelFuture);
  }
}

RecordingServer server({Map<String, Object> extra = const {}}) =>
    RecordingServer({
      '/wallets': {
        'items': [
          walletJson('w1', 'Cash'),
          walletJson('w2', 'Lama', isArchived: true),
        ],
        'totalBalance': 0,
      },
      '/reports/monthly': reportJson(
        comparison: {'previousExpense': 20000, 'changePct': 25},
        series: [
          for (var day = 1; day <= 30; day++)
            {
              'label': '2026-11-${day.toString().padLeft(2, '0')}',
              'income': 0,
              'expense': day * 1000,
            },
        ],
      ),
      '/reports/weekly': reportJson(
        series: [
          for (var day = 2; day <= 8; day++)
            {'label': '2026-11-0$day', 'income': 0, 'expense': day * 1000},
        ],
      ),
      '/reports/daily': reportJson(),
      '/transactions': {
        'items': [transactionJson('nasi goreng')],
        'nextCursor': null,
      },
      ...extra,
    });

void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(text).first);
    await tester.pumpAndSettle();
  }

  test('mondayOf: Senin tetap, Minggu mundur 6 hari, lintas bulan', () {
    expect(mondayOf(DateTime(2026, 11, 2)), DateTime(2026, 11, 2));
    expect(mondayOf(DateTime(2026, 11, 8)), DateTime(2026, 11, 2));
    expect(mondayOf(DateTime(2026, 11, 1)), DateTime(2026, 10, 26));
  });

  test('Report terbaca dari JSON: share integer dan comparison null', () {
    final report = Report.fromJson(
      reportJson(comparison: {'previousExpense': 0, 'changePct': null}),
    );
    expect(report.byCategory.single.share, 1.0);
    expect(report.comparison?.changePct, isNull);
    expect(Report.fromJson(reportJson()).comparison, isNull);
  });

  group('Layar Laporan', () {
    testWidgets('bulanan: total, perbandingan, grafik, donut, kategori', (
      tester,
    ) async {
      await pumpRoutedApp(tester, server(), routeName: Routes.reports);

      expect(find.text('+Rp100.000'), findsOneWidget);
      expect(find.text('−Rp25.000'), findsWidgets);
      expect(find.text('+Rp75.000'), findsOneWidget);
      expect(
        find.text('Pengeluaran naik 25% dari bulan lalu (Rp20.000).'),
        findsOneWidget,
      );
      expect(find.byType(BarChart), findsOneWidget);
      expect(find.byType(PieChart), findsOneWidget);
      expect(find.text('Makan'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('bulan lalu kosong: teks tanpa persen', (tester) async {
      await pumpRoutedApp(
        tester,
        server(
          extra: {
            '/reports/monthly': reportJson(
              comparison: {'previousExpense': 0, 'changePct': null},
            ),
          },
        ),
        routeName: Routes.reports,
      );
      expect(find.text('Bulan lalu belum ada pengeluaran.'), findsOneWidget);
    });

    testWidgets('mingguan mengirim hari Senin, grafik tanpa donut', (
      tester,
    ) async {
      final fake = server();
      await pumpRoutedApp(tester, fake, routeName: Routes.reports);

      await tapText(tester, 'Mingguan');

      final start = DateTime.parse(
        fake.queries['/reports/weekly']!['start'] as String,
      );
      expect(start.weekday, DateTime.monday);
      expect(find.byType(BarChart), findsOneWidget);
      expect(find.byType(PieChart), findsNothing);
    });

    testWidgets('harian menampilkan daftar transaksi hari itu', (tester) async {
      final fake = server();
      await pumpRoutedApp(tester, fake, routeName: Routes.reports);

      await tapText(tester, 'Harian');

      expect(find.byType(BarChart), findsNothing);
      await tester.ensureVisible(find.text('nasi goreng'));
      expect(find.text('nasi goreng'), findsOneWidget);
      // Daftar transaksi mengikuti `period` dari respons laporan.
      expect(fake.queries['/transactions']!['from'], '2026-11-01');
      expect(fake.queries['/transactions']!['to'], '2026-11-01');
    });

    testWidgets('geser periode mengubah bulan yang diminta', (tester) async {
      final fake = server();
      await pumpRoutedApp(tester, fake, routeName: Routes.reports);
      final now = DateTime.now();
      String key(DateTime date) =>
          '${date.year}-${date.month.toString().padLeft(2, '0')}';
      expect(fake.queries['/reports/monthly']!['month'], key(now));

      await tester.tap(find.byTooltip('Periode sebelumnya'));
      await tester.pumpAndSettle();
      expect(
        fake.queries['/reports/monthly']!['month'],
        key(DateTime(now.year, now.month - 1)),
      );

      await tester.tap(find.byTooltip('Periode berikutnya'));
      await tester.tap(find.byTooltip('Periode berikutnya'));
      await tester.pumpAndSettle();
      expect(
        fake.queries['/reports/monthly']!['month'],
        key(DateTime(now.year, now.month + 1)),
      );
    });

    testWidgets('filter dompet: arsip ada di pilihan, query ikut berubah', (
      tester,
    ) async {
      final fake = server();
      await pumpRoutedApp(tester, fake, routeName: Routes.reports);
      expect(fake.queries['/reports/monthly']!.containsKey('wallet'), isFalse);

      await tester.tap(find.text('Semua dompet'));
      await tester.pumpAndSettle();
      expect(find.text('Lama (arsip)'), findsOneWidget);
      await tester.tap(find.text('Lama (arsip)'));
      await tester.pumpAndSettle();

      expect(fake.queries['/reports/monthly']!['wallet'], 'w2');
    });

    testWidgets('periode kosong menampilkan state kosong tanpa grafik', (
      tester,
    ) async {
      await pumpRoutedApp(
        tester,
        server(
          extra: {
            '/reports/monthly': reportJson(income: 0, expense: 0, count: 0),
          },
        ),
        routeName: Routes.reports,
      );
      expect(find.text('Belum ada transaksi di periode ini.'), findsOneWidget);
      expect(find.byType(BarChart), findsNothing);
    });

    testWidgets('error menampilkan pesan dan bisa dicoba lagi', (tester) async {
      final fake = server(extra: {'/reports/monthly': 500});
      await pumpRoutedApp(tester, fake, routeName: Routes.reports);
      expect(find.text('Terjadi kesalahan di server'), findsOneWidget);

      fake.responses['/reports/monthly'] = reportJson();
      await tapText(tester, 'Coba lagi');
      expect(find.text('+Rp100.000'), findsOneWidget);
    });

    testWidgets('tap kategori membuka transaksi kategori di periode itu', (
      tester,
    ) async {
      final fake = server();
      await pumpRoutedApp(tester, fake, routeName: Routes.reports);

      await tapText(tester, 'Makan');

      expect(find.widgetWithText(AppBar, 'Makan'), findsOneWidget);
      expect(find.text('nasi goreng'), findsOneWidget);
      expect(fake.queries['/transactions'], {
        'limit': 100,
        'from': '2026-11-01',
        'to': '2026-11-30',
        'category': 'c1',
      });
    });
  });
}
