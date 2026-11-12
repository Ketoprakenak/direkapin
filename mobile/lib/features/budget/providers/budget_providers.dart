import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/format/money.dart';
import '../data/budget_api.dart';
import '../data/budget_models.dart';

part 'budget_providers.g.dart';

@riverpod
BudgetApi budgetApi(Ref ref) => BudgetApi(ref.watch(apiClientProvider));

/// [month] = `YYYY-MM`.
@riverpod
Future<List<Budget>> budgets(Ref ref, String month) =>
    ref.watch(budgetApiProvider).list(month);

/// Pesan untuk budget yang baru saja melewati 80% atau 100% karena pengeluaran
/// [amount] di [categoryId]. [budgets] = data setelah pengeluaran tersimpan.
List<String> budgetAlerts(
  List<Budget> budgets,
  String categoryId,
  int amount,
) => [
  for (final budget in budgets)
    if (budget.categories.any((category) => category.id == categoryId))
      if (_crossed(budget, amount) case final level?)
        level == BudgetLevel.over
            ? 'Budget ${budget.name} terlewati: '
                  '${formatRupiah(budget.spent)} dari ${formatRupiah(budget.limitAmount)}'
            : 'Budget ${budget.name} sudah ${(budget.ratio * 100).floor()}%: '
                  'sisa ${formatRupiah(budget.remaining)}',
];

/// Level baru jika [amount] membuat budget naik level; null jika tetap.
BudgetLevel? _crossed(Budget budget, int amount) {
  final after = budgetLevel(budget.ratio);
  final before = budgetLevel((budget.spent - amount) / budget.limitAmount);
  return after.index > before.index ? after : null;
}
