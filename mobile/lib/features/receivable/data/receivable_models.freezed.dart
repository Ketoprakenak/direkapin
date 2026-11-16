// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'receivable_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Receivable {

 String get id; ReceivableDirection get direction; String get title; String get date; String? get note; int get total; int get remaining; ReceivableLoan? get loan; List<Debtor> get debtors;
/// Create a copy of Receivable
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReceivableCopyWith<Receivable> get copyWith => _$ReceivableCopyWithImpl<Receivable>(this as Receivable, _$identity);

  /// Serializes this Receivable to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Receivable;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Receivable&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.direction, _this.direction) || other.direction == _this.direction)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.total, _this.total) || other.total == _this.total)&&(identical(other.remaining, _this.remaining) || other.remaining == _this.remaining)&&(identical(other.loan, _this.loan) || other.loan == _this.loan)&&const DeepCollectionEquality().equals(other.debtors, _this.debtors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Receivable;
  return Object.hash(runtimeType,_this.id,_this.direction,_this.title,_this.date,_this.note,_this.total,_this.remaining,_this.loan,const DeepCollectionEquality().hash(_this.debtors));
}

@override
String toString() {
  final _this = this as Receivable;
  return 'Receivable(id: ${_this.id}, direction: ${_this.direction}, title: ${_this.title}, date: ${_this.date}, note: ${_this.note}, total: ${_this.total}, remaining: ${_this.remaining}, loan: ${_this.loan}, debtors: ${_this.debtors})';
}


}

/// @nodoc
abstract mixin class $ReceivableCopyWith<$Res>  {
  factory $ReceivableCopyWith(Receivable value, $Res Function(Receivable) _then) = _$ReceivableCopyWithImpl;
@useResult
$Res call({
 String id, ReceivableDirection direction, String title, String date, String? note, int total, int remaining, ReceivableLoan? loan, List<Debtor> debtors
});


$ReceivableLoanCopyWith<$Res>? get loan;

}
/// @nodoc
class _$ReceivableCopyWithImpl<$Res>
    implements $ReceivableCopyWith<$Res> {
  _$ReceivableCopyWithImpl(this._self, this._then);

  final Receivable _self;
  final $Res Function(Receivable) _then;

/// Create a copy of Receivable
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? direction = null,Object? title = null,Object? date = null,Object? note = freezed,Object? total = null,Object? remaining = null,Object? loan = freezed,Object? debtors = null,}) {
  return _then(Receivable(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as ReceivableDirection,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as int,loan: freezed == loan ? _self.loan : loan // ignore: cast_nullable_to_non_nullable
as ReceivableLoan?,debtors: null == debtors ? _self.debtors : debtors // ignore: cast_nullable_to_non_nullable
as List<Debtor>,
  ));
}
/// Create a copy of Receivable
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReceivableLoanCopyWith<$Res>? get loan {
    if (_self.loan == null) {
    return null;
  }

  return $ReceivableLoanCopyWith<$Res>(_self.loan!, (value) {
    return _then(_self.copyWith(loan: value));
  });
}
}


