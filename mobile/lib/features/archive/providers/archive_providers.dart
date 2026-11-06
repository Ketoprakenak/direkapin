import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/media/gallery_saver.dart';
import '../data/archive_api.dart';
import '../data/archive_models.dart';

part 'archive_providers.g.dart';

@riverpod
ArchiveApi archiveApi(Ref ref) => ArchiveApi(ref.watch(apiClientProvider));

@riverpod
Future<List<Archive>> archives(Ref ref) => ref.watch(archiveApiProvider).list();

/// Tempat file sementara dan tujuan akhir ZIP. Dipisah supaya bisa diganti di test.
class ArchiveFiles {
  const ArchiveFiles();

  Future<String> tempPath(String fileName) async =>
      '${(await getTemporaryDirectory()).path}/$fileName';

  Future<void> saveToDownloads(String path, String fileName) =>
      saveFileToDownloads(path, fileName);
}

@riverpod
ArchiveFiles archiveFiles(Ref ref) => const ArchiveFiles();

/// Progress per id arsip. keepAlive: download jalan terus walau layarnya ditinggal.
@Riverpod(keepAlive: true)
class ArchiveDownloads extends _$ArchiveDownloads {
  @override
  Map<String, double> build() => const {};

  /// Melempar `ApiException`, `PlatformException`, atau `FileSystemException`.
  Future<void> start(Archive archive) async {
    if (state.containsKey(archive.id)) return;
    state = {...state, archive.id: 0};
    final fileName = 'direkapin-arsip-${archive.month}.zip';
    final files = ref.read(archiveFilesProvider);
    String? temp;
    try {
      temp = await files.tempPath('${archive.id}.zip');
      await ref
          .read(archiveApiProvider)
          .download(
            archive.id,
            temp,
            onProgress: (progress) =>
                state = {...state, archive.id: progress},
          );
      await files.saveToDownloads(temp, fileName);
    } finally {
      state = {...state}..remove(archive.id);
      // Status bisa sudah berubah di server walau penyimpanan di HP gagal (D-22).
      ref.invalidate(archivesProvider);
      if (temp != null) await _deleteQuietly(temp);
    }
  }

  Future<void> _deleteQuietly(String path) async {
    try {
      await File(path).delete();
    } on FileSystemException {
      // File sementara: dibersihkan Android kalau gagal dihapus di sini.
    }
  }
}
