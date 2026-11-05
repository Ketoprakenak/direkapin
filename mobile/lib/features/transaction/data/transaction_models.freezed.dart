// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Transaction {

 String get id; TxType get type; int get amount; DateTime get occurredAt; String? get note; WalletRef get wallet; CategoryRef get category; List<Attachment> get attachments;
/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionCopyWith<Transaction> get copyWith => _$TransactionCopyWithImpl<Transaction>(this as Transaction, _$identity);

  /// Serializes this Transaction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Transaction;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Transaction&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.occurredAt, _this.occurredAt) || other.occurredAt == _this.occurredAt)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.wallet, _this.wallet) || other.wallet == _this.wallet)&&(identical(other.category, _this.category) || other.category == _this.category)&&const DeepCollectionEquality().equals(other.attachments, _this.attachments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Transaction;
  return Object.hash(runtimeType,_this.id,_this.type,_this.amount,_this.occurredAt,_this.note,_this.wallet,_this.category,const DeepCollectionEquality().hash(_this.attachments));
}

@override
String toString() {
  final _this = this as Transaction;
  return 'Transaction(id: ${_this.id}, type: ${_this.type}, amount: ${_this.amount}, occurredAt: ${_this.occurredAt}, note: ${_this.note}, wallet: ${_this.wallet}, category: ${_this.category}, attachments: ${_this.attachments})';
}


}

/// @nodoc
abstract mixin class $TransactionCopyWith<$Res>  {
  factory $TransactionCopyWith(Transaction value, $Res Function(Transaction) _then) = _$TransactionCopyWithImpl;
@useResult
$Res call({
 String id, TxType type, int amount, DateTime occurredAt, String? note, WalletRef wallet, CategoryRef category, List<Attachment> attachments
});


$WalletRefCopyWith<$Res> get wallet;$CategoryRefCopyWith<$Res> get category;

}
/// @nodoc
class _$TransactionCopyWithImpl<$Res>
    implements $TransactionCopyWith<$Res> {
  _$TransactionCopyWithImpl(this._self, this._then);

  final Transaction _self;
  final $Res Function(Transaction) _then;

/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? amount = null,Object? occurredAt = null,Object? note = freezed,Object? wallet = null,Object? category = null,Object? attachments = null,}) {
  return _then(Transaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TxType,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,wallet: null == wallet ? _self.wallet : wallet // ignore: cast_nullable_to_non_nullable
as WalletRef,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as CategoryRef,attachments: null == attachments ? _self.attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<Attachment>,
  ));
}
/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WalletRefCopyWith<$Res> get wallet {
  
  return $WalletRefCopyWith<$Res>(_self.wallet, (value) {
    return _then(_self.copyWith(wallet: value));
  });
}/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategoryRefCopyWith<$Res> get category {
  
  return $CategoryRefCopyWith<$Res>(_self.category, (value) {
    return _then(_self.copyWith(category: value));
  });
}
}


/// Adds pattern-matching-related methods to [Transaction].
extension TransactionPatterns on Transaction {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Transaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Transaction() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Transaction value)  $default,){
final _that = this;
switch (_that) {
case _Transaction():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Transaction value)?  $default,){
final _that = this;
switch (_that) {
case _Transaction() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  TxType type,  int amount,  DateTime occurredAt,  String? note,  WalletRef wallet,  CategoryRef category,  List<Attachment> attachments)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Transaction() when $default != null:
return $default(_that.id,_that.type,_that.amount,_that.occurredAt,_that.note,_that.wallet,_that.category,_that.attachments);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  TxType type,  int amount,  DateTime occurredAt,  String? note,  WalletRef wallet,  CategoryRef category,  List<Attachment> attachments)  $default,) {final _that = this;
switch (_that) {
case _Transaction():
return $default(_that.id,_that.type,_that.amount,_that.occurredAt,_that.note,_that.wallet,_that.category,_that.attachments);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  TxType type,  int amount,  DateTime occurredAt,  String? note,  WalletRef wallet,  CategoryRef category,  List<Attachment> attachments)?  $default,) {final _that = this;
switch (_that) {
case _Transaction() when $default != null:
return $default(_that.id,_that.type,_that.amount,_that.occurredAt,_that.note,_that.wallet,_that.category,_that.attachments);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Transaction implements Transaction {
  const _Transaction({required this.id, required this.type, required this.amount, required this.occurredAt, this.note, required this.wallet, required this.category, required  List<Attachment> attachments}): _attachments = attachments;
  factory _Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);

@override final  String id;
@override final  TxType type;
@override final  int amount;
@override final  DateTime occurredAt;
@override final  String? note;
@override final  WalletRef wallet;
@override final  CategoryRef category;
 final  List<Attachment> _attachments;
@override List<Attachment> get attachments {
  if (_attachments is EqualUnmodifiableListView) return _attachments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attachments);
}


/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionCopyWith<_Transaction> get copyWith => __$TransactionCopyWithImpl<_Transaction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransactionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Transaction&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.note, note) || other.note == note)&&(identical(other.wallet, wallet) || other.wallet == wallet)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other.attachments, _attachments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,type,amount,occurredAt,note,wallet,category,const DeepCollectionEquality().hash(_attachments));
}

@override
String toString() {
    return 'Transaction(id: $id, type: $type, amount: $amount, occurredAt: $occurredAt, note: $note, wallet: $wallet, category: $category, attachments: $attachments)';
}


}

/// @nodoc
abstract mixin class _$TransactionCopyWith<$Res> implements $TransactionCopyWith<$Res> {
  factory _$TransactionCopyWith(_Transaction value, $Res Function(_Transaction) _then) = __$TransactionCopyWithImpl;
@override @useResult
$Res call({
 String id, TxType type, int amount, DateTime occurredAt, String? note, WalletRef wallet, CategoryRef category, List<Attachment> attachments
});


@override $WalletRefCopyWith<$Res> get wallet;@override $CategoryRefCopyWith<$Res> get category;

}
/// @nodoc
class __$TransactionCopyWithImpl<$Res>
    implements _$TransactionCopyWith<$Res> {
  __$TransactionCopyWithImpl(this._self, this._then);

  final _Transaction _self;
  final $Res Function(_Transaction) _then;

/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? amount = null,Object? occurredAt = null,Object? note = freezed,Object? wallet = null,Object? category = null,Object? attachments = null,}) {
  return _then(_Transaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TxType,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,wallet: null == wallet ? _self.wallet : wallet // ignore: cast_nullable_to_non_nullable
as WalletRef,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as CategoryRef,attachments: null == attachments ? _self._attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<Attachment>,
  ));
}

/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WalletRefCopyWith<$Res> get wallet {
  
  return $WalletRefCopyWith<$Res>(_self.wallet, (value) {
    return _then(_self.copyWith(wallet: value));
  });
}/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategoryRefCopyWith<$Res> get category {
  
  return $CategoryRefCopyWith<$Res>(_self.category, (value) {
    return _then(_self.copyWith(category: value));
  });
}
}

// dart format on
