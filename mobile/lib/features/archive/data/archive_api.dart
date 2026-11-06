import 'package:dio/dio.dart';

import '../../../core/api/api_error.dart';
import 'archive_models.dart';

class ArchiveApi {
  const ArchiveApi(this._dio);

  final Dio _dio;

  Future<List<Archive>> list() => apiCall(() async {
    final response = await _dio.get<Map<String, dynamic>>('/archives');
    return (response.data!['items'] as List)
        .map((item) => Archive.fromJson(item as Map<String, dynamic>))
        .toList();
  });

  Future<void> download(
    String id,
    String savePath, {
    required void Function(double progress) onProgress,
  }) => apiCall(
    () => _dio.download(
      '/archives/$id/download',
      savePath,
      onReceiveProgress: (received, total) {
        if (total > 0) onProgress(received / total);
      },
    ),
  );
}
