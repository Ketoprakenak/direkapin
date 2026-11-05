import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../core/api/api_error.dart';

class AttachmentApi {
  const AttachmentApi(this._dio);

  final Dio _dio;

  Future<void> uploadForTransaction(
    String transactionId,
    String filePath, {
    required void Function(double progress) onProgress,
  }) => apiCall(
    () => _dio.post<void>(
      '/attachments',
      data: FormData.fromMap({
        'transactionId': transactionId,
        'file': MultipartFile.fromFileSync(
          filePath,
          filename: 'foto.jpg',
          contentType: DioMediaType('image', 'jpeg'),
        ),
      }),
      options: Options(sendTimeout: const Duration(seconds: 60)),
      onSendProgress: (sent, total) {
        if (total > 0) onProgress(sent / total);
      },
    ),
  );

  /// Lewat dio, bukan URL gambar biasa, supaya token ikut dipasang dan di-refresh.
  Future<Uint8List> bytes(String id, {required bool thumb}) =>
      apiCall(() async {
        final response = await _dio.get<List<int>>(
          '/attachments/$id',
          queryParameters: {'size': thumb ? 'thumb' : 'full'},
          options: Options(responseType: ResponseType.bytes),
        );
        return Uint8List.fromList(response.data!);
      });

  Future<void> delete(String id) =>
      apiCall(() => _dio.delete<void>('/attachments/$id'));
}
