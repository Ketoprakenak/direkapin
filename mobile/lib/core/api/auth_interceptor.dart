import 'package:dio/dio.dart';

import '../auth/token_storage.dart';

/// Memasang access token. Auto refresh saat 401 ditambahkan di Slice 1.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokens);

  final TokenStorage _tokens;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokens.readAccessToken();
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }
}
