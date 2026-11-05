import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:direkapin/core/api/api_client.dart';
import 'package:direkapin/core/media/photo_service.dart';
import 'package:direkapin/core/router/router.dart';
import 'package:direkapin/core/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

/// Server palsu: GET dijawab dari [responses], penulisan dicatat di [writes].
class FakeServer implements HttpClientAdapter {
  FakeServer(this.responses);

  /// Path tanpa query. Nilai `int` berarti error dengan status itu.
  final Map<String, Object> responses;
  final writes = <({String method, String path, Map<String, dynamic>? body})>[];

  /// Jika terisi, penulisan berikutnya gagal dengan body error ini.
  ({int status, Map<String, Object?> body})? writeFailure;

  /// Path penulisan yang gagal dengan status 500.
  final failingPaths = <String>{};

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.method != 'GET') {
      writes.add((
        method: options.method,
        path: options.path,
        body: options.data is Map<String, dynamic>
            ? options.data as Map<String, dynamic>
            : null,
      ));
      final failure = writeFailure;
      if (failure != null) return _json(failure.body, failure.status);
      if (failingPaths.contains(options.path)) return _json(const {}, 500);
      return _json(const {'id': 'id-baru'}, 200);
    }
    final response = responses[options.path];
    if (response == null) return _json(const {'items': []}, 200);
    if (response is int) {
      return _json(const {
        'error': {
          'code': 'INTERNAL_ERROR',
          'message': 'Terjadi kesalahan di server',
        },
      }, response);
    }
    return _json(response, 200);
  }

  ResponseBody _json(Object body, int status) => ResponseBody.fromString(
    jsonEncode(body),
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  @override
  void close({bool force = false}) {}
}

/// Tema polos: google_fonts butuh jaringan, yang tidak ada di test.
final testTheme = ThemeData(extensions: const [AppColors.light]);

Future<void> pumpRoutedApp(
  WidgetTester tester,
  FakeServer server, {
  required String routeName,
  Map<String, String> pathParameters = const {},
  Object? extra,
  PhotoService photoService = const PhotoService(),
}) async {
  FlutterSecureStorage.setMockInitialValues({'refreshToken': 'r'});
  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        photoServiceProvider.overrideWithValue(photoService),
        apiClientProvider.overrideWithValue(
          Dio(BaseOptions(baseUrl: 'https://example.test'))
            ..httpClientAdapter = server,
        ),
      ],
      child: Consumer(
        builder: (context, ref, _) => MaterialApp.router(
          theme: testTheme,
          routerConfig: ref.watch(appRouterProvider),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  final context = tester.element(find.byType(Scaffold).first);
  ProviderScope.containerOf(context)
      .read(appRouterProvider)
      .pushNamed(routeName, pathParameters: pathParameters, extra: extra);
  await tester.pumpAndSettle();
}

Map<String, Object?> walletJson(
  String id,
  String name, {
  int balance = 0,
  bool isArchived = false,
}) => {
  'id': id,
  'name': name,
  'type': 'CASH',
  'initialBalance': 0,
  'balance': balance,
  'icon': 'account_balance_wallet_rounded',
  'color': '#14B8A6',
  'isArchived': isArchived,
  'sortOrder': 0,
};

Map<String, Object?> categoryJson(
  String id,
  String name, {
  String type = 'EXPENSE',
  bool isDefault = true,
}) => {
  'id': id,
  'name': name,
  'type': type,
  'icon': 'restaurant_rounded',
  'color': '#F97316',
  'isDefault': isDefault,
  'isHidden': false,
  'sortOrder': 0,
};

Map<String, Object?> dashboardJson({
  int totalBalance = 0,
  List<Map<String, Object?>> wallets = const [],
  bool hasEntry = false,
  int streak = 0,
  int todayExpense = 0,
}) => {
  'totalBalance': totalBalance,
  'wallets': wallets,
  'month': {'income': 100000, 'expense': 25000, 'net': 75000},
  'today': {
    'date': '2026-11-04',
    'expense': todayExpense,
    'activities': <Object>[],
    'hasEntry': hasEntry,
  },
  'last7Days': [
    for (var day = 29; day <= 31; day++)
      {'label': '2026-10-$day', 'income': 0, 'expense': 1000 * day},
    for (var day = 1; day <= 4; day++)
      {'label': '2026-11-0$day', 'income': 0, 'expense': 0},
  ],
  'streak': {'current': streak, 'longest': streak},
};
