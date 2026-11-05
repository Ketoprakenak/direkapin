import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:direkapin/core/api/auth_interceptor.dart';
import 'package:direkapin/core/auth/token_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

/// Server palsu: `/x` hanya menerima token `baru`; `/auth/refresh` memakai [refreshStatus].
class _FakeServer implements HttpClientAdapter {
  int refreshCalls = 0;
  int? refreshStatus = 200;
  final seenAuthorization = <String?>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path == '/auth/refresh') {
      refreshCalls++;
      await Future<void>.delayed(const Duration(milliseconds: 10));
      if (refreshStatus == null) {
        throw DioException.connectionError(
          requestOptions: options,
          reason: 'offline',
        );
      }
      return _json({'accessToken': 'baru', 'refreshToken': 'r2'}, refreshStatus!);
    }
    await requestStream?.drain<void>();
    final authorization = options.headers['Authorization'] as String?;
    seenAuthorization.add(authorization);
    if (options.path == '/auth/login') return _json({}, 401);
    return _json({}, authorization == 'Bearer baru' ? 200 : 401);
  }

  ResponseBody _json(Map<String, Object?> body, int status) =>
      ResponseBody.fromString(
        jsonEncode(body),
        status,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const tokens = TokenStorage();
  late _FakeServer server;
  late int expiredCalls;
  late Dio dio;

  void setUpClient(Map<String, String> stored) {
    FlutterSecureStorage.setMockInitialValues({...stored});
    server = _FakeServer();
    expiredCalls = 0;
    final options = BaseOptions(baseUrl: 'https://example.test');
    dio = Dio(options)
      ..httpClientAdapter = server
      ..interceptors.add(
        AuthInterceptor(
          tokens,
          refreshClient: Dio(options)..httpClientAdapter = server,
          onSessionExpired: () => expiredCalls++,
        ),
      );
  }

  const stale = {'accessToken': 'lama', 'refreshToken': 'r1'};

  test('token masih valid dipasang tanpa refresh', () async {
    setUpClient({'accessToken': 'baru', 'refreshToken': 'r1'});
    await dio.get<void>('/x');
    expect(server.seenAuthorization, ['Bearer baru']);
    expect(server.refreshCalls, 0);
  });

  test('belum login tidak memasang header', () async {
    setUpClient({});
    await expectLater(dio.get<void>('/x'), throwsA(isA<DioException>()));
    expect(server.seenAuthorization, [null]);
  });

  test('401 di-refresh diam-diam, diulang, dan token baru tersimpan', () async {
    setUpClient(stale);
    final response = await dio.get<void>('/x');

    expect(response.statusCode, 200);
    expect(server.refreshCalls, 1);
    expect(await tokens.readAccessToken(), 'baru');
    expect(await tokens.readRefreshToken(), 'r2');
    expect(expiredCalls, 0);
  });

  test('upload FormData tetap terkirim saat diulang setelah 401', () async {
    setUpClient(stale);
    final response = await dio.post<void>(
      '/x',
      data: FormData.fromMap({
        'transactionId': 't1',
        'file': MultipartFile.fromBytes([1, 2, 3], filename: 'foto.jpg'),
      }),
    );

    expect(response.statusCode, 200);
    expect(server.seenAuthorization, ['Bearer lama', 'Bearer baru']);
  });

  test('request barengan hanya memicu satu refresh', () async {
    setUpClient(stale);
    final responses = await Future.wait([
      dio.get<void>('/x'),
      dio.get<void>('/x'),
      dio.get<void>('/x'),
    ]);

    expect(responses.map((r) => r.statusCode), [200, 200, 200]);
    expect(server.refreshCalls, 1);
  });

  test('refresh ditolak server: token dihapus dan sesi berakhir', () async {
    setUpClient(stale);
    server.refreshStatus = 401;

    await expectLater(dio.get<void>('/x'), throwsA(isA<DioException>()));
    expect(await tokens.readRefreshToken(), isNull);
    expect(expiredCalls, 1);
  });

  test('server offline saat refresh: sesi tetap ada', () async {
    setUpClient(stale);
    server.refreshStatus = null;

    await expectLater(dio.get<void>('/x'), throwsA(isA<DioException>()));
    expect(await tokens.readRefreshToken(), 'r1');
    expect(expiredCalls, 0);
  });

  test('401 dari endpoint auth tidak memicu refresh', () async {
    setUpClient(stale);
    await expectLater(
      dio.post<void>('/auth/login', data: {}),
      throwsA(isA<DioException>()),
    );
    expect(server.refreshCalls, 0);
    expect(await tokens.readRefreshToken(), 'r1');
  });

  test('401 tanpa refresh token: sesi berakhir', () async {
    setUpClient({'accessToken': 'lama'});
    await expectLater(dio.get<void>('/x'), throwsA(isA<DioException>()));
    expect(server.refreshCalls, 0);
    expect(expiredCalls, 1);
  });

  test('clear menghapus kedua token', () async {
    setUpClient({});
    await tokens.save(accessToken: 'a', refreshToken: 'r');
    await tokens.clear();
    expect(await tokens.readAccessToken(), isNull);
    expect(await tokens.readRefreshToken(), isNull);
  });
}
