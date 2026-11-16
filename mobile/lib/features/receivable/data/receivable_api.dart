import 'package:dio/dio.dart';

import '../../../core/api/api_error.dart';
import 'receivable_models.dart';

class ReceivableApi {
  const ReceivableApi(this._dio);

  final Dio _dio;

  Future<({List<Receivable> items, int totalRemaining})> list({
    required bool all,
    required ReceivableDirection direction,
  }) => apiCall(() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/receivables',
      queryParameters: {
        'status': all ? 'all' : 'open',
        'direction': direction.isPayable ? 'payable' : 'receivable',
      },
    );
    final data = response.data!;
    return (
      items: (data['items'] as List)
          .map((item) => Receivable.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalRemaining: data['totalRemaining'] as int,
    );
  });

  Future<void> create(Map<String, Object?> data) =>
      apiCall(() => _dio.post<void>('/receivables', data: data));

  Future<void> update(String id, Map<String, Object?> data) =>
      apiCall(() => _dio.patch<void>('/receivables/$id', data: data));

  Future<void> delete(String id) =>
      apiCall(() => _dio.delete<void>('/receivables/$id'));

  Future<void> updateDebtor(String debtorId, Map<String, Object?> data) =>
      apiCall(
        () => _dio.patch<void>('/receivables/debtors/$debtorId', data: data),
      );

  Future<void> pay(String debtorId, Map<String, Object?> data) => apiCall(
    () =>
        _dio.post<void>('/receivables/debtors/$debtorId/payments', data: data),
  );
}
