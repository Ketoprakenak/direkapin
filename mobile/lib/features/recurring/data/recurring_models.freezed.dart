// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recurring_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RecurringNext {

 String get month; String get dueDate;
/// Create a copy of RecurringNext
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecurringNextCopyWith<RecurringNext> get copyWith => _$RecurringNextCopyWithImpl<RecurringNext>(this as RecurringNext, _$identity);

  /// Serializes this RecurringNext to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RecurringNext;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecurringNext&&(identical(other.month, _this.month) || other.month == _this.month)&&(identical(other.dueDate, _this.dueDate) || other.dueDate == _this.dueDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RecurringNext;
  return Object.hash(runtimeType,_this.month,_this.dueDate);
}

@override
String toString() {
  final _this = this as RecurringNext;
  return 'RecurringNext(month: ${_this.month}, dueDate: ${_this.dueDate})';
}


}

/// @nodoc
abstract mixin class $RecurringNextCopyWith<$Res>  {
  factory $RecurringNextCopyWith(RecurringNext value, $Res Function(RecurringNext) _then) = _$RecurringNextCopyWithImpl;
@useResult
$Res call({
 String month, String dueDate
});




}
/// @nodoc
class _$RecurringNextCopyWithImpl<$Res>
    implements $RecurringNextCopyWith<$Res> {
  _$RecurringNextCopyWithImpl(this._self, this._then);

  final RecurringNext _self;
  final $Res Function(RecurringNext) _then;

/// Create a copy of RecurringNext
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? month = null,Object? dueDate = null,}) {
  return _then(RecurringNext(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as String,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RecurringNext].
extension RecurringNextPatterns on RecurringNext {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecurringNext value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecurringNext() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecurringNext value)  $default,){
final _that = this;
switch (_that) {
case _RecurringNext():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecurringNext value)?  $default,){
final _that = this;
switch (_that) {
case _RecurringNext() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String month,  String dueDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecurringNext() when $default != null:
return $default(_that.month,_that.dueDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String month,  String dueDate)  $default,) {final _that = this;
switch (_that) {
case _RecurringNext():
return $default(_that.month,_that.dueDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String month,  String dueDate)?  $default,) {final _that = this;
switch (_that) {
case _RecurringNext() when $default != null:
return $default(_that.month,_that.dueDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecurringNext implements RecurringNext {
  const _RecurringNext({required this.month, required this.dueDate});
  factory _RecurringNext.fromJson(Map<String, dynamic> json) => _$RecurringNextFromJson(json);

@override final  String month;
@override final  String dueDate;

/// Create a copy of RecurringNext
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecurringNextCopyWith<_RecurringNext> get copyWith => __$RecurringNextCopyWithImpl<_RecurringNext>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecurringNextToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecurringNext&&(identical(other.month, month) || other.month == month)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,month,dueDate);
}

@override
String toString() {
    return 'RecurringNext(month: $month, dueDate: $dueDate)';
}


}

/// @nodoc
abstract mixin class _$RecurringNextCopyWith<$Res> implements $RecurringNextCopyWith<$Res> {
  factory _$RecurringNextCopyWith(_RecurringNext value, $Res Function(_RecurringNext) _then) = __$RecurringNextCopyWithImpl;
@override @useResult
$Res call({
 String month, String dueDate
});




}
/// @nodoc
class __$RecurringNextCopyWithImpl<$Res>
    implements _$RecurringNextCopyWith<$Res> {
  __$RecurringNextCopyWithImpl(this._self, this._then);

  final _RecurringNext _self;
  final $Res Function(_RecurringNext) _then;

/// Create a copy of RecurringNext
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? month = null,Object? dueDate = null,}) {
  return _then(_RecurringNext(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as String,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Recurring {

 String get id; TxType get type; int get amount; String? get note; int get dayOfMonth; String get startMonth; String? get endMonth; String? get lastHandledMonth; WalletRef get wallet; CategoryRef get category; RecurringNext? get next;
/// Create a copy of Recurring
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecurringCopyWith<Recurring> get copyWith => _$RecurringCopyWithImpl<Recurring>(this as Recurring, _$identity);

  /// Serializes this Recurring to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Recurring;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Recurring&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.dayOfMonth, _this.dayOfMonth) || other.dayOfMonth == _this.dayOfMonth)&&(identical(other.startMonth, _this.startMonth) || other.startMonth == _this.startMonth)&&(identical(other.endMonth, _this.endMonth) || other.endMonth == _this.endMonth)&&(identical(other.lastHandledMonth, _this.lastHandledMonth) || other.lastHandledMonth == _this.lastHandledMonth)&&(identical(other.wallet, _this.wallet) || other.wallet == _this.wallet)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.next, _this.next) || other.next == _this.next));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Recurring;
  return Object.hash(runtimeType,_this.id,_this.type,_this.amount,_this.note,_this.dayOfMonth,_this.startMonth,_this.endMonth,_this.lastHandledMonth,_this.wallet,_this.category,_this.next);
}

@override
String toString() {
  final _this = this as Recurring;
  return 'Recurring(id: ${_this.id}, type: ${_this.type}, amount: ${_this.amount}, note: ${_this.note}, dayOfMonth: ${_this.dayOfMonth}, startMonth: ${_this.startMonth}, endMonth: ${_this.endMonth}, lastHandledMonth: ${_this.lastHandledMonth}, wallet: ${_this.wallet}, category: ${_this.category}, next: ${_this.next})';
}


}

/// @nodoc
abstract mixin class $RecurringCopyWith<$Res>  {
  factory $RecurringCopyWith(Recurring value, $Res Function(Recurring) _then) = _$RecurringCopyWithImpl;
@useResult
$Res call({
 String id, TxType type, int amount, String? note, int dayOfMonth, String startMonth, String? endMonth, String? lastHandledMonth, WalletRef wallet, CategoryRef category, RecurringNext? next
});


$WalletRefCopyWith<$Res> get wallet;$CategoryRefCopyWith<$Res> get category;$RecurringNextCopyWith<$Res>? get next;

}
/// @nodoc
class _$RecurringCopyWithImpl<$Res>
    implements $RecurringCopyWith<$Res> {
  _$RecurringCopyWithImpl(this._self, this._then);

  final Recurring _self;
  final $Res Function(Recurring) _then;

/// Create a copy of Recurring
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? amount = null,Object? note = freezed,Object? dayOfMonth = null,Object? startMonth = null,Object? endMonth = freezed,Object? lastHandledMonth = freezed,Object? wallet = null,Object? category = null,Object? next = freezed,}) {
  return _then(Recurring(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TxType,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,dayOfMonth: null == dayOfMonth ? _self.dayOfMonth : dayOfMonth // ignore: cast_nullable_to_non_nullable
as int,startMonth: null == startMonth ? _self.startMonth : startMonth // ignore: cast_nullable_to_non_nullable
as String,endMonth: freezed == endMonth ? _self.endMonth : endMonth // ignore: cast_nullable_to_non_nullable
as String?,lastHandledMonth: freezed == lastHandledMonth ? _self.lastHandledMonth : lastHandledMonth // ignore: cast_nullable_to_non_nullable
as String?,wallet: null == wallet ? _self.wallet : wallet // ignore: cast_nullable_to_non_nullable
as WalletRef,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as CategoryRef,next: freezed == next ? _self.next : next // ignore: cast_nullable_to_non_nullable
as RecurringNext?,
  ));
}
/// Create a copy of Recurring
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WalletRefCopyWith<$Res> get wallet {
  
  return $WalletRefCopyWith<$Res>(_self.wallet, (value) {
    return _then(_self.copyWith(wallet: value));
  });
}/// Create a copy of Recurring
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategoryRefCopyWith<$Res> get category {
  
  return $CategoryRefCopyWith<$Res>(_self.category, (value) {
    return _then(_self.copyWith(category: value));
  });
}/// Create a copy of Recurring
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecurringNextCopyWith<$Res>? get next {
    if (_self.next == null) {
    return null;
  }

  return $RecurringNextCopyWith<$Res>(_self.next!, (value) {
    return _then(_self.copyWith(next: value));
  });
}
}


/// Adds pattern-matching-related methods to [Recurring].
extension RecurringPatterns on Recurring {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Recurring value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Recurring() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Recurring value)  $default,){
final _that = this;
switch (_that) {
case _Recurring():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Recurring value)?  $default,){
final _that = this;
switch (_that) {
case _Recurring() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  TxType type,  int amount,  String? note,  int dayOfMonth,  String startMonth,  String? endMonth,  String? lastHandledMonth,  WalletRef wallet,  CategoryRef category,  RecurringNext? next)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Recurring() when $default != null:
return $default(_that.id,_that.type,_that.amount,_that.note,_that.dayOfMonth,_that.startMonth,_that.endMonth,_that.lastHandledMonth,_that.wallet,_that.category,_that.next);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  TxType type,  int amount,  String? note,  int dayOfMonth,  String startMonth,  String? endMonth,  String? lastHandledMonth,  WalletRef wallet,  CategoryRef category,  RecurringNext? next)  $default,) {final _that = this;
switch (_that) {
case _Recurring():
return $default(_that.id,_that.type,_that.amount,_that.note,_that.dayOfMonth,_that.startMonth,_that.endMonth,_that.lastHandledMonth,_that.wallet,_that.category,_that.next);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  TxType type,  int amount,  String? note,  int dayOfMonth,  String startMonth,  String? endMonth,  String? lastHandledMonth,  WalletRef wallet,  CategoryRef category,  RecurringNext? next)?  $default,) {final _that = this;
switch (_that) {
case _Recurring() when $default != null:
return $default(_that.id,_that.type,_that.amount,_that.note,_that.dayOfMonth,_that.startMonth,_that.endMonth,_that.lastHandledMonth,_that.wallet,_that.category,_that.next);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Recurring implements Recurring {
  const _Recurring({required this.id, required this.type, required this.amount, this.note, required this.dayOfMonth, required this.startMonth, this.endMonth, this.lastHandledMonth, required this.wallet, required this.category, this.next});
  factory _Recurring.fromJson(Map<String, dynamic> json) => _$RecurringFromJson(json);

@override final  String id;
@override final  TxType type;
@override final  int amount;
@override final  String? note;
@override final  int dayOfMonth;
@override final  String startMonth;
@override final  String? endMonth;
@override final  String? lastHandledMonth;
@override final  WalletRef wallet;
@override final  CategoryRef category;
@override final  RecurringNext? next;

/// Create a copy of Recurring
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecurringCopyWith<_Recurring> get copyWith => __$RecurringCopyWithImpl<_Recurring>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecurringToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Recurring&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.note, note) || other.note == note)&&(identical(other.dayOfMonth, dayOfMonth) || other.dayOfMonth == dayOfMonth)&&(identical(other.startMonth, startMonth) || other.startMonth == startMonth)&&(identical(other.endMonth, endMonth) || other.endMonth == endMonth)&&(identical(other.lastHandledMonth, lastHandledMonth) || other.lastHandledMonth == lastHandledMonth)&&(identical(other.wallet, wallet) || other.wallet == wallet)&&(identical(other.category, category) || other.category == category)&&(identical(other.next, next) || other.next == next));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,type,amount,note,dayOfMonth,startMonth,endMonth,lastHandledMonth,wallet,category,next);
}

