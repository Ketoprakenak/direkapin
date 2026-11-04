import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../api/api_client.dart';
import 'token_storage.dart';

part 'session_provider.g.dart';

@Riverpod(keepAlive: true)
TokenStorage tokenStorage(Ref ref) => const TokenStorage();

/// `true` jika perangkat punya sesi. Tidak menunggu server, supaya aplikasi tetap
/// cepat dibuka walau server offline.
@Riverpod(keepAlive: true)
class Session extends _$Session {
  @override
  Future<bool> build() async {
    final tokens = ref.watch(tokenStorageProvider);
    final loggedIn = await tokens.readRefreshToken() != null;
    if (loggedIn) {
      // Di latar belakang: sesi yang sudah kedaluwarsa dibereskan AuthInterceptor,
      // lalu markLoggedOut mengarahkan user ke layar login.
      unawaited(
        ref.read(apiClientProvider).get<void>('/me').then((_) {}, onError: (_) {}),
      );
    }
    return loggedIn;
  }

  void markLoggedIn() => state = const AsyncData(true);

  void markLoggedOut() => state = const AsyncData(false);
}
