import 'dart:async';

import '../../../core/auth/token_storage.dart';
import 'auth_api.dart';
import 'auth_models.dart';

class AuthRepository {
  const AuthRepository(this._api, this._tokens);

  final AuthApi _api;
  final TokenStorage _tokens;

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String inviteCode,
  }) async => _save(
    await _api.register(
      name: name,
      email: email,
      password: password,
      inviteCode: inviteCode,
    ),
  );

  Future<void> login({required String email, required String password}) async =>
      _save(await _api.login(email: email, password: password));

  Future<void> forgotPassword(String email) => _api.forgotPassword(email);

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) => _api.resetPassword(email: email, code: code, newPassword: newPassword);

  /// Token di HP selalu dihapus. Server dikabari tanpa ditunggu, supaya logout
  /// tetap langsung jalan saat offline.
  Future<void> logout() async {
    final refreshToken = await _tokens.readRefreshToken();
    await _tokens.clear();
    if (refreshToken != null) {
      unawaited(_api.logout(refreshToken).then((_) {}, onError: (_) {}));
    }
  }

  Future<void> _save(AuthTokens tokens) => _tokens.save(
    accessToken: tokens.accessToken,
    refreshToken: tokens.refreshToken,
  );
}
