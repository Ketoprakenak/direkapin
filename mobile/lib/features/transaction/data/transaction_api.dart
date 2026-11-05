import 'package:dio/dio.dart';

import '../../../core/api/api_error.dart';
import 'transaction_models.dart';

class TransactionApi {
  const TransactionApi(this._dio);

  final Dio _dio;

  Future<List<Transaction>> list({
    String? walletId,
    String? categoryId,
    String? from,
    String? to,
    required int limit,
  }) => apiCall(() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/transactions',
      queryParameters: {
        'limit': limit,
        'wallet': ?walletId,
        'category': ?categoryId,
        'from': ?from,
        'to': ?to,
      },
    );
    return (response.data!['items'] as List)
        .map((item) => Transaction.fromJson(item as Map<String, dynamic>))
        .toList();
  });

  /// ID transaksi baru, untuk upload fotonya.
  Future<String> create(Map<String, Object?> data) => apiCall(() async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/transactions',
      data: data,
    );
    return response.data!['id'] as String;
  });

  Future<void> update(String id, Map<String, Object?> data) =>
      apiCall(() => _dio.patch<void>('/transactions/$id', data: data));

  Future<void> delete(String id) =>
      apiCall(() => _dio.delete<void>('/transactions/$id'));
}
