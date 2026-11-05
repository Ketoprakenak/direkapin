import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../../auth/data/auth_models.dart';
import '../data/settings_api.dart';

part 'settings_providers.g.dart';

@riverpod
SettingsApi settingsApi(Ref ref) => SettingsApi(ref.watch(apiClientProvider));

@riverpod
Future<User> me(Ref ref) => ref.watch(settingsApiProvider).me();
