import 'package:dio/dio.dart';
import 'package:direkapin/core/api/api_error.dart';
import 'package:flutter_test/flutter_test.dart';

DioException withBody(Object? data) {
  final options = RequestOptions(path: '/x');
  return DioException(
    requestOptions: options,
    response: Response(requestOptions: options, statusCode: 400, data: data),
  );
}

void main() {
  test('membaca format Error dari kontrak', () {
    final error = ApiException.fromDio(
      withBody({
        'error': {
          'code': 'VALIDATION_ERROR',
          'message': 'Data belum valid',
          'details': {'amount': 'Nominal harus lebih dari 0'},
        },
      }),
    );
    expect(error.code, 'VALIDATION_ERROR');
    expect(error.message, 'Data belum valid');
    expect(error.details, {'amount': 'Nominal harus lebih dari 0'});
  });

  test('tanpa details tetap valid', () {
    final error = ApiException.fromDio(
      withBody({
        'error': {'code': 'NOT_FOUND', 'message': 'Data tidak ditemukan'},
      }),
    );
    expect(error.details, isEmpty);
  });

  test('tanpa respons memakai teks server offline', () {
    final error = ApiException.fromDio(
      DioException(requestOptions: RequestOptions(path: '/x')),
    );
    expect(error.code, ApiException.networkError);
    expect(error.message, 'Server lagi nggak bisa dihubungi. Coba lagi sebentar.');
  });

  test('respons di luar kontrak tidak menampilkan isinya', () {
    final error = ApiException.fromDio(withBody('<html>Bad Gateway</html>'));
    expect(error.code, 'INTERNAL_ERROR');
    expect(error.message, 'Terjadi kesalahan di server');
  });
}
