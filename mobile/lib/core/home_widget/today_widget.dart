import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/dashboard/data/dashboard_models.dart';
import '../format/money.dart';
import '../theme/app_themes.dart';
import '../widgets/mascot.dart';

part 'today_widget.g.dart';

/// Maskot persegi; widget menaruhnya utuh setinggi widget di kanan bawah (`fitEnd`).
const mascotImageSize = 360;

/// Sisi gambar latar widget 2×2 (persegi, D-85). Potongan foto tidak boleh lebih
/// kecil dari ini dalam piksel asli, supaya gambar di widget tidak pecah.
const widgetImageSize = 360;

/// Latar dipudarkan supaya angka di atasnya tetap kebaca (D-83).
const _backgroundSaturation = 0.35;

/// Kunci yang dikosongkan saat keluar akun; warna tema tetap disimpan.
const _accountKeys = ['date', 'expense', 'income', 'image', 'mascot'];

/// `#AARRGGBB`, dibaca Kotlin dengan `Color.parseColor`.
String argbHex(Color color) =>
    '#${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';

/// Teks siap tampil + warna tema untuk widget "Hari ini". Saldo tidak pernah ikut.
Map<String, String> todayWidgetData(Dashboard d, AppThemeData theme) {
  final income = d.last7Days
      .where((p) => p.label == d.today.date)
      .fold(0, (sum, p) => sum + p.income);
  return {
    'date': d.today.date,
    'expense': '−${formatRupiah(d.today.expense)}',
    'income': formatRupiah(income, showPlus: true),
    'surface': argbHex(theme.scheme.surface),
    'text': argbHex(theme.scheme.onSurface),
    'textSecondary': argbHex(theme.scheme.onSurfaceVariant),
    'ink': argbHex(theme.scheme.onSurface),
    'accent': argbHex(theme.scheme.primary),
    'incomeColor': argbHex(theme.colors.income),
    'expenseColor': argbHex(theme.colors.expense),
  };
}

/// Matriks `ColorFilter.matrix` 4×5: [s] 1 = warna asli, 0 = abu-abu (luminans Rec.709).
List<double> saturationMatrix(double s) {
  const lr = 0.2126, lg = 0.7152, lb = 0.0722;
  final r = lr * (1 - s), g = lg * (1 - s), b = lb * (1 - s);
  return [
    r + s, g, b, 0, 0, //
    r, g + s, b, 0, 0, //
    r, g, b + s, 0, 0, //
    0, 0, 0, 1, 0, //
  ];
}

final _fadePaint = Paint()
  ..colorFilter = ColorFilter.matrix(saturationMatrix(_backgroundSaturation))
  ..filterQuality = FilterQuality.medium;

Future<Uint8List> _toPng(ui.Picture picture, int width, int height) async {
  final image = await picture.toImage(width, height);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return data!.buffer.asUint8List();
}

/// Maskot tema pose `wave`, dipudarkan, latar transparan; kaki menempel tepi bawah,
/// sisi lain diberi ruang supaya tangan melambai tidak terpotong.
Future<Uint8List> renderMascot(AppThemeData theme, {required bool happy}) {
  const size = 300.0;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)
    ..saveLayer(null, _fadePaint)
    ..translate((mascotImageSize - size) / 2, mascotImageSize - size);
  mascotPainter(
    theme,
    expression: happy ? MascotExpression.happy : MascotExpression.neutral,
    pose: MascotPose.wave,
  ).paint(canvas, const Size.square(size));
  canvas.restore();
  return _toPng(recorder.endRecording(), mascotImageSize, mascotImageSize);
}

/// Zoom 1 = foto utuh (persegi sebesar sisi panjang); maksimum menjaga potongan
/// tetap ≥ [widgetImageSize] piksel asli supaya tidak pecah.
double maxWidgetZoom(Size image) => max(1, image.longestSide / widgetImageSize);

/// Potongan persegi dalam piksel foto; boleh lebih besar dari foto (sisanya diisi
/// blur). Zoom dijepit ke [1, [maxWidgetZoom]]; sisi yang lebih kecil dari potongan
/// tetap di tengah, sisi lain tidak bisa digeser lewat tepi foto.
Rect widgetCrop(Size image, {required double zoom, required Offset center}) {
  final side = image.longestSide / zoom.clamp(1, maxWidgetZoom(image));
  double axis(double value, double length) =>
      side >= length ? length / 2 : value.clamp(side / 2, length - side / 2);
  return Rect.fromCenter(
    center: Offset(axis(center.dx, image.width), axis(center.dy, image.height)),
    width: side,
    height: side,
  );
}

