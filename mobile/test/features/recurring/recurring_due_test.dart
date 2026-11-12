import 'dart:async';

import 'package:direkapin/core/widgets/frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../helpers/fake_server.dart';
import '../../helpers/recurring_fixtures.dart';

void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));

  Map<String, Object?> dueJson() => {
    'recurring': recurringJson(),
    'month': '2026-11',
    'dueDate': '2026-11-05',
  };

  FakeServer serverWith(Object due) =>
      FakeServer({'/dashboard': dashboardJson(), '/recurring/due': due})
        ..writeResponses['/recurring/r1/record'] = {
          'id': 't1',
          'type': 'EXPENSE',
          'amount': 150000,
          'occurredAt': '2026-11-05T05:00:00Z',
          'note': null,
          'wallet': recurringJson()['wallet']!,
          'category': recurringJson()['category']!,
          'attachments': <Object>[],
        };

  Finder dueCard() => find.widgetWithText(FrameCard, 'Jatuh tempo');
  int reads(FakeServer s, String path) =>
      s.reads.where((u) => u.path == path).length;
  void tall(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Map<String, Object?> items() => {
    'items': [dueJson()],
  };

  testWidgets('tanpa due: kartu tidak tampil', (tester) async {
    await pumpRoutedApp(
      tester,
      serverWith({'items': <Object>[]}),
      routeName: null,
    );
    expect(dueCard(), findsNothing);
  });

  testWidgets('error memuat due: kartu tersembunyi, Beranda jalan', (
    tester,
  ) async {
    await pumpRoutedApp(tester, serverWith(500), routeName: null);
    expect(dueCard(), findsNothing);
    expect(find.text('Pengeluaran 7 hari'), findsOneWidget);
  });

  testWidgets('Catat: sheet, simpan, POST record, refresh', (tester) async {
    final server = serverWith(items());
    tall(tester);
    await pumpRoutedApp(tester, server, routeName: null);
    expect(dueCard(), findsOneWidget);
    expect(find.text('Listrik'), findsOneWidget);
    expect(find.textContaining('5 November 2026'), findsOneWidget);
    final before = reads(server, '/dashboard');

    await tester.tap(find.text('Catat'));
    await tester.pumpAndSettle();
    expect(find.text('150.000'), findsOneWidget);
    server.responses['/recurring/due'] = {'items': <Object>[]};
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(dueCard(), findsNothing);

    final write = server.writes.single;
    expect(write.path, '/recurring/r1/record');
    expect(write.body!['month'], '2026-11');
    expect(write.body!['amount'], 150000);
    expect(
      DateTime.parse(write.body!['occurredAt'] as String).toLocal().day,
      5,
    );
    expect(reads(server, '/dashboard'), greaterThan(before));
  });

  Future<void> confirmSkip(WidgetTester tester) async {
    await tester.tap(find.text('Lewati'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Lewati'),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Lewati: konfirmasi lalu POST skip', (tester) async {
    final server = serverWith(items());
    tall(tester);
    await pumpRoutedApp(tester, server, routeName: null);
    await confirmSkip(tester);
    expect(server.writes.single.path, '/recurring/r1/skip');
    expect(server.writes.single.body, {'month': '2026-11'});
  });

  testWidgets('409: SnackBar pesan server dan daftar di-refresh', (
    tester,
  ) async {
    final server = serverWith(items())
      ..pathFailures['/recurring/r1/skip'] = (
        status: 409,
        body: {
          'error': {'code': 'CONFLICT', 'message': 'Sudah diproses'},
        },
      );
    tall(tester);
    await pumpRoutedApp(tester, server, routeName: null);
    final before = reads(server, '/recurring/due');
    await confirmSkip(tester);
    expect(find.text('Sudah diproses'), findsOneWidget);
    expect(reads(server, '/recurring/due'), greaterThan(before));
  });

  testWidgets('ketukan ganda Lewati: hanya satu dialog dan satu request', (
    tester,
  ) async {
    final server = serverWith(items());
    tall(tester);
    await pumpRoutedApp(tester, server, routeName: null);
    expect(find.bySemanticsLabel(RegExp('Lewati Listrik')), findsOneWidget);
    await tester.tap(find.text('Lewati'));
    await tester.tap(find.text('Lewati'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.textContaining('November 2026?'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Lewati'),
      ),
    );
    await tester.pumpAndSettle();
    expect(server.writes, hasLength(1));
  });

  testWidgets('ketukan ganda Simpan: satu pop, satu request', (tester) async {
    final server = serverWith(items());
    tall(tester);
    await pumpRoutedApp(tester, server, routeName: null);
    await tester.tap(find.text('Catat'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan'));
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(server.writes, hasLength(1));
    // Beranda tetap tampil (rute di bawah sheet tidak ikut ter-pop).
    expect(find.text('Pengeluaran 7 hari'), findsOneWidget);
  });

  testWidgets('400 walletId: SnackBar dompet diarsipkan', (tester) async {
    final server = serverWith(items())
      ..pathFailures['/recurring/r1/record'] = (
        status: 400,
        body: {
          'error': {
            'code': 'VALIDATION_ERROR',
            'message': 'Data belum valid',
            'details': {'walletId': 'Pilih dompet'},
          },
        },
      );
    tall(tester);
    await pumpRoutedApp(tester, server, routeName: null);
    await tester.tap(find.text('Catat'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(
      find.text('Dompet aturan sudah diarsipkan. Ubah aturan dulu.'),
      findsOneWidget,
    );
  });

  testWidgets('tarik untuk menyegarkan memuat ulang /recurring/due', (
    tester,
  ) async {
    final server = serverWith(items());
    tall(tester);
    await pumpRoutedApp(tester, server, routeName: null);
    final before = reads(server, '/recurring/due');
    unawaited(
      tester.state<RefreshIndicatorState>(find.byType(RefreshIndicator)).show(),
    );
    await tester.pumpAndSettle();
    expect(reads(server, '/recurring/due'), greaterThan(before));
  });
}
