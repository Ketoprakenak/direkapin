import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_error.dart';
import '../../budget/providers/budget_providers.dart';
import '../../calendar/providers/calendar_providers.dart';
import '../../recurring/providers/recurring_providers.dart';
import '../../report/providers/report_providers.dart';
import '../../transaction/providers/transaction_providers.dart';
import '../../wallet/providers/wallet_providers.dart';
import '../data/dashboard_models.dart';

part 'dashboard_providers.g.dart';

@riverpod
Future<Dashboard> dashboard(Ref ref) async {
  final dio = ref.watch(apiClientProvider);
  return apiCall(() async {
    final response = await dio.get<Map<String, dynamic>>('/dashboard');
    return Dashboard.fromJson(response.data!);
  });
}

/// Dipanggil setelah data uang berubah, supaya saldo dan Beranda langsung ter-update.
void refreshMoney(WidgetRef ref) {
  ref.invalidate(dashboardProvider);
  ref.invalidate(calendarMonthProvider);
  ref.invalidate(dayDetailProvider);
  ref.invalidate(walletsProvider);
  ref.invalidate(transfersProvider);
  ref.invalidate(walletTransactionsProvider);
  ref.invalidate(lastUsedWalletIdProvider);
  ref.invalidate(recentTransactionsProvider);
  ref.invalidate(reportProvider);
  ref.invalidate(periodTransactionsProvider);
  ref.invalidate(searchTransactionsProvider);
  ref.invalidate(budgetsProvider);
  ref.invalidate(recurringDueProvider);
  ref.invalidate(recurringListProvider);
}