@override
String toString() {
    return 'Recurring(id: $id, type: $type, amount: $amount, note: $note, dayOfMonth: $dayOfMonth, startMonth: $startMonth, endMonth: $endMonth, lastHandledMonth: $lastHandledMonth, wallet: $wallet, category: $category, next: $next)';
}


}

/// @nodoc
abstract mixin class _$RecurringCopyWith<$Res> implements $RecurringCopyWith<$Res> {
  factory _$RecurringCopyWith(_Recurring value, $Res Function(_Recurring) _then) = __$RecurringCopyWithImpl;
@override @useResult
$Res call({
 String id, TxType type, int amount, String? note, int dayOfMonth, String startMonth, String? endMonth, String? lastHandledMonth, WalletRef wallet, CategoryRef category, RecurringNext? next
});


@override $WalletRefCopyWith<$Res> get wallet;@override $CategoryRefCopyWith<$Res> get category;@override $RecurringNextCopyWith<$Res>? get next;

}
/// @nodoc
class __$RecurringCopyWithImpl<$Res>
    implements _$RecurringCopyWith<$Res> {
  __$RecurringCopyWithImpl(this._self, this._then);

  final _Recurring _self;
  final $Res Function(_Recurring) _then;

/// Create a copy of Recurring
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? amount = null,Object? note = freezed,Object? dayOfMonth = null,Object? startMonth = null,Object? endMonth = freezed,Object? lastHandledMonth = freezed,Object? wallet = null,Object? category = null,Object? next = freezed,}) {
  return _then(_Recurring(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TxType,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,dayOfMonth: null == dayOfMonth ? _self.dayOfMonth : dayOfMonth // ignore: cast_nullable_to_non_nullable
as int,startMonth: null == startMonth ? _self.startMonth : startMonth // ignore: cast_nullable_to_non_nullable
as String,endMonth: freezed == endMonth ? _self.endMonth : endMonth // ignore: cast_nullable_to_non_nullable
as String?,lastHandledMonth: freezed == lastHandledMonth ? _self.lastHandledMonth : lastHandledMonth // ignore: cast_nullable_to_non_nullable
as String?,wallet: null == wallet ? _self.wallet : wallet // ignore: cast_nullable_to_non_nullable
as WalletRef,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as CategoryRef,next: freezed == next ? _self.next : next // ignore: cast_nullable_to_non_nullable
as RecurringNext?,
  ));
}

