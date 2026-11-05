import 'dart:io';

import 'package:direkapin/core/media/photo_service.dart';
import 'package:direkapin/core/router/router.dart';
import 'package:direkapin/features/activity/data/activity_models.dart';
import 'package:direkapin/features/activity/presentation/activity_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../helpers/fake_server.dart';

class _FakePhotos implements PhotoService {
  _FakePhotos(this.path, {this.count = 1, this.skipped = 0});

  final String path;
  final int count;
  final int skipped;
  int? lastLimit;

  @override
  Future<({List<String> paths, int skipped})> pick(
    ImageSource source, {
    required int limit,
  }) async {
    lastLimit = limit;
    return (paths: List.filled(count, path), skipped: skipped);
  }
}

Map<String, Object?> attachmentJson(String id) => {
  'id': id,
  'thumbUrl': '/api/v1/attachments/$id?size=thumb',
  'fullUrl': '/api/v1/attachments/$id?size=full',
  'isArchived': false,
  'archiveMonth': null,
  'width': 800,
  'height': 600,
  'sizeBytes': 1000,
  'createdAt': '2026-11-04T02:30:00.000Z',
};

Map<String, Object?> activityJson({
  String? time = '09:30',
  String? location = 'Aula',
  bool isImportant = true,
  List<Map<String, Object?>> attachments = const [],
}) => {
  'id': 'k1',
  'title': 'Seminar',
  'date': '2026-11-04',
  'time': time,
  'location': location,
  'description': 'Bawa laptop',
  'isImportant': isImportant,
  'attachments': attachments,
  'createdAt': '2026-11-04T02:30:00.000Z',
  'updatedAt': '2026-11-04T02:30:00.000Z',
};

