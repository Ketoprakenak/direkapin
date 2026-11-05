import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_error.dart';
import '../../transaction/data/transaction_models.dart';
import '../../transaction/providers/transaction_providers.dart';
import '../data/report_models.dart';

part 'report_providers.g.dart';

/// [key] = tanggal (harian), Senin awal minggu (mingguan), atau `YYYY-MM` (bulanan).
@riverpod
Future<Report> report(
  Ref ref,
  ReportType type,
  String key, {
  String? walletId,
}) async {
  final dio = ref.watch(apiClientProvider);
  final (path, param) = switch (type) {
    ReportType.daily => ('/reports/daily', 'date'),
    ReportType.weekly => ('/reports/weekly', 'start'),
    ReportType.monthly => ('/reports/monthly', 'month'),
  };
  return apiCall(() async {
    final response = await dio.get<Map<String, dynamic>>(
      path,
      queryParameters: {param: key, 'wallet': ?walletId},
    );
    return Report.fromJson(response.data!);
  });
}

// shortcut: hanya 100 transaksi terbaru, tambah "muat lagi" jika satu periode melebihi itu.
@riverpod
Future<List<Transaction>> periodTransactions(
  Ref ref,
  String from,
  String to, {
  String? walletId,
  String? categoryId,
}) => ref
    .watch(transactionApiProvider)
    .list(
      from: from,
      to: to,
      walletId: walletId,
      categoryId: categoryId,
      limit: 100,
    );
