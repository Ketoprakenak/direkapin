// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Transaction _$TransactionFromJson(Map<String, dynamic> json) => _Transaction(
  id: json['id'] as String,
  type: $enumDecode(_$TxTypeEnumMap, json['type']),
  amount: (json['amount'] as num).toInt(),
  occurredAt: DateTime.parse(json['occurredAt'] as String),
  note: json['note'] as String?,
  wallet: WalletRef.fromJson(json['wallet'] as Map<String, dynamic>),
  category: CategoryRef.fromJson(json['category'] as Map<String, dynamic>),
  attachments: (json['attachments'] as List<dynamic>)
      .map((e) => Attachment.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TransactionToJson(_Transaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$TxTypeEnumMap[instance.type]!,
      'amount': instance.amount,
      'occurredAt': instance.occurredAt.toIso8601String(),
      'note': instance.note,
      'wallet': instance.wallet,
      'category': instance.category,
      'attachments': instance.attachments,
    };

const _$TxTypeEnumMap = {TxType.income: 'INCOME', TxType.expense: 'EXPENSE'};
