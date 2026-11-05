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

/// Mengompres paling banyak [limit] foto. Foto yang gagal atau melewati batas
/// dihitung di `skipped`; melempar hanya jika tidak ada satu pun yang berhasil.
Future<({List<String> paths, int skipped})> compressPicked(
  List<XFile> picked,
  int limit,
  Future<String> Function(XFile file) compress,
) async {
  final paths = <String>[];
  for (final file in picked.take(limit)) {
    try {
      paths.add(await compress(file));
    } on Exception {
      // Foto lain tetap dipakai; jumlah yang dilewati dilaporkan ke user.
    }
  }
  if (picked.isNotEmpty && paths.isEmpty) {
    throw Exception('Foto gagal dikompres');
  }
  return (paths: paths, skipped: picked.length - paths.length);
}

/// Satu-satunya jalan mengambil foto (FIN-13): UI tidak pernah melihat file asli.
class PhotoService {
  const PhotoService();

  Future<String> _compress(XFile picked) async {
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

  /// Path JPEG hasil kompres; kosong jika user batal memilih.
  /// Galeri boleh memilih banyak foto, kamera selalu satu.
  // shortcut: foto hilang jika Android mematikan aplikasi saat kamera terbuka, pakai retrieveLostData kalau ini terjadi di HP user.
  Future<({List<String> paths, int skipped})> pick(
    ImageSource source, {
    required int limit,
  }) async {
    final picker = ImagePicker();
    final maxPx = _maxPhotoPx.toDouble();
    // pickMultiImage menolak limit di bawah 2.
    final picked = source == ImageSource.gallery && limit > 1
        ? await picker.pickMultiImage(
            limit: limit,
            maxWidth: maxPx,
            maxHeight: maxPx,
            imageQuality: 85,
          )
        : [
            ?await picker.pickImage(
              source: source,
              maxWidth: maxPx,
              maxHeight: maxPx,
              imageQuality: 85,
            ),
          ];
    return compressPicked(picked, limit, _compress);
  }
}

@riverpod
PhotoService photoService(Ref ref) => const PhotoService();
