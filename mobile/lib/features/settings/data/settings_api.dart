import 'dart:typed_data';

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

  Future<void> updateName(String name) => apiCall(() async {
    await _dio.patch<void>('/me', data: {'name': name});
  });

  Future<void> updateReminderTime(String time) => apiCall(() async {
    await _dio.patch<void>('/me', data: {'reminderTime': time});
  });

  Future<void> updateHeatmap(HeatmapSetting heatmap) => apiCall(() async {
    await _dio.patch<void>('/me', data: {'heatmap': heatmap.toJson()});
  });

  Future<void> uploadAvatar(String filePath) => apiCall(
    () => _dio.put<void>(
      '/me/avatar',
      data: FormData.fromMap({
        'file': MultipartFile.fromFileSync(
          filePath,
          filename: 'avatar.jpg',
          contentType: DioMediaType('image', 'jpeg'),
        ),
      }),
      options: Options(sendTimeout: const Duration(seconds: 60)),
    ),
  );

  Future<void> deleteAvatar() => apiCall(() => _dio.delete<void>('/me/avatar'));

  /// Lewat dio, bukan URL gambar biasa, supaya token ikut dipasang.
  Future<Uint8List> avatarBytes() => apiCall(() async {
    final response = await _dio.get<List<int>>(
      '/me/avatar',
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data!);
  });
}