/// Adds pattern-matching-related methods to [Receivable].
extension ReceivablePatterns on Receivable {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Receivable value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Receivable() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Receivable value)  $default,){
final _that = this;
switch (_that) {
case _Receivable():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Receivable value)?  $default,){
final _that = this;
switch (_that) {
case _Receivable() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  ReceivableDirection direction,  String title,  String date,  String? note,  int total,  int remaining,  ReceivableLoan? loan,  List<Debtor> debtors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Receivable() when $default != null:
return $default(_that.id,_that.direction,_that.title,_that.date,_that.note,_that.total,_that.remaining,_that.loan,_that.debtors);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  ReceivableDirection direction,  String title,  String date,  String? note,  int total,  int remaining,  ReceivableLoan? loan,  List<Debtor> debtors)  $default,) {final _that = this;
switch (_that) {
case _Receivable():
return $default(_that.id,_that.direction,_that.title,_that.date,_that.note,_that.total,_that.remaining,_that.loan,_that.debtors);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  ReceivableDirection direction,  String title,  String date,  String? note,  int total,  int remaining,  ReceivableLoan? loan,  List<Debtor> debtors)?  $default,) {final _that = this;
switch (_that) {
case _Receivable() when $default != null:
return $default(_that.id,_that.direction,_that.title,_that.date,_that.note,_that.total,_that.remaining,_that.loan,_that.debtors);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Receivable implements Receivable {
  const _Receivable({required this.id, this.direction = ReceivableDirection.receivable, required this.title, required this.date, this.note, required this.total, required this.remaining, this.loan, required  List<Debtor> debtors}): _debtors = debtors;
  factory _Receivable.fromJson(Map<String, dynamic> json) => _$ReceivableFromJson(json);

@override final  String id;
@override@JsonKey() final  ReceivableDirection direction;
@override final  String title;
@override final  String date;
@override final  String? note;
@override final  int total;
@override final  int remaining;
@override final  ReceivableLoan? loan;
 final  List<Debtor> _debtors;
@override List<Debtor> get debtors {
  if (_debtors is EqualUnmodifiableListView) return _debtors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_debtors);
}


/// Create a copy of Receivable
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReceivableCopyWith<_Receivable> get copyWith => __$ReceivableCopyWithImpl<_Receivable>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReceivableToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Receivable&&(identical(other.id, id) || other.id == id)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.title, title) || other.title == title)&&(identical(other.date, date) || other.date == date)&&(identical(other.note, note) || other.note == note)&&(identical(other.total, total) || other.total == total)&&(identical(other.remaining, remaining) || other.remaining == remaining)&&(identical(other.loan, loan) || other.loan == loan)&&const DeepCollectionEquality().equals(other.debtors, _debtors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,direction,title,date,note,total,remaining,loan,const DeepCollectionEquality().hash(_debtors));
}

@override
String toString() {
    return 'Receivable(id: $id, direction: $direction, title: $title, date: $date, note: $note, total: $total, remaining: $remaining, loan: $loan, debtors: $debtors)';
}


}

/// @nodoc
abstract mixin class _$ReceivableCopyWith<$Res> implements $ReceivableCopyWith<$Res> {
  factory _$ReceivableCopyWith(_Receivable value, $Res Function(_Receivable) _then) = __$ReceivableCopyWithImpl;
@override @useResult
$Res call({
 String id, ReceivableDirection direction, String title, String date, String? note, int total, int remaining, ReceivableLoan? loan, List<Debtor> debtors
});


@override $ReceivableLoanCopyWith<$Res>? get loan;

}
/// @nodoc
class __$ReceivableCopyWithImpl<$Res>
    implements _$ReceivableCopyWith<$Res> {
  __$ReceivableCopyWithImpl(this._self, this._then);

  final _Receivable _self;
  final $Res Function(_Receivable) _then;

/// Create a copy of Receivable
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? direction = null,Object? title = null,Object? date = null,Object? note = freezed,Object? total = null,Object? remaining = null,Object? loan = freezed,Object? debtors = null,}) {
  return _then(_Receivable(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as ReceivableDirection,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as int,loan: freezed == loan ? _self.loan : loan // ignore: cast_nullable_to_non_nullable
as ReceivableLoan?,debtors: null == debtors ? _self._debtors : debtors // ignore: cast_nullable_to_non_nullable
as List<Debtor>,
  ));
}

/// Create a copy of Receivable
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReceivableLoanCopyWith<$Res>? get loan {
    if (_self.loan == null) {
    return null;
  }

  return $ReceivableLoanCopyWith<$Res>(_self.loan!, (value) {
    return _then(_self.copyWith(loan: value));
  });
}
}


