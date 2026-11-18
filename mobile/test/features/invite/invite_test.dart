import 'package:direkapin/core/router/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../helpers/fake_server.dart';

Map<String, Object> _me({required bool isOwner}) => {
  'id': 'u1',
  'name': 'Desta',
  'email': 'd@x.com',
  'timezone': 'Asia/Jakarta',
  'reminderTime': '21:00',
  'hasAvatar': false,
  'createdAt': '2026-11-01T00:00:00.000Z',
  'isOwner': isOwner,
};

Map<String, Object?> _invite(
  String code, {
  String expiresAt = '2099-11-24T00:00:00.000Z',
  String? usedByName,
}) => {
  'code': code,
  'createdAt': '2026-11-17T00:00:00.000Z',
  'expiresAt': expiresAt,
  'usedAt': usedByName == null ? null : '2026-11-18T00:00:00.000Z',
  'usedByName': usedByName,
};

void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));

  Future<void> openProfile(WidgetTester tester, FakeServer server) async {
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);
    await pumpRoutedApp(tester, server, routeName: null);
    await tester.tap(find.widgetWithText(NavigationDestination, 'Profil'));
    await tester.pumpAndSettle();
  }

  testWidgets('Profil: baris Kode undangan hanya untuk owner', (tester) async {
    await openProfile(tester, FakeServer({'/me': _me(isOwner: true)}));
    expect(find.text('Kode undangan'), findsOneWidget);
  });

  testWidgets('Profil: bukan owner tanpa baris Kode undangan', (tester) async {
    await openProfile(tester, FakeServer({'/me': _me(isOwner: false)}));
    expect(find.text('Kode undangan'), findsNothing);
  });

  testWidgets('kosong', (tester) async {
    await pumpRoutedApp(
      tester,
      FakeServer({
        '/invites': {'items': <Object>[]},
      }),
      routeName: Routes.invites,
    );
    expect(
      find.text('Belum ada kode. Buat satu buat ngajak teman.'),
      findsOneWidget,
    );
  });

  testWidgets('status kartu dan salin kode', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    await pumpRoutedApp(
      tester,
      FakeServer({
        '/invites': {
          'items': [
            _invite('AAAA1111BBBB2222'),
            _invite('CCCC3333DDDD4444', usedByName: 'Budi'),
            _invite('EEEE5555FFFF6666', expiresAt: '2026-11-10T00:00:00.000Z'),
          ],
        },
      }),
      routeName: Routes.invites,
    );
    expect(find.textContaining('Berlaku sampai'), findsOneWidget);
    expect(find.text('Dipakai Budi'), findsOneWidget);
    expect(find.text('Kedaluwarsa'), findsOneWidget);
    expect(find.byTooltip('Salin kode'), findsOneWidget);

    await tester.tap(find.byTooltip('Salin kode'));
    await tester.pumpAndSettle();
    expect(copied, 'AAAA1111BBBB2222');
    expect(find.text('Kode disalin'), findsOneWidget);
  });

  testWidgets(
    'Buat kode: sekali kirim walau ditap dua kali, daftar dimuat ulang',
    (tester) async {
      final server = FakeServer({
        '/invites': {'items': <Object>[]},
      });
      await pumpRoutedApp(tester, server, routeName: Routes.invites);
      final readsBefore = server.reads
          .where((u) => u.path == '/invites')
          .length;
      await tester.tap(find.text('Buat kode'));
      await tester.tap(find.text('Buat kode'));
      await tester.pumpAndSettle();
      expect(server.writes.map((w) => w.path), ['/invites']);
      expect(
        server.reads.where((u) => u.path == '/invites').length,
        greaterThan(readsBefore),
      );
    },
  );

  testWidgets('bukan owner lewat link langsung: server 404 = ErrorState', (
    tester,
  ) async {
    await pumpRoutedApp(
      tester,
      FakeServer({'/invites': 404}),
      routeName: Routes.invites,
    );
    expect(find.text('Coba lagi'), findsOneWidget);
  });
}
