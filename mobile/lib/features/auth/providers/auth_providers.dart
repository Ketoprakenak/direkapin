import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/auth/session_provider.dart';
import '../data/auth_api.dart';
import '../data/auth_repository.dart';

part 'auth_providers.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => AuthRepository(
  AuthApi(ref.watch(apiClientProvider)),
  ref.watch(tokenStorageProvider),
);
