import 'package:dio/dio.dart';

import '../../../core/api/api_error.dart';
import '../../transaction/data/transaction_models.dart';
import 'recurring_models.dart';

class RecurringApi {
  const RecurringApi(this._dio);

  final Dio _dio;

  Future<List<Recurring>> list() => apiCall(() async {
    final response = await _dio.get<Map<String, dynamic>>('/recurring');
    return (response.data!['items'] as List)
        .map((item) => Recurring.fromJson(item as Map<String, dynamic>))
        .toList();
  });

  Future<void> create(Map<String, Object?> data) =>
      apiCall(() => _dio.post<void>('/recurring', data: data));

  Future<void> update(String id, Map<String, Object?> data) =>
      apiCall(() => _dio.patch<void>('/recurring/$id', data: data));

  Future<void> delete(String id) =>
      apiCall(() => _dio.delete<void>('/recurring/$id'));

  Future<List<RecurringDue>> due() => apiCall(() async {
    final response = await _dio.get<Map<String, dynamic>>('/recurring/due');
    return (response.data!['items'] as List)
        .map((item) => RecurringDue.fromJson(item as Map<String, dynamic>))
        .toList();
  });

  /// [data] wajib berisi `month`; opsional `amount`, `occurredAt`, `walletId`, `note`.
  Future<Transaction> record(String id, Map<String, Object?> data) =>
      apiCall(() async {
        final response = await _dio.post<Map<String, dynamic>>(
          '/recurring/$id/record',
          data: data,
        );
        return Transaction.fromJson(response.data!);
      });

  Future<void> skip(String id, String month) => apiCall(
    () => _dio.post<void>('/recurring/$id/skip', data: {'month': month}),
  );
}
