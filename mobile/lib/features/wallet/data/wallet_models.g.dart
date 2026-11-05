// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Wallet _$WalletFromJson(Map<String, dynamic> json) => _Wallet(
  id: json['id'] as String,
  name: json['name'] as String,
  type: $enumDecode(_$WalletTypeEnumMap, json['type']),
  initialBalance: (json['initialBalance'] as num).toInt(),
  balance: (json['balance'] as num).toInt(),
  icon: json['icon'] as String,
  color: json['color'] as String,
  isArchived: json['isArchived'] as bool,
  sortOrder: (json['sortOrder'] as num).toInt(),
);

Map<String, dynamic> _$WalletToJson(_Wallet instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': _$WalletTypeEnumMap[instance.type]!,
  'initialBalance': instance.initialBalance,
  'balance': instance.balance,
  'icon': instance.icon,
  'color': instance.color,
  'isArchived': instance.isArchived,
  'sortOrder': instance.sortOrder,
};

const _$WalletTypeEnumMap = {
  WalletType.cash: 'CASH',
  WalletType.bank: 'BANK',
  WalletType.ewallet: 'EWALLET',
};

_WalletRef _$WalletRefFromJson(Map<String, dynamic> json) => _WalletRef(
  id: json['id'] as String,
  name: json['name'] as String,
  icon: json['icon'] as String,
  color: json['color'] as String,
);

Map<String, dynamic> _$WalletRefToJson(_WalletRef instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'color': instance.color,
    };

_Transfer _$TransferFromJson(Map<String, dynamic> json) => _Transfer(
  id: json['id'] as String,
  fromWallet: WalletRef.fromJson(json['fromWallet'] as Map<String, dynamic>),
  toWallet: WalletRef.fromJson(json['toWallet'] as Map<String, dynamic>),
  amount: (json['amount'] as num).toInt(),
  occurredAt: DateTime.parse(json['occurredAt'] as String),
  note: json['note'] as String?,
);

Map<String, dynamic> _$TransferToJson(_Transfer instance) => <String, dynamic>{
  'id': instance.id,
  'fromWallet': instance.fromWallet,
  'toWallet': instance.toWallet,
  'amount': instance.amount,
  'occurredAt': instance.occurredAt.toIso8601String(),
  'note': instance.note,
};
