import 'package:flutter/services.dart';

const _channel = MethodChannel('direkapin/gallery');

/// Menyimpan JPEG ke album Direkapin di galeri HP (kode native: MainActivity.kt).
/// Melempar [PlatformException]; kode `permission_denied` berarti izin ditolak.
// shortcut: selalu JPEG karena aplikasi hanya mengupload JPEG, deteksi formatnya kalau ada klien lain yang mengirim WebP.
Future<void> saveJpegToGallery(Uint8List bytes, String fileName) => _channel
    .invokeMethod<void>('saveJpeg', {'bytes': bytes, 'fileName': fileName});
