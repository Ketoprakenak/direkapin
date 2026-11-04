import 'package:dio/dio.dart';

/// Bentuk `Error` dari docs/openapi.yaml. [message] aman ditampilkan ke user.
class ApiException implements Exception {
  const ApiException(this.code, this.message, [this.details = const {}]);

  /// Tidak ada respons dari server; bukan kode dari kontrak API.
  static const networkError = 'NETWORK_ERROR';

  final String code;
  final String message;
  final Map<String, String> details;

  factory ApiException.fromDio(DioException exception) {
    final data = exception.response?.data;
    final error = data is Map ? data['error'] : null;
    if (error is Map && error['code'] is String && error['message'] is String) {
      final details = error['details'];
      return ApiException(
        error['code'] as String,
        error['message'] as String,
        details is Map
            ? details.map((key, value) => MapEntry('$key', '$value'))
            : const {},
      );
    }
    if (exception.response == null) {
      return const ApiException(
        networkError,
        'Server lagi nggak bisa dihubungi. Coba lagi sebentar.',
      );
    }
    return const ApiException('INTERNAL_ERROR', 'Terjadi kesalahan di server');
  }

  @override
  String toString() => 'ApiException($code)';
}
