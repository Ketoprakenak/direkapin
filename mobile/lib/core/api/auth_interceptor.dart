import 'package:dio/dio.dart';

import '../auth/token_storage.dart';

/// Memasang access token dan me-refresh diam-diam saat 401.
/// `QueuedInterceptor` membuat request yang gagal barengan diproses satu per satu,
/// jadi refresh token yang sekali pakai tidak dikirim dua kali.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor(
    this._tokens, {
    required Dio refreshClient,
    required this._onSessionExpired,
  }) : _client = refreshClient;

  final TokenStorage _tokens;

  /// Tanpa interceptor ini, supaya refresh dan retry tidak memicu dirinya sendiri.
  final Dio _client;
  final void Function() _onSessionExpired;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokens.readAccessToken();
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    if (err.response?.statusCode != 401 || options.path.startsWith('/auth/')) {
      return handler.next(err);
    }

    try {
      final token = await _validAccessToken(options);
      if (token == null) return handler.next(err);
      options.headers['Authorization'] = 'Bearer $token';
      // FormData hanya bisa dikirim sekali, jadi retry memakai salinannya.
      final data = options.data;
      if (data is FormData) options.data = data.clone();
      handler.resolve(await _client.fetch<dynamic>(options));
    } on DioException catch (e) {
      // Hanya penolakan dari server yang mengakhiri sesi; server offline tidak.
      if (e.response?.statusCode == 401) await _expire();
      handler.next(e);
    }
  }

  Future<String?> _validAccessToken(RequestOptions failed) async {
    final current = await _tokens.readAccessToken();
    // Request lain di antrean sudah me-refresh saat request ini menunggu.
    if (current != null && failed.headers['Authorization'] != 'Bearer $current') {
      return current;
    }

    final refreshToken = await _tokens.readRefreshToken();
    if (refreshToken == null) {
      await _expire();
      return null;
    }
    final response = await _client.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    final accessToken = response.data!['accessToken'] as String;
    await _tokens.save(
      accessToken: accessToken,
      refreshToken: response.data!['refreshToken'] as String,
    );
    return accessToken;
  }

  Future<void> _expire() async {
    await _tokens.clear();
    _onSessionExpired();
  }
}
