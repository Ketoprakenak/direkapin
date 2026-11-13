import 'package:dio/dio.dart';

import '../../../core/api/api_error.dart';
import 'activity_models.dart';

class ActivityApi {
  const ActivityApi(this._dio);

  final Dio _dio;

  /// Kegiatan di rentang [from]..[to] (`YYYY-MM-DD`, inklusif).
  Future<List<Activity>> list(String from, String to) => apiCall(() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/activities',
      queryParameters: {'from': from, 'to': to},
    );
    return (response.data!['items'] as List)
        .map((item) => Activity.fromJson(item as Map<String, dynamic>))
        .toList();
  });

  /// ID kegiatan baru, untuk upload fotonya.
  Future<String> create(Map<String, Object?> data) => apiCall(() async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/activities',
      data: data,
    );
    return response.data!['id'] as String;
  });

  Future<void> update(String id, Map<String, Object?> data) =>
      apiCall(() => _dio.patch<void>('/activities/$id', data: data));

  Future<void> delete(String id) =>
      apiCall(() => _dio.delete<void>('/activities/$id'));
}
