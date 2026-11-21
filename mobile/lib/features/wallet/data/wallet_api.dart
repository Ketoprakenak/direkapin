import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_error.dart';
import 'wallet_models.dart';

class WalletApi {
  const WalletApi(this._dio);

  final Dio _dio;

  Future<List<Wallet>> list({
    required bool includeArchived,
    bool includeSavings = false,
  }) => apiCall(() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/wallets',
      queryParameters: {
        'includeArchived': includeArchived,
        'includeSavings': includeSavings,
      },
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

  Future<void> createSavings(Map<String, Object?> data) =>
      apiCall(() => _dio.post<void>('/savings', data: data));

  Future<void> updateSavingsTarget(String id, int? targetAmount) => apiCall(
    () =>
        _dio.patch<void>('/savings/$id', data: {'targetAmount': targetAmount}),
  );

  Future<void> deleteSavings(String id, {String? toWalletId}) => apiCall(
    () => _dio.delete<void>(
      '/savings/$id',
      queryParameters: {'toWalletId': ?toWalletId},
    ),
  );

  // shortcut: hanya 100 transfer terbaru, tambah "muat lagi" jika riwayatnya melebihi itu.
  Future<List<Transfer>> transfers({String? walletId}) => apiCall(() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/transfers',
      queryParameters: {'limit': 100, 'wallet': ?walletId},
    );
    return (response.data!['items'] as List)
        .map((item) => Transfer.fromJson(item as Map<String, dynamic>))
        .toList();
  });

  /// Transfer masuk/keluar satu dompet per halaman, terbaru di atas.
  Future<ApiPage<Transfer>> transferPage({
    required String walletId,
    String? cursor,
  }) => apiCall(() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/transfers',
      queryParameters: {'limit': 50, 'wallet': walletId, 'cursor': ?cursor},
    );
    return (
      items: (response.data!['items'] as List)
          .map((item) => Transfer.fromJson(item as Map<String, dynamic>))
          .toList(),
      nextCursor: response.data!['nextCursor'] as String?,
    );
  });

  Future<void> createTransfer(Map<String, Object?> data) =>
      apiCall(() => _dio.post<void>('/transfers', data: data));

  Future<void> updateTransfer(String id, Map<String, Object?> data) =>
      apiCall(() => _dio.patch<void>('/transfers/$id', data: data));

  Future<void> deleteTransfer(String id) =>
      apiCall(() => _dio.delete<void>('/transfers/$id'));
}