/// Create a copy of Recurring
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WalletRefCopyWith<$Res> get wallet {
  
  return $WalletRefCopyWith<$Res>(_self.wallet, (value) {
    return _then(_self.copyWith(wallet: value));
  });
}/// Create a copy of Recurring
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategoryRefCopyWith<$Res> get category {
  
  return $CategoryRefCopyWith<$Res>(_self.category, (value) {
    return _then(_self.copyWith(category: value));
  });
}/// Create a copy of Recurring
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecurringNextCopyWith<$Res>? get next {
    if (_self.next == null) {
    return null;
  }

  return $RecurringNextCopyWith<$Res>(_self.next!, (value) {
    return _then(_self.copyWith(next: value));
  });
}
}


/// @nodoc
mixin _$RecurringDue {

 Recurring get recurring; String get month; String get dueDate;
/// Create a copy of RecurringDue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecurringDueCopyWith<RecurringDue> get copyWith => _$RecurringDueCopyWithImpl<RecurringDue>(this as RecurringDue, _$identity);

  /// Serializes this RecurringDue to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RecurringDue;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecurringDue&&(identical(other.recurring, _this.recurring) || other.recurring == _this.recurring)&&(identical(other.month, _this.month) || other.month == _this.month)&&(identical(other.dueDate, _this.dueDate) || other.dueDate == _this.dueDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RecurringDue;
  return Object.hash(runtimeType,_this.recurring,_this.month,_this.dueDate);
}