/// @nodoc
mixin _$ReceivableLoan {

 String get transactionId; int get amount; WalletRef get wallet;
/// Create a copy of ReceivableLoan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReceivableLoanCopyWith<ReceivableLoan> get copyWith => _$ReceivableLoanCopyWithImpl<ReceivableLoan>(this as ReceivableLoan, _$identity);

  /// Serializes this ReceivableLoan to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReceivableLoan;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReceivableLoan&&(identical(other.transactionId, _this.transactionId) || other.transactionId == _this.transactionId)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.wallet, _this.wallet) || other.wallet == _this.wallet));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReceivableLoan;
  return Object.hash(runtimeType,_this.transactionId,_this.amount,_this.wallet);
}

@override
String toString() {
  final _this = this as ReceivableLoan;
  return 'ReceivableLoan(transactionId: ${_this.transactionId}, amount: ${_this.amount}, wallet: ${_this.wallet})';
}


}

/// @nodoc
abstract mixin class $ReceivableLoanCopyWith<$Res>  {
  factory $ReceivableLoanCopyWith(ReceivableLoan value, $Res Function(ReceivableLoan) _then) = _$ReceivableLoanCopyWithImpl;
@useResult
$Res call({
 String transactionId, int amount, WalletRef wallet
});


$WalletRefCopyWith<$Res> get wallet;

}
/// @nodoc
class _$ReceivableLoanCopyWithImpl<$Res>
    implements $ReceivableLoanCopyWith<$Res> {
  _$ReceivableLoanCopyWithImpl(this._self, this._then);

  final ReceivableLoan _self;
  final $Res Function(ReceivableLoan) _then;

/// Create a copy of ReceivableLoan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? transactionId = null,Object? amount = null,Object? wallet = null,}) {
  return _then(ReceivableLoan(
transactionId: null == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,wallet: null == wallet ? _self.wallet : wallet // ignore: cast_nullable_to_non_nullable
as WalletRef,
  ));
}
/// Create a copy of ReceivableLoan
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WalletRefCopyWith<$Res> get wallet {
  
  return $WalletRefCopyWith<$Res>(_self.wallet, (value) {
    return _then(_self.copyWith(wallet: value));
  });
}
}


/// Adds pattern-matching-related methods to [ReceivableLoan].
extension ReceivableLoanPatterns on ReceivableLoan {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReceivableLoan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReceivableLoan() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReceivableLoan value)  $default,){
final _that = this;
switch (_that) {
case _ReceivableLoan():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReceivableLoan value)?  $default,){
final _that = this;
switch (_that) {
case _ReceivableLoan() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String transactionId,  int amount,  WalletRef wallet)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReceivableLoan() when $default != null:
return $default(_that.transactionId,_that.amount,_that.wallet);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String transactionId,  int amount,  WalletRef wallet)  $default,) {final _that = this;
switch (_that) {
case _ReceivableLoan():
return $default(_that.transactionId,_that.amount,_that.wallet);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String transactionId,  int amount,  WalletRef wallet)?  $default,) {final _that = this;
switch (_that) {
case _ReceivableLoan() when $default != null:
return $default(_that.transactionId,_that.amount,_that.wallet);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReceivableLoan implements ReceivableLoan {
  const _ReceivableLoan({required this.transactionId, required this.amount, required this.wallet});
  factory _ReceivableLoan.fromJson(Map<String, dynamic> json) => _$ReceivableLoanFromJson(json);

@override final  String transactionId;
@override final  int amount;
@override final  WalletRef wallet;

/// Create a copy of ReceivableLoan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReceivableLoanCopyWith<_ReceivableLoan> get copyWith => __$ReceivableLoanCopyWithImpl<_ReceivableLoan>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReceivableLoanToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReceivableLoan&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.wallet, wallet) || other.wallet == wallet));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,transactionId,amount,wallet);
}

@override
String toString() {
    return 'ReceivableLoan(transactionId: $transactionId, amount: $amount, wallet: $wallet)';
}


}

/// @nodoc
abstract mixin class _$ReceivableLoanCopyWith<$Res> implements $ReceivableLoanCopyWith<$Res> {
  factory _$ReceivableLoanCopyWith(_ReceivableLoan value, $Res Function(_ReceivableLoan) _then) = __$ReceivableLoanCopyWithImpl;
@override @useResult
$Res call({
 String transactionId, int amount, WalletRef wallet
});


@override $WalletRefCopyWith<$Res> get wallet;

}
/// @nodoc
class __$ReceivableLoanCopyWithImpl<$Res>
    implements _$ReceivableLoanCopyWith<$Res> {
  __$ReceivableLoanCopyWithImpl(this._self, this._then);

  final _ReceivableLoan _self;
  final $Res Function(_ReceivableLoan) _then;

/// Create a copy of ReceivableLoan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? transactionId = null,Object? amount = null,Object? wallet = null,}) {
  return _then(_ReceivableLoan(
transactionId: null == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,wallet: null == wallet ? _self.wallet : wallet // ignore: cast_nullable_to_non_nullable
as WalletRef,
  ));
}

/// Create a copy of ReceivableLoan
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WalletRefCopyWith<$Res> get wallet {
  
  return $WalletRefCopyWith<$Res>(_self.wallet, (value) {
    return _then(_self.copyWith(wallet: value));
  });
}
}


