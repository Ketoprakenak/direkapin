import 'package:direkapin/core/auth/session_provider.dart';
import 'package:direkapin/core/home_widget/today_widget.dart';
import 'package:direkapin/core/theme/app_themes.dart';
import 'package:direkapin/features/settings/providers/settings_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../helpers/fake_server.dart';

FakeServer _server() => FakeServer({
  '/dashboard': dashboardJson(hasEntry: true, todayExpense: 45000),
  '/me': {
    'id': 'u1',
    'name': 'Desta',
    'email': 'd@x.com',
    'timezone': 'Asia/Makassar',
    'reminderTime': '21:00',
    'hasAvatar': false,
    'createdAt': '2026-11-01T00:00:00.000Z',
  },
});

ProviderContainer _container(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(NavigationBar)));

void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));

  testWidgets('Beranda dimuat → widget dapat angka hari ini + maskot tema', (
    tester,
  ) async {
    final widget = FakeTodayWidgetService();
    await pumpRoutedApp(
      tester,
      _server(),
      routeName: null,
      todayWidget: widget,
    );

    expect(widget.saves, isNotEmpty);
    expect(widget.saves.last, containsPair('date', '2026-11-04'));
    expect(widget.saves.last, containsPair('expense', '−Rp45.000'));
    expect(widget.saves.last, containsPair('mascot', '/widget/mascot.png'));
    expect(widget.saves.last, containsPair('image', null));
    expect(widget.saves.last.containsKey('totalBalance'), isFalse);
    // Widget membandingkan tanggal di zona waktu profil, bukan zona HP.
    expect(widget.saves.last, containsPair('timezone', 'Asia/Makassar'));
    expect(widget.mascots.last, (theme: 'teal', happy: true));
  });

  testWidgets('ada foto sendiri → foto jadi latar, maskot tidak dirender', (
    tester,
  ) async {
    final widget = FakeTodayWidgetService()..photo = '/widget/photo.png';
    await pumpRoutedApp(
      tester,
      _server(),
      routeName: null,
      todayWidget: widget,
    );

    expect(widget.saves.last, containsPair('image', '/widget/photo.png'));
    expect(widget.saves.last, containsPair('mascot', null));
    expect(widget.mascots, isEmpty);
  });

  testWidgets('ganti tema → widget ikut warna dan maskot tema baru', (
    tester,
  ) async {
    final widget = FakeTodayWidgetService();
    await pumpRoutedApp(
      tester,
      _server(),
      routeName: null,
      todayWidget: widget,
    );

    final dark = themeById('dark');
    await _container(tester).read(appThemeChoiceProvider.notifier).set(dark);
    await tester.pumpAndSettle();

    expect(
      widget.saves.last,
      containsPair('surface', argbHex(dark.scheme.surface)),
    );
    expect(widget.mascots.last.theme, 'dark');
  });

  testWidgets('plugin widget gagal → Beranda tetap tampil', (tester) async {
    final widget = FakeTodayWidgetService()..failure = Exception('plugin');
    await pumpRoutedApp(
      tester,
      _server(),
      routeName: null,
      todayWidget: widget,
    );

    expect(
      find.widgetWithText(NavigationDestination, 'Beranda'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('keluar akun → data widget dikosongkan', (tester) async {
    final widget = FakeTodayWidgetService();
    await pumpRoutedApp(
      tester,
      _server(),
      routeName: null,
      todayWidget: widget,
    );

    _container(tester).read(sessionProvider.notifier).markLoggedOut();
    await tester.pumpAndSettle();

    expect(widget.clears, 1);
  });

  testWidgets('dibuka dari tombol + widget → form Catat', (tester) async {
    final widget = FakeTodayWidgetService()
      ..launchUri = Uri.parse('direkapin://catat');
    await pumpRoutedApp(
      tester,
      _server(),
      routeName: null,
      todayWidget: widget,
    );

    expect(find.text('Tambah transaksi'), findsOneWidget);
  });

  testWidgets('tap widget saat app terbuka: + → form, area lain → tetap', (
    tester,
  ) async {
    final widget = FakeTodayWidgetService();
    await pumpRoutedApp(
      tester,
      _server(),
      routeName: null,
      todayWidget: widget,
    );

    widget.clickController.add(null);
    await tester.pumpAndSettle();
    expect(find.text('Tambah transaksi'), findsNothing);

    widget.clickController.add(Uri.parse('direkapin://catat'));
    await tester.pumpAndSettle();
    expect(find.text('Tambah transaksi'), findsOneWidget);
  });
}
