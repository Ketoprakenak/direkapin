// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wallet_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Wallet {

 String get id; String get name; WalletType get type; int get initialBalance; int get balance; String get icon; String get color; bool get isArchived; int get sortOrder;
/// Create a copy of Wallet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WalletCopyWith<Wallet> get copyWith => _$WalletCopyWithImpl<Wallet>(this as Wallet, _$identity);

  /// Serializes this Wallet to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Wallet;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Wallet&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.initialBalance, _this.initialBalance) || other.initialBalance == _this.initialBalance)&&(identical(other.balance, _this.balance) || other.balance == _this.balance)&&(identical(other.icon, _this.icon) || other.icon == _this.icon)&&(identical(other.color, _this.color) || other.color == _this.color)&&(identical(other.isArchived, _this.isArchived) || other.isArchived == _this.isArchived)&&(identical(other.sortOrder, _this.sortOrder) || other.sortOrder == _this.sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Wallet;
  return Object.hash(runtimeType,_this.id,_this.name,_this.type,_this.initialBalance,_this.balance,_this.icon,_this.color,_this.isArchived,_this.sortOrder);
}

@override
String toString() {
  final _this = this as Wallet;
  return 'Wallet(id: ${_this.id}, name: ${_this.name}, type: ${_this.type}, initialBalance: ${_this.initialBalance}, balance: ${_this.balance}, icon: ${_this.icon}, color: ${_this.color}, isArchived: ${_this.isArchived}, sortOrder: ${_this.sortOrder})';
}


}

