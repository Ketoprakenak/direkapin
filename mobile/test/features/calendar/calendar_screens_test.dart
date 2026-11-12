import 'package:direkapin/core/format/dates.dart';
import 'package:direkapin/core/router/router.dart';
import 'package:direkapin/core/widgets/frame.dart';
import 'package:direkapin/core/theme/app_theme.dart';
import 'package:direkapin/core/theme/app_themes.dart';
import 'package:direkapin/features/calendar/data/calendar_models.dart';
import 'package:direkapin/features/calendar/presentation/widgets/calendar_cell.dart';
import 'package:direkapin/features/transaction/data/transaction_models.dart';
import 'package:direkapin/features/wallet/data/wallet_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../helpers/fake_server.dart';

void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));

  const walletRefJson = {
    'id': 'w1',
    'name': 'Cash',
    'icon': 'x',
    'color': '#14B8A6',
  };
  const bankRefJson = {
    'id': 'w2',
    'name': 'OVO',
    'icon': 'x',
    'color': '#3B82F6',
  };
  const categoryRefJson = {
    'id': 'c1',
    'name': 'Makan',
    'icon': 'x',
    'color': '#F97316',
  };

  Map<String, Object?> transactionJson({String? note}) => {
    'id': 't1',
    'type': 'EXPENSE',
    'amount': 25000,
    'occurredAt': '2026-11-04T02:30:00.000Z',
    'note': note,
    'wallet': walletRefJson,
    'category': categoryRefJson,
    'attachments': <Object>[],
    'createdAt': '2026-11-04T02:30:00.000Z',
    'updatedAt': '2026-11-04T02:30:00.000Z',
  };

  const transferJson = {
    'id': 'x1',
    'fromWallet': bankRefJson,
    'toWallet': walletRefJson,
    'amount': 100000,
    'occurredAt': '2026-11-04T03:00:00.000Z',
    'note': null,
  };

  Map<String, Object?> dayJson({
    List<Object> transactions = const [],
    List<Object> transfers = const [],
    List<Object> activities = const [],
    int expense = 0,
  }) => {
    'date': '2026-11-04',
    'income': 0,
    'expense': expense,
    'transactions': transactions,
    'transfers': transfers,
    'activities': activities,
    'note': null,
  };

  Map<String, Object> commonResponses(Map<String, Object?> day) => {
    '/days/2026-11-04': day,
    '/dashboard': dashboardJson(),
    '/wallets': {
      'items': [
        walletJson('w1', 'Cash'),
        walletJson('w2', 'OVO', isArchived: true),
      ],
      'totalBalance': 0,
    },
    '/categories': {
      'items': [categoryJson('c1', 'Makan'), categoryJson('c2', 'Transport')],
    },
  };

  Finder field(String label) => find.widgetWithText(TextFormField, label);

  group('Sel kalender', () {
    Future<void> pumpCell(
      WidgetTester tester,
      CalendarDay? data, {
      bool isToday = false,
      String themeId = 'teal',
    }) => tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(themeById(themeId)),
        home: Scaffold(
          body: CalendarCell(day: 10, isToday: isToday, data: data),
        ),
      ),
    );

    Finder icons() => find.byWidgetPredicate(
      (widget) =>
          widget is Icon &&
          [
            Icons.south_west_rounded,
            Icons.north_east_rounded,
            Icons.event_rounded,
            Icons.star_rounded,
          ].contains(widget.icon),
    );

    Color? dateTint() {
      final box = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration! as BoxDecoration).borderRadius != null &&
            (widget.child is Text),
      );
      if (box.evaluate().isEmpty) return null;
      return ((box.evaluate().single.widget as Container).decoration!
              as BoxDecoration)
          .color;
    }

    testWidgets(
      'ikon sesuai isi, kegiatan penting jadi bintang, total keluar',
      (tester) async {
        await pumpCell(
          tester,
          const CalendarDay(
            date: '2026-11-10',
            income: 5000,
            expense: 25000,
            activityCount: 1,
            hasImportant: true,
          ),
        );
        expect(find.byIcon(Icons.south_west_rounded), findsOneWidget);
        expect(find.byIcon(Icons.north_east_rounded), findsOneWidget);
        expect(find.byIcon(Icons.star_rounded), findsOneWidget);
        expect(find.byIcon(Icons.event_rounded), findsNothing);
        expect(find.text('25rb'), findsOneWidget);
      },
    );

    testWidgets('hanya pengeluaran: satu ikon tanpa bintang', (tester) async {
      await pumpCell(
        tester,
        const CalendarDay(
          date: '2026-11-10',
          income: 0,
          expense: 1000,
          activityCount: 0,
          hasImportant: false,
        ),
      );
      expect(icons(), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsNothing);
    });

    testWidgets('mood mewarnai latar tanggal, tanpa emoji (D-61)', (
      tester,
    ) async {
      await pumpCell(
        tester,
        const CalendarDay(
          date: '2026-11-10',
          income: 0,
          expense: 0,
          activityCount: 0,
          hasImportant: false,
          mood: '😢',
        ),
      );
      expect(find.text('😢'), findsNothing);
      expect(icons(), findsNothing);
      expect(
        dateTint(),
        themeById('teal').colors.moodTints['😢']!.withValues(alpha: 0.35),
      );
      final box = tester.widget<Container>(
        find.ancestor(of: find.text('10'), matching: find.byType(Container)),
      );
      expect(
        (box.decoration! as BoxDecoration).borderRadius,
        BorderRadius.circular(themeById('teal').style.dateRadius),
      );
    });

    const both = CalendarDay(
      date: '2026-11-10',
      income: 5000,
      expense: 25000,
      activityCount: 0,
      hasImportant: false,
    );

    testWidgets('tema dot: lingkaran income/expense, tanpa ikon panah', (
      tester,
    ) async {
      await pumpCell(tester, both, themeId: 'yellow');
      final colors = themeById('yellow').colors;
      expect(find.byIcon(Icons.south_west_rounded), findsNothing);
      expect(find.byIcon(Icons.north_east_rounded), findsNothing);
      for (final c in [colors.income, colors.expense]) {
        expect(
          find.byWidgetPredicate(
            (w) =>
                w is Container &&
                w.decoration is BoxDecoration &&
                (w.decoration! as BoxDecoration).shape == BoxShape.circle &&
                (w.decoration! as BoxDecoration).color == c,
          ),
          findsOneWidget,
        );
      }
    });

    testWidgets('tema bar: persegi panjang income/expense', (tester) async {
      await pumpCell(tester, both, themeId: 'sky');
      final colors = themeById('sky').colors;
      expect(find.byIcon(Icons.south_west_rounded), findsNothing);
      for (final c in [colors.income, colors.expense]) {
        final finder = find.byWidgetPredicate(
          (w) =>
              w is Container &&
              w.decoration is BoxDecoration &&
              (w.decoration! as BoxDecoration).color == c,
        );
        expect(finder, findsOneWidget);
        final size = tester.getSize(finder);
        expect(size.width, greaterThan(size.height));
      }
    });

    testWidgets('tanpa data: tanpa titik dan total', (tester) async {
      await pumpCell(tester, null);
      expect(icons(), findsNothing);
      expect(dateTint(), isNull);
      expect(find.text('10'), findsOneWidget);
    });
  });

  group('Kalender', () {
    testWidgets('penanda bulan ini, tap tanggal membuka Halaman Hari', (
      tester,
    ) async {
      final now = DateTime.now();
      final server = FakeServer({
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
        '/days/${dateKey(now)}': dayJson(expense: 25000),
        '/dashboard': dashboardJson(),
      });
      await pumpRoutedApp(tester, server, routeName: Routes.calendar);

      expect(find.text('25rb'), findsOneWidget);
      expect(find.text(formatMonth(now)), findsOneWidget);
      expect(
        find.ancestor(
          of: find.byType(TableCalendar<void>),
          matching: find.byType(FrameCard),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('${now.day}'));
      await tester.pumpAndSettle();
      expect(find.text(formatLongDate(now)), findsOneWidget);
    });

    testWidgets('bulan kosong menampilkan ajakan', (tester) async {
      final server = FakeServer({
        '/calendar': {'month': '2026-11', 'days': <Object>[]},
        '/dashboard': dashboardJson(),
      });
      await pumpRoutedApp(tester, server, routeName: Routes.calendar);
      await tester.scrollUntilVisible(
        find.text('Bulan ini masih kosong. Yuk, catat yang pertama.'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
    });

    testWidgets('error menampilkan tombol coba lagi', (tester) async {
      final server = FakeServer({
        '/calendar': 500,
        '/dashboard': dashboardJson(),
      });
      await pumpRoutedApp(tester, server, routeName: Routes.calendar);
      await tester.scrollUntilVisible(
        find.text('Coba lagi'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
    });
  });

  group('Halaman Hari', () {
    Future<void> pumpDay(WidgetTester tester, FakeServer server) =>
        pumpRoutedApp(
          tester,
          server,
          routeName: Routes.day,
          pathParameters: {'date': '2026-11-04'},
        );

    testWidgets('mood: pilih tersimpan, tap lagi menghapus (ACT-05)', (
      tester,
    ) async {
      final server = FakeServer(commonResponses(dayJson()));
      await pumpDay(tester, server);

      await tester.tap(find.text('😄'));
      await tester.pumpAndSettle();
      expect(server.writes.last.method, 'PUT');
      expect(server.writes.last.path, '/days/2026-11-04/note');
      expect(server.writes.last.body, {'mood': '😄'});

      await tester.tap(find.text('😄'));
      await tester.pumpAndSettle();
      expect(server.writes.last.body, {'mood': null});
    });

    testWidgets('kosong menampilkan ajakan', (tester) async {
      await pumpDay(tester, FakeServer(commonResponses(dayJson())));
      expect(
        find.text(
          'Belum ada catatan hari ini. Mulai dari pengeluaran pertamamu.',
        ),
        findsOneWidget,
      );
      expect(find.text('Rabu, 4 November 2026'), findsOneWidget);
    });

    testWidgets('menampilkan kegiatan penting, transaksi, dan transfer', (
      tester,
    ) async {
      final server = FakeServer(
        commonResponses(
          dayJson(
            expense: 25000,
            transactions: [transactionJson()],
            transfers: [transferJson],
            activities: [
              {
                'id': 'a1',
                'title': 'Wisuda',
                'date': '2026-11-04',
                'time': '08:00',
                'location': null,
                'description': null,
                'isImportant': true,
                'attachments': <Object>[],
                'createdAt': '2026-11-04T02:30:00.000Z',
                'updatedAt': '2026-11-04T02:30:00.000Z',
              },
            ],
          ),
        ),
      );
      await pumpDay(tester, server);

      // Ringkasan + Kegiatan + Transaksi + Transfer.
      expect(find.byType(FrameCard), findsAtLeastNWidgets(4));
      expect(find.text('Wisuda'), findsOneWidget);
      expect(find.text('08.00'), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
      expect(find.text('Makan'), findsOneWidget);
      expect(find.text('−Rp25.000'), findsNWidgets(2));
      expect(find.text('OVO ke Cash'), findsOneWidget);
    });

    testWidgets('error dan coba lagi', (tester) async {
      final responses = commonResponses(dayJson());
      responses['/days/2026-11-04'] = 500;
      final server = FakeServer(responses);
      await pumpDay(tester, server);
      expect(find.text('Terjadi kesalahan di server'), findsOneWidget);

      server.responses['/days/2026-11-04'] = dayJson();
      await tester.tap(find.text('Coba lagi'));
      await tester.pumpAndSettle();
      expect(find.text('Terjadi kesalahan di server'), findsNothing);
    });

    testWidgets('tambah dari Halaman Hari memakai tanggal itu', (tester) async {
      final server = FakeServer(commonResponses(dayJson()));
      await pumpDay(tester, server);
      await tester.tap(find.byTooltip('Tambah'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Transaksi'));
      await tester.pumpAndSettle();
      expect(find.text('Rabu, 4 November 2026'), findsWidgets);

      await tester.enterText(field('Nominal'), '1000');
      await tester.tap(find.text('Makan'));
      await tester.pump();
      await tester.ensureVisible(find.text('Simpan'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      final local = DateTime.parse(
        server.writes.single.body!['occurredAt'] as String,
      ).toLocal();
      expect(dateKey(local), '2026-11-04');
    });
  });

  group('Detail dan edit', () {
    Future<void> pumpDetail(
      WidgetTester tester,
      FakeServer server,
      Transaction transaction,
    ) => pumpRoutedApp(
      tester,
      server,
      routeName: Routes.transactionDetail,
      extra: transaction,
    );

    testWidgets(
      'edit: terisi data lama, pindah tanggal terkirim, lalu kembali',
      (tester) async {
        final server = FakeServer(commonResponses(dayJson()));
        await pumpDetail(
          tester,
          server,
          Transaction.fromJson(transactionJson(note: 'nasi goreng')),
        );

        expect(find.text('nasi goreng'), findsOneWidget);
        await tester.tap(find.text('Ubah'));
        await tester.pumpAndSettle();

        expect(find.text('Ubah transaksi'), findsOneWidget);
        expect(find.text('25.000'), findsOneWidget);
        expect(find.text('nasi goreng'), findsOneWidget);

        await tester.enterText(field('Nominal'), '30000');
        await tester.enterText(field('Catatan (opsional)'), '');
        await tester.ensureVisible(find.text('Simpan'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Simpan'));
        await tester.pumpAndSettle();

        final write = server.writes.single;
        expect(write.method, 'PATCH');
        expect(write.path, '/transactions/t1');
        expect(write.body, containsPair('amount', 30000));
        expect(write.body, containsPair('walletId', 'w1'));
        expect(write.body, containsPair('categoryId', 'c1'));
        expect(write.body, containsPair('note', null));
        expect(find.text('Ubah transaksi'), findsNothing);
        expect(find.text('Detail transaksi'), findsNothing);
      },
    );

    testWidgets(
      'kategori tersembunyi yang dipakai tetap muncul, yang lain tidak (D-34)',
      (tester) async {
        final responses = commonResponses(dayJson());
        responses['/categories'] = {
          'items': [
            {...categoryJson('c1', 'Makan'), 'isHidden': true},
            {...categoryJson('c9', 'Hiburan'), 'isHidden': true},
            categoryJson('c2', 'Transport'),
          ],
        };
        await pumpDetail(
          tester,
          FakeServer(responses),
          Transaction.fromJson(transactionJson()),
        );
        await tester.tap(find.text('Ubah'));
        await tester.pumpAndSettle();

        expect(find.text('Makan'), findsOneWidget);
        expect(find.text('Transport'), findsOneWidget);
        expect(find.text('Hiburan'), findsNothing);
      },
    );

    testWidgets('dompet arsip yang dipakai tetap jadi pilihan (D-34)', (
      tester,
    ) async {
      final json = transactionJson();
      json['wallet'] = bankRefJson;
      final server = FakeServer(commonResponses(dayJson()));
      await pumpDetail(tester, server, Transaction.fromJson(json));
      await tester.tap(find.text('Ubah'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Simpan'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(server.writes.single.body, containsPair('walletId', 'w2'));
    });

    testWidgets(
      'hapus minta konfirmasi: batal tidak menghapus, hapus mengirim DELETE',
      (tester) async {
        final server = FakeServer(commonResponses(dayJson()));
        await pumpDetail(
          tester,
          server,
          Transaction.fromJson(transactionJson()),
        );

        await tester.tap(find.text('Hapus'));
        await tester.pumpAndSettle();
        expect(
          find.text('Hapus transaksi ini? Foto struknya juga ikut terhapus.'),
          findsOneWidget,
        );
        await tester.tap(find.text('Batal'));
        await tester.pumpAndSettle();
        expect(server.writes, isEmpty);

        await tester.tap(find.text('Hapus'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Hapus').last);
        await tester.pumpAndSettle();

        expect(server.writes.single.method, 'DELETE');
        expect(server.writes.single.path, '/transactions/t1');
        expect(find.text('Transaksi terhapus'), findsOneWidget);
        expect(find.text('Detail transaksi'), findsNothing);
      },
    );

    testWidgets('gagal hapus tetap di detail dengan pesan server', (
      tester,
    ) async {
      final server = FakeServer(commonResponses(dayJson()));
      server.writeFailure = (
        status: 404,
        body: {
          'error': {'code': 'NOT_FOUND', 'message': 'Data tidak ditemukan'},
        },
      );
      await pumpDetail(tester, server, Transaction.fromJson(transactionJson()));
      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hapus').last);
      await tester.pumpAndSettle();

      expect(find.text('Data tidak ditemukan'), findsOneWidget);
      expect(find.text('Detail transaksi'), findsOneWidget);
    });

    testWidgets('edit transfer mengirim PATCH /transfers', (tester) async {
      final server = FakeServer(commonResponses(dayJson()));
      await pumpRoutedApp(
        tester,
        server,
        routeName: Routes.transferDetail,
        extra: Transfer.fromJson(transferJson),
      );
      await tester.tap(find.text('Ubah'));
      await tester.pumpAndSettle();
      expect(find.text('Ubah transfer'), findsOneWidget);

      await tester.enterText(field('Nominal'), '50000');
      await tester.ensureVisible(find.text('Simpan'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      final write = server.writes.single;
      expect(write.path, '/transfers/x1');
      expect(write.body, containsPair('amount', 50000));
      expect(write.body, containsPair('fromWalletId', 'w2'));
      expect(write.body, containsPair('toWalletId', 'w1'));
    });
  });
}
