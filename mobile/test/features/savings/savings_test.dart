import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../helpers/fake_server.dart';

void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));

  final bca = walletJson('w1', 'BCA', balance: 900000);
  final liburan = walletJson(
    's1',
    'Liburan',
    type: 'SAVINGS',
    balance: 1000000,
    targetAmount: 5000000,
  );
  final darurat = walletJson('s2', 'Darurat', type: 'SAVINGS', balance: 300000);
  final hp = walletJson(
    's3',
    'HP baru',
    type: 'SAVINGS',
    balance: 2000000,
    targetAmount: 1500000,
  );

  Map<String, Object?> ref(String id, String name) => {
    'id': id,
    'name': name,
    'icon': 'savings_rounded',
    'color': '#00897B',
  };
  Map<String, Object?> transfer(String id, int amount, String at) => {
    'id': id,
    'fromWallet': ref('w1', 'BCA'),
    'toWallet': ref('s1', 'Liburan'),
    'amount': amount,
    'occurredAt': at,
    'note': null,
  };

  FakeServer server({
    List<Map<String, Object?>>? savings,
    int availableBalance = 900000,
    int fronted = 0,
  }) => FakeServer({
    '/dashboard': dashboardJson(
      totalBalance: 4200000,
      availableBalance: availableBalance,
      frontedPayableRemaining: fronted,
      wallets: [bca],
      savings: savings ?? [liburan, darurat, hp],
      receivableRemaining: 150000,
      payableRemaining: 50000,
    ),
    '/receivables': {'items': <Object>[], 'totalRemaining': 150000},
    '/wallets': {
      'items': [bca, liburan],
      'totalBalance': 1900000,
    },
    '/categories': {
      'items': [categoryJson('c1', 'Makan')],
    },
    '/transfers': {
      'items': [
        transfer('x1', 500000, '2026-11-14T13:15:00.000Z'),
        transfer('x2', 750000, '2026-10-25T02:00:00.000Z'),
      ],
    },
    '/transactions': {
      'items': [
        {
          'id': 't1',
          'type': 'EXPENSE',
          'amount': 250000,
          'occurredAt': '2026-11-10T05:00:00.000Z',
          'note': 'Tiket pesawat',
          'wallet': ref('s1', 'Liburan'),
          'category': {
            'id': 'c1',
            'name': 'Hiburan',
            'icon': 'x',
            'color': '#F97316',
          },
          'attachments': <Object>[],
          'createdAt': '2026-11-10T05:00:00.000Z',
          'updatedAt': '2026-11-10T05:00:00.000Z',
        },
      ],
    },
  });

  Future<void> openSheet(
    WidgetTester tester,
    FakeServer server, {
    bool reveal = true,
  }) async {
    await pumpRoutedApp(tester, server, routeName: null);
    if (reveal) await tester.tap(find.byTooltip('Tampilkan saldo'));
    await tester.tap(find.text('Total saldo'));
    await tester.pumpAndSettle();
  }

  Future<void> scrollTo(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      100,
      scrollable: find
          .descendant(
            of: find.byType(BottomSheet),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
  }

  Future<void> openMenu(WidgetTester tester, String name, String item) async {
    await tester.tap(find.byTooltip('Menu $name'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(item).last);
    await tester.pumpAndSettle();
  }

  Future<void> pickWallet(WidgetTester tester) async {
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('BCA · Rp900.000').last);
    await tester.pumpAndSettle();
  }

  testWidgets('sheet: saldo bisa digunakan, progres target, tercapai', (
    tester,
  ) async {
    await openSheet(tester, server());
    expect(find.text('Bisa digunakan'), findsOneWidget);
    expect(find.text('Rp900.000'), findsOneWidget);
    expect(find.text('Liburan'), findsOneWidget);
    expect(find.text('20% dari Rp5.000.000'), findsOneWidget);
    expect(find.text('Kurang Rp4.000.000'), findsOneWidget);
    await scrollTo(tester, find.text('Tercapai'));
    expect(find.text('Tanpa target'), findsOneWidget);
    expect(find.text('Tercapai'), findsOneWidget);
  });

  testWidgets('saldo tersembunyi ikut tersembunyi di sheet', (tester) async {
    await openSheet(tester, server(), reveal: false);
    expect(find.text('Rp900.000'), findsNothing);
    expect(find.text('Rp••••••'), findsWidgets);
  });

  testWidgets('belum ada tabungan', (tester) async {
    await openSheet(tester, server(savings: []));
    expect(find.text('Belum ada tabungan'), findsOneWidget);
  });

  testWidgets('buat tabungan dengan target dan setoran awal', (tester) async {
    final fake = server();
    await openSheet(tester, fake);
    await scrollTo(tester, find.text('Buat tabungan'));
    await tester.tap(find.text('Buat tabungan'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nama'),
      'Laptop',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Target (opsional)'),
      '500000',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Setoran awal (opsional)'),
      '100000',
    );
    await tester.pumpAndSettle();
    await pickWallet(tester);
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(fake.writes.single.path, '/savings');
    expect(fake.writes.single.body, {
      'name': 'Laptop',
      'targetAmount': 500000,
      'initialAmount': 100000,
      'fromWalletId': 'w1',
    });
  });

  testWidgets('setor = transfer ke tabungan tanpa biaya admin', (tester) async {
    final fake = server();
    await openSheet(tester, fake);
    await openMenu(tester, 'Liburan', 'Setor');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nominal'),
      '50000',
    );
    await pickWallet(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Setor'));
    await tester.pumpAndSettle();

    final write = fake.writes.single;
    expect(write.path, '/transfers');
    expect(write.body, containsPair('toWalletId', 's1'));
    expect(write.body, containsPair('fromWalletId', 'w1'));
    expect(write.body, containsPair('amount', 50000));
    expect(write.body!.containsKey('fee'), isFalse);
  });

  testWidgets('ubah target: kosong = tanpa target', (tester) async {
    final fake = server();
    await openSheet(tester, fake);
    await openMenu(tester, 'Liburan', 'Ubah target');
    await tester.enterText(find.widgetWithText(TextFormField, 'Target'), '');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(fake.writes.single.method, 'PATCH');
    expect(fake.writes.single.path, '/savings/s1');
    expect(fake.writes.single.body, {'targetAmount': null});
  });

  testWidgets('hapus dengan sisa wajib pilih dompet tujuan', (tester) async {
    final fake = server();
    await openSheet(tester, fake);
    await openMenu(tester, 'Liburan', 'Hapus');
    expect(find.textContaining('Sisa Rp1.000.000'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Hapus'));
    await tester.pumpAndSettle();
    expect(find.text('Pilih dompet'), findsOneWidget);
    expect(fake.writes, isEmpty);

    await pickWallet(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Hapus'));
    await tester.pumpAndSettle();
    expect(fake.writes.single.method, 'DELETE');
    expect(fake.writes.single.path, '/savings/s1');
  });

  testWidgets('catat pengeluaran membuka form dengan dompet tabungan', (
    tester,
  ) async {
    await openSheet(tester, server());
    await openMenu(tester, 'Liburan', 'Catat pengeluaran');
    expect(find.text('Tambah transaksi'), findsOneWidget);
    expect(
      find.widgetWithText(DropdownButtonFormField<String>, 'Liburan'),
      findsOneWidget,
    );
  });

  testWidgets('tap kartu tabungan membuka riwayat per bulan', (tester) async {
    final fake = server();
    await openSheet(tester, fake);
    await tester.tap(find.text('Liburan'));
    await tester.pumpAndSettle();

    expect(find.text('Disetor'), findsOneWidget);
    expect(find.text('Rp1.250.000'), findsOneWidget);
    expect(find.text('Dipakai'), findsOneWidget);
    expect(find.text('Rp250.000'), findsOneWidget);
    expect(find.text('November 2026'), findsOneWidget);
    expect(find.text('Oktober 2026'), findsOneWidget);
    expect(find.text('Setor dari BCA'), findsNWidgets(2));
    expect(find.text('+Rp500.000'), findsOneWidget);
    expect(find.text('−Rp250.000'), findsOneWidget);
    expect(find.textContaining('Tiket pesawat'), findsOneWidget);
    expect(
      fake.reads.any(
        (uri) =>
            uri.path == '/transfers' && uri.queryParameters['wallet'] == 's1',
      ),
      isTrue,
    );
  });

  testWidgets('baris Piutang minus, tap membuka layar Piutang', (tester) async {
    await openSheet(tester, server());
    expect(find.text('Piutang'), findsOneWidget);
    expect(find.text('−Rp150.000'), findsOneWidget);
    await tester.tap(find.text('Piutang'));
    await tester.pumpAndSettle();
    expect(find.text('Total belum dibayar'), findsOneWidget);
  });

  testWidgets('Bisa digunakan: keterangan potongan talangan (D-81)', (
    tester,
  ) async {
    await openSheet(tester, server(fronted: 50000));
    expect(
      find.text('Sudah dipotong utang ditalangin Rp50.000'),
      findsOneWidget,
    );
  });

  testWidgets('tanpa talangan: tanpa keterangan; negatif tampil minus', (
    tester,
  ) async {
    await openSheet(tester, server(availableBalance: -20000));
    expect(find.textContaining('Sudah dipotong'), findsNothing);
    expect(find.text('−Rp20.000'), findsOneWidget);
  });

  testWidgets('keterangan talangan ikut tersembunyi', (tester) async {
    await openSheet(tester, server(fronted: 50000), reveal: false);
    expect(find.textContaining('Sudah dipotong'), findsNothing);
  });

  testWidgets('baris Piutang ikut tersembunyi', (tester) async {
    await openSheet(tester, server(), reveal: false);
    expect(find.text('−Rp150.000'), findsNothing);
    expect(find.text('Rp50.000'), findsNothing);
  });

  testWidgets('baris Utang, tap membuka tab Utang', (tester) async {
    final fake = server();
    await openSheet(tester, fake);
    expect(find.text('Utang'), findsOneWidget);
    expect(find.text('Rp50.000'), findsOneWidget);
    await tester.tap(find.text('Utang'));
    await tester.pumpAndSettle();
    expect(find.text('Total utang'), findsOneWidget);
    expect(
      fake.reads.any(
        (uri) =>
            uri.path == '/receivables' &&
            uri.queryParameters['direction'] == 'payable',
      ),
      isTrue,
    );
  });
}
