import 'package:freezed_annotation/freezed_annotation.dart';

import '../../category/data/category_models.dart';

part 'budget_models.freezed.dart';
part 'budget_models.g.dart';

/// Budget multi kategori yang berlaku di satu bulan (FIN-12, D-60).
@freezed
abstract class Budget with _$Budget {
  const Budget._();

  const factory Budget({
    required String id,
    required String name,
    required int limitAmount,
    required String startMonth,
    String? endMonth,
    required List<CategoryRef> categories,
    required int spent,
  }) = _Budget;

  factory Budget.fromJson(Map<String, dynamic> json) => _$BudgetFromJson(json);

  double get ratio => spent / limitAmount;
  int get remaining => limitAmount - spent;
}

/// Ambang peringatan: kuning mulai 80%, merah mulai 100%.
enum BudgetLevel { normal, warning, over }

const budgetWarningRatio = 0.8;

BudgetLevel budgetLevel(double ratio) => ratio >= 1
    ? BudgetLevel.over
    : ratio >= budgetWarningRatio
    ? BudgetLevel.warning
    : BudgetLevel.normal;
