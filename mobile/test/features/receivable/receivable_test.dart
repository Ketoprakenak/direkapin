import 'package:direkapin/core/router/router.dart';
import 'package:direkapin/core/theme/tokens.dart';
import 'package:direkapin/core/widgets/state_views.dart';
import 'package:direkapin/features/receivable/data/receivable_models.dart';
import 'package:direkapin/features/transaction/data/transaction_models.dart';
import 'package:direkapin/features/receivable/presentation/receivable_form_screen.dart';
import 'package:direkapin/features/receivable/presentation/receivables_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../helpers/fake_server.dart';

void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));

  Map<String, Object?> debtor(
    String id,
    String name,
    int amount, {
    int paid = 0,
  }) => {
    'id': id,
    'name': name,
    'amount': amount,
    'paid': paid,
    'remaining': amount - paid,
    'payments': [
      if (paid > 0)
        {
          'transactionId': 't-$id',
          'amount': paid,
          'occurredAt': '2026-11-15T03:00:00.000Z',
          'wallet': {
            'id': 'w1',
            'name': 'BCA',
            'icon': 'account_balance_rounded',
            'color': '#3B82F6',
          },
        },
    ],
  };

  final bakso = {
    'id': 'r1',
    'direction': 'RECEIVABLE',
    'loan': null,
    'title': 'Makan bakso',
    'date': '2026-11-16',
    'note': null,
    'total': 150000,
    'remaining': 30000,
    'debtors': [
      debtor('d1', 'Budi', 50000, paid: 20000),
      debtor('d2', 'Andi', 100000, paid: 100000),
    ],
  };

  FakeServer server({List<Map<String, Object?>>? items}) => FakeServer({
    '/dashboard': dashboardJson(receivableRemaining: 30000),
    '/receivables': {
      'items': items ?? [bakso],
      'totalRemaining': 30000,
    },
    '/wallets': {
      'items': [walletJson('w1', 'BCA', balance: 900000)],
      'totalBalance': 900000,
    },
    '/categories': {
      'items': [categoryJson('c1', 'Makan')],
    },
  });

  final kos = {
    'id': 'r2',
    'direction': 'PAYABLE',
    'title': 'Pinjam kos',
    'date': '2026-11-14',
    'note': null,
    'total': 1000000,
    'remaining': 900000,
    'loan': {
      'transactionId': 't-loan',
      'amount': 1000000,
      'wallet': {
        'id': 'w1',
        'name': 'BCA',
        'icon': 'account_balance_rounded',
        'color': '#3B82F6',
      },
    },
    'debtors': [debtor('d3', 'Dodi', 1000000, paid: 100000)],
  };

  testWidgets('daftar kosong', (tester) async {
    await pumpRoutedApp(
      tester,
      server(items: []),
      routeName: Routes.receivables,
    );
    expect(
      find.text('Belum ada piutang. Catat waktu kamu nalangin teman.'),
      findsOneWidget,
    );
  });

  testWidgets('kartu: sisa, chip orang, toggle Semua', (tester) async {
    final fake = server();
    await pumpRoutedApp(tester, fake, routeName: Routes.receivables);
    expect(find.text('Makan bakso'), findsOneWidget);
    expect(find.textContaining('Sisa Rp30.000'), findsOneWidget);
    expect(find.text('Budi · Rp30.000'), findsOneWidget);
    expect(find.text('Andi'), findsOneWidget);

    await tester.tap(find.text('Semua'));
    await tester.pumpAndSettle();
    expect(
      fake.reads.any(
        (uri) =>
            uri.path == '/receivables' &&
            uri.queryParameters['status'] == 'all',
      ),
      isTrue,
    );
  });

  testWidgets('form: validasi baris lalu kirim body persis', (tester) async {
    final fake = server();
    await pumpRoutedApp(tester, fake, routeName: Routes.receivableForm);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Judul'),
      'Kopi kantor',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nama 1'),
      'Sari',
    );
    await tester.ensureVisible(find.text('Simpan'));
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(find.text('Nominal harus lebih dari 0'), findsOneWidget);
    expect(fake.writes, isEmpty);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nominal'),
      '30000',
    );
    await tester.tap(find.text('Tambah orang'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nama 2'),
      'Dimas',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nominal').last,
      '25000',
    );
    await tester.pumpAndSettle();
    expect(find.text('Rp55.000'), findsOneWidget);
    expect(
      find.text('Dicatat sebagai pengeluaran "Piutang diberikan"'),
      findsOneWidget,
    );
    await tester.ensureVisible(find.text('Simpan'));
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    // Piutang dari menu = pinjamkan uang: dompet wajib (D-86).
    expect(find.text('Pilih dompet'), findsOneWidget);
    expect(fake.writes, isEmpty);

    await tester.ensureVisible(find.byType(DropdownButtonFormField<String>));
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('BCA · Rp900.000').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Simpan'));
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    final write = fake.writes.single;
    expect(write.path, '/receivables');
    expect(write.body!['title'], 'Kopi kantor');
    expect(write.body, containsPair('loanWalletId', 'w1'));
    expect(write.body!.containsKey('direction'), isFalse);
    expect(write.body!['debtors'], [
      {'name': 'Sari', 'amount': 30000},
      {'name': 'Dimas', 'amount': 25000},
    ]);
    expect(write.body!.containsKey('note'), isFalse);
    expect(write.body!['clientId'], isA<String>());
  });

  testWidgets('lunas: cap LUNAS TERBAYAR di kartu dan detail', (tester) async {
    final kopi = {
      ...bakso,
      'id': 'r3',
      'title': 'Kopi kantor',
      'remaining': 0,
      'total': 55000,
      'debtors': [debtor('d4', 'Sari', 55000, paid: 55000)],
    };
    await pumpRoutedApp(
      tester,
      server(items: [bakso, kopi]),
      routeName: Routes.receivables,
    );
    expect(find.text('LUNAS TERBAYAR'), findsOneWidget);
    // Hijau = warna masuk tema, supaya kontras di semua tema (DESIGN.md).
    final green = AppColors.of(tester.element(find.text('Kopi kantor'))).income;
    expect(
      tester.widget<Text>(find.text('LUNAS TERBAYAR')).style?.color,
      green,
    );
    // Cap miring: latar kartu, garis hijau, dan tidak menabrak bar di bawahnya.
    final stampBox = find
        .descendant(
          of: find.byType(PaidStamp),
          matching: find.byType(DecoratedBox),
        )
        .first;
    final decoration =
        tester.widget<DecoratedBox>(stampBox).decoration as BoxDecoration;
    final context = tester.element(find.text('Kopi kantor'));
    expect(decoration.color, Theme.of(context).colorScheme.surface);
    expect((decoration.border! as Border).top.color, green);
    final stampBottom = [
      tester.getBottomLeft(stampBox).dy,
      tester.getBottomRight(stampBox).dy,
    ].reduce((a, b) => a > b ? a : b);
    expect(
      stampBottom,
      lessThanOrEqualTo(tester.getRect(find.byType(PaidBar).last).top),
    );
    await tester.tap(find.text('Kopi kantor'));
    await tester.pumpAndSettle();
    expect(find.text('LUNAS TERBAYAR'), findsOneWidget);
    expect(
      tester.widget<Text>(find.text('LUNAS TERBAYAR')).style?.color,
      green,
    );
    expect(tester.widget<Text>(find.text('Lunas')).style?.color, green);
    expect(find.widgetWithText(FilledButton, 'Bayar'), findsNothing);
  });

  testWidgets('detail: Bayar default sisa, lunas tanpa tombol', (tester) async {
    final fake = server();
    await pumpRoutedApp(
      tester,
      fake,
      routeName: Routes.receivableDetail,
      pathParameters: {'id': 'r1'},
    );
    expect(find.widgetWithText(FilledButton, 'Bayar'), findsOneWidget);
    expect(find.text('Lunas'), findsOneWidget);
    expect(find.textContaining('Rp20.000 ke BCA'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Bayar'));
    await tester.pumpAndSettle();
    expect(find.text('Budi bayar'), findsOneWidget);
    expect(find.text('30.000'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nominal'),
      '40000',
    );
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(find.text('Melebihi sisa utang Rp30.000'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nominal'),
      '30000',
    );
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('BCA · Rp900.000').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan'));
    // Refresh sesudah bayar tidak boleh mengganti detail dengan skeleton.
    for (var i = 0; i < 5; i++) {
      await tester.pump();
      expect(find.byType(ListSkeleton), findsNothing);
    }
    await tester.pumpAndSettle();

    final write = fake.writes.single;
    expect(write.path, '/receivables/debtors/d1/payments');
    expect(write.body, containsPair('amount', 30000));
    expect(write.body, containsPair('walletId', 'w1'));
  });

  testWidgets('tab Utang: baca direction=payable, kosong, FAB', (tester) async {
    final fake = server(items: []);
    await pumpRoutedApp(tester, fake, routeName: Routes.receivables);
    expect(find.text('Utang & Piutang'), findsOneWidget);
    await tester.tap(find.text('Utang'));
    await tester.pumpAndSettle();
    expect(
      fake.reads.any(
        (uri) =>
            uri.path == '/receivables' &&
            uri.queryParameters['direction'] == 'payable',
      ),
      isTrue,
    );
    expect(find.text('Total utang'), findsOneWidget);
    expect(
      find.text(
        'Belum ada utang. Catat kalau ada yang nalangin atau minjemin kamu.',
      ),
      findsOneWidget,
    );
    expect(find.text('Catat utang'), findsOneWidget);
  });

  testWidgets('form utang: pinjam tunai wajib dompet, body persis', (
    tester,
  ) async {
    final fake = server();
    await pumpRoutedApp(
      tester,
      fake,
      routeName: Routes.receivableForm,
      extra: ReceivableDirection.payable,
    );
    expect(find.text('Catat utang'), findsOneWidget);
    expect(find.text('Tambah orang'), findsNothing);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Judul'),
      'Pinjam kos',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Utang ke'),
      'Dodi',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nominal'),
      '1000000',
    );
    await tester.tap(find.text('Pinjam tunai'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Simpan'));
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(find.text('Pilih dompet'), findsOneWidget);
    expect(fake.writes, isEmpty);

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('BCA · Rp900.000').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Simpan'));
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    final write = fake.writes.single;
    expect(write.path, '/receivables');
    expect(write.body, containsPair('direction', 'PAYABLE'));
    expect(write.body, containsPair('loanWalletId', 'w1'));
    expect(write.body!['debtors'], [
      {'name': 'Dodi', 'amount': 1000000},
    ]);
  });

  testWidgets('detail utang: info pinjaman, bayar wajib kategori', (
    tester,
  ) async {
    final fake = server(items: [kos]);
    await pumpRoutedApp(
      tester,
      fake,
      routeName: Routes.receivableDetail,
      pathParameters: {'id': 'r2'},
    );
    expect(find.text('Pinjaman masuk ke BCA'), findsOneWidget);
    // Cicilan utang = uang keluar: panah keluar, bukan masuk.
    expect(find.byIcon(Icons.north_east_rounded), findsOneWidget);
    expect(find.byIcon(Icons.south_west_rounded), findsNothing);
    await tester.tap(find.widgetWithText(FilledButton, 'Bayar'));
    await tester.pumpAndSettle();
    expect(find.text('Bayar utang ke Dodi'), findsOneWidget);
    expect(find.text('Dari dompet'), findsOneWidget);

    final dropdowns = find.byType(DropdownButtonFormField<String>);
    await tester.tap(dropdowns.first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('BCA · Rp900.000').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(find.text('Pilih kategori'), findsOneWidget);
    expect(fake.writes, isEmpty);

    await tester.tap(dropdowns.last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Makan').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    final write = fake.writes.single;
    expect(write.path, '/receivables/debtors/d3/payments');
    expect(write.body, containsPair('categoryId', 'c1'));
    expect(write.body, containsPair('walletId', 'w1'));
  });

  test('splitEvenly: rata termasuk owner, sisa milik owner', () {
    expect(splitEvenly(200000, 2), [66666, 66666]);
    expect(splitEvenly(1, 1), [0]);
  });

  const makan = ReceivableSource(
    transactionId: 't1',
    amount: 200000,
    categoryName: 'Makan',
    date: '2026-11-16',
  );

  testWidgets('bagi ke teman: terisi dari pengeluaran, Bagi rata, body', (
    tester,
  ) async {
    final fake = server();
    await pumpRoutedApp(
      tester,
      fake,
      routeName: Routes.receivableForm,
      extra: makan,
    );
    expect(find.text('Bagi ke teman'), findsOneWidget);
    expect(find.text('Dari pengeluaran Makan Rp200.000'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Makan'), findsOneWidget);
    // Sudah ada pengeluarannya: tanpa pilihan dompet (D-86).
    expect(find.byType(DropdownButtonFormField<String>), findsNothing);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nama 1'),
      'Budi',
    );
    await tester.tap(find.text('Tambah orang'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nama 2'),
      'Andi',
    );
    await tester.ensureVisible(find.text('Bagi rata'));
    await tester.tap(find.text('Bagi rata'));
    await tester.pumpAndSettle();
    expect(find.text('66.666'), findsNWidgets(2));
    expect(find.text('Bagian kamu Rp66.668'), findsOneWidget);
    await tester.ensureVisible(find.text('Simpan'));
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    final write = fake.writes.single;
    expect(write.body, containsPair('sourceTransactionId', 't1'));
    expect(write.body, containsPair('date', '2026-11-16'));
    expect(write.body, containsPair('title', 'Makan'));
    expect(write.body!['debtors'], [
      {'name': 'Budi', 'amount': 66666},
      {'name': 'Andi', 'amount': 66666},
    ]);
  });

  testWidgets('bagi ke teman: melebihi nominal dan bagian 0 ditolak', (
    tester,
  ) async {
    final fake = server();
    await pumpRoutedApp(
      tester,
      fake,
      routeName: Routes.receivableForm,
      extra: makan,
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nama 1'),
      'Budi',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nominal'),
      '250000',
    );
    await tester.ensureVisible(find.text('Simpan'));
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(find.text('Melebihi nominal pengeluaran Rp200.000'), findsOneWidget);
    expect(fake.writes, isEmpty);
  });

  testWidgets('bagi rata hasil 0 ditolak validasi baris', (tester) async {
    final fake = server();
    await pumpRoutedApp(
      tester,
      fake,
      routeName: Routes.receivableForm,
      extra: const ReceivableSource(
        transactionId: 't1',
        amount: 1,
        categoryName: 'Makan',
        date: '2026-11-16',
      ),
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nama 1'),
      'Budi',
    );
    await tester.ensureVisible(find.text('Bagi rata'));
    await tester.tap(find.text('Bagi rata'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Simpan'));
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(find.text('Nominal harus lebih dari 0'), findsOneWidget);
    expect(fake.writes, isEmpty);
  });

  Transaction expense({String type = 'EXPENSE', String? receivableId}) =>
      Transaction.fromJson({
        'id': 't1',
        'type': type,
        'amount': 200000,
        'occurredAt': '2026-11-16T05:30:00.000Z',
        'note': null,
        'wallet': {
          'id': 'w1',
          'name': 'BCA',
          'icon': 'account_balance_rounded',
          'color': '#3B82F6',
        },
        'category': {
          'id': 'c1',
          'name': 'Makan',
          'icon': 'restaurant_rounded',
          'color': '#F97316',
        },
        'attachments': <Object>[],
        'receivableId': receivableId,
      });

  testWidgets('detail pengeluaran: tombol Bagi ke teman membuka form bagi', (
    tester,
  ) async {
    await pumpRoutedApp(
      tester,
      server(),
      routeName: Routes.transactionDetail,
      extra: expense(),
    );
    await tester.ensureVisible(
      find.widgetWithText(OutlinedButton, 'Bagi ke teman'),
    );
    await tester.tap(find.widgetWithText(OutlinedButton, 'Bagi ke teman'));
    await tester.pumpAndSettle();
    expect(find.text('Dari pengeluaran Makan Rp200.000'), findsOneWidget);
  });

  testWidgets('detail: sudah dibagi = baris, pemasukan = tanpa apa-apa', (
    tester,
  ) async {
    await pumpRoutedApp(
      tester,
      server(),
      routeName: Routes.transactionDetail,
      extra: expense(receivableId: 'r1'),
    );
    expect(find.text('Dibagi ke teman'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Bagi ke teman'), findsNothing);
    await tester.ensureVisible(find.text('Dibagi ke teman'));
    await tester.tap(find.text('Dibagi ke teman'));
    await tester.pumpAndSettle();
    expect(find.text('Makan bakso'), findsWidgets);
  });

  testWidgets('detail pemasukan: tanpa Bagi ke teman', (tester) async {
    await pumpRoutedApp(
      tester,
      server(),
      routeName: Routes.transactionDetail,
      extra: expense(type: 'INCOME'),
    );
    expect(find.textContaining('ibagi ke teman'), findsNothing);
    expect(find.textContaining('Bagi ke teman'), findsNothing);
  });

  testWidgets('detail piutang: info asal, tap membuka transaksi', (
    tester,
  ) async {
    final fake = FakeServer({
      ...server().responses,
      '/receivables': {
        'items': [
          {
            ...bakso,
            'source': {
              'transactionId': 't1',
              'amount': 200000,
              'categoryName': 'Makan',
            },
          },
        ],
        'totalRemaining': 30000,
      },
      '/transactions/t1': expense().toJson(),
    });
    await pumpRoutedApp(
      tester,
      fake,
      routeName: Routes.receivableDetail,
      pathParameters: {'id': 'r1'},
    );
    expect(find.text('Dari pengeluaran Makan Rp200.000'), findsOneWidget);
    await tester.tap(find.text('Dari pengeluaran Makan Rp200.000'));
    await tester.pumpAndSettle();
    expect(find.text('Detail transaksi'), findsOneWidget);
  });
}
