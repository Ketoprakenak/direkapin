import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:direkapin/core/auth/token_storage.dart';
import 'package:direkapin/features/auth/data/auth_api.dart';
import 'package:direkapin/features/auth/data/auth_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

class _OfflineAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) => throw DioException.connectionError(
    requestOptions: options,
    reason: 'offline',
  );

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('logout tetap menghapus token walau server offline', () async {
    FlutterSecureStorage.setMockInitialValues({
      'accessToken': 'a',
      'refreshToken': 'r',
    });
    const tokens = TokenStorage();
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = _OfflineAdapter();

    await AuthRepository(AuthApi(dio), tokens).logout();

    expect(await tokens.readAccessToken(), isNull);
    expect(await tokens.readRefreshToken(), isNull);
  });
}