/// Lukis [crop] foto ke [dst]: ruang di luar foto diisi foto yang sama, diblur.
/// Dipakai editor dan [fadePhoto], jadi pratinjau = hasil di widget.
void paintWidgetPhoto(Canvas canvas, ui.Image photo, Rect crop, Rect dst) {
  final k = dst.width / crop.width;
  final size = Size(photo.width.toDouble(), photo.height.toDouble());
  canvas
    ..save()
    ..clipRect(dst)
    ..drawImageRect(
      photo,
      Rect.fromCenter(
        center: size.center(Offset.zero),
        width: size.shortestSide,
        height: size.shortestSide,
      ),
      dst,
      Paint()
        ..imageFilter = ui.ImageFilter.blur(
          sigmaX: dst.width / 15,
          sigmaY: dst.width / 15,
        )
        ..filterQuality = FilterQuality.low,
    )
    ..drawImageRect(
      photo,
      Offset.zero & size,
      Rect.fromLTWH(
        dst.left - crop.left * k,
        dst.top - crop.top * k,
        size.width * k,
        size.height * k,
      ),
      Paint()..filterQuality = FilterQuality.medium,
    )
    ..restore();
}

/// Bagian [crop] foto jadi persegi [widgetImageSize], lalu dipudarkan.
Future<Uint8List> fadePhoto(Uint8List bytes, Rect crop) async {
  final photo = await decodePhoto(bytes);
  const out = Rect.fromLTWH(0, 0, widgetImageSize + 0.0, widgetImageSize + 0.0);
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)..saveLayer(out, _fadePaint);
  paintWidgetPhoto(canvas, photo, crop, out);
  canvas.restore();
  photo.dispose();
  return _toPng(recorder.endRecording(), widgetImageSize, widgetImageSize);
}

Future<ui.Image> decodePhoto(Uint8List bytes) async {
  final codec = await ui.instantiateImageCodec(bytes);
  return (await codec.getNextFrame()).image;
}

/// Jembatan ke widget layar utama (`TodayWidgetProvider.kt`). Dipalsukan di test.
class TodayWidgetService {
  const TodayWidgetService();

  static const _androidName = 'id.my.direkapin.app.TodayWidgetProvider';

  /// File latar hanya di HP; tidak pernah diupload.
  Future<File> _file(String name) async {
    final dir = Directory(
      '${(await getApplicationDocumentsDirectory()).path}/widget',
    );
    await dir.create(recursive: true);
    return File('${dir.path}/$name');
  }

  /// Ditulis ke file sementara lalu di-rename, supaya widget tidak membaca file setengah jadi.
  Future<String> _write(String name, Uint8List bytes) async {
    final file = await _file(name);
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsBytes(bytes, flush: true);
    return (await tmp.rename(file.path)).path;
  }

  /// Nilai null menghapus kunci.
  Future<void> save(Map<String, String?> data) async {
    for (final MapEntry(:key, :value) in data.entries) {
      await HomeWidget.saveWidgetData<String>(key, value);
    }
    await HomeWidget.updateWidget(qualifiedAndroidName: _androidName);
  }

  Future<void> clear() => save({for (final key in _accountKeys) key: null});

  Future<String> writeMascot(AppThemeData theme, {required bool happy}) async =>
      _write('mascot.png', await renderMascot(theme, happy: happy));

  Future<String?> savedPhoto() async {
    final file = await _file('photo.png');
    return await file.exists() ? file.path : null;
  }

  /// Foto galeri untuk editor bingkai (D-85).
  Future<ui.Image> loadPhoto(String pickedPath) async =>
      decodePhoto(await File(pickedPath).readAsBytes());

  Future<void> savePhoto(String pickedPath, Rect crop) async => _write(
    'photo.png',
    await fadePhoto(await File(pickedPath).readAsBytes(), crop),
  );

  Future<void> deletePhoto() async {
    final file = await _file('photo.png');
    if (await file.exists()) await file.delete();
  }

  /// Intent awal tetap tersimpan selama proses hidup (activity `singleTop`);
  /// tanpa ini, login ulang membuka form Catat lagi.
  static var _launchConsumed = false;

  Future<Uri?> initialLaunch() async {
    if (_launchConsumed) return null;
    _launchConsumed = true;
    return HomeWidget.initiallyLaunchedFromHomeWidget();
  }

  Stream<Uri?> get clicks => HomeWidget.widgetClicked;
}

@riverpod
TodayWidgetService todayWidgetService(Ref ref) => const TodayWidgetService();

/// Path foto latar widget, null = maskot tema.
@riverpod
Future<String?> widgetPhoto(Ref ref) =>
    ref.watch(todayWidgetServiceProvider).savedPhoto();