@override
String toString() {
  final _this = this as RecurringDue;
  return 'RecurringDue(recurring: ${_this.recurring}, month: ${_this.month}, dueDate: ${_this.dueDate})';
}


}

/// @nodoc
abstract mixin class $RecurringDueCopyWith<$Res>  {
  factory $RecurringDueCopyWith(RecurringDue value, $Res Function(RecurringDue) _then) = _$RecurringDueCopyWithImpl;
@useResult
$Res call({
 Recurring recurring, String month, String dueDate
});


$RecurringCopyWith<$Res> get recurring;

}
/// @nodoc
class _$RecurringDueCopyWithImpl<$Res>
    implements $RecurringDueCopyWith<$Res> {
  _$RecurringDueCopyWithImpl(this._self, this._then);

  final RecurringDue _self;
  final $Res Function(RecurringDue) _then;

/// Create a copy of RecurringDue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? recurring = null,Object? month = null,Object? dueDate = null,}) {
  return _then(RecurringDue(
recurring: null == recurring ? _self.recurring : recurring // ignore: cast_nullable_to_non_nullable
as Recurring,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as String,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of RecurringDue
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecurringCopyWith<$Res> get recurring {
  
  return $RecurringCopyWith<$Res>(_self.recurring, (value) {
    return _then(_self.copyWith(recurring: value));
  });
}
}


/// Adds pattern-matching-related methods to [RecurringDue].
extension RecurringDuePatterns on RecurringDue {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecurringDue value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecurringDue() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecurringDue value)  $default,){
final _that = this;
switch (_that) {
case _RecurringDue():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecurringDue value)?  $default,){
final _that = this;
switch (_that) {
case _RecurringDue() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Recurring recurring,  String month,  String dueDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecurringDue() when $default != null:
return $default(_that.recurring,_that.month,_that.dueDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Recurring recurring,  String month,  String dueDate)  $default,) {final _that = this;
switch (_that) {
case _RecurringDue():
return $default(_that.recurring,_that.month,_that.dueDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Recurring recurring,  String month,  String dueDate)?  $default,) {final _that = this;
switch (_that) {
case _RecurringDue() when $default != null:
return $default(_that.recurring,_that.month,_that.dueDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecurringDue implements RecurringDue {
  const _RecurringDue({required this.recurring, required this.month, required this.dueDate});
  factory _RecurringDue.fromJson(Map<String, dynamic> json) => _$RecurringDueFromJson(json);

@override final  Recurring recurring;
@override final  String month;
@override final  String dueDate;

/// Create a copy of RecurringDue
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecurringDueCopyWith<_RecurringDue> get copyWith => __$RecurringDueCopyWithImpl<_RecurringDue>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecurringDueToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecurringDue&&(identical(other.recurring, recurring) || other.recurring == recurring)&&(identical(other.month, month) || other.month == month)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,recurring,month,dueDate);
}

@override
String toString() {
    return 'RecurringDue(recurring: $recurring, month: $month, dueDate: $dueDate)';
}


}

/// @nodoc
abstract mixin class _$RecurringDueCopyWith<$Res> implements $RecurringDueCopyWith<$Res> {
  factory _$RecurringDueCopyWith(_RecurringDue value, $Res Function(_RecurringDue) _then) = __$RecurringDueCopyWithImpl;
@override @useResult
$Res call({
 Recurring recurring, String month, String dueDate
});


@override $RecurringCopyWith<$Res> get recurring;

}
/// @nodoc
class __$RecurringDueCopyWithImpl<$Res>
    implements _$RecurringDueCopyWith<$Res> {
  __$RecurringDueCopyWithImpl(this._self, this._then);

  final _RecurringDue _self;
  final $Res Function(_RecurringDue) _then;

/// Create a copy of RecurringDue
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? recurring = null,Object? month = null,Object? dueDate = null,}) {
  return _then(_RecurringDue(
recurring: null == recurring ? _self.recurring : recurring // ignore: cast_nullable_to_non_nullable
as Recurring,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as String,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of RecurringDue
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecurringCopyWith<$Res> get recurring {
  
  return $RecurringCopyWith<$Res>(_self.recurring, (value) {
    return _then(_self.copyWith(recurring: value));
  });
}
}

// dart format on
