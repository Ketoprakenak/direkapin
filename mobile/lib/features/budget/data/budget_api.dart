import 'package:dio/dio.dart';

import '../../../core/api/api_error.dart';
import 'budget_models.dart';

class BudgetApi {
  const BudgetApi(this._dio);

  final Dio _dio;

  Future<List<Budget>> list(String month) => apiCall(() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/budgets',
      queryParameters: {'month': month},
    );
    return (response.data!['items'] as List)
        .map((item) => Budget.fromJson(item as Map<String, dynamic>))
        .toList();
  });

  Future<void> create(Map<String, Object?> data) =>
      apiCall(() => _dio.post<void>('/budgets', data: data));

  /// [data] wajib berisi `month`: perubahan berlaku mulai bulan itu.
  Future<void> update(String id, Map<String, Object?> data) =>
      apiCall(() => _dio.patch<void>('/budgets/$id', data: data));

  Future<void> delete(String id, String month) => apiCall(
    () => _dio.delete<void>('/budgets/$id', queryParameters: {'month': month}),
  );
}