/// @nodoc
mixin _$Debtor {

 String get id; String get name; int get amount; int get paid; int get remaining; List<DebtorPayment> get payments;
/// Create a copy of Debtor
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DebtorCopyWith<Debtor> get copyWith => _$DebtorCopyWithImpl<Debtor>(this as Debtor, _$identity);

  /// Serializes this Debtor to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Debtor;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Debtor&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.paid, _this.paid) || other.paid == _this.paid)&&(identical(other.remaining, _this.remaining) || other.remaining == _this.remaining)&&const DeepCollectionEquality().equals(other.payments, _this.payments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Debtor;
  return Object.hash(runtimeType,_this.id,_this.name,_this.amount,_this.paid,_this.remaining,const DeepCollectionEquality().hash(_this.payments));
}

@override
String toString() {
  final _this = this as Debtor;
  return 'Debtor(id: ${_this.id}, name: ${_this.name}, amount: ${_this.amount}, paid: ${_this.paid}, remaining: ${_this.remaining}, payments: ${_this.payments})';
}


}

/// @nodoc
abstract mixin class $DebtorCopyWith<$Res>  {
  factory $DebtorCopyWith(Debtor value, $Res Function(Debtor) _then) = _$DebtorCopyWithImpl;
@useResult
$Res call({
 String id, String name, int amount, int paid, int remaining, List<DebtorPayment> payments
});




}
/// @nodoc
class _$DebtorCopyWithImpl<$Res>
    implements $DebtorCopyWith<$Res> {
  _$DebtorCopyWithImpl(this._self, this._then);

  final Debtor _self;
  final $Res Function(Debtor) _then;

/// Create a copy of Debtor
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? amount = null,Object? paid = null,Object? remaining = null,Object? payments = null,}) {
  return _then(Debtor(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,paid: null == paid ? _self.paid : paid // ignore: cast_nullable_to_non_nullable
as int,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as int,payments: null == payments ? _self.payments : payments // ignore: cast_nullable_to_non_nullable
as List<DebtorPayment>,
  ));
}

}


