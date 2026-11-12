import 'package:direkapin/core/router/router.dart';
import 'package:direkapin/core/widgets/frame.dart';
import 'package:direkapin/core/widgets/state_views.dart';
import 'package:direkapin/features/recurring/data/recurring_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../helpers/fake_server.dart';
import '../../helpers/recurring_fixtures.dart';

void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));

  FakeServer serverWith(List<Map<String, Object?>> rules) => FakeServer({
    '/dashboard': dashboardJson(),
    '/wallets': {
      'items': [walletJson('w1', 'Cash', balance: 75000)],
      'totalBalance': 75000,
    },
    '/categories': {
      'items': [categoryJson('c1', 'Listrik'), categoryJson('c2', 'Air')],
    },
    '/recurring': {'items': rules},
  });

  test('Recurring.fromJson membaca contoh openapi', () {
    final rule = Recurring.fromJson(recurringJson());
    expect(rule.amount, 150000);
    expect(rule.endMonth, isNull);
    expect(rule.next!.dueDate, '2026-11-05');
  });

  testWidgets('kosong: EmptyState', (tester) async {
    await pumpRoutedApp(tester, serverWith([]), routeName: Routes.recurring);
    expect(find.byType(EmptyState), findsOneWidget);
  });

  testWidgets('berisi: kategori, nominal, tanggal', (tester) async {
    await pumpRoutedApp(
      tester,
      serverWith([recurringJson()]),
      routeName: Routes.recurring,
    );
    expect(find.byType(FrameCard), findsOneWidget);
    expect(find.text('Listrik'), findsOneWidget);
    expect(find.text('−Rp150.000'), findsOneWidget);
    expect(find.textContaining('Tiap tanggal 5'), findsOneWidget);
  });

  testWidgets('tambah: validasi lalu POST body benar', (tester) async {
    final server = serverWith([]);
    await pumpRoutedApp(tester, server, routeName: Routes.recurring);
    await tester.tap(find.byTooltip('Tambah aturan'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Simpan'));
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(find.text('Nominal harus lebih dari 0'), findsOneWidget);
    expect(find.text('Pilih kategori'), findsOneWidget);
    expect(server.writes, isEmpty);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nominal'),
      '150000',
    );
    await tester.tap(find.text('Listrik'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Simpan'));
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(server.writes, hasLength(1));
    final write = server.writes.single;
    expect(write.method, 'POST');
    expect(write.path, '/recurring');
    expect(write.body!['type'], 'EXPENSE');
    expect(write.body!['amount'], 150000);
    expect(write.body!['categoryId'], 'c1');
    expect(write.body!['walletId'], 'w1');
    expect(write.body!['dayOfMonth'], isA<int>());
    expect(write.body!['startMonth'], matches(RegExp(r'^\d{4}-\d{2}$')));
    expect(write.body!.containsKey('endMonth'), isTrue);
    expect(write.body!['endMonth'], isNull);
    // Kembali ke daftar dan daftar diambil ulang.
    expect(find.byType(EmptyState), findsOneWidget);
    expect(server.reads.where((u) => u.path == '/recurring'), hasLength(2));
  });

  testWidgets('ubah: form terisi lalu PATCH', (tester) async {
    final server = serverWith([recurringJson()]);
    await pumpRoutedApp(tester, server, routeName: Routes.recurring);
    await tester.tap(find.text('Listrik'));
    await tester.pumpAndSettle();
    expect(find.text('Ubah aturan'), findsOneWidget);
    expect(find.text('150.000'), findsOneWidget);

    await tester.ensureVisible(find.text('Simpan'));
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    final write = server.writes.single;
    expect(write.method, 'PATCH');
    expect(write.path, '/recurring/r1');
    expect(write.body!['amount'], 150000);
    expect(write.body!['dayOfMonth'], 5);
  });

  testWidgets('hapus: konfirmasi lalu DELETE', (tester) async {
    final server = serverWith([recurringJson()]);
    await pumpRoutedApp(tester, server, routeName: Routes.recurring);
    await tester.tap(find.text('Listrik'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Hapus'));
    await tester.pumpAndSettle();
    expect(server.writes, isEmpty);
    await tester.tap(find.widgetWithText(TextButton, 'Hapus'));
    await tester.pumpAndSettle();
    expect(server.writes.single.method, 'DELETE');
    expect(server.writes.single.path, '/recurring/r1');
  });

  testWidgets('endMonth sebelum startMonth: simpan diblokir', (tester) async {
    final server = serverWith([
      {...recurringJson(), 'endMonth': '2026-10'},
    ]);
    await pumpRoutedApp(tester, server, routeName: Routes.recurring);
    await tester.tap(find.text('Listrik'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Simpan'));
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(
      find.text('Bulan berakhir tidak boleh sebelum bulan mulai'),
      findsOneWidget,
    );
    expect(server.writes, isEmpty);
  });

  testWidgets('ubah nominal: PATCH membawa nilai baru', (tester) async {
    final server = serverWith([recurringJson()]);
    await pumpRoutedApp(tester, server, routeName: Routes.recurring);
    await tester.tap(find.text('Listrik'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nominal'),
      '200000',
    );
    await tester.ensureVisible(find.text('Simpan'));
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(server.writes.single.method, 'PATCH');
    expect(server.writes.single.body!['amount'], 200000);
  });

  testWidgets('ganti tipe: kategori terpilih direset', (tester) async {
    final server = serverWith([]);
    await pumpRoutedApp(tester, server, routeName: Routes.recurring);
    await tester.tap(find.byTooltip('Tambah aturan'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nominal'),
      '1000',
    );
    await tester.tap(find.text('Listrik'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Simpan'));
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(find.text('Pilih kategori'), findsOneWidget);
    expect(server.writes, isEmpty);
  });
}
