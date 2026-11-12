import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_error.dart';
import '../../transaction/data/transaction_models.dart';
import '../../transaction/providers/transaction_providers.dart';
import '../data/report_models.dart';

part 'report_providers.g.dart';

/// [key] = Senin awal minggu (mingguan), `YYYY-MM` (bulanan), atau
/// `YYYY-MM-DD_YYYY-MM-DD` (rentang).
@riverpod
Future<Report> report(
  Ref ref,
  ReportType type,
  String key, {
  String? walletId,
}) async {
  final dio = ref.watch(apiClientProvider);
  final (path, query) = switch (type) {
    ReportType.weekly => ('/reports/weekly', {'start': key}),
    ReportType.monthly => ('/reports/monthly', {'month': key}),
    ReportType.range => (
      '/reports/range',
      {'from': key.split('_').first, 'to': key.split('_').last},
    ),
  };
  return apiCall(() async {
    final response = await dio.get<Map<String, dynamic>>(
      path,
      queryParameters: {...query, 'wallet': ?walletId},
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
