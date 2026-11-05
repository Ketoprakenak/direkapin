import 'package:freezed_annotation/freezed_annotation.dart';

import '../../attachment/data/attachment_models.dart';
import '../../category/data/category_models.dart';
import '../../wallet/data/wallet_models.dart';

part 'transaction_models.freezed.dart';
part 'transaction_models.g.dart';

@freezed
abstract class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    required TxType type,
    required int amount,
    required DateTime occurredAt,
    String? note,
    required WalletRef wallet,
    required CategoryRef category,
    required List<Attachment> attachments,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
}
