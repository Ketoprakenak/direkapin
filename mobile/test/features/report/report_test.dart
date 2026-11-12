import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:direkapin/core/format/dates.dart';
import 'package:direkapin/core/router/router.dart';
import 'package:direkapin/core/widgets/frame.dart';
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
      '/reports/range': reportJson(
        series: [
          for (var day = 1; day <= 10; day++)
            {
              'label': '2026-11-${day.toString().padLeft(2, '0')}',
              'income': 0,
              'expense': day * 1000,
            },
        ],
      ),
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
      expect(find.byType(LineChart), findsOneWidget);
      expect(find.byType(PieChart), findsOneWidget);
      // Bulanan: kategori terbesar langsung tampil di kartu samping donut.
      expect(find.text('Makan'), findsOneWidget);
      expect(find.text('100% pengeluaran'), findsOneWidget);
    });

    testWidgets('toggle Top 3: donut 3 kategori terbesar, label berganti', (
      tester,
    ) async {
      await pumpRoutedApp(tester, server(), routeName: Routes.reports);
      expect(find.text('Semua'), findsNothing);

      await tapText(tester, 'Top 3');
      expect(find.byType(PieChart), findsOneWidget);
      expect(find.text('Semua'), findsOneWidget);
      expect(find.text('Top 3'), findsNothing);
      expect(find.text('Makan'), findsOneWidget);

      await tapText(tester, 'Semua');
      expect(find.text('Top 3'), findsOneWidget);
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

    testWidgets('mingguan mengirim hari Senin, tanpa grafik batang dan donut', (
      tester,
    ) async {
      final fake = server();
      await pumpRoutedApp(tester, fake, routeName: Routes.reports);

      await tapText(tester, 'Mingguan');

      final start = DateTime.parse(
        fake.queries['/reports/weekly']!['start'] as String,
      );
      expect(start.weekday, DateTime.monday);
      expect(find.byType(LineChart), findsNothing);
      expect(find.byType(PieChart), findsNothing);
    });

    testWidgets('tab laporan Mingguan, Bulanan, Custom tanpa Harian', (
      tester,
    ) async {
      await pumpRoutedApp(tester, server(), routeName: Routes.reports);

      final xs = [
        for (final tab in ['Mingguan', 'Bulanan', 'Custom'])
          tester.getCenter(find.text(tab)).dx,
      ];
      expect(xs[0] < xs[1] && xs[1] < xs[2], isTrue);
      expect(find.text('Harian'), findsNothing);
    });

    testWidgets('Custom memanggil /reports/range dengan rentang bawaan', (
      tester,
    ) async {
      final fake = server();
      await pumpRoutedApp(tester, fake, routeName: Routes.reports);

      await tapText(tester, 'Custom');

      final now = DateTime.now();
      expect(fake.reads.last.path, '/reports/range');
      expect(fake.queries['/reports/range'], {
        'from': dateKey(DateTime(now.year, now.month)),
        'to': dateKey(now),
      });
    });

    /// Mengisi rentang tetap 3-17 Maret 2025 lewat mode ketik pemilih, supaya
    /// selalu berbeda dari rentang bawaan, apa pun tanggal hari ini.
    Future<({String from, String to})> pickRange(WidgetTester tester) async {
      final now = DateTime.now();
      final start = DateTime(2025, 3, 3);
      final end = DateTime(2025, 3, 17);
      await tester.tap(find.byTooltip('Pilih rentang'));
      await tester.pumpAndSettle();
      final dialog = find.byType(DateRangePickerDialog);
      expect(dialog, findsOneWidget);
      expect(
        tester.widget<DateRangePickerDialog>(dialog).lastDate,
        DateTime(now.year, now.month, now.day),
      );
      final l10n = MaterialLocalizations.of(tester.element(dialog));
      await tester.tap(find.byTooltip(l10n.inputDateModeButtonLabel));
      await tester.pumpAndSettle();
      final fields = find.descendant(
        of: find.byType(DateRangePickerDialog),
        matching: find.byType(TextField),
      );
      await tester.enterText(fields.at(0), l10n.formatCompactDate(start));
      await tester.enterText(fields.at(1), l10n.formatCompactDate(end));
      await tester.tap(find.text(l10n.okButtonLabel));
      await tester.pumpAndSettle();
      return (from: dateKey(start), to: dateKey(end));
    }

    testWidgets('pilih rentang lewat pemilih', (tester) async {
      final fake = server();
      await pumpRoutedApp(tester, fake, routeName: Routes.reports);
      await tapText(tester, 'Custom');

      final picked = await pickRange(tester);

      expect(fake.queries['/reports/range'], {
        'from': picked.from,
        'to': picked.to,
      });
    });

    testWidgets('rentang tetap setelah pindah tab', (tester) async {
      final fake = server();
      await pumpRoutedApp(tester, fake, routeName: Routes.reports);
      await tapText(tester, 'Custom');
      final picked = await pickRange(tester);

      await tapText(tester, 'Bulanan');
      fake.queries.remove('/reports/range');
      await tapText(tester, 'Custom');

      expect(fake.queries['/reports/range'], {
        'from': picked.from,
        'to': picked.to,
      });
    });

    testWidgets('Custom tanpa Budget, dengan grafik dan donut', (tester) async {
      await pumpRoutedApp(tester, server(), routeName: Routes.reports);
      await tapText(tester, 'Custom');

      expect(find.text('Pengeluaran per hari'), findsOneWidget);
      expect(find.byType(LineChart), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byType(PieChart),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Pengeluaran per kategori'), findsOneWidget);
      expect(find.text('Budget'), findsNothing);
      expect(find.text('Kelola budget'), findsNothing);
      expect(find.text('Atur budget'), findsNothing);
    });

    testWidgets('tab, toggle, dan label rentang setinggi target sentuh', (
      tester,
    ) async {
      await pumpRoutedApp(tester, server(), routeName: Routes.reports);

      for (final tab in ['Mingguan', 'Bulanan', 'Custom']) {
        final target = find.ancestor(
          of: find.text(tab),
          matching: find.byType(InkWell),
        );
        expect(
          tester.getSize(target).height,
          greaterThanOrEqualTo(kMinInteractiveDimension),
          reason: tab,
        );
      }
      await tester.ensureVisible(find.text('Top 3'));
      await tester.pumpAndSettle();
      expect(
        tester
            .getSize(
              find
                  .ancestor(
                    of: find.text('Top 3'),
                    matching: find.byType(GestureDetector),
                  )
                  .first,
            )
            .height,
        greaterThanOrEqualTo(kMinInteractiveDimension),
      );

      await tester.scrollUntilVisible(
        find.text('Custom'),
        -200,
        scrollable: find.byType(Scrollable).first,
      );
      await tapText(tester, 'Custom');
      expect(
        tester.getSize(find.byTooltip('Pilih rentang')).height,
        greaterThanOrEqualTo(kMinInteractiveDimension),
      );
    });

    testWidgets('kotak ringkasan berframe', (tester) async {
      await pumpRoutedApp(tester, server(), routeName: Routes.reports);

      for (final label in ['Pemasukan', 'Pengeluaran', 'Selisih']) {
        expect(
          find.ancestor(of: find.text(label), matching: find.byType(FrameCard)),
          findsOneWidget,
          reason: label,
        );
      }
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
      expect(find.byType(LineChart), findsNothing);
    });

    testWidgets('error menampilkan pesan dan bisa dicoba lagi', (tester) async {
      final fake = server(extra: {'/reports/monthly': 500});
      await pumpRoutedApp(tester, fake, routeName: Routes.reports);
      expect(find.text('Terjadi kesalahan di server'), findsOneWidget);

      fake.responses['/reports/monthly'] = reportJson();
      await tapText(tester, 'Coba lagi');
      expect(find.text('+Rp100.000'), findsOneWidget);
    });

    testWidgets('bulanan: bagian Budget, Kelola budget membuka layar Budget', (
      tester,
    ) async {
      final fake = server(
        extra: {
          '/budgets': {
            'items': [
              {
                'id': 'b1',
                'name': 'Makan & Transport',
                'limitAmount': 100000,
                'startMonth': '2026-11',
                'endMonth': null,
                'categories': [
                  {
                    'id': 'c1',
                    'name': 'Makan',
                    'icon': 'x',
                    'color': '#F97316',
                  },
                ],
                'spent': 85000,
              },
            ],
          },
        },
      );
      await pumpRoutedApp(tester, fake, routeName: Routes.reports);

      await tester.scrollUntilVisible(
        find.text('Kelola budget'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Makan & Transport'), findsOneWidget);
      expect(find.text('85%'), findsOneWidget);
      expect(fake.queries['/budgets'], {'month': '2026-11'});

      await tapText(tester, 'Kelola budget');
      expect(find.widgetWithText(AppBar, 'Budget'), findsOneWidget);
    });

    testWidgets('kartu donut: tombol ‹ › pindah kategori, berputar', (
      tester,
    ) async {
      Map<String, Object?> share(String id, String name, int amount) => {
        'category': {'id': id, 'name': name, 'icon': 'x', 'color': '#F97316'},
        'amount': amount,
        'share': amount / 25000,
      };
      await pumpRoutedApp(
        tester,
        server(
          extra: {
            '/reports/monthly': {
              ...reportJson(),
              'byCategory': [
                share('c1', 'Makan', 24000),
                share('c2', 'Parkir', 1000),
              ],
            },
          },
        ),
        routeName: Routes.reports,
      );

      await tester.ensureVisible(find.text('1/2'));
      await tester.pumpAndSettle();
      expect(find.text('Makan'), findsOneWidget);
      await tester.tap(find.byTooltip('Kategori berikutnya'));
      await tester.pumpAndSettle();
      expect(find.text('Parkir'), findsOneWidget);
      expect(find.text('2/2'), findsOneWidget);
      await tester.tap(find.byTooltip('Kategori berikutnya'));
      await tester.pumpAndSettle();
      expect(find.text('Makan'), findsOneWidget);
    });

    testWidgets('tap donut: nominal + persen, Lihat detail membuka transaksi', (
      tester,
    ) async {
      final fake = server();
      await pumpRoutedApp(tester, fake, routeName: Routes.reports);

      final donut = find.byType(PieChart);
      await tester.ensureVisible(donut);
      await tester.pumpAndSettle();
      // Cincin donut: lubang tengah 40 px + setengah tebal cincin 10 px.
      await tester.tapAt(tester.getCenter(donut) + const Offset(50, 0));
      await tester.pumpAndSettle();
      expect(find.text('Makan'), findsOneWidget);
      expect(find.text('100% pengeluaran'), findsOneWidget);

      await tapText(tester, 'Lihat detail');

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
