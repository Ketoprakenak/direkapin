// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calendar_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CalendarDay {

 String get date; int get income; int get expense; int get activityCount; bool get hasImportant;
/// Create a copy of CalendarDay
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CalendarDayCopyWith<CalendarDay> get copyWith => _$CalendarDayCopyWithImpl<CalendarDay>(this as CalendarDay, _$identity);

  /// Serializes this CalendarDay to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CalendarDay;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CalendarDay&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.income, _this.income) || other.income == _this.income)&&(identical(other.expense, _this.expense) || other.expense == _this.expense)&&(identical(other.activityCount, _this.activityCount) || other.activityCount == _this.activityCount)&&(identical(other.hasImportant, _this.hasImportant) || other.hasImportant == _this.hasImportant));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CalendarDay;
  return Object.hash(runtimeType,_this.date,_this.income,_this.expense,_this.activityCount,_this.hasImportant);
}

@override
String toString() {
  final _this = this as CalendarDay;
  return 'CalendarDay(date: ${_this.date}, income: ${_this.income}, expense: ${_this.expense}, activityCount: ${_this.activityCount}, hasImportant: ${_this.hasImportant})';
}


}

/// @nodoc
abstract mixin class $CalendarDayCopyWith<$Res>  {
  factory $CalendarDayCopyWith(CalendarDay value, $Res Function(CalendarDay) _then) = _$CalendarDayCopyWithImpl;
@useResult
$Res call({
 String date, int income, int expense, int activityCount, bool hasImportant
});




}
/// @nodoc
class _$CalendarDayCopyWithImpl<$Res>
    implements $CalendarDayCopyWith<$Res> {
  _$CalendarDayCopyWithImpl(this._self, this._then);

  final CalendarDay _self;
  final $Res Function(CalendarDay) _then;

/// Create a copy of CalendarDay
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? income = null,Object? expense = null,Object? activityCount = null,Object? hasImportant = null,}) {
  return _then(CalendarDay(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as int,expense: null == expense ? _self.expense : expense // ignore: cast_nullable_to_non_nullable
as int,activityCount: null == activityCount ? _self.activityCount : activityCount // ignore: cast_nullable_to_non_nullable
as int,hasImportant: null == hasImportant ? _self.hasImportant : hasImportant // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CalendarDay].
extension CalendarDayPatterns on CalendarDay {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CalendarDay value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CalendarDay() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CalendarDay value)  $default,){
final _that = this;
switch (_that) {
case _CalendarDay():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CalendarDay value)?  $default,){
final _that = this;
switch (_that) {
case _CalendarDay() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String date,  int income,  int expense,  int activityCount,  bool hasImportant)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CalendarDay() when $default != null:
return $default(_that.date,_that.income,_that.expense,_that.activityCount,_that.hasImportant);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String date,  int income,  int expense,  int activityCount,  bool hasImportant)  $default,) {final _that = this;
switch (_that) {
case _CalendarDay():
return $default(_that.date,_that.income,_that.expense,_that.activityCount,_that.hasImportant);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String date,  int income,  int expense,  int activityCount,  bool hasImportant)?  $default,) {final _that = this;
switch (_that) {
case _CalendarDay() when $default != null:
return $default(_that.date,_that.income,_that.expense,_that.activityCount,_that.hasImportant);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CalendarDay implements CalendarDay {
  const _CalendarDay({required this.date, required this.income, required this.expense, required this.activityCount, required this.hasImportant});
  factory _CalendarDay.fromJson(Map<String, dynamic> json) => _$CalendarDayFromJson(json);

@override final  String date;
@override final  int income;
@override final  int expense;
@override final  int activityCount;
@override final  bool hasImportant;

/// Create a copy of CalendarDay
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CalendarDayCopyWith<_CalendarDay> get copyWith => __$CalendarDayCopyWithImpl<_CalendarDay>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CalendarDayToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CalendarDay&&(identical(other.date, date) || other.date == date)&&(identical(other.income, income) || other.income == income)&&(identical(other.expense, expense) || other.expense == expense)&&(identical(other.activityCount, activityCount) || other.activityCount == activityCount)&&(identical(other.hasImportant, hasImportant) || other.hasImportant == hasImportant));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,date,income,expense,activityCount,hasImportant);
}

@override
String toString() {
    return 'CalendarDay(date: $date, income: $income, expense: $expense, activityCount: $activityCount, hasImportant: $hasImportant)';
}


}