/// Adds pattern-matching-related methods to [Debtor].
extension DebtorPatterns on Debtor {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Debtor value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Debtor() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Debtor value)  $default,){
final _that = this;
switch (_that) {
case _Debtor():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Debtor value)?  $default,){
final _that = this;
switch (_that) {
case _Debtor() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  int amount,  int paid,  int remaining,  List<DebtorPayment> payments)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Debtor() when $default != null:
return $default(_that.id,_that.name,_that.amount,_that.paid,_that.remaining,_that.payments);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  int amount,  int paid,  int remaining,  List<DebtorPayment> payments)  $default,) {final _that = this;
switch (_that) {
case _Debtor():
return $default(_that.id,_that.name,_that.amount,_that.paid,_that.remaining,_that.payments);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  int amount,  int paid,  int remaining,  List<DebtorPayment> payments)?  $default,) {final _that = this;
switch (_that) {
case _Debtor() when $default != null:
return $default(_that.id,_that.name,_that.amount,_that.paid,_that.remaining,_that.payments);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Debtor implements Debtor {
  const _Debtor({required this.id, required this.name, required this.amount, required this.paid, required this.remaining, required  List<DebtorPayment> payments}): _payments = payments;
  factory _Debtor.fromJson(Map<String, dynamic> json) => _$DebtorFromJson(json);

@override final  String id;
@override final  String name;
@override final  int amount;
@override final  int paid;
@override final  int remaining;
 final  List<DebtorPayment> _payments;
@override List<DebtorPayment> get payments {
  if (_payments is EqualUnmodifiableListView) return _payments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_payments);
}


/// Create a copy of Debtor
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DebtorCopyWith<_Debtor> get copyWith => __$DebtorCopyWithImpl<_Debtor>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DebtorToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Debtor&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.paid, paid) || other.paid == paid)&&(identical(other.remaining, remaining) || other.remaining == remaining)&&const DeepCollectionEquality().equals(other.payments, _payments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,amount,paid,remaining,const DeepCollectionEquality().hash(_payments));
}

@override
String toString() {
    return 'Debtor(id: $id, name: $name, amount: $amount, paid: $paid, remaining: $remaining, payments: $payments)';
}


}

/// @nodoc
abstract mixin class _$DebtorCopyWith<$Res> implements $DebtorCopyWith<$Res> {
  factory _$DebtorCopyWith(_Debtor value, $Res Function(_Debtor) _then) = __$DebtorCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, int amount, int paid, int remaining, List<DebtorPayment> payments
});




}
/// @nodoc
class __$DebtorCopyWithImpl<$Res>
    implements _$DebtorCopyWith<$Res> {
  __$DebtorCopyWithImpl(this._self, this._then);

  final _Debtor _self;
  final $Res Function(_Debtor) _then;

/// Create a copy of Debtor
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? amount = null,Object? paid = null,Object? remaining = null,Object? payments = null,}) {
  return _then(_Debtor(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,paid: null == paid ? _self.paid : paid // ignore: cast_nullable_to_non_nullable
as int,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as int,payments: null == payments ? _self._payments : payments // ignore: cast_nullable_to_non_nullable
as List<DebtorPayment>,
  ));
}


}


/// @nodoc
mixin _$DebtorPayment {

 String get transactionId; int get amount; DateTime get occurredAt; WalletRef get wallet;
/// Create a copy of DebtorPayment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DebtorPaymentCopyWith<DebtorPayment> get copyWith => _$DebtorPaymentCopyWithImpl<DebtorPayment>(this as DebtorPayment, _$identity);

  /// Serializes this DebtorPayment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DebtorPayment;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DebtorPayment&&(identical(other.transactionId, _this.transactionId) || other.transactionId == _this.transactionId)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.occurredAt, _this.occurredAt) || other.occurredAt == _this.occurredAt)&&(identical(other.wallet, _this.wallet) || other.wallet == _this.wallet));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DebtorPayment;
  return Object.hash(runtimeType,_this.transactionId,_this.amount,_this.occurredAt,_this.wallet);
}

@override
String toString() {
  final _this = this as DebtorPayment;
  return 'DebtorPayment(transactionId: ${_this.transactionId}, amount: ${_this.amount}, occurredAt: ${_this.occurredAt}, wallet: ${_this.wallet})';
}


}

/// @nodoc
abstract mixin class $DebtorPaymentCopyWith<$Res>  {
  factory $DebtorPaymentCopyWith(DebtorPayment value, $Res Function(DebtorPayment) _then) = _$DebtorPaymentCopyWithImpl;
@useResult
$Res call({
 String transactionId, int amount, DateTime occurredAt, WalletRef wallet
});


$WalletRefCopyWith<$Res> get wallet;

}
/// @nodoc
class _$DebtorPaymentCopyWithImpl<$Res>
    implements $DebtorPaymentCopyWith<$Res> {
  _$DebtorPaymentCopyWithImpl(this._self, this._then);

  final DebtorPayment _self;
  final $Res Function(DebtorPayment) _then;

/// Create a copy of DebtorPayment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? transactionId = null,Object? amount = null,Object? occurredAt = null,Object? wallet = null,}) {
  return _then(DebtorPayment(
transactionId: null == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,wallet: null == wallet ? _self.wallet : wallet // ignore: cast_nullable_to_non_nullable
as WalletRef,
  ));
}
/// Create a copy of DebtorPayment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WalletRefCopyWith<$Res> get wallet {
  
  return $WalletRefCopyWith<$Res>(_self.wallet, (value) {
    return _then(_self.copyWith(wallet: value));
  });
}
}


