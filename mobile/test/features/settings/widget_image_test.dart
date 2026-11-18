import 'dart:ui' as ui;

import 'package:direkapin/core/media/photo_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../helpers/fake_server.dart';

class _FakePhotos implements PhotoService {
  _FakePhotos(this.paths);

  final List<String> paths;
  final sources = <ImageSource>[];

  @override
  Future<({List<String> paths, int skipped})> pick(
    ImageSource source, {
    required int limit,
  }) async {
    sources.add(source);
    return (paths: paths, skipped: 0);
  }
}

Future<ui.Image> _image(WidgetTester tester, int width, int height) async =>
    (await tester.runAsync(() {
      final recorder = ui.PictureRecorder();
      Canvas(recorder);
      return recorder.endRecording().toImage(width, height);
    }))!;

Future<void> _pickPhoto(WidgetTester tester) async {
  await tester.tap(find.text('Foto dari galeri'));
  await tester.pumpAndSettle();
  expect(find.text('Atur foto widget'), findsOneWidget);
}

Future<void> _openSheet(
  WidgetTester tester,
  FakeTodayWidgetService widget,
  PhotoService photos,
) async {
  tester.view.physicalSize = const Size(1080, 3000);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.reset);
  await pumpRoutedApp(
    tester,
    FakeServer({'/dashboard': dashboardJson()}),
    routeName: null,
    photoService: photos,
    todayWidget: widget,
  );
  await tester.tap(find.widgetWithText(NavigationDestination, 'Profil'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Gambar widget'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));

  testWidgets(
    'pilih foto → atur di bingkai → Pakai: potongan tengah disimpan',
    (tester) async {
      final widget = FakeTodayWidgetService()
        ..loadedPhoto = await _image(tester, 1600, 1200);
      final photos = _FakePhotos(['/tmp/pic.jpg']);
      await _openSheet(tester, widget, photos);

      await _pickPhoto(tester);
      await tester.tap(find.text('Pakai'));
      await tester.pumpAndSettle();

      expect(photos.sources, [ImageSource.gallery]);
      expect(widget.pickedPhotos, ['/tmp/pic.jpg']);
      // Bawaan: foto utuh di tengah bingkai.
      expect(widget.crops, [const Rect.fromLTWH(0, -200, 1600, 1600)]);
      expect(widget.saves.last, containsPair('image', '/widget/photo.png'));
      expect(
        find.descendant(
          of: find.widgetWithText(ListTile, 'Gambar widget'),
          matching: find.text('Foto dari galeri'),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('geser foto lalu Pakai → potongan ikut bergeser', (tester) async {
    final widget = FakeTodayWidgetService()
      ..loadedPhoto = await _image(tester, 1600, 1200);
    await _openSheet(tester, widget, _FakePhotos(['/tmp/pic.jpg']));
    await _pickPhoto(tester);

    await tester.drag(find.byType(Slider), const Offset(2000, 0));
    await tester.pumpAndSettle();
    // Tarik foto ke kanan = bagian kiri foto masuk bingkai, mentok di tepi.
    await tester.drag(
      find.byKey(const Key('widget-photo-stage')),
      const Offset(2000, 0),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pakai'));
    await tester.pumpAndSettle();

    expect(widget.crops.single.left, 0);
    expect(widget.crops.single.top, closeTo(420, 0.01));
    expect(widget.crops.single.width, closeTo(360, 0.01));
  });

  testWidgets('zoom in mentok di batas resolusi, ada keterangan', (
    tester,
  ) async {
    final widget = FakeTodayWidgetService()
      ..loadedPhoto = await _image(tester, 1600, 1200);
    await _openSheet(tester, widget, _FakePhotos(['/tmp/pic.jpg']));
    await _pickPhoto(tester);
    expect(find.textContaining('Batas zoom'), findsNothing);

    await tester.drag(find.byType(Slider), const Offset(2000, 0));
    await tester.pumpAndSettle();
    expect(find.textContaining('Batas zoom'), findsOneWidget);
    await tester.tap(find.text('Pakai'));
    await tester.pumpAndSettle();

    expect(widget.crops.single.width, closeTo(360, 0.01));
    expect(widget.crops.single.center, const Offset(800, 600));
  });

  testWidgets('foto kecil: zoom in mati', (tester) async {
    final widget = FakeTodayWidgetService()
      ..loadedPhoto = await _image(tester, 300, 300);
    await _openSheet(tester, widget, _FakePhotos(['/tmp/pic.jpg']));
    await _pickPhoto(tester);

    expect(tester.widget<Slider>(find.byType(Slider)).onChanged, isNull);
  });

  testWidgets('tutup editor → foto tidak disimpan', (tester) async {
    final widget = FakeTodayWidgetService()
      ..loadedPhoto = await _image(tester, 1600, 1200);
    await _openSheet(tester, widget, _FakePhotos(['/tmp/pic.jpg']));
    await _pickPhoto(tester);

    await tester.tap(find.byTooltip('Tutup'));
    await tester.pumpAndSettle();

    expect(widget.crops, isEmpty);
    expect(widget.photo, isNull);
  });

  testWidgets('batal di galeri → pilihan tetap maskot', (tester) async {
    final widget = FakeTodayWidgetService();
    await _openSheet(tester, widget, _FakePhotos([]));

    await tester.tap(find.text('Foto dari galeri'));
    await tester.pumpAndSettle();

    expect(widget.pickedPhotos, isEmpty);
    expect(widget.saves.last, containsPair('mascot', '/widget/mascot.png'));
    expect(widget.saves.last, containsPair('image', null));
  });

  testWidgets('pilih Maskot tema → foto lama dihapus, widget pakai maskot', (
    tester,
  ) async {
    final widget = FakeTodayWidgetService()..photo = '/widget/photo.png';
    await _openSheet(tester, widget, _FakePhotos([]));

    await tester.tap(find.text('Maskot tema').last);
    await tester.pumpAndSettle();

    expect(widget.photo, isNull);
    expect(widget.saves.last, containsPair('mascot', '/widget/mascot.png'));
    expect(widget.saves.last, containsPair('image', null));
  });
}