/// @nodoc
abstract mixin class _$CalendarDayCopyWith<$Res> implements $CalendarDayCopyWith<$Res> {
  factory _$CalendarDayCopyWith(_CalendarDay value, $Res Function(_CalendarDay) _then) = __$CalendarDayCopyWithImpl;
@override @useResult
$Res call({
 String date, int income, int expense, int activityCount, bool hasImportant
});




}
/// @nodoc
class __$CalendarDayCopyWithImpl<$Res>
    implements _$CalendarDayCopyWith<$Res> {
  __$CalendarDayCopyWithImpl(this._self, this._then);

  final _CalendarDay _self;
  final $Res Function(_CalendarDay) _then;

/// Create a copy of CalendarDay
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? income = null,Object? expense = null,Object? activityCount = null,Object? hasImportant = null,}) {
  return _then(_CalendarDay(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as int,expense: null == expense ? _self.expense : expense // ignore: cast_nullable_to_non_nullable
as int,activityCount: null == activityCount ? _self.activityCount : activityCount // ignore: cast_nullable_to_non_nullable
as int,hasImportant: null == hasImportant ? _self.hasImportant : hasImportant // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$DayDetail {

 String get date; int get income; int get expense; List<Transaction> get transactions; List<Transfer> get transfers; List<Activity> get activities;
/// Create a copy of DayDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DayDetailCopyWith<DayDetail> get copyWith => _$DayDetailCopyWithImpl<DayDetail>(this as DayDetail, _$identity);

  /// Serializes this DayDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DayDetail;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DayDetail&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.income, _this.income) || other.income == _this.income)&&(identical(other.expense, _this.expense) || other.expense == _this.expense)&&const DeepCollectionEquality().equals(other.transactions, _this.transactions)&&const DeepCollectionEquality().equals(other.transfers, _this.transfers)&&const DeepCollectionEquality().equals(other.activities, _this.activities));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DayDetail;
  return Object.hash(runtimeType,_this.date,_this.income,_this.expense,const DeepCollectionEquality().hash(_this.transactions),const DeepCollectionEquality().hash(_this.transfers),const DeepCollectionEquality().hash(_this.activities));
}

@override
String toString() {
  final _this = this as DayDetail;
  return 'DayDetail(date: ${_this.date}, income: ${_this.income}, expense: ${_this.expense}, transactions: ${_this.transactions}, transfers: ${_this.transfers}, activities: ${_this.activities})';
}


}

/// @nodoc
abstract mixin class $DayDetailCopyWith<$Res>  {
  factory $DayDetailCopyWith(DayDetail value, $Res Function(DayDetail) _then) = _$DayDetailCopyWithImpl;
@useResult
$Res call({
 String date, int income, int expense, List<Transaction> transactions, List<Transfer> transfers, List<Activity> activities
});




}
/// @nodoc
class _$DayDetailCopyWithImpl<$Res>
    implements $DayDetailCopyWith<$Res> {
  _$DayDetailCopyWithImpl(this._self, this._then);

  final DayDetail _self;
  final $Res Function(DayDetail) _then;

/// Create a copy of DayDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? income = null,Object? expense = null,Object? transactions = null,Object? transfers = null,Object? activities = null,}) {
  return _then(DayDetail(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as int,expense: null == expense ? _self.expense : expense // ignore: cast_nullable_to_non_nullable
as int,transactions: null == transactions ? _self.transactions : transactions // ignore: cast_nullable_to_non_nullable
as List<Transaction>,transfers: null == transfers ? _self.transfers : transfers // ignore: cast_nullable_to_non_nullable
as List<Transfer>,activities: null == activities ? _self.activities : activities // ignore: cast_nullable_to_non_nullable
as List<Activity>,
  ));
}

}


