import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:direkapin/core/api/auth_interceptor.dart';
import 'package:direkapin/core/auth/token_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

class _CaptureAdapter implements HttpClientAdapter {
  RequestOptions? last;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = options;
    return ResponseBody.fromString('{}', 200);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<RequestOptions> send() async {
    final adapter = _CaptureAdapter();
    final dio = Dio()
      ..httpClientAdapter = adapter
      ..interceptors.add(AuthInterceptor(const TokenStorage()));
    await dio.get<void>('https://example.test/x');
    return adapter.last!;
  }

  test('memasang token jika ada', () async {
    FlutterSecureStorage.setMockInitialValues({'accessToken': 'abc'});
    expect((await send()).headers['Authorization'], 'Bearer abc');
  });

  test('tidak memasang header jika belum login', () async {
    FlutterSecureStorage.setMockInitialValues({});
    expect((await send()).headers.containsKey('Authorization'), isFalse);
  });

  test('clear menghapus kedua token', () async {
    FlutterSecureStorage.setMockInitialValues({});
    const tokens = TokenStorage();
    await tokens.save(accessToken: 'a', refreshToken: 'r');
    expect(await tokens.readRefreshToken(), 'r');
    await tokens.clear();
    expect(await tokens.readAccessToken(), isNull);
    expect(await tokens.readRefreshToken(), isNull);
  });
}
