import 'package:direkapin/core/router/router.dart';
import 'package:direkapin/features/activity/data/activity_models.dart';
import 'package:direkapin/features/attachment/presentation/photo_viewer_screen.dart';
import 'package:direkapin/features/memories/providers/memory_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../helpers/fake_server.dart';

Map<String, Object?> _activity(
  String id,
  int photos, {
  String date = '2026-11-04',
  String? title,
}) => {
  'id': id,
  'title': title ?? 'Kegiatan $id',
  'date': date,
  'isImportant': false,
  'attachments': [
    for (var i = 0; i < photos; i++)
      {
        'id': '$id-$i',
        'thumbUrl': '/attachments/$id-$i?size=thumb',
        'fullUrl': '/attachments/$id-$i?size=full',
        'isArchived': false,
        'width': 800,
        'height': 600,
        'sizeBytes': 1000,
        'createdAt': '2026-11-04T02:30:00.000Z',
      },
  ],
};

FakeServer _server(List<Map<String, Object?>> activities) => FakeServer({
  '/dashboard': dashboardJson(),
  '/activities': {'items': activities},
});

void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));

  test('memoryMonth: 3 hari terakhir s.d. tanggal 7 bulan berikutnya', () {
    String? at(int y, int m, int d) => memoryMonth(DateTime(y, m, d));
    expect(at(2026, 11, 27), isNull);
    expect(at(2026, 11, 28), '2026-11');
    expect(at(2026, 11, 30), '2026-11');
    expect(at(2026, 12, 1), '2026-11');
    expect(at(2026, 12, 7), '2026-11');
    expect(at(2026, 12, 8), isNull);
    expect(at(2027, 1, 3), '2026-12');
    expect(at(2026, 12, 29), '2026-12');
    expect(at(2027, 2, 25), isNull);
    expect(at(2027, 2, 26), '2027-02');
    expect(at(2028, 2, 26), isNull);
    expect(at(2028, 2, 27), '2028-02');
  });

  test('memoryGroups: hanya yang berfoto, terbaru dulu, lalu judul', () {
    final groups = memoryGroups([
      for (final json in [
        _activity('a', 1, date: '2026-11-02'),
        _activity('b', 0, date: '2026-11-20'),
        _activity('c', 2, date: '2026-11-10', title: 'Zumba'),
        _activity('d', 1, date: '2026-11-10', title: 'Arisan'),
      ])
        Activity.fromJson(json),
    ]);
    expect(groups.map((g) => g.activity.id), ['d', 'c', 'a']);
    expect(groups[1].photos, hasLength(2));
  });

  group('Kartu Kenangan di Beranda', () {
    Future<void> pump(WidgetTester tester, FakeServer server, DateTime now) =>
        pumpRoutedApp(
          tester,
          server,
          routeName: null,
          overrides: [memoryNowProvider.overrideWithValue(now)],
        );

    testWidgets('awal bulan: kartu bulan lalu, tap buka galerinya', (
      tester,
    ) async {
      final server = _server([
        _activity('a', 2, date: '2026-11-25', title: 'Camping'),
        _activity('b', 1, date: '2026-11-15', title: 'Seminar'),
      ]);
      await pump(tester, server, DateTime(2026, 12, 2));

      expect(find.text('November kamu'), findsOneWidget);
      expect(find.text('3 foto · 2 kegiatan'), findsOneWidget);
      expect(
        server.reads.any(
          (u) =>
              u.path.endsWith('/activities') &&
              u.queryParameters['from'] == '2026-11-01' &&
              u.queryParameters['to'] == '2026-11-30',
        ),
        isTrue,
      );

      await tester.tap(find.text('November kamu'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Kenangan'), findsOneWidget);
      expect(find.text('November 2026'), findsOneWidget);
      expect(find.textContaining('Camping'), findsOneWidget);
    });

    testWidgets('tombol tutup menyembunyikan kartu bulan itu', (tester) async {
      await pump(tester, _server([_activity('a', 1)]), DateTime(2026, 11, 29));
      expect(find.text('November kamu'), findsOneWidget);

      await tester.tap(find.byTooltip('Tutup kartu Kenangan'));
      await tester.pumpAndSettle();
      expect(find.text('November kamu'), findsNothing);
      expect(
        await const FlutterSecureStorage().read(key: 'memoryDismissed'),
        '2026-11',
      );
    });

    testWidgets('tanpa foto atau di luar jendela: tidak tampil', (
      tester,
    ) async {
      await pump(tester, _server([_activity('a', 0)]), DateTime(2026, 12, 2));
      expect(find.text('November kamu'), findsNothing);

      await pump(tester, _server([_activity('a', 1)]), DateTime(2026, 12, 15));
      expect(find.textContaining('kamu'), findsNothing);
    });
  });

  group('Galeri Kenangan', () {
    testWidgets('grup per kegiatan, tap foto buka layar foto di urutan benar', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 3000);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);
      await pumpRoutedApp(
        tester,
        _server([
          _activity('a', 2, date: '2026-10-25', title: 'Camping'),
          _activity('b', 1, date: '2026-10-15', title: 'Seminar'),
        ]),
        routeName: Routes.memories,
        extra: '2026-10',
      );

      expect(find.text('Oktober 2026'), findsOneWidget);
      expect(find.text('Min, 25 Okt · Camping'), findsOneWidget);
      expect(find.text('Kam, 15 Okt · Seminar'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Foto Seminar 1'));
      await tester.pumpAndSettle();
      final viewer = tester.widget<PhotoViewerScreen>(
        find.byType(PhotoViewerScreen),
      );
      expect(viewer.args.attachments, hasLength(3));
      expect(viewer.args.initialIndex, 2);
    });

    testWidgets('bulan kosong, bulan ini tidak bisa maju, error', (
      tester,
    ) async {
      await pumpRoutedApp(tester, _server([]), routeName: Routes.memories);
      expect(find.text('Belum ada foto kegiatan bulan ini.'), findsOneWidget);
      final next = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.chevron_right_rounded),
      );
      expect(next.onPressed, isNull);

      await pumpRoutedApp(
        tester,
        FakeServer({'/activities': 500}),
        routeName: Routes.memories,
      );
      expect(find.text('Coba lagi'), findsOneWidget);
    });
  });
}
