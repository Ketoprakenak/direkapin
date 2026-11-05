import 'package:dio/dio.dart';

import '../../../core/api/api_error.dart';
import 'wallet_models.dart';

class WalletApi {
  const WalletApi(this._dio);

  final Dio _dio;

  Future<List<Wallet>> list({required bool includeArchived}) => apiCall(() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/wallets',
      queryParameters: {'includeArchived': includeArchived},
    );
    return (response.data!['items'] as List)
        .map((item) => Wallet.fromJson(item as Map<String, dynamic>))
        .toList();
  });

  Future<void> create(Map<String, Object?> data) =>
      apiCall(() => _dio.post<void>('/wallets', data: data));

  Future<void> update(String id, Map<String, Object?> data) =>
      apiCall(() => _dio.patch<void>('/wallets/$id', data: data));

  Future<void> delete(String id) =>
      apiCall(() => _dio.delete<void>('/wallets/$id'));

  // shortcut: hanya 100 transfer terbaru, tambah "muat lagi" jika riwayatnya melebihi itu.
  Future<List<Transfer>> transfers() => apiCall(() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/transfers',
      queryParameters: {'limit': 100},
    );
    return (response.data!['items'] as List)
        .map((item) => Transfer.fromJson(item as Map<String, dynamic>))
        .toList();
  });

  Future<void> createTransfer(Map<String, Object?> data) =>
      apiCall(() => _dio.post<void>('/transfers', data: data));

  Future<void> updateTransfer(String id, Map<String, Object?> data) =>
      apiCall(() => _dio.patch<void>('/transfers/$id', data: data));

  Future<void> deleteTransfer(String id) =>
      apiCall(() => _dio.delete<void>('/transfers/$id'));
}
