import 'package:dio/dio.dart';

import '../../../core/api/api_error.dart';
import '../../auth/data/auth_models.dart';

class SettingsApi {
  const SettingsApi(this._dio);

  final Dio _dio;

  Future<User> me() => apiCall(() async {
    final response = await _dio.get<Map<String, dynamic>>('/me');
    return User.fromJson(response.data!);
  });

  Future<void> updateReminderTime(String time) => apiCall(() async {
    await _dio.patch<void>('/me', data: {'reminderTime': time});
  });
}
