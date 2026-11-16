// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receivable_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Receivable _$ReceivableFromJson(Map<String, dynamic> json) => _Receivable(
  id: json['id'] as String,
  direction:
      $enumDecodeNullable(_$ReceivableDirectionEnumMap, json['direction']) ??
      ReceivableDirection.receivable,
  title: json['title'] as String,
  date: json['date'] as String,
  note: json['note'] as String?,
  total: (json['total'] as num).toInt(),
  remaining: (json['remaining'] as num).toInt(),
  loan: json['loan'] == null
      ? null
      : ReceivableLoan.fromJson(json['loan'] as Map<String, dynamic>),
  debtors: (json['debtors'] as List<dynamic>)
      .map((e) => Debtor.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ReceivableToJson(_Receivable instance) =>
    <String, dynamic>{
      'id': instance.id,
      'direction': _$ReceivableDirectionEnumMap[instance.direction]!,
      'title': instance.title,
      'date': instance.date,
      'note': instance.note,
      'total': instance.total,
      'remaining': instance.remaining,
      'loan': instance.loan,
      'debtors': instance.debtors,
    };

const _$ReceivableDirectionEnumMap = {
  ReceivableDirection.receivable: 'RECEIVABLE',
  ReceivableDirection.payable: 'PAYABLE',
};

_ReceivableLoan _$ReceivableLoanFromJson(Map<String, dynamic> json) =>
    _ReceivableLoan(
      transactionId: json['transactionId'] as String,
      amount: (json['amount'] as num).toInt(),
      wallet: WalletRef.fromJson(json['wallet'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ReceivableLoanToJson(_ReceivableLoan instance) =>
    <String, dynamic>{
      'transactionId': instance.transactionId,
      'amount': instance.amount,
      'wallet': instance.wallet,
    };

_Debtor _$DebtorFromJson(Map<String, dynamic> json) => _Debtor(
  id: json['id'] as String,
  name: json['name'] as String,
  amount: (json['amount'] as num).toInt(),
  paid: (json['paid'] as num).toInt(),
  remaining: (json['remaining'] as num).toInt(),
  payments: (json['payments'] as List<dynamic>)
      .map((e) => DebtorPayment.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$DebtorToJson(_Debtor instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'amount': instance.amount,
  'paid': instance.paid,
  'remaining': instance.remaining,
  'payments': instance.payments,
};

_DebtorPayment _$DebtorPaymentFromJson(Map<String, dynamic> json) =>
    _DebtorPayment(
      transactionId: json['transactionId'] as String,
      amount: (json['amount'] as num).toInt(),
      occurredAt: DateTime.parse(json['occurredAt'] as String),
      wallet: WalletRef.fromJson(json['wallet'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DebtorPaymentToJson(_DebtorPayment instance) =>
    <String, dynamic>{
      'transactionId': instance.transactionId,
      'amount': instance.amount,
      'occurredAt': instance.occurredAt.toIso8601String(),
      'wallet': instance.wallet,
    };
