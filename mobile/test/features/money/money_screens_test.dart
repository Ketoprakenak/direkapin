import 'package:direkapin/core/router/router.dart';
import 'package:direkapin/core/widgets/frame.dart';
import 'package:direkapin/core/widgets/mascot.dart';
import 'package:direkapin/core/widgets/state_views.dart';
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
    testWidgets('sapaan, saldo tersembunyi sampai ikon mata ditekan, streak', (
      tester,
    ) async {
      final server = FakeServer({
        '/me': {
          'id': 'u1',
          'name': 'Desta',
          'email': 'desta@example.com',
          'timezone': 'Asia/Jakarta',
          'reminderTime': '21:00',
          'hasAvatar': false,
          'createdAt': '2026-11-01T00:00:00.000Z',
        },
        '/dashboard': dashboardJson(
          totalBalance: 75000,
          wallets: [cash],
          streak: 7,
        ),
      });
      await pumpRoutedApp(tester, server, routeName: Routes.home);

      expect(find.text('Hai, Desta'), findsOneWidget);
      expect(find.text('Rp75.000'), findsNothing);
      await tester.tap(find.byTooltip('Tampilkan saldo'));
      await tester.pump();
      expect(find.text('Rp75.000'), findsOneWidget);
      expect(find.text('Masuk bulan ini'), findsNothing);
      await tester.tap(find.text('Tampilkan detail'));
      await tester.pump();
      expect(find.text('Masuk bulan ini'), findsOneWidget);
      // Saldo per dompet tidak lagi tampil di Beranda.
      expect(find.text('Cash'), findsNothing);
      expect(find.text('7 hari berturut-turut mencatat'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text(
          'Belum ada catatan hari ini. Mulai dari pengeluaran pertamamu.',
        ),
        200,
        scrollable: find.byType(Scrollable).first,
      );
    });

    const me = {
      'id': 'u1',
      'name': 'Desta',
      'email': 'desta@example.com',
      'timezone': 'Asia/Jakarta',
      'reminderTime': '21:00',
      'hasAvatar': false,
      'createdAt': '2026-11-01T00:00:00.000Z',
    };
    Finder titleMascot() =>
        find.descendant(of: find.byType(AppBar), matching: find.byType(Mascot));

    testWidgets('maskot di judul netral jika belum mencatat; EmptyState juga '
        'bermaskot', (tester) async {
      await pumpRoutedApp(
        tester,
        FakeServer({'/me': me, '/dashboard': dashboardJson()}),
        routeName: Routes.home,
      );
      expect(
        tester.widget<Mascot>(titleMascot()).expression,
        MascotExpression.neutral,
      );
      await tester.scrollUntilVisible(
        find.byType(EmptyState),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        find.descendant(
          of: find.byType(EmptyState),
          matching: find.byType(Mascot),
        ),
        findsOneWidget,
      );
    });

    testWidgets('maskot di judul happy jika sudah mencatat hari ini', (
      tester,
    ) async {
      await pumpRoutedApp(
        tester,
        FakeServer({'/me': me, '/dashboard': dashboardJson(hasEntry: true)}),
        routeName: Routes.home,
      );
      expect(
        tester.widget<Mascot>(titleMascot()).expression,
        MascotExpression.happy,
      );
    });

    testWidgets('saldo negatif ditampilkan dengan tanda minus', (tester) async {
      final server = FakeServer({
        '/dashboard': dashboardJson(totalBalance: -25000),
      });
      await pumpRoutedApp(tester, server, routeName: Routes.home);
      await tester.tap(find.byTooltip('Tampilkan saldo'));
      await tester.pump();
      expect(find.text('−Rp25.000'), findsOneWidget);
    });

    testWidgets('error menampilkan pesan dan tombol coba lagi', (tester) async {
      final server = FakeServer({'/dashboard': 500});
      await pumpRoutedApp(tester, server, routeName: Routes.home);
      expect(find.text('Terjadi kesalahan di server'), findsOneWidget);

      server.responses['/dashboard'] = dashboardJson(totalBalance: 1000);
      await tester.tap(find.text('Coba lagi'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Tampilkan saldo'));
      await tester.pump();
      expect(find.text('Rp1.000'), findsOneWidget);
    });

    testWidgets(
      'badge di judul, 3 transaksi terakhir, masuk hari ini (ENG-02, DSH-04)',
      (tester) async {
        final dashboard = dashboardJson(streak: 3, hasEntry: true);
        final last7 = [...(dashboard['last7Days']! as List)];
        last7[last7.length - 1] = {
          'label': '2026-11-04',
          'income': 50000,
          'expense': 0,
        };
        Map<String, Object?> tx(String id, String category) => {
          'id': id,
          'type': 'EXPENSE',
          'amount': 15000,
          'occurredAt': '2026-11-04T02:30:00.000Z',
          'note': null,
          'wallet': {
            'id': 'w1',
            'name': 'Cash',
            'icon': 'x',
            'color': '#14B8A6',
          },
          'category': {
            'id': id,
            'name': category,
            'icon': 'x',
            'color': '#F97316',
          },
          'attachments': <Object>[],
        };
        final server = FakeServer({
          '/me': {
            'id': 'u1',
            'name': 'Desta',
            'email': 'desta@example.com',
            'timezone': 'Asia/Jakarta',
            'reminderTime': '21:00',
            'hasAvatar': false,
            'createdAt': '2026-11-01T00:00:00.000Z',
          },
          '/dashboard': {
            ...dashboard,
            'last7Days': last7,
            'streak': {'current': 3, 'longest': 30},
          },
          '/transactions': {
            'items': [
              tx('t1', 'Makan'),
              tx('t2', 'Transport'),
              tx('t3', 'Kopi'),
            ],
            'nextCursor': null,
          },
        });
        await pumpRoutedApp(tester, server, routeName: Routes.home);

        // Streak terpanjang 30: badge 30 di judul; chip 7 dan 30 didapat, 100 terkunci.
        expect(
          find.descendant(of: find.byType(AppBar), matching: find.text('30')),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.military_tech_rounded), findsNWidgets(3));
        expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
        final query = server.reads.lastWhere(
          (uri) => uri.path.endsWith('/transactions'),
        );
        expect(query.queryParameters['limit'], '3');
        await tester.scrollUntilVisible(
          find.text('Kopi'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('Transaksi terakhir'), findsOneWidget);
        expect(find.text('Makan'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text('Masuk hari ini'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('+Rp50.000'), findsOneWidget);
      },
    );

    testWidgets('bagian utama memakai FrameCard, chip badge di FrameBox', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 4000);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);
      final server = FakeServer({
        '/me': {
          'id': 'u1',
          'name': 'Desta',
          'email': 'desta@example.com',
          'timezone': 'Asia/Jakarta',
          'reminderTime': '21:00',
          'hasAvatar': false,
          'createdAt': '2026-11-01T00:00:00.000Z',
        },
        '/dashboard': {
          ...dashboardJson(streak: 3, hasEntry: true),
          'streak': {'current': 3, 'longest': 30},
        },
      });
      await pumpRoutedApp(tester, server, routeName: Routes.home);

      // Saldo, streak, grafik 7 hari, Hari ini (daftar transaksi gagal = tersembunyi).
      expect(find.byType(FrameCard), findsAtLeastNWidgets(4));
      expect(
        find.ancestor(of: find.text('7 hari'), matching: find.byType(FrameBox)),
        findsOneWidget,
      );
    });

    testWidgets('tanpa badge: judul hanya nama', (tester) async {
      final server = FakeServer({
        '/me': {
          'id': 'u1',
          'name': 'Desta',
          'email': 'desta@example.com',
          'timezone': 'Asia/Jakarta',
          'reminderTime': '21:00',
          'hasAvatar': false,
          'createdAt': '2026-11-01T00:00:00.000Z',
        },
        '/dashboard': dashboardJson(streak: 3),
      });
      await pumpRoutedApp(tester, server, routeName: Routes.home);
      expect(find.text('Hai, Desta'), findsOneWidget);
      expect(find.byIcon(Icons.military_tech_rounded), findsNothing);
      expect(find.text('Masuk hari ini'), findsNothing);
    });

    testWidgets('cari transaksi: kata kunci dan jenis jadi filter (FIN-11)', (
      tester,
    ) async {
      final server = formServer();
      await pumpRoutedApp(tester, server, routeName: Routes.transactionSearch);
      expect(find.text('Tidak ada transaksi yang cocok.'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'kopi');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Keluar'));
      await tester.pumpAndSettle();

      final last = server.reads.lastWhere(
        (uri) => uri.path.endsWith('/transactions'),
      );
      expect(last.queryParameters, containsPair('q', 'kopi'));
      expect(last.queryParameters, containsPair('type', 'EXPENSE'));
      expect(find.text('Semua kategori'), findsOneWidget);
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

    testWidgets(
      'cukup nominal + kategori: terkirim sebagai Keluar, integer, UTC',
      (tester) async {
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
      },
    );

    testWidgets('dompet awal = dompet transaksi terakhir (D-31)', (
      tester,
    ) async {
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
                'wallet': {
                  'id': 'w2',
                  'name': 'Bank',
                  'icon': 'x',
                  'color': '#14B8A6',
                },
                'category': {
                  'id': 'c1',
                  'name': 'Makan',
                  'icon': 'x',
                  'color': '#F97316',
                },
                'attachments': <Object>[],
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

    testWidgets('error server ditampilkan, data form tetap ada', (
      tester,
    ) async {
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

    testWidgets(
      'Simpan ulang setelah gagal memakai clientId yang sama (D-58)',
      (tester) async {
        final server = formServer();
        server.writeFailure = (
          status: 503,
          body: {
            'error': {
              'code': 'INTERNAL_ERROR',
              'message': 'Terjadi kesalahan di server',
            },
          },
        );
        await pumpRoutedApp(tester, server, routeName: Routes.transactionForm);

        await tester.enterText(field('Nominal'), '25000');
        await tester.tap(find.text('Makan'));
        await tester.pump();
        await tapSave(tester);
        server.writeFailure = null;
        await tapSave(tester);

        expect(server.writes, hasLength(2));
        final first = server.writes.first.body!['clientId'] as String;
        expect(first, isNotEmpty);
        expect(server.writes.last.body!['clientId'], first);
      },
    );

    testWidgets('transfer: dompet sama ditolak, dompet berbeda terkirim', (
      tester,
    ) async {
      final server = formServer();
      await pumpRoutedApp(tester, server, routeName: Routes.transactionForm);

      await tester.tap(find.text('Transfer'));
      await tester.pumpAndSettle();
      await tester.enterText(field('Nominal'), '100000');

      await tapSave(tester);
      expect(find.text('Pilih dompet'), findsOneWidget);

      await tester.tap(
        find.widgetWithText(DropdownButtonFormField<String>, 'Ke dompet'),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cash').last);
      await tester.pumpAndSettle();
      await tapSave(tester);
      expect(find.text('Dompet asal dan tujuan harus berbeda'), findsOneWidget);
      expect(server.writes, isEmpty);

      await tester.tap(
        find.widgetWithText(DropdownButtonFormField<String>, 'Ke dompet'),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bank').last);
      await tester.pumpAndSettle();
      await tapSave(tester);

      final write = server.writes.single;
      expect(write.path, '/transfers');
      expect(write.body, containsPair('fromWalletId', 'w1'));
      expect(write.body, containsPair('toWalletId', 'w2'));
      expect(write.body!.containsKey('categoryId'), isFalse);
      expect(write.body, containsPair('fee', 0));
    });

    testWidgets(
      'transfer: biaya admin, pilihan dompet yang dipotong, dan validasi',
      (tester) async {
        final server = formServer();
        await pumpRoutedApp(tester, server, routeName: Routes.transactionForm);

        await tester.tap(find.text('Transfer'));
        await tester.pumpAndSettle();
        await tester.enterText(field('Nominal'), '15000');
        await tester.tap(
          find.widgetWithText(DropdownButtonFormField<String>, 'Ke dompet'),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Bank').last);
        await tester.pumpAndSettle();

        expect(find.text('Dipotong dari'), findsNothing);
        await tester.enterText(field('Biaya admin (opsional)'), '1000');
        await tester.pump();
        expect(find.text('Diterima: Rp14.000'), findsOneWidget);

        await tester.enterText(field('Biaya admin (opsional)'), '15000');
        await tapSave(tester);
        expect(
          find.text('Biaya admin harus lebih kecil dari nominal transfer'),
          findsOneWidget,
        );
        expect(server.writes, isEmpty);

        await tester.ensureVisible(find.text('Dompet asal'));
        await tester.tap(find.text('Dompet asal'));
        await tester.pump();
        expect(
          find.text('Total keluar dari dompet asal: Rp30.000'),
          findsOneWidget,
        );
        await tapSave(tester);

        final write = server.writes.single;
        expect(write.body, containsPair('fee', 15000));
        expect(write.body, containsPair('feePaidBy', 'FROM'));
      },
    );

    testWidgets('tanpa dompet aktif menampilkan ajakan', (tester) async {
      final server = formServer(
        extra: {
          '/wallets': {'items': <Object>[], 'totalBalance': 0},
        },
      );
      await pumpRoutedApp(tester, server, routeName: Routes.transactionForm);
      expect(
        find.text('Belum ada dompet aktif. Tambah dompet dulu, yuk.'),
        findsOneWidget,
      );
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

    testWidgets('dompet punya transaksi tidak bisa dihapus, bisa diarsipkan', (
      tester,
    ) async {
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
      expect(
        find.text('Dompet masih punya transaksi. Arsipkan saja.'),
        findsOneWidget,
      );

      server.writeFailure = null;
      await tester.ensureVisible(find.text('Arsipkan'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Arsipkan'));
      await tester.pumpAndSettle();
      expect(server.writes.last.body, {'isArchived': true});
    });
  });

  group('Kategori', () {
    testWidgets('bawaan: nama terkunci dan tidak ada tombol hapus', (
      tester,
    ) async {
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
