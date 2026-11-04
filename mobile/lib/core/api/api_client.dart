import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../auth/session_provider.dart';
import 'auth_interceptor.dart';

part 'api_client.g.dart';

const _apiUrl = String.fromEnvironment('API_URL');

@Riverpod(keepAlive: true)
Dio apiClient(Ref ref) {
  assert(_apiUrl != '', 'Jalankan dengan --dart-define=API_URL=...');
  final options = BaseOptions(
    baseUrl: '$_apiUrl/api/v1',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
  );
  return Dio(options)
    ..interceptors.add(
      AuthInterceptor(
        ref.watch(tokenStorageProvider),
        refreshClient: Dio(options),
        onSessionExpired: () => ref.read(sessionProvider.notifier).markLoggedOut(),
      ),
    );
}
