import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:image_picker/image_picker.dart' show ImageSource;

part 'photo_service.g.dart';

const maxPhotoBytes = 400 * 1024;
const _maxPhotoPx = 1600;

/// Mencoba kualitas 80, 70, lalu 60, dan berhenti begitu hasilnya ≤ [maxPhotoBytes].
/// Hasil kualitas 60 tetap dipakai walau masih lebih besar; server menerima sampai 2 MB.
Future<XFile?> compressUntilSmall(
  Future<XFile?> Function(int quality) compress,
) async {
  XFile? result;
  for (final quality in const [80, 70, 60]) {
    result = await compress(quality);
    if (result == null || await result.length() <= maxPhotoBytes) return result;
  }
  return result;
}

/// Satu-satunya jalan mengambil foto (FIN-13): UI tidak pernah melihat file asli.
class PhotoService {
  const PhotoService();

  /// Path JPEG hasil kompres, atau null jika user batal memilih.
  // shortcut: foto hilang jika Android mematikan aplikasi saat kamera terbuka, pakai retrieveLostData kalau ini terjadi di HP user.
  Future<String?> pick(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: _maxPhotoPx.toDouble(),
      maxHeight: _maxPhotoPx.toDouble(),
      imageQuality: 85,
    );
    if (picked == null) return null;

    final compressed = await compressUntilSmall(
      (quality) => FlutterImageCompress.compressAndGetFile(
        picked.path,
        '${picked.path}_$quality.jpg',
        minWidth: _maxPhotoPx,
        minHeight: _maxPhotoPx,
        quality: quality,
        // EXIF berisi lokasi; arah foto sudah diterapkan ke piksel.
        keepExif: false,
      ),
    );
    if (compressed == null) throw Exception('Foto gagal dikompres');
    return compressed.path;
  }
}

@riverpod
PhotoService photoService(Ref ref) => const PhotoService();
