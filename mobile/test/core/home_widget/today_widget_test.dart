import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:direkapin/core/home_widget/today_widget.dart';
import 'package:direkapin/core/theme/app_themes.dart';
import 'package:direkapin/features/dashboard/data/dashboard_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_server.dart';

Future<ui.Image> _decode(Uint8List png) async {
  final codec = await ui.instantiateImageCodec(png);
  return (await codec.getNextFrame()).image;
}

/// 400×200: kiri merah, kanan biru.
Future<Uint8List> _halves() async {
  final recorder = ui.PictureRecorder();
  Canvas(recorder)
    ..drawRect(
      const Rect.fromLTWH(0, 0, 200, 200),
      Paint()..color = const Color(0xFFFF0000),
    )
    ..drawRect(
      const Rect.fromLTWH(200, 0, 200, 200),
      Paint()..color = const Color(0xFF0000FF),
    );
  final source = await recorder.endRecording().toImage(400, 200);
  final data = await source.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}

Future<Color> _pixel(ui.Image image, int x, int y) async {
  final data = await image.toByteData();
  final i = (y * image.width + x) * 4;
  return Color.fromARGB(
    data!.getUint8(i + 3),
    data.getUint8(i),
    data.getUint8(i + 1),
    data.getUint8(i + 2),
  );
}

void main() {
  group('todayWidgetData', () {
    test('angka hari ini dan warna tema (tanpa status, D-85)', () {
      final json = dashboardJson(hasEntry: true, todayExpense: 45000);
      (json['last7Days']! as List).last['income'] = 2000000;
      final teal = appThemes.first;

      final data = todayWidgetData(Dashboard.fromJson(json), teal);

      expect(data, {
        'date': '2026-11-04',
        'expense': '−Rp45.000',
        'income': '+Rp2.000.000',
        'surface': argbHex(teal.scheme.surface),
        'text': argbHex(teal.scheme.onSurface),
        'textSecondary': argbHex(teal.scheme.onSurfaceVariant),
        'ink': argbHex(teal.scheme.onSurface),
        'accent': argbHex(teal.scheme.primary),
        'incomeColor': argbHex(teal.colors.income),
        'expenseColor': argbHex(teal.colors.expense),
      });
    });

    test('belum mencatat + hari ini tidak ada di last7Days → +Rp0', () {
      final json = dashboardJson();
      (json['today']! as Map)['date'] = '2026-11-05';

      final data = todayWidgetData(Dashboard.fromJson(json), appThemes.first);

      expect(data['expense'], '−Rp0');
      expect(data['income'], '+Rp0');
      expect(data.containsKey('status'), isFalse);
    });
  });

  test('argbHex menulis #AARRGGBB', () {
    expect(argbHex(const Color(0x8012AB0F)), '#8012AB0F');
  });

  test('saturationMatrix: 1 = identitas, 0 = abu-abu', () {
    expect(saturationMatrix(1), [
      1, 0, 0, 0, 0, //
      0, 1, 0, 0, 0, //
      0, 0, 1, 0, 0, //
      0, 0, 0, 1, 0, //
    ]);
    final grey = saturationMatrix(0);
    expect(grey.sublist(0, 3), grey.sublist(5, 8));
    expect(grey.sublist(0, 3), grey.sublist(10, 13));
  });

  testWidgets('maskot persegi 360 transparen, tidak terpotong tepi', (
    tester,
  ) async {
    await tester.runAsync(() async {
      for (final theme in appThemes) {
        final image = await _decode(await renderMascot(theme, happy: true));
        expect((image.width, image.height), (360, 360), reason: theme.id);
        // Widget menaruhnya setinggi widget di kanan bawah; sisi atas/kiri/kanan
        // kosong supaya tangan melambai tidak terpotong di ukuran mana pun.
        for (final (x, y) in [(0, 0), (359, 0), (0, 180), (359, 180)]) {
          expect((await _pixel(image, x, y)).a, 0, reason: '${theme.id} $x,$y');
        }
      }
    });
  });

  group('potongan foto persegi (D-85)', () {
    test('zoom maksimum menjaga potongan minimal 360 px asli', () {
      expect(maxWidgetZoom(const Size(1600, 1200)), closeTo(1600 / 360, 1e-9));
      // Foto kecil: tidak bisa di-zoom in sama sekali.
      expect(maxWidgetZoom(const Size(300, 300)), 1.0);
    });

    test('zoom 1 = foto utuh di tengah, persegi sebesar sisi panjang', () {
      expect(
        widgetCrop(
          const Size(1600, 1200),
          zoom: 1,
          center: const Offset(800, 600),
        ),
        const Rect.fromLTWH(0, -200, 1600, 1600),
      );
      expect(
        widgetCrop(const Size(900, 1600), zoom: 1, center: Offset.zero),
        const Rect.fromLTWH(-350, 0, 1600, 1600),
      );
    });

    test('zoom dijepit ke [1, maks]', () {
      const size = Size(1600, 1200);
      final far = widgetCrop(size, zoom: 10, center: const Offset(800, 600));
      expect(far.width, closeTo(360, 1e-9));
      expect(far.center, const Offset(800, 600));
      final out = widgetCrop(size, zoom: 0.2, center: const Offset(800, 600));
      expect(out.width, 1600);
    });

    test(
      'posisi tidak bisa lewat tepi foto; sisi yang muat tetap di tengah',
      () {
        const size = Size(1600, 1200);
        expect(
          widgetCrop(size, zoom: 2, center: Offset.zero),
          const Rect.fromLTWH(0, 0, 800, 800),
        );
        expect(
          widgetCrop(size, zoom: 2, center: const Offset(5000, 5000)),
          const Rect.fromLTWH(800, 400, 800, 800),
        );
        // Sisi 1300: lebar 1600 bisa digeser, tinggi 1200 tidak (tetap di tengah).
        expect(
          widgetCrop(size, zoom: 1600 / 1300, center: Offset.zero),
          const Rect.fromLTWH(0, -50, 1300, 1300),
        );
      },
    );
  });

  testWidgets('foto utuh: sisa ruang diisi foto yang diblur, bukan kosong', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final image = await _decode(
        await fadePhoto(
          await _halves(),
          const Rect.fromLTWH(0, -100, 400, 400),
        ),
      );

      expect((image.width, image.height), (widgetImageSize, widgetImageSize));
      final left = await _pixel(image, 5, 180);
      final right = await _pixel(image, 355, 180);
      expect(left.r, greaterThan(left.b));
      expect(right.b, greaterThan(right.r));
      // Pita atas di luar foto: buram tapi tidak transparan.
      expect((await _pixel(image, 180, 10)).a, 1.0);
    });
  });

  testWidgets('foto dipotong persegi 360 sesuai bingkai lalu dipudarkan', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final image = await _decode(
        await fadePhoto(await _halves(), const Rect.fromLTWH(200, 0, 200, 200)),
      );

      expect((image.width, image.height), (widgetImageSize, widgetImageSize));
      final left = await _pixel(image, 5, 180);
      expect(left.a, 1.0);
      // Hanya bagian biru yang masuk, dan warnanya kusam (merah naik dari 0).
      expect((left.b * 255).round(), greaterThan((left.r * 255).round()));
      expect((left.r * 255).round(), greaterThan(10));
    });
  });
}
