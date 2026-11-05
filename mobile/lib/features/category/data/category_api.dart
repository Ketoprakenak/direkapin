import 'package:dio/dio.dart';

import '../../../core/api/api_error.dart';
import 'category_models.dart';

class CategoryApi {
  const CategoryApi(this._dio);

  final Dio _dio;

  Future<List<Category>> list({
    required TxType type,
    required bool includeHidden,
  }) => apiCall(() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/categories',
      queryParameters: {'type': type.apiValue, 'includeHidden': includeHidden},
    );
    return (response.data!['items'] as List)
        .map((item) => Category.fromJson(item as Map<String, dynamic>))
        .toList();
  });

  Future<void> create(Map<String, Object?> data) =>
      apiCall(() => _dio.post<void>('/categories', data: data));

  Future<void> update(String id, Map<String, Object?> data) =>
      apiCall(() => _dio.patch<void>('/categories/$id', data: data));

  Future<void> delete(String id) =>
      apiCall(() => _dio.delete<void>('/categories/$id'));
}