void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));

  Finder field(String label) => find.widgetWithText(TextFormField, label);

  Future<void> tapText(WidgetTester tester, String text) async {
    // Field yang baru diisi menggulir layar ke kursornya; tunggu dulu.
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(text));
    await tester.pumpAndSettle();
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  List<String> paths(FakeServer server) =>
      server.writes.map((write) => '${write.method} ${write.path}').toList();

  group('Form kegiatan', () {
    testWidgets('judul wajib', (tester) async {
      final server = FakeServer({});
      await pumpRoutedApp(tester, server, routeName: Routes.activityForm);

      await tapText(tester, 'Simpan');

      expect(find.text('Judul wajib diisi'), findsOneWidget);
      expect(server.writes, isEmpty);
    });

    testWidgets(
      'cukup judul: seharian, tanggal awal terisi, field kosong tidak terkirim',
      (tester) async {
        final server = FakeServer({});
        await pumpRoutedApp(
          tester,
          server,
          routeName: Routes.activityForm,
          extra: ActivityFormArgs(initialDate: DateTime(2026, 11, 4)),
        );

        expect(find.text('Seharian'), findsOneWidget);
        await tester.enterText(field('Judul'), '  Rapat  ');
        await tapText(tester, 'Simpan');

        expect(server.writes.single.path, '/activities');
        expect(server.writes.single.body, {
          'title': 'Rapat',
          'date': '2026-11-04',
          'isImportant': false,
        });
        expect(find.text('Kegiatan tersimpan'), findsOneWidget);
        expect(find.text('Tambah kegiatan'), findsNothing);
      },
    );

    testWidgets('toggle penting ikut terkirim', (tester) async {
      final server = FakeServer({});
      await pumpRoutedApp(tester, server, routeName: Routes.activityForm);

      await tester.enterText(field('Judul'), 'Rapat');
      await tapText(tester, 'Tandai penting');
      await tapText(tester, 'Simpan');

      expect(server.writes.single.body, containsPair('isImportant', true));
    });

    testWidgets(
      'edit: terisi data lama, "Seharian" dan lokasi kosong mengirim null',
      (tester) async {
        final server = FakeServer({});
        await pumpRoutedApp(
          tester,
          server,
          routeName: Routes.activityForm,
          extra: ActivityFormArgs(activity: Activity.fromJson(activityJson())),
        );

        expect(find.text('Ubah kegiatan'), findsOneWidget);
        expect(find.text('Seminar'), findsOneWidget);
        expect(find.text('09.30'), findsOneWidget);

        await tapText(tester, 'Seharian');
        await tester.enterText(field('Lokasi (opsional)'), '');
        await tapText(tester, 'Simpan');

        final write = server.writes.single;
        expect(write.method, 'PATCH');
        expect(write.path, '/activities/k1');
        expect(write.body, containsPair('time', null));
        expect(write.body, containsPair('location', null));
        expect(write.body, containsPair('description', 'Bawa laptop'));
      },
    );

    testWidgets('error server ditampilkan, isi form tetap ada', (tester) async {
      final server = FakeServer({})
        ..writeFailure = (
          status: 400,
          body: {
            'error': {
              'code': 'VALIDATION_ERROR',
              'message': 'Data belum valid',
              'details': {'title': 'Judul terlalu panjang'},
            },
          },
        );
      await pumpRoutedApp(tester, server, routeName: Routes.activityForm);

      await tester.enterText(field('Judul'), 'Rapat');
      await tapText(tester, 'Simpan');

      expect(find.text('Judul terlalu panjang'), findsOneWidget);
      expect(find.text('Rapat'), findsOneWidget);
    });

    group('foto', () {
      late String photoPath;

      setUpAll(() {
        final dir = Directory.systemTemp.createTempSync('direkapin-test');
        photoPath = '${dir.path}/foto.jpg';
        File(photoPath).writeAsBytesSync([1, 2, 3]);
      });

      Future<void> addPhoto(WidgetTester tester) async {
        await tapText(tester, 'Tambah foto');
        await tapText(tester, 'Galeri');
      }

      testWidgets(
        'kegiatan disimpan dulu, foto gagal, "Coba lagi" tidak kirim ulang',
        (tester) async {
          final server = FakeServer({})..failingPaths.add('/attachments');
          await pumpRoutedApp(
            tester,
            server,
            routeName: Routes.activityForm,
            photoService: _FakePhotos(photoPath),
          );
          await tester.enterText(field('Judul'), 'Rapat');
          await addPhoto(tester);
          await tapText(tester, 'Simpan');

          expect(
            find.text('Foto gagal diupload. Kegiatan tetap tersimpan.'),
            findsOneWidget,
          );

          server.failingPaths.clear();
          await tapText(tester, 'Coba lagi');

          expect(paths(server), [
            'POST /activities',
            'POST /attachments',
            'POST /attachments',
          ]);
          expect(find.text('Kegiatan tersimpan'), findsOneWidget);
        },
      );

      testWidgets('batas 5 foto: tombol tambah hilang di foto ke-5', (
        tester,
      ) async {
        final activity = Activity.fromJson(
          activityJson(
            attachments: [for (var i = 0; i < 4; i++) attachmentJson('a$i')],
          ),
        );
        await pumpRoutedApp(
          tester,
          FakeServer({}),
          routeName: Routes.activityForm,
          extra: ActivityFormArgs(activity: activity),
          photoService: _FakePhotos(photoPath),
        );

        expect(find.text('Foto kegiatan (maks. 5)'), findsOneWidget);
        await addPhoto(tester);

        expect(find.text('Tambah foto'), findsNothing);
        expect(find.text('Foto kegiatan (maks. 5)'), findsOneWidget);
      });

      testWidgets('pilih banyak: semua masuk, limit = sisa slot', (
        tester,
      ) async {
        final photos = _FakePhotos(photoPath, count: 3);
        final server = FakeServer({});
        final activity = Activity.fromJson(
          activityJson(attachments: [attachmentJson('a0')]),
        );
        await pumpRoutedApp(
          tester,
          server,
          routeName: Routes.activityForm,
          extra: ActivityFormArgs(activity: activity),
          photoService: photos,
        );
        await addPhoto(tester);

        expect(photos.lastLimit, 4);
        expect(find.byTooltip('Hapus foto'), findsNWidgets(4));

        await tapText(tester, 'Simpan');
        expect(paths(server), [
          'PATCH /activities/k1',
          'POST /attachments',
          'POST /attachments',
          'POST /attachments',
        ]);
      });

      testWidgets('foto yang dilewati diberitahukan', (tester) async {
        await pumpRoutedApp(
          tester,
          FakeServer({}),
          routeName: Routes.activityForm,
          photoService: _FakePhotos(photoPath, count: 1, skipped: 2),
        );
        await addPhoto(tester);

        expect(
          find.text(
            '2 foto nggak ikut ditambahkan. '
            'Sudah lewat batas 5 foto, atau filenya rusak.',
          ),
          findsOneWidget,
        );
        expect(find.byTooltip('Hapus foto'), findsOneWidget);
      });

      testWidgets('server menolak foto ke-6: pesannya ditampilkan', (
        tester,
      ) async {
        final server = FakeServer({});
        server.pathFailures['/attachments'] = (
          status: 422,
          body: {
            'error': {
              'code': 'PHOTO_LIMIT_REACHED',
              'message': 'Maksimal 5 foto',
            },
          },
        );
        await pumpRoutedApp(
          tester,
          server,
          routeName: Routes.activityForm,
          extra: ActivityFormArgs(activity: Activity.fromJson(activityJson())),
          photoService: _FakePhotos(photoPath),
        );
        await addPhoto(tester);
        await tapText(tester, 'Simpan');

        expect(find.text('Maksimal 5 foto'), findsOneWidget);
      });
    });
  });

  group('Detail kegiatan', () {
    testWidgets('menampilkan semua field dan bintang', (tester) async {
      await pumpRoutedApp(
        tester,
        FakeServer({}),
        routeName: Routes.activityDetail,
        extra: Activity.fromJson(activityJson()),
      );

      expect(find.text('Seminar'), findsOneWidget);
      expect(find.text('Rabu, 4 November 2026'), findsOneWidget);
      expect(find.text('09.30'), findsOneWidget);
      expect(find.text('Aula'), findsOneWidget);
      expect(find.text('Bawa laptop'), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    });

    testWidgets('tanpa jam dan lokasi: "Seharian", baris lokasi hilang', (
      tester,
    ) async {
      await pumpRoutedApp(
        tester,
        FakeServer({}),
        routeName: Routes.activityDetail,
        extra: Activity.fromJson(
          activityJson(time: null, location: null, isImportant: false),
        ),
      );

      expect(find.text('Seharian'), findsOneWidget);
      expect(find.text('Lokasi'), findsNothing);
      expect(find.byIcon(Icons.star_rounded), findsNothing);
    });

    testWidgets('hapus minta konfirmasi lalu mengirim DELETE', (tester) async {
      final server = FakeServer({});
      await pumpRoutedApp(
        tester,
        server,
        routeName: Routes.activityDetail,
        extra: Activity.fromJson(activityJson()),
      );

      await tapText(tester, 'Hapus');
      expect(
        find.text('Hapus kegiatan ini? Fotonya juga ikut terhapus.'),
        findsOneWidget,
      );
      expect(server.writes, isEmpty);

      await tester.tap(find.text('Hapus').last);
      await tester.pumpAndSettle();

      expect(paths(server), ['DELETE /activities/k1']);
      expect(find.text('Kegiatan terhapus'), findsOneWidget);
      expect(find.text('Detail kegiatan'), findsNothing);
    });

    testWidgets('Ubah membuka form kegiatan', (tester) async {
      await pumpRoutedApp(
        tester,
        FakeServer({}),
        routeName: Routes.activityDetail,
        extra: Activity.fromJson(activityJson()),
      );

      await tapText(tester, 'Ubah');
      expect(find.text('Ubah kegiatan'), findsOneWidget);
    });
  });

  testWidgets('Halaman Hari: tap kegiatan membuka Detail', (tester) async {
    await pumpRoutedApp(
      tester,
      FakeServer({
        '/days/2026-11-04': {
          'date': '2026-11-04',
          'income': 0,
          'expense': 0,
          'transactions': <Object>[],
          'transfers': <Object>[],
          'activities': [activityJson()],
          'note': null,
        },
      }),
      routeName: Routes.day,
      pathParameters: {'date': '2026-11-04'},
    );

    expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    await tapText(tester, 'Seminar');
    expect(find.text('Detail kegiatan'), findsOneWidget);
  });

  testWidgets('tombol Kegiatan di FAB membuka form', (tester) async {
    await pumpRoutedApp(
      tester,
      FakeServer({'/dashboard': dashboardJson()}),
      routeName: Routes.home,
    );

    await tester.tap(find.byTooltip('Tambah'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kegiatan'));
    await tester.pumpAndSettle();

    expect(find.text('Tambah kegiatan'), findsOneWidget);
  });
}
