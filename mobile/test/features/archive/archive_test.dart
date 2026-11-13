import 'dart:io';

import 'package:direkapin/core/router/router.dart';
import 'package:direkapin/core/widgets/frame.dart';
import 'package:direkapin/features/archive/data/archive_models.dart';
import 'package:direkapin/features/archive/providers/archive_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

Map<String, Object?> _archive(
  String status, {
  String id = 'a1',
  String month = '2026-09',
  int photoCount = 12,
  int sizeBytes = 3565158,
}) => {
  'id': id,
  'month': month,
  'sizeBytes': sizeBytes,
  'photoCount': photoCount,
  'status': status,
  'createdAt': DateTime.now()
      .subtract(const Duration(days: 10))
      .toUtc()
      .toIso8601String(),
  'expiresAt': DateTime.now()
      .add(const Duration(days: 20))
      .toUtc()
      .toIso8601String(),
  'downloadedAt': null,
};

FakeServer _server(List<Map<String, Object?>> items) => FakeServer({
  '/me': _me,
  '/dashboard': dashboardJson(),
  '/archives': {'items': items},
});

class _FakeFiles extends ArchiveFiles {
  final saved = <String>[];
  Object? saveError;
  late String lastTemp;

  @override
  Future<String> tempPath(String fileName) async =>
      lastTemp = '${Directory.systemTemp.path}/direkapin_test_$fileName';

  @override
  Future<void> saveToDownloads(
    String path,
    String fileName, {
    String mimeType = 'application/zip',
  }) async {
    if (saveError != null) throw saveError!;
    saved.add(fileName);
  }
}

Future<void> _openArchives(
  WidgetTester tester,
  FakeServer server, {
  _FakeFiles? files,
  FakeReminderService? reminders,
}) => pumpRoutedApp(
  tester,
  server,
  routeName: Routes.archives,
  reminders: reminders,
  overrides: [if (files != null) archiveFilesProvider.overrideWithValue(files)],
);

