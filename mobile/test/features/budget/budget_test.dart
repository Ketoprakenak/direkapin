import 'package:direkapin/core/router/router.dart';
import 'package:direkapin/core/widgets/frame.dart';
import 'package:direkapin/features/budget/data/budget_models.dart';
import 'package:direkapin/features/budget/providers/budget_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../helpers/fake_server.dart';

Map<String, Object?> budgetJson({
  String id = 'b1',
  String name = 'Makan & Transport',
  int limitAmount = 100000,
  int spent = 0,
  List<String> categoryIds = const ['c1', 'c2'],
}) => {
  'id': id,
  'name': name,
  'limitAmount': limitAmount,
  'startMonth': '2026-11',
  'endMonth': null,
  'categories': [
    for (final id in categoryIds)
      {
        'id': id,
        'name': id == 'c1' ? 'Makan' : 'Transport',
        'icon': 'x',
        'color': '#F97316',
      },
  ],
  'spent': spent,
};

void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));

  final cash = walletJson('w1', 'Cash', balance: 75000);
  FakeServer budgetServer(List<Map<String, Object?>> budgets) => FakeServer({
    '/dashboard': dashboardJson(),
    '/wallets': {
      'items': [cash],
      'totalBalance': 75000,
    },
    '/categories': {
      'items': [
        categoryJson('c1', 'Makan'),
        categoryJson('c2', 'Transport'),
        categoryJson('c3', 'Biaya Admin'),
      ],
    },
    '/budgets': {'items': budgets},
  });

  group('budgetAlerts', () {
    Budget budget(int spent) => Budget.fromJson(budgetJson(spent: spent));

    test('hanya muncul saat melewati 80% atau 100%', () {
      // 75rb → 85rb: lewat 80%.
      expect(budgetAlerts([budget(85000)], 'c1', 10000), [
        'Budget Makan & Transport sudah 85%: sisa Rp15.000',
      ]);
      // 90rb → 120rb: lewat 100%.
      expect(budgetAlerts([budget(120000)], 'c2', 30000), [
        'Budget Makan & Transport terlewati: Rp120.000 dari Rp100.000',
      ]);
      // Sudah kuning sebelumnya, tetap kuning: tidak diulang.
      expect(budgetAlerts([budget(90000)], 'c1', 5000), isEmpty);
      // Kategori di luar budget.
      expect(budgetAlerts([budget(99000)], 'c9', 99000), isEmpty);
    });
  });

  group('Layar Budget', () {
    testWidgets('kartu: sisa, persen, ikon peringatan sesuai level', (
      tester,
    ) async {
      final server = budgetServer([
        budgetJson(spent: 85000),
        budgetJson(id: 'b2', name: 'Jajan', spent: 130000),
        budgetJson(id: 'b3', name: 'Bensin', spent: 10000),
      ]);
      await pumpRoutedApp(
        tester,
        server,
        routeName: Routes.budgets,
        extra: '2026-11',
      );

      expect(find.byType(FrameCard), findsNWidgets(3));
      expect(find.text('Sisa budget bulan ini: Rp15.000'), findsOneWidget);
      expect(find.text('85%'), findsOneWidget);
      expect(find.text('Lewat Rp30.000'), findsOneWidget);
      expect(find.text('130%'), findsOneWidget);
      expect(find.text('Sisa budget bulan ini: Rp90.000'), findsOneWidget);
      // Kuning untuk 85%, merah untuk 130%, tanpa ikon untuk 10%.
      expect(find.byIcon(Icons.warning_rounded), findsNWidgets(2));
      // Bar selesai beranimasi di nilai sebenarnya; sisa bar punya warna sendiri.
      final bars = tester
          .widgetList<LinearProgressIndicator>(
            find.byType(LinearProgressIndicator),
          )
          .toList();
      expect(bars.map((bar) => bar.value), [0.85, 1.0, 0.1]);
      expect(bars.first.backgroundColor, isNot(bars.first.color));
      expect(server.reads.last.queryParameters, {'month': '2026-11'});
    });

    testWidgets('kosong: ajakan menambah budget', (tester) async {
      await pumpRoutedApp(
        tester,
        budgetServer([]),
        routeName: Routes.budgets,
        extra: '2026-11',
      );
      expect(
        find.text(
          'Belum ada budget. Tambah budget untuk kategori yang mau dijaga.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('tambah: multi kategori, Biaya Admin tidak bisa dipilih', (
      tester,
    ) async {
      final server = budgetServer([]);
      await pumpRoutedApp(
        tester,
        server,
        routeName: Routes.budgets,
        extra: '2026-11',
      );
      await tester.tap(find.byTooltip('Tambah budget'));
      await tester.pumpAndSettle();
      expect(find.text('Biaya Admin'), findsNothing);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nama budget'),
        'Makan & Transport',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Batas per bulan'),
        '2500000',
      );
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();
      expect(find.text('Pilih minimal satu kategori'), findsOneWidget);
      expect(server.writes, isEmpty);

      await tester.tap(find.text('Makan'));
      await tester.tap(find.text('Transport'));
      await tester.pump();
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(server.writes.single.method, 'POST');
      expect(server.writes.single.path, '/budgets');
      expect(server.writes.single.body, {
        'name': 'Makan & Transport',
        'limitAmount': 2500000,
        'categoryIds': ['c1', 'c2'],
        'month': '2026-11',
      });
    });
  });

  testWidgets('simpan pengeluaran yang melewati 80%: snackbar + notifikasi', (
    tester,
  ) async {
    final reminders = FakeReminderService();
    final server = budgetServer([budgetJson(spent: 85000)]);
    await pumpRoutedApp(
      tester,
      server,
      routeName: Routes.transactionForm,
      reminders: reminders,
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nominal'),
      '10000',
    );
    await tester.tap(find.text('Makan'));
    await tester.pump();
    await tester.ensureVisible(find.text('Simpan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    const message = 'Budget Makan & Transport sudah 85%: sisa Rp15.000';
    expect(reminders.budgetAlerts, [message]);
    expect(find.textContaining(message), findsOneWidget);
  });
}
