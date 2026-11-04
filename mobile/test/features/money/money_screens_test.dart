import 'package:direkapin/core/router/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../helpers/fake_server.dart';

void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));

  final cash = walletJson('w1', 'Cash', balance: 75000);
  final bank = walletJson('w2', 'Bank', balance: 500000);

  FakeServer formServer({Map<String, Object> extra = const {}}) => FakeServer({
    '/dashboard': dashboardJson(),
    '/wallets': {
      'items': [cash, bank],
      'totalBalance': 575000,
    },
    '/categories': {
      'items': [categoryJson('c1', 'Makan'), categoryJson('c2', 'Transport')],
    },
    '/transactions': {'items': <Object>[], 'nextCursor': null},
    ...extra,
  });

  Finder field(String label) => find.widgetWithText(TextFormField, label);

  Future<void> tapSave(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Simpan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
  }

  group('Beranda', () {
    testWidgets('menampilkan saldo, dompet, streak, dan ajakan mencatat', (tester) async {
      final server = FakeServer({
        '/dashboard': dashboardJson(totalBalance: 75000, wallets: [cash], streak: 7),
      });
      await pumpRoutedApp(tester, server, routeName: Routes.home);

      expect(find.text('Rp75.000'), findsNWidgets(2));
      expect(find.text('Cash'), findsOneWidget);
      expect(find.text('7 hari berturut-turut mencatat'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Belum ada catatan hari ini. Mulai dari pengeluaran pertamamu.'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
    });

    testWidgets('saldo negatif ditampilkan dengan tanda minus', (tester) async {
      final server = FakeServer({
        '/dashboard': dashboardJson(totalBalance: -25000),
      });
      await pumpRoutedApp(tester, server, routeName: Routes.home);
      expect(find.text('−Rp25.000'), findsOneWidget);
    });

    testWidgets('error menampilkan pesan dan tombol coba lagi', (tester) async {
      final server = FakeServer({'/dashboard': 500});
      await pumpRoutedApp(tester, server, routeName: Routes.home);
      expect(find.text('Terjadi kesalahan di server'), findsOneWidget);

      server.responses['/dashboard'] = dashboardJson(totalBalance: 1000);
      await tester.tap(find.text('Coba lagi'));
      await tester.pumpAndSettle();
      expect(find.text('Rp1.000'), findsOneWidget);
    });

    testWidgets('FAB membuka pilihan, lalu form transaksi', (tester) async {
      await pumpRoutedApp(tester, formServer(), routeName: Routes.home);
      await tester.tap(find.byTooltip('Tambah'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Transaksi'));
      await tester.pumpAndSettle();
      expect(find.text('Tambah transaksi'), findsOneWidget);
    });
  });

  group('Form transaksi', () {
    testWidgets('nominal dan kategori wajib', (tester) async {
      final server = formServer();
      await pumpRoutedApp(tester, server, routeName: Routes.transactionForm);
      await tapSave(tester);

      expect(find.text('Nominal harus lebih dari 0'), findsOneWidget);
      expect(find.text('Pilih kategori'), findsOneWidget);
      expect(server.writes, isEmpty);
    });

    testWidgets('cukup nominal + kategori: terkirim sebagai Keluar, integer, UTC', (tester) async {
      final server = formServer();
      await pumpRoutedApp(tester, server, routeName: Routes.transactionForm);

      await tester.enterText(field('Nominal'), '25000');
      await tester.tap(find.text('Makan'));
      await tester.pump();
      await tapSave(tester);

      expect(server.writes, hasLength(1));
      final write = server.writes.single;
      expect(write.path, '/transactions');
      expect(write.body, containsPair('amount', 25000));
      expect(write.body, containsPair('type', 'EXPENSE'));
      expect(write.body, containsPair('categoryId', 'c1'));
      expect(write.body, containsPair('walletId', 'w1'));
      expect(write.body!['occurredAt'] as String, endsWith('Z'));
      expect(write.body!.containsKey('note'), isFalse);
      expect(find.text('Transaksi tersimpan'), findsOneWidget);
      expect(find.text('Tambah transaksi'), findsNothing);
    });

    testWidgets('dompet awal = dompet transaksi terakhir (D-31)', (tester) async {
      final server = formServer(
        extra: {
          '/transactions': {
            'items': [
              {
                'id': 't1',
                'type': 'EXPENSE',
                'amount': 1,
                'occurredAt': '2026-11-04T02:30:00.000Z',
                'note': null,
                'wallet': {'id': 'w2', 'name': 'Bank', 'icon': 'x', 'color': '#14B8A6'},
                'category': {'id': 'c1', 'name': 'Makan', 'icon': 'x', 'color': '#F97316'},
              },
            ],
            'nextCursor': null,
          },
        },
      );
      await pumpRoutedApp(tester, server, routeName: Routes.transactionForm);

      await tester.enterText(field('Nominal'), '1000');
      await tester.tap(find.text('Makan'));
      await tester.pump();
      await tapSave(tester);

      expect(server.writes.single.body, containsPair('walletId', 'w2'));
    });

    testWidgets('error server ditampilkan, data form tetap ada', (tester) async {
      final server = formServer();
      server.writeFailure = (
        status: 400,
        body: {
          'error': {
            'code': 'VALIDATION_ERROR',
            'message': 'Data belum valid',
            'details': {'walletId': 'Pilih dompet'},
          },
        },
      );
      await pumpRoutedApp(tester, server, routeName: Routes.transactionForm);

      await tester.enterText(field('Nominal'), '25000');
      await tester.tap(find.text('Makan'));
      await tester.pump();
      await tapSave(tester);

      expect(find.text('Pilih dompet'), findsOneWidget);
      expect(find.text('25.000'), findsOneWidget);
      expect(find.text('Tambah transaksi'), findsOneWidget);
    });

    testWidgets('transfer: dompet sama ditolak, dompet berbeda terkirim', (tester) async {
      final server = formServer();
      await pumpRoutedApp(tester, server, routeName: Routes.transactionForm);

      await tester.tap(find.text('Transfer'));
      await tester.pumpAndSettle();
      await tester.enterText(field('Nominal'), '100000');

      await tapSave(tester);
      expect(find.text('Pilih dompet'), findsOneWidget);

      await tester.tap(find.widgetWithText(DropdownButtonFormField<String>, 'Ke dompet'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cash').last);
      await tester.pumpAndSettle();
      await tapSave(tester);
      expect(find.text('Dompet asal dan tujuan harus berbeda'), findsOneWidget);
      expect(server.writes, isEmpty);

      await tester.tap(find.widgetWithText(DropdownButtonFormField<String>, 'Ke dompet'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bank').last);
      await tester.pumpAndSettle();
      await tapSave(tester);

      final write = server.writes.single;
      expect(write.path, '/transfers');
      expect(write.body, containsPair('fromWalletId', 'w1'));
      expect(write.body, containsPair('toWalletId', 'w2'));
      expect(write.body!.containsKey('categoryId'), isFalse);
    });

    testWidgets('tanpa dompet aktif menampilkan ajakan', (tester) async {
      final server = formServer(
        extra: {
          '/wallets': {'items': <Object>[], 'totalBalance': 0},
        },
      );
      await pumpRoutedApp(tester, server, routeName: Routes.transactionForm);
      expect(find.text('Belum ada dompet aktif. Tambah dompet dulu, yuk.'), findsOneWidget);
    });
  });

  group('Dompet', () {
    testWidgets('daftar, tambah, dan pesan nama dobel', (tester) async {
      final server = formServer();
      await pumpRoutedApp(tester, server, routeName: Routes.wallets);
      expect(find.text('Rp500.000'), findsOneWidget);

      await tester.tap(find.byTooltip('Tambah dompet'));
      await tester.pumpAndSettle();

      await tapSave(tester);
      expect(find.text('Nama wajib diisi'), findsOneWidget);

      server.writeFailure = (
        status: 409,
        body: {
          'error': {'code': 'NAME_TAKEN', 'message': 'Nama sudah dipakai'},
        },
      );
      await tester.enterText(field('Nama dompet'), 'Cash');
      await tapSave(tester);
      expect(find.text('Nama sudah dipakai'), findsOneWidget);

      server.writeFailure = null;
      await tester.enterText(field('Nama dompet'), 'OVO');
      await tester.enterText(field('Saldo awal'), '-5000');
      await tapSave(tester);

      final body = server.writes.last.body!;
      expect(body['name'], 'OVO');
      expect(body['initialBalance'], -5000);
      expect(find.text('Tambah dompet'), findsNothing);
    });

    testWidgets('dompet punya transaksi tidak bisa dihapus, bisa diarsipkan', (tester) async {
      final server = formServer();
      await pumpRoutedApp(tester, server, routeName: Routes.wallets);
      await tester.tap(find.byTooltip('Ubah Cash'));
      await tester.pumpAndSettle();

      server.writeFailure = (
        status: 409,
        body: {
          'error': {
            'code': 'WALLET_IN_USE',
            'message': 'Dompet masih punya transaksi. Arsipkan saja.',
          },
        },
      );
      await tester.ensureVisible(find.widgetWithText(TextButton, 'Hapus'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Hapus'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Hapus').last);
      await tester.pumpAndSettle();
      expect(find.text('Dompet masih punya transaksi. Arsipkan saja.'), findsOneWidget);

      server.writeFailure = null;
      await tester.ensureVisible(find.text('Arsipkan'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Arsipkan'));
      await tester.pumpAndSettle();
      expect(server.writes.last.body, {'isArchived': true});
    });
  });

  group('Kategori', () {
    testWidgets('bawaan: nama terkunci dan tidak ada tombol hapus', (tester) async {
      final server = formServer();
      await pumpRoutedApp(tester, server, routeName: Routes.categories);
      await tester.tap(find.text('Makan'));
      await tester.pumpAndSettle();

      final name = tester.widget<TextFormField>(field('Nama kategori'));
      expect(name.enabled, isFalse);
      expect(find.widgetWithText(TextButton, 'Hapus'), findsNothing);
    });

    testWidgets('tambah custom mengikuti tab yang aktif', (tester) async {
      final server = formServer();
      await pumpRoutedApp(tester, server, routeName: Routes.categories);
      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Tambah kategori'));
      await tester.pumpAndSettle();
      await tester.enterText(field('Nama kategori'), 'Bonus');
      await tapSave(tester);

      final body = server.writes.single.body!;
      expect(body['name'], 'Bonus');
      expect(body['type'], 'INCOME');
    });
  });
}
