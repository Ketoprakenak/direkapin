import 'package:freezed_annotation/freezed_annotation.dart';

import '../../category/data/category_models.dart';
import '../../wallet/data/wallet_models.dart';

part 'recurring_models.freezed.dart';
part 'recurring_models.g.dart';

/// Kejadian berikutnya sebuah aturan: [month] `YYYY-MM`, [dueDate] `YYYY-MM-DD`.
@freezed
abstract class RecurringNext with _$RecurringNext {
  const factory RecurringNext({
    required String month,
    required String dueDate,
  }) = _RecurringNext;

  factory RecurringNext.fromJson(Map<String, dynamic> json) =>
      _$RecurringNextFromJson(json);
}

/// Aturan transaksi berulang bulanan (FIN-15).
@freezed
abstract class Recurring with _$Recurring {
  const factory Recurring({
    required String id,
    required TxType type,
    required int amount,
    String? note,
    required int dayOfMonth,
    required String startMonth,
    String? endMonth,
    String? lastHandledMonth,
    required WalletRef wallet,
    required CategoryRef category,
    RecurringNext? next,
  }) = _Recurring;

  factory Recurring.fromJson(Map<String, dynamic> json) =>
      _$RecurringFromJson(json);
}

/// Aturan yang sudah jatuh tempo dan menunggu dicatat/dilewati.
@freezed
abstract class RecurringDue with _$RecurringDue {
  const factory RecurringDue({
    required Recurring recurring,
    required String month,
    required String dueDate,
  }) = _RecurringDue;

  factory RecurringDue.fromJson(Map<String, dynamic> json) =>
      _$RecurringDueFromJson(json);
}