/// Adds pattern-matching-related methods to [DayDetail].
extension DayDetailPatterns on DayDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DayDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DayDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DayDetail value)  $default,){
final _that = this;
switch (_that) {
case _DayDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DayDetail value)?  $default,){
final _that = this;
switch (_that) {
case _DayDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String date,  int income,  int expense,  List<Transaction> transactions,  List<Transfer> transfers,  List<Activity> activities)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DayDetail() when $default != null:
return $default(_that.date,_that.income,_that.expense,_that.transactions,_that.transfers,_that.activities);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String date,  int income,  int expense,  List<Transaction> transactions,  List<Transfer> transfers,  List<Activity> activities)  $default,) {final _that = this;
switch (_that) {
case _DayDetail():
return $default(_that.date,_that.income,_that.expense,_that.transactions,_that.transfers,_that.activities);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String date,  int income,  int expense,  List<Transaction> transactions,  List<Transfer> transfers,  List<Activity> activities)?  $default,) {final _that = this;
switch (_that) {
case _DayDetail() when $default != null:
return $default(_that.date,_that.income,_that.expense,_that.transactions,_that.transfers,_that.activities);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DayDetail implements DayDetail {
  const _DayDetail({required this.date, required this.income, required this.expense, required  List<Transaction> transactions, required  List<Transfer> transfers, required  List<Activity> activities}): _transactions = transactions,_transfers = transfers,_activities = activities;
  factory _DayDetail.fromJson(Map<String, dynamic> json) => _$DayDetailFromJson(json);

@override final  String date;
@override final  int income;
@override final  int expense;
 final  List<Transaction> _transactions;
@override List<Transaction> get transactions {
  if (_transactions is EqualUnmodifiableListView) return _transactions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_transactions);
}

 final  List<Transfer> _transfers;
@override List<Transfer> get transfers {
  if (_transfers is EqualUnmodifiableListView) return _transfers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_transfers);
}

 final  List<Activity> _activities;
@override List<Activity> get activities {
  if (_activities is EqualUnmodifiableListView) return _activities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_activities);
}


/// Create a copy of DayDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DayDetailCopyWith<_DayDetail> get copyWith => __$DayDetailCopyWithImpl<_DayDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DayDetailToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DayDetail&&(identical(other.date, date) || other.date == date)&&(identical(other.income, income) || other.income == income)&&(identical(other.expense, expense) || other.expense == expense)&&const DeepCollectionEquality().equals(other.transactions, _transactions)&&const DeepCollectionEquality().equals(other.transfers, _transfers)&&const DeepCollectionEquality().equals(other.activities, _activities));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,date,income,expense,const DeepCollectionEquality().hash(_transactions),const DeepCollectionEquality().hash(_transfers),const DeepCollectionEquality().hash(_activities));
}

@override
String toString() {
    return 'DayDetail(date: $date, income: $income, expense: $expense, transactions: $transactions, transfers: $transfers, activities: $activities)';
}


}

/// @nodoc
abstract mixin class _$DayDetailCopyWith<$Res> implements $DayDetailCopyWith<$Res> {
  factory _$DayDetailCopyWith(_DayDetail value, $Res Function(_DayDetail) _then) = __$DayDetailCopyWithImpl;
@override @useResult
$Res call({
 String date, int income, int expense, List<Transaction> transactions, List<Transfer> transfers, List<Activity> activities
});




}
/// @nodoc
class __$DayDetailCopyWithImpl<$Res>
    implements _$DayDetailCopyWith<$Res> {
  __$DayDetailCopyWithImpl(this._self, this._then);

  final _DayDetail _self;
  final $Res Function(_DayDetail) _then;

/// Create a copy of DayDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? income = null,Object? expense = null,Object? transactions = null,Object? transfers = null,Object? activities = null,}) {
  return _then(_DayDetail(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as int,expense: null == expense ? _self.expense : expense // ignore: cast_nullable_to_non_nullable
as int,transactions: null == transactions ? _self._transactions : transactions // ignore: cast_nullable_to_non_nullable
as List<Transaction>,transfers: null == transfers ? _self._transfers : transfers // ignore: cast_nullable_to_non_nullable
as List<Transfer>,activities: null == activities ? _self._activities : activities // ignore: cast_nullable_to_non_nullable
as List<Activity>,
  ));
}


}

// dart format on