/// File I/O sungguhan macet di waktu palsu test, jadi download harus dimulai di waktu nyata.
Future<void> _tapDownload(WidgetTester tester) async {
  await tester.runAsync(() async {
    await tester.tap(find.text('Download arsip'));
    await Future<void>.delayed(const Duration(milliseconds: 500));
  });
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));

  test('daysUntil membulatkan ke atas dan tidak negatif', () {
    final now = DateTime.utc(2026, 11, 1);
    expect(daysUntil(now.add(const Duration(days: 20)), now), 20);
    expect(daysUntil(now.add(const Duration(hours: 1)), now), 1);
    expect(daysUntil(now.subtract(const Duration(days: 1)), now), 0);
  });

  test('formatSize memakai KB dan MB bergaya Indonesia', () {
    expect(formatSize(1500), '2 KB');
    expect(formatSize(3565158), '3,4 MB');
  });

  group('S-13 Arsip', () {
    testWidgets('kosong', (tester) async {
      await _openArchives(tester, _server([]));
      expect(find.textContaining('Belum ada arsip'), findsOneWidget);
    });

    testWidgets('error punya tombol coba lagi', (tester) async {
      await _openArchives(
        tester,
        FakeServer({
          '/me': _me,
          '/dashboard': dashboardJson(),
          '/archives': 500,
        }),
      );
      expect(find.text('Coba lagi'), findsOneWidget);
    });

    testWidgets('menampilkan isi dan status tiap arsip', (tester) async {
      await _openArchives(
        tester,
        _server([
          _archive('READY'),
          _archive('DOWNLOADED', id: 'a2', month: '2026-08'),
          _archive('EXPIRED', id: 'a3', month: '2026-07'),
          _archive(
            'FAILED',
            id: 'a4',
            month: '2026-06',
            photoCount: 0,
            sizeBytes: 0,
          ),
        ]),
      );

      expect(find.text('September 2026'), findsOneWidget);
      expect(find.text('12 foto · 3,4 MB'), findsNWidgets(3));
      expect(find.text('Foto asli dihapus dalam 20 hari'), findsOneWidget);
      expect(find.textContaining('Sudah di-download'), findsOneWidget);
      expect(find.textContaining('ZIP sudah dihapus'), findsOneWidget);
      expect(find.textContaining('dicoba lagi besok'), findsOneWidget);
      // Hanya arsip yang masih punya ZIP yang bisa di-download.
      expect(find.text('Download arsip'), findsOneWidget);
      expect(find.text('Download lagi'), findsOneWidget);
    });

    testWidgets(
      'download sukses: disimpan, temp dihapus, daftar dimuat ulang',
      (tester) async {
        final files = _FakeFiles();
        final server = _server([_archive('READY')]);
        await _openArchives(tester, server, files: files);
        server.responses['/archives'] = {
          'items': [_archive('DOWNLOADED')],
        };

        await _tapDownload(tester);

        expect(files.saved, ['direkapin-arsip-2026-09.zip']);
        expect(File(files.lastTemp).existsSync(), isFalse);
        expect(
          find.text('Arsip tersimpan di Download/Direkapin'),
          findsOneWidget,
        );
        expect(find.text('Download lagi'), findsOneWidget);
      },
    );

    testWidgets('izin ditolak: pesan jelas, tombol kembali', (tester) async {
      final files = _FakeFiles()
        ..saveError = PlatformException(code: 'permission_denied');
      await _openArchives(tester, _server([_archive('READY')]), files: files);

      await _tapDownload(tester);

      expect(find.textContaining('Izin penyimpanan ditolak'), findsOneWidget);
      expect(find.text('Download arsip'), findsOneWidget);
      expect(File(files.lastTemp).existsSync(), isFalse);
    });

    testWidgets('server menolak (410): pesan server tampil', (tester) async {
      final files = _FakeFiles();
      final server = _server([_archive('READY')]);
      server.errors['/archives/a1/download'] = (
        status: 410,
        body: {
          'error': {
            'code': 'ARCHIVE_EXPIRED',
            'message': 'Arsip sudah kedaluwarsa',
          },
        },
      );
      await _openArchives(tester, server, files: files);

      await _tapDownload(tester);

      expect(find.text('Arsip sudah kedaluwarsa'), findsOneWidget);
      expect(files.saved, isEmpty);
    });
  });

  group('notifikasi arsip', () {
    testWidgets('hanya arsip READY yang dijadwalkan', (tester) async {
      final reminders = FakeReminderService();
      await pumpRoutedApp(
        tester,
        _server([
          _archive('READY'),
          _archive('DOWNLOADED', id: 'a2', month: '2026-08'),
        ]),
        routeName: Routes.profile,
        reminders: reminders,
      );
      expect(reminders.archiveSyncs.last.map((a) => a.id), ['a1']);
      expect(reminders.archiveTimezones.last, 'Asia/Jakarta');
    });

    testWidgets('/archives gagal: jadwal lama tidak disentuh', (tester) async {
      final reminders = FakeReminderService();
      await pumpRoutedApp(
        tester,
        FakeServer({
          '/me': _me,
          '/dashboard': dashboardJson(),
          '/archives': 500,
        }),
        routeName: Routes.profile,
        reminders: reminders,
      );
      expect(reminders.archiveSyncs, isEmpty);
    });

    testWidgets('dibuka dari notifikasi arsip: masuk layar Arsip', (
      tester,
    ) async {
      await pumpRoutedApp(
        tester,
        _server([]),
        routeName: null,
        reminders: FakeReminderService()..launchedPayload = 'archive',
      );
      final router = ProviderScope.containerOf(
        tester.element(find.byType(Scaffold).first),
      ).read(appRouterProvider);
      expect(router.state.uri.path, '/arsip');
    });

    testWidgets('tap notifikasi arsip saat aplikasi berjalan', (tester) async {
      final reminders = FakeReminderService();
      await pumpRoutedApp(
        tester,
        _server([]),
        routeName: null,
        reminders: reminders,
      );
      reminders.onTap!('archive');
      await tester.pumpAndSettle();
      final router = ProviderScope.containerOf(
        tester.element(find.byType(Scaffold).first),
      ).read(appRouterProvider);
      expect(router.state.uri.path, '/arsip');
    });
  });

  group('S-14 Profil', () {
    testWidgets('menampilkan nama, email, dan menu Arsip', (tester) async {
      await pumpRoutedApp(tester, _server([]), routeName: Routes.profile);
      expect(find.text('Desta'), findsOneWidget);
      expect(find.text('d@x.com'), findsOneWidget);
      expect(find.text('D'), findsOneWidget);
      // Grup header + pengingat, dan grup menu.
      expect(find.byType(FrameCard), findsNWidgets(2));

      await tester.ensureVisible(find.text('Arsip foto'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Arsip foto'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Belum ada arsip'), findsOneWidget);
    });

    testWidgets('profil gagal dimuat bisa dicoba lagi', (tester) async {
      await pumpRoutedApp(
        tester,
        FakeServer({'/me': 500, '/dashboard': dashboardJson()}),
        routeName: Routes.profile,
      );
      expect(find.text('Profil gagal dimuat'), findsOneWidget);
    });

    testWidgets('ubah nama mengirim PATCH', (tester) async {
      final server = _server([]);
      await pumpRoutedApp(tester, server, routeName: Routes.profile);

      await tester.tap(find.byTooltip('Ubah nama'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '  Budi  ');
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(server.writes.single.method, 'PATCH');
      expect(server.writes.single.body, {'name': 'Budi'});
    });

    testWidgets('nama terlalu pendek ditolak di form', (tester) async {
      final server = _server([]);
      await pumpRoutedApp(tester, server, routeName: Routes.profile);

      await tester.tap(find.byTooltip('Ubah nama'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'B');
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(find.text('Nama 2 sampai 50 karakter'), findsOneWidget);
      expect(server.writes, isEmpty);
    });

    testWidgets('ubah nama gagal menampilkan pesan server', (tester) async {
      final server = _server([])..failingPaths.add('/me');
      await pumpRoutedApp(tester, server, routeName: Routes.profile);

      await tester.tap(find.byTooltip('Ubah nama'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Budi');
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(find.text('Terjadi kesalahan di server'), findsOneWidget);
    });
  });
}
