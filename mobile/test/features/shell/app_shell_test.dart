import 'package:direkapin/core/router/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Tema polos: google_fonts butuh jaringan, yang tidak ada di test.
  Widget app() => ProviderScope(
    child: Consumer(
      builder: (context, ref, _) =>
          MaterialApp.router(routerConfig: ref.watch(appRouterProvider)),
    ),
  );

  testWidgets('mulai di Beranda dengan 4 tab', (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.byType(NavigationDestination), findsNWidgets(4));
    expect(find.widgetWithText(AppBar, 'Beranda'), findsOneWidget);
  });

  testWidgets('tap tab berpindah layar', (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    for (final tab in ['Kalender', 'Laporan', 'Profil', 'Beranda']) {
      await tester.tap(find.widgetWithText(NavigationDestination, tab));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, tab), findsOneWidget);
    }
  });
}