/// Adds pattern-matching-related methods to [DebtorPayment].
extension DebtorPaymentPatterns on DebtorPayment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DebtorPayment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DebtorPayment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DebtorPayment value)  $default,){
final _that = this;
switch (_that) {
case _DebtorPayment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DebtorPayment value)?  $default,){
final _that = this;
switch (_that) {
case _DebtorPayment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String transactionId,  int amount,  DateTime occurredAt,  WalletRef wallet)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DebtorPayment() when $default != null:
return $default(_that.transactionId,_that.amount,_that.occurredAt,_that.wallet);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String transactionId,  int amount,  DateTime occurredAt,  WalletRef wallet)  $default,) {final _that = this;
switch (_that) {
case _DebtorPayment():
return $default(_that.transactionId,_that.amount,_that.occurredAt,_that.wallet);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String transactionId,  int amount,  DateTime occurredAt,  WalletRef wallet)?  $default,) {final _that = this;
switch (_that) {
case _DebtorPayment() when $default != null:
return $default(_that.transactionId,_that.amount,_that.occurredAt,_that.wallet);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DebtorPayment implements DebtorPayment {
  const _DebtorPayment({required this.transactionId, required this.amount, required this.occurredAt, required this.wallet});
  factory _DebtorPayment.fromJson(Map<String, dynamic> json) => _$DebtorPaymentFromJson(json);

@override final  String transactionId;
@override final  int amount;
@override final  DateTime occurredAt;
@override final  WalletRef wallet;

/// Create a copy of DebtorPayment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DebtorPaymentCopyWith<_DebtorPayment> get copyWith => __$DebtorPaymentCopyWithImpl<_DebtorPayment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DebtorPaymentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DebtorPayment&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.wallet, wallet) || other.wallet == wallet));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,transactionId,amount,occurredAt,wallet);
}

@override
String toString() {
    return 'DebtorPayment(transactionId: $transactionId, amount: $amount, occurredAt: $occurredAt, wallet: $wallet)';
}


}

/// @nodoc
abstract mixin class _$DebtorPaymentCopyWith<$Res> implements $DebtorPaymentCopyWith<$Res> {
  factory _$DebtorPaymentCopyWith(_DebtorPayment value, $Res Function(_DebtorPayment) _then) = __$DebtorPaymentCopyWithImpl;
@override @useResult
$Res call({
 String transactionId, int amount, DateTime occurredAt, WalletRef wallet
});


@override $WalletRefCopyWith<$Res> get wallet;

}
/// @nodoc
class __$DebtorPaymentCopyWithImpl<$Res>
    implements _$DebtorPaymentCopyWith<$Res> {
  __$DebtorPaymentCopyWithImpl(this._self, this._then);

  final _DebtorPayment _self;
  final $Res Function(_DebtorPayment) _then;

/// Create a copy of DebtorPayment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? transactionId = null,Object? amount = null,Object? occurredAt = null,Object? wallet = null,}) {
  return _then(_DebtorPayment(
transactionId: null == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,wallet: null == wallet ? _self.wallet : wallet // ignore: cast_nullable_to_non_nullable
as WalletRef,
  ));
}

/// Create a copy of DebtorPayment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WalletRefCopyWith<$Res> get wallet {
  
  return $WalletRefCopyWith<$Res>(_self.wallet, (value) {
    return _then(_self.copyWith(wallet: value));
  });
}
}

// dart format on
