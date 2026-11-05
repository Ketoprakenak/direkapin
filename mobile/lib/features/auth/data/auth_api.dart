import 'package:dio/dio.dart';

import '../../../core/api/api_error.dart';
import 'auth_models.dart';

class AuthApi {
  const AuthApi(this._dio);

  final Dio _dio;

  Future<AuthTokens> register({
    required String name,
    required String email,
    required String password,
    required String inviteCode,
  }) => _requestTokens('/auth/register', {
    'name': name,
    'email': email,
    'password': password,
    'inviteCode': inviteCode,
  });

  Future<AuthTokens> login({required String email, required String password}) =>
      _requestTokens('/auth/login', {'email': email, 'password': password});

  Future<void> logout(String refreshToken) async {
    try {
      await _dio.post<void>('/auth/logout', data: {'refreshToken': refreshToken});
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<AuthTokens> _requestTokens(String path, Map<String, String> data) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(path, data: data);
      return AuthTokens.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