/// @nodoc
abstract mixin class $WalletCopyWith<$Res>  {
  factory $WalletCopyWith(Wallet value, $Res Function(Wallet) _then) = _$WalletCopyWithImpl;
@useResult
$Res call({
 String id, String name, WalletType type, int initialBalance, int balance, String icon, String color, bool isArchived, int sortOrder
});




}
/// @nodoc
class _$WalletCopyWithImpl<$Res>
    implements $WalletCopyWith<$Res> {
  _$WalletCopyWithImpl(this._self, this._then);

  final Wallet _self;
  final $Res Function(Wallet) _then;

/// Create a copy of Wallet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? type = null,Object? initialBalance = null,Object? balance = null,Object? icon = null,Object? color = null,Object? isArchived = null,Object? sortOrder = null,}) {
  return _then(Wallet(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as WalletType,initialBalance: null == initialBalance ? _self.initialBalance : initialBalance // ignore: cast_nullable_to_non_nullable
as int,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as int,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Wallet].
extension WalletPatterns on Wallet {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Wallet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Wallet() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Wallet value)  $default,){
final _that = this;
switch (_that) {
case _Wallet():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Wallet value)?  $default,){
final _that = this;
switch (_that) {
case _Wallet() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  WalletType type,  int initialBalance,  int balance,  String icon,  String color,  bool isArchived,  int sortOrder)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Wallet() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.initialBalance,_that.balance,_that.icon,_that.color,_that.isArchived,_that.sortOrder);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  WalletType type,  int initialBalance,  int balance,  String icon,  String color,  bool isArchived,  int sortOrder)  $default,) {final _that = this;
switch (_that) {
case _Wallet():
return $default(_that.id,_that.name,_that.type,_that.initialBalance,_that.balance,_that.icon,_that.color,_that.isArchived,_that.sortOrder);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  WalletType type,  int initialBalance,  int balance,  String icon,  String color,  bool isArchived,  int sortOrder)?  $default,) {final _that = this;
switch (_that) {
case _Wallet() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.initialBalance,_that.balance,_that.icon,_that.color,_that.isArchived,_that.sortOrder);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Wallet implements Wallet {
  const _Wallet({required this.id, required this.name, required this.type, required this.initialBalance, required this.balance, required this.icon, required this.color, required this.isArchived, required this.sortOrder});
  factory _Wallet.fromJson(Map<String, dynamic> json) => _$WalletFromJson(json);

@override final  String id;
@override final  String name;
@override final  WalletType type;
@override final  int initialBalance;
@override final  int balance;
@override final  String icon;
@override final  String color;
@override final  bool isArchived;
@override final  int sortOrder;

/// Create a copy of Wallet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WalletCopyWith<_Wallet> get copyWith => __$WalletCopyWithImpl<_Wallet>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WalletToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Wallet&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.initialBalance, initialBalance) || other.initialBalance == initialBalance)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.isArchived, isArchived) || other.isArchived == isArchived)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,type,initialBalance,balance,icon,color,isArchived,sortOrder);
}

@override
String toString() {
    return 'Wallet(id: $id, name: $name, type: $type, initialBalance: $initialBalance, balance: $balance, icon: $icon, color: $color, isArchived: $isArchived, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class _$WalletCopyWith<$Res> implements $WalletCopyWith<$Res> {
  factory _$WalletCopyWith(_Wallet value, $Res Function(_Wallet) _then) = __$WalletCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, WalletType type, int initialBalance, int balance, String icon, String color, bool isArchived, int sortOrder
});




}
/// @nodoc
class __$WalletCopyWithImpl<$Res>
    implements _$WalletCopyWith<$Res> {
  __$WalletCopyWithImpl(this._self, this._then);

  final _Wallet _self;
  final $Res Function(_Wallet) _then;

/// Create a copy of Wallet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? type = null,Object? initialBalance = null,Object? balance = null,Object? icon = null,Object? color = null,Object? isArchived = null,Object? sortOrder = null,}) {
  return _then(_Wallet(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as WalletType,initialBalance: null == initialBalance ? _self.initialBalance : initialBalance // ignore: cast_nullable_to_non_nullable
as int,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as int,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,isArchived: null == isArchived ? _self.isArchived : isArchived // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$WalletRef {

 String get id; String get name; String get icon; String get color;
/// Create a copy of WalletRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WalletRefCopyWith<WalletRef> get copyWith => _$WalletRefCopyWithImpl<WalletRef>(this as WalletRef, _$identity);

  /// Serializes this WalletRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as WalletRef;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WalletRef&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.icon, _this.icon) || other.icon == _this.icon)&&(identical(other.color, _this.color) || other.color == _this.color));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WalletRef;
  return Object.hash(runtimeType,_this.id,_this.name,_this.icon,_this.color);
}

@override
String toString() {
  final _this = this as WalletRef;
  return 'WalletRef(id: ${_this.id}, name: ${_this.name}, icon: ${_this.icon}, color: ${_this.color})';
}


}

/// @nodoc
abstract mixin class $WalletRefCopyWith<$Res>  {
  factory $WalletRefCopyWith(WalletRef value, $Res Function(WalletRef) _then) = _$WalletRefCopyWithImpl;
@useResult
$Res call({
 String id, String name, String icon, String color
});




}
/// @nodoc
class _$WalletRefCopyWithImpl<$Res>
    implements $WalletRefCopyWith<$Res> {
  _$WalletRefCopyWithImpl(this._self, this._then);

  final WalletRef _self;
  final $Res Function(WalletRef) _then;

/// Create a copy of WalletRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? icon = null,Object? color = null,}) {
  return _then(WalletRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [WalletRef].
extension WalletRefPatterns on WalletRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WalletRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WalletRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WalletRef value)  $default,){
final _that = this;
switch (_that) {
case _WalletRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WalletRef value)?  $default,){
final _that = this;
switch (_that) {
case _WalletRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String icon,  String color)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WalletRef() when $default != null:
return $default(_that.id,_that.name,_that.icon,_that.color);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String icon,  String color)  $default,) {final _that = this;
switch (_that) {
case _WalletRef():
return $default(_that.id,_that.name,_that.icon,_that.color);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String icon,  String color)?  $default,) {final _that = this;
switch (_that) {
case _WalletRef() when $default != null:
return $default(_that.id,_that.name,_that.icon,_that.color);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WalletRef implements WalletRef {
  const _WalletRef({required this.id, required this.name, required this.icon, required this.color});
  factory _WalletRef.fromJson(Map<String, dynamic> json) => _$WalletRefFromJson(json);

@override final  String id;
@override final  String name;
@override final  String icon;
@override final  String color;

/// Create a copy of WalletRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WalletRefCopyWith<_WalletRef> get copyWith => __$WalletRefCopyWithImpl<_WalletRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WalletRefToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WalletRef&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,icon,color);
}

@override
String toString() {
    return 'WalletRef(id: $id, name: $name, icon: $icon, color: $color)';
}


}

/// @nodoc
abstract mixin class _$WalletRefCopyWith<$Res> implements $WalletRefCopyWith<$Res> {
  factory _$WalletRefCopyWith(_WalletRef value, $Res Function(_WalletRef) _then) = __$WalletRefCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String icon, String color
});




}
/// @nodoc
class __$WalletRefCopyWithImpl<$Res>
    implements _$WalletRefCopyWith<$Res> {
  __$WalletRefCopyWithImpl(this._self, this._then);

  final _WalletRef _self;
  final $Res Function(_WalletRef) _then;

/// Create a copy of WalletRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? icon = null,Object? color = null,}) {
  return _then(_WalletRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Transfer {

 String get id; WalletRef get fromWallet; WalletRef get toWallet; int get amount; DateTime get occurredAt; String? get note;
/// Create a copy of Transfer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransferCopyWith<Transfer> get copyWith => _$TransferCopyWithImpl<Transfer>(this as Transfer, _$identity);

  /// Serializes this Transfer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Transfer;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Transfer&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.fromWallet, _this.fromWallet) || other.fromWallet == _this.fromWallet)&&(identical(other.toWallet, _this.toWallet) || other.toWallet == _this.toWallet)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.occurredAt, _this.occurredAt) || other.occurredAt == _this.occurredAt)&&(identical(other.note, _this.note) || other.note == _this.note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Transfer;
  return Object.hash(runtimeType,_this.id,_this.fromWallet,_this.toWallet,_this.amount,_this.occurredAt,_this.note);
}

@override
String toString() {
  final _this = this as Transfer;
  return 'Transfer(id: ${_this.id}, fromWallet: ${_this.fromWallet}, toWallet: ${_this.toWallet}, amount: ${_this.amount}, occurredAt: ${_this.occurredAt}, note: ${_this.note})';
}


}

/// @nodoc
abstract mixin class $TransferCopyWith<$Res>  {
  factory $TransferCopyWith(Transfer value, $Res Function(Transfer) _then) = _$TransferCopyWithImpl;
@useResult
$Res call({
 String id, WalletRef fromWallet, WalletRef toWallet, int amount, DateTime occurredAt, String? note
});


$WalletRefCopyWith<$Res> get fromWallet;$WalletRefCopyWith<$Res> get toWallet;

}
/// @nodoc
class _$TransferCopyWithImpl<$Res>
    implements $TransferCopyWith<$Res> {
  _$TransferCopyWithImpl(this._self, this._then);

  final Transfer _self;
  final $Res Function(Transfer) _then;

/// Create a copy of Transfer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fromWallet = null,Object? toWallet = null,Object? amount = null,Object? occurredAt = null,Object? note = freezed,}) {
  return _then(Transfer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fromWallet: null == fromWallet ? _self.fromWallet : fromWallet // ignore: cast_nullable_to_non_nullable
as WalletRef,toWallet: null == toWallet ? _self.toWallet : toWallet // ignore: cast_nullable_to_non_nullable
as WalletRef,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of Transfer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WalletRefCopyWith<$Res> get fromWallet {
  
  return $WalletRefCopyWith<$Res>(_self.fromWallet, (value) {
    return _then(_self.copyWith(fromWallet: value));
  });
}/// Create a copy of Transfer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WalletRefCopyWith<$Res> get toWallet {
  
  return $WalletRefCopyWith<$Res>(_self.toWallet, (value) {
    return _then(_self.copyWith(toWallet: value));
  });
}
}


/// Adds pattern-matching-related methods to [Transfer].
extension TransferPatterns on Transfer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Transfer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Transfer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Transfer value)  $default,){
final _that = this;
switch (_that) {
case _Transfer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Transfer value)?  $default,){
final _that = this;
switch (_that) {
case _Transfer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  WalletRef fromWallet,  WalletRef toWallet,  int amount,  DateTime occurredAt,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Transfer() when $default != null:
return $default(_that.id,_that.fromWallet,_that.toWallet,_that.amount,_that.occurredAt,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  WalletRef fromWallet,  WalletRef toWallet,  int amount,  DateTime occurredAt,  String? note)  $default,) {final _that = this;
switch (_that) {
case _Transfer():
return $default(_that.id,_that.fromWallet,_that.toWallet,_that.amount,_that.occurredAt,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  WalletRef fromWallet,  WalletRef toWallet,  int amount,  DateTime occurredAt,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _Transfer() when $default != null:
return $default(_that.id,_that.fromWallet,_that.toWallet,_that.amount,_that.occurredAt,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Transfer implements Transfer {
  const _Transfer({required this.id, required this.fromWallet, required this.toWallet, required this.amount, required this.occurredAt, this.note});
  factory _Transfer.fromJson(Map<String, dynamic> json) => _$TransferFromJson(json);

@override final  String id;
@override final  WalletRef fromWallet;
@override final  WalletRef toWallet;
@override final  int amount;
@override final  DateTime occurredAt;
@override final  String? note;

/// Create a copy of Transfer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransferCopyWith<_Transfer> get copyWith => __$TransferCopyWithImpl<_Transfer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransferToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Transfer&&(identical(other.id, id) || other.id == id)&&(identical(other.fromWallet, fromWallet) || other.fromWallet == fromWallet)&&(identical(other.toWallet, toWallet) || other.toWallet == toWallet)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,fromWallet,toWallet,amount,occurredAt,note);
}

@override
String toString() {
    return 'Transfer(id: $id, fromWallet: $fromWallet, toWallet: $toWallet, amount: $amount, occurredAt: $occurredAt, note: $note)';
}


}

/// @nodoc
abstract mixin class _$TransferCopyWith<$Res> implements $TransferCopyWith<$Res> {
  factory _$TransferCopyWith(_Transfer value, $Res Function(_Transfer) _then) = __$TransferCopyWithImpl;
@override @useResult
$Res call({
 String id, WalletRef fromWallet, WalletRef toWallet, int amount, DateTime occurredAt, String? note
});


@override $WalletRefCopyWith<$Res> get fromWallet;@override $WalletRefCopyWith<$Res> get toWallet;

}
/// @nodoc
class __$TransferCopyWithImpl<$Res>
    implements _$TransferCopyWith<$Res> {
  __$TransferCopyWithImpl(this._self, this._then);

  final _Transfer _self;
  final $Res Function(_Transfer) _then;

/// Create a copy of Transfer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fromWallet = null,Object? toWallet = null,Object? amount = null,Object? occurredAt = null,Object? note = freezed,}) {
  return _then(_Transfer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fromWallet: null == fromWallet ? _self.fromWallet : fromWallet // ignore: cast_nullable_to_non_nullable
as WalletRef,toWallet: null == toWallet ? _self.toWallet : toWallet // ignore: cast_nullable_to_non_nullable
as WalletRef,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of Transfer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WalletRefCopyWith<$Res> get fromWallet {
  
  return $WalletRefCopyWith<$Res>(_self.fromWallet, (value) {
    return _then(_self.copyWith(fromWallet: value));
  });
}/// Create a copy of Transfer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WalletRefCopyWith<$Res> get toWallet {
  
  return $WalletRefCopyWith<$Res>(_self.toWallet, (value) {
    return _then(_self.copyWith(toWallet: value));
  });
}
}

// dart format on
