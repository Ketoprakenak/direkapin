import 'package:direkapin/core/router/router.dart';
import 'package:direkapin/core/widgets/frame.dart';
import 'package:direkapin/core/theme/app_theme.dart';
import 'package:direkapin/core/theme/app_themes.dart';
import 'package:direkapin/core/widgets/mascot.dart';
import 'package:direkapin/features/settings/presentation/theme_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../helpers/fake_server.dart';

const _me = {
  'id': 'u1',
  'name': 'Desta',
  'email': 'd@x.com',
  'timezone': 'Asia/Jakarta',
  'reminderTime': '21:00',
  'hasAvatar': false,
  'createdAt': '2026-11-01T00:00:00.000Z',
};

void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));

  testWidgets(
    'Profil: baris Tema menampilkan tema aktif dan membuka layar Tema',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 3000);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);
      await pumpRoutedApp(tester, FakeServer({'/me': _me}), routeName: null);
      await tester.tap(find.widgetWithText(NavigationDestination, 'Profil'));
      await tester.pumpAndSettle();
      expect(find.text('Tema'), findsOneWidget);
      expect(find.text('Teal'), findsOneWidget);
      await tester.tap(find.text('Tema'));
      await tester.pumpAndSettle();
      expect(find.text('Kuning pastel'), findsOneWidget);
    },
  );

  testWidgets('layar Tema: 7 kartu, tap Lavender tersimpan, centang pindah', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);
    await pumpRoutedApp(tester, FakeServer({}), routeName: Routes.themes);
    expect(find.byType(Mascot), findsNWidgets(7));
    expect(find.byType(FrameCard), findsNWidgets(7));
    await tester.tap(find.text('Lavender'));
    await tester.pumpAndSettle();
    expect(await const FlutterSecureStorage().read(key: 'theme'), 'lavender');
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    expect(
      find.descendant(
        of: find.ancestor(
          of: find.text('Lavender'),
          matching: find.byType(InkWell),
        ),
        matching: find.byIcon(Icons.check_circle_rounded),
      ),
      findsOneWidget,
    );
  });

  testWidgets('ganti tema mengubah Theme app', (tester) async {
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);
    await pumpRoutedApp(tester, FakeServer({}), routeName: Routes.themes);
    expect(
      Theme.of(tester.element(find.byType(Scaffold).last)).brightness,
      Brightness.light,
    );
    await tester.tap(find.text('Gelap'));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.byType(Scaffold).last)).brightness,
      Brightness.dark,
    );
  });

  testWidgets('tiap kartu memakai warna temanya sendiri', (tester) async {
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);
    await pumpRoutedApp(tester, FakeServer({}), routeName: Routes.themes);
    for (final id in ['yellow', 'dark']) {
      final t = themeById(id);
      final mascot = find.descendant(
        of: find.ancestor(
          of: find.text(t.name),
          matching: find.byType(InkWell),
        ),
        matching: find.byType(Mascot),
      );
      expect(
        Theme.of(tester.element(mascot)).colorScheme.primary,
        t.scheme.primary,
      );
    }
  });

  testWidgets('teks besar 1.5x tidak meluap', (tester) async {
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);
    FlutterSecureStorage.setMockInitialValues({'refreshToken': 'r'});
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
        child: ProviderScope(
          child: MaterialApp(
            theme: buildTheme(appThemes.first),
            home: const ThemeScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
