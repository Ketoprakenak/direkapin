import 'dart:convert';
import 'dart:io';

import 'package:direkapin/core/media/photo_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../helpers/fake_server.dart';

Map<String, Object> _me({required bool hasAvatar}) => {
  'id': 'u1',
  'name': 'Desta',
  'email': 'd@x.com',
  'timezone': 'Asia/Jakarta',
  'reminderTime': '21:00',
  'hasAvatar': hasAvatar,
  'createdAt': '2026-11-01T00:00:00.000Z',
};

class _FakePhotos implements PhotoService {
  _FakePhotos(this.path);

  final String path;

  @override
  Future<({List<String> paths, int skipped})> pick(
    ImageSource source, {
    required int limit,
  }) async => (paths: [path], skipped: 0);
}

late String _photoPath;

final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
);

Future<void> _openProfile(WidgetTester tester, FakeServer server) async {
  tester.view.physicalSize = const Size(1080, 3000);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.reset);
  await pumpRoutedApp(
    tester,
    server,
    routeName: null,
    photoService: _FakePhotos(_photoPath),
  );
  await tester.tap(find.widgetWithText(NavigationDestination, 'Profil'));
  await tester.pumpAndSettle();
}

Future<void> _openSheet(WidgetTester tester) async {
  await tester.tap(find.bySemanticsLabel('Ubah foto profil'));
  await tester.pumpAndSettle();
}

ImageProvider? _avatarImage(WidgetTester tester) =>
    tester.widget<CircleAvatar>(find.byType(CircleAvatar)).backgroundImage;

void main() {
  setUpAll(() {
    final dir = Directory.systemTemp.createTempSync('avatar_test');
    _photoPath = '${dir.path}/pic.jpg';
    File(_photoPath).writeAsBytesSync([1, 2, 3]);
    return initializeDateFormatting('id_ID');
  });

  testWidgets('tanpa foto: inisial tampil, sheet punya 2 pilihan', (
    tester,
  ) async {
    await _openProfile(tester, FakeServer({'/me': _me(hasAvatar: false)}));
    expect(find.text('D'), findsOneWidget);
    expect(_avatarImage(tester), isNull);
    await _openSheet(tester);
    expect(find.text('Ambil foto'), findsOneWidget);
    expect(find.text('Pilih dari galeri'), findsOneWidget);
    expect(find.text('Hapus foto'), findsNothing);
  });

  testWidgets('ada foto: gambar tampil, sheet punya 3 pilihan', (tester) async {
    final server = FakeServer({
      '/me': _me(hasAvatar: true),
      '/me/avatar': _png,
    });
    await _openProfile(tester, server);
    expect(_avatarImage(tester), isA<MemoryImage>());
    expect(find.text('D'), findsNothing);
    await _openSheet(tester);
    expect(find.text('Ambil foto'), findsOneWidget);
    expect(find.text('Pilih dari galeri'), findsOneWidget);
    expect(find.text('Hapus foto'), findsOneWidget);
  });

  testWidgets('gagal memuat foto: kembali ke inisial', (tester) async {
    final server = FakeServer({'/me': _me(hasAvatar: true), '/me/avatar': 500});
    await _openProfile(tester, server);
    expect(find.text('D'), findsOneWidget);
  });

  testWidgets('hapus foto memanggil DELETE lalu kembali ke inisial', (
    tester,
  ) async {
    final responses = <String, Object>{
      '/me': _me(hasAvatar: true),
      '/me/avatar': _png,
    };
    final server = FakeServer(responses);
    await _openProfile(tester, server);
    responses['/me'] = _me(hasAvatar: false);
    await _openSheet(tester);
    await tester.tap(find.text('Hapus foto'));
    await tester.pumpAndSettle();
    expect(
      server.writes.map((w) => '${w.method} ${w.path}'),
      contains('DELETE /me/avatar'),
    );
    expect(find.text('D'), findsOneWidget);
  });

  testWidgets('unggah memanggil PUT /me/avatar lalu memuat ulang profil', (
    tester,
  ) async {
    final server = FakeServer({'/me': _me(hasAvatar: false)});
    await _openProfile(tester, server);
    final meReads = server.reads.where((u) => u.path == '/me').length;
    await _openSheet(tester);
    await tester.tap(find.text('Pilih dari galeri'));
    await tester.pumpAndSettle();
    expect(
      server.writes.map((w) => '${w.method} ${w.path}'),
      contains('PUT /me/avatar'),
    );
    expect(server.reads.where((u) => u.path == '/me').length, meReads + 1);
  });

  testWidgets('unggah gagal menampilkan pesan error server', (tester) async {
    final server = FakeServer({'/me': _me(hasAvatar: false)});
    server.pathFailures['/me/avatar'] = (
      status: 413,
      body: {
        'error': {'code': 'FILE_TOO_LARGE', 'message': 'Foto terlalu besar'},
      },
    );
    await _openProfile(tester, server);
    await _openSheet(tester);
    await tester.tap(find.text('Ambil foto'));
    await tester.pumpAndSettle();
    expect(find.text('Foto terlalu besar'), findsOneWidget);
  });
}
