// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MonthSummary {

 int get income; int get expense; int get net;
/// Create a copy of MonthSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MonthSummaryCopyWith<MonthSummary> get copyWith => _$MonthSummaryCopyWithImpl<MonthSummary>(this as MonthSummary, _$identity);

  /// Serializes this MonthSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MonthSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MonthSummary&&(identical(other.income, _this.income) || other.income == _this.income)&&(identical(other.expense, _this.expense) || other.expense == _this.expense)&&(identical(other.net, _this.net) || other.net == _this.net));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MonthSummary;
  return Object.hash(runtimeType,_this.income,_this.expense,_this.net);
}

@override
String toString() {
  final _this = this as MonthSummary;
  return 'MonthSummary(income: ${_this.income}, expense: ${_this.expense}, net: ${_this.net})';
}


}

/// @nodoc
abstract mixin class $MonthSummaryCopyWith<$Res>  {
  factory $MonthSummaryCopyWith(MonthSummary value, $Res Function(MonthSummary) _then) = _$MonthSummaryCopyWithImpl;
@useResult
$Res call({
 int income, int expense, int net
});




}
/// @nodoc
class _$MonthSummaryCopyWithImpl<$Res>
    implements $MonthSummaryCopyWith<$Res> {
  _$MonthSummaryCopyWithImpl(this._self, this._then);

  final MonthSummary _self;
  final $Res Function(MonthSummary) _then;

/// Create a copy of MonthSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? income = null,Object? expense = null,Object? net = null,}) {
  return _then(MonthSummary(
income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as int,expense: null == expense ? _self.expense : expense // ignore: cast_nullable_to_non_nullable
as int,net: null == net ? _self.net : net // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MonthSummary].
extension MonthSummaryPatterns on MonthSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MonthSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MonthSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MonthSummary value)  $default,){
final _that = this;
switch (_that) {
case _MonthSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MonthSummary value)?  $default,){
final _that = this;
switch (_that) {
case _MonthSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int income,  int expense,  int net)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MonthSummary() when $default != null:
return $default(_that.income,_that.expense,_that.net);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int income,  int expense,  int net)  $default,) {final _that = this;
switch (_that) {
case _MonthSummary():
return $default(_that.income,_that.expense,_that.net);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int income,  int expense,  int net)?  $default,) {final _that = this;
switch (_that) {
case _MonthSummary() when $default != null:
return $default(_that.income,_that.expense,_that.net);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MonthSummary implements MonthSummary {
  const _MonthSummary({required this.income, required this.expense, required this.net});
  factory _MonthSummary.fromJson(Map<String, dynamic> json) => _$MonthSummaryFromJson(json);

@override final  int income;
@override final  int expense;
@override final  int net;

/// Create a copy of MonthSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MonthSummaryCopyWith<_MonthSummary> get copyWith => __$MonthSummaryCopyWithImpl<_MonthSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MonthSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MonthSummary&&(identical(other.income, income) || other.income == income)&&(identical(other.expense, expense) || other.expense == expense)&&(identical(other.net, net) || other.net == net));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,income,expense,net);
}

@override
String toString() {
    return 'MonthSummary(income: $income, expense: $expense, net: $net)';
}


}

/// @nodoc
abstract mixin class _$MonthSummaryCopyWith<$Res> implements $MonthSummaryCopyWith<$Res> {
  factory _$MonthSummaryCopyWith(_MonthSummary value, $Res Function(_MonthSummary) _then) = __$MonthSummaryCopyWithImpl;
@override @useResult
$Res call({
 int income, int expense, int net
});




}
/// @nodoc
class __$MonthSummaryCopyWithImpl<$Res>
    implements _$MonthSummaryCopyWith<$Res> {
  __$MonthSummaryCopyWithImpl(this._self, this._then);

  final _MonthSummary _self;
  final $Res Function(_MonthSummary) _then;

/// Create a copy of MonthSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? income = null,Object? expense = null,Object? net = null,}) {
  return _then(_MonthSummary(
income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as int,expense: null == expense ? _self.expense : expense // ignore: cast_nullable_to_non_nullable
as int,net: null == net ? _self.net : net // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$TodaySummary {

 String get date; int get expense; List<Activity> get activities; bool get hasEntry;
/// Create a copy of TodaySummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodaySummaryCopyWith<TodaySummary> get copyWith => _$TodaySummaryCopyWithImpl<TodaySummary>(this as TodaySummary, _$identity);

  /// Serializes this TodaySummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TodaySummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodaySummary&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.expense, _this.expense) || other.expense == _this.expense)&&const DeepCollectionEquality().equals(other.activities, _this.activities)&&(identical(other.hasEntry, _this.hasEntry) || other.hasEntry == _this.hasEntry));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TodaySummary;
  return Object.hash(runtimeType,_this.date,_this.expense,const DeepCollectionEquality().hash(_this.activities),_this.hasEntry);
}

@override
String toString() {
  final _this = this as TodaySummary;
  return 'TodaySummary(date: ${_this.date}, expense: ${_this.expense}, activities: ${_this.activities}, hasEntry: ${_this.hasEntry})';
}


}

/// @nodoc
abstract mixin class $TodaySummaryCopyWith<$Res>  {
  factory $TodaySummaryCopyWith(TodaySummary value, $Res Function(TodaySummary) _then) = _$TodaySummaryCopyWithImpl;
@useResult
$Res call({
 String date, int expense, List<Activity> activities, bool hasEntry
});




}
/// @nodoc
class _$TodaySummaryCopyWithImpl<$Res>
    implements $TodaySummaryCopyWith<$Res> {
  _$TodaySummaryCopyWithImpl(this._self, this._then);

  final TodaySummary _self;
  final $Res Function(TodaySummary) _then;

/// Create a copy of TodaySummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? expense = null,Object? activities = null,Object? hasEntry = null,}) {
  return _then(TodaySummary(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,expense: null == expense ? _self.expense : expense // ignore: cast_nullable_to_non_nullable
as int,activities: null == activities ? _self.activities : activities // ignore: cast_nullable_to_non_nullable
as List<Activity>,hasEntry: null == hasEntry ? _self.hasEntry : hasEntry // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TodaySummary].
extension TodaySummaryPatterns on TodaySummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TodaySummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TodaySummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TodaySummary value)  $default,){
final _that = this;
switch (_that) {
case _TodaySummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TodaySummary value)?  $default,){
final _that = this;
switch (_that) {
case _TodaySummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String date,  int expense,  List<Activity> activities,  bool hasEntry)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TodaySummary() when $default != null:
return $default(_that.date,_that.expense,_that.activities,_that.hasEntry);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String date,  int expense,  List<Activity> activities,  bool hasEntry)  $default,) {final _that = this;
switch (_that) {
case _TodaySummary():
return $default(_that.date,_that.expense,_that.activities,_that.hasEntry);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String date,  int expense,  List<Activity> activities,  bool hasEntry)?  $default,) {final _that = this;
switch (_that) {
case _TodaySummary() when $default != null:
return $default(_that.date,_that.expense,_that.activities,_that.hasEntry);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TodaySummary implements TodaySummary {
  const _TodaySummary({required this.date, required this.expense, required  List<Activity> activities, required this.hasEntry}): _activities = activities;
  factory _TodaySummary.fromJson(Map<String, dynamic> json) => _$TodaySummaryFromJson(json);

@override final  String date;
@override final  int expense;
 final  List<Activity> _activities;
@override List<Activity> get activities {
  if (_activities is EqualUnmodifiableListView) return _activities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_activities);
}

@override final  bool hasEntry;

/// Create a copy of TodaySummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TodaySummaryCopyWith<_TodaySummary> get copyWith => __$TodaySummaryCopyWithImpl<_TodaySummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TodaySummaryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TodaySummary&&(identical(other.date, date) || other.date == date)&&(identical(other.expense, expense) || other.expense == expense)&&const DeepCollectionEquality().equals(other.activities, _activities)&&(identical(other.hasEntry, hasEntry) || other.hasEntry == hasEntry));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,date,expense,const DeepCollectionEquality().hash(_activities),hasEntry);
}

@override
String toString() {
    return 'TodaySummary(date: $date, expense: $expense, activities: $activities, hasEntry: $hasEntry)';
}


}

/// @nodoc
abstract mixin class _$TodaySummaryCopyWith<$Res> implements $TodaySummaryCopyWith<$Res> {
  factory _$TodaySummaryCopyWith(_TodaySummary value, $Res Function(_TodaySummary) _then) = __$TodaySummaryCopyWithImpl;
@override @useResult
$Res call({
 String date, int expense, List<Activity> activities, bool hasEntry
});




}
/// @nodoc
class __$TodaySummaryCopyWithImpl<$Res>
    implements _$TodaySummaryCopyWith<$Res> {
  __$TodaySummaryCopyWithImpl(this._self, this._then);

  final _TodaySummary _self;
  final $Res Function(_TodaySummary) _then;

/// Create a copy of TodaySummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? expense = null,Object? activities = null,Object? hasEntry = null,}) {
  return _then(_TodaySummary(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,expense: null == expense ? _self.expense : expense // ignore: cast_nullable_to_non_nullable
as int,activities: null == activities ? _self._activities : activities // ignore: cast_nullable_to_non_nullable
as List<Activity>,hasEntry: null == hasEntry ? _self.hasEntry : hasEntry // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$SeriesPoint {

 String get label; int get income; int get expense;
/// Create a copy of SeriesPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SeriesPointCopyWith<SeriesPoint> get copyWith => _$SeriesPointCopyWithImpl<SeriesPoint>(this as SeriesPoint, _$identity);

  /// Serializes this SeriesPoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SeriesPoint;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SeriesPoint&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.income, _this.income) || other.income == _this.income)&&(identical(other.expense, _this.expense) || other.expense == _this.expense));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SeriesPoint;
  return Object.hash(runtimeType,_this.label,_this.income,_this.expense);
}

@override
String toString() {
  final _this = this as SeriesPoint;
  return 'SeriesPoint(label: ${_this.label}, income: ${_this.income}, expense: ${_this.expense})';
}


}

/// @nodoc
abstract mixin class $SeriesPointCopyWith<$Res>  {
  factory $SeriesPointCopyWith(SeriesPoint value, $Res Function(SeriesPoint) _then) = _$SeriesPointCopyWithImpl;
@useResult
$Res call({
 String label, int income, int expense
});




}
/// @nodoc
class _$SeriesPointCopyWithImpl<$Res>
    implements $SeriesPointCopyWith<$Res> {
  _$SeriesPointCopyWithImpl(this._self, this._then);

  final SeriesPoint _self;
  final $Res Function(SeriesPoint) _then;

/// Create a copy of SeriesPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? income = null,Object? expense = null,}) {
  return _then(SeriesPoint(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as int,expense: null == expense ? _self.expense : expense // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SeriesPoint].
extension SeriesPointPatterns on SeriesPoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SeriesPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SeriesPoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SeriesPoint value)  $default,){
final _that = this;
switch (_that) {
case _SeriesPoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SeriesPoint value)?  $default,){
final _that = this;
switch (_that) {
case _SeriesPoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  int income,  int expense)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SeriesPoint() when $default != null:
return $default(_that.label,_that.income,_that.expense);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  int income,  int expense)  $default,) {final _that = this;
switch (_that) {
case _SeriesPoint():
return $default(_that.label,_that.income,_that.expense);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  int income,  int expense)?  $default,) {final _that = this;
switch (_that) {
case _SeriesPoint() when $default != null:
return $default(_that.label,_that.income,_that.expense);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SeriesPoint implements SeriesPoint {
  const _SeriesPoint({required this.label, required this.income, required this.expense});
  factory _SeriesPoint.fromJson(Map<String, dynamic> json) => _$SeriesPointFromJson(json);

@override final  String label;
@override final  int income;
@override final  int expense;

/// Create a copy of SeriesPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SeriesPointCopyWith<_SeriesPoint> get copyWith => __$SeriesPointCopyWithImpl<_SeriesPoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SeriesPointToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SeriesPoint&&(identical(other.label, label) || other.label == label)&&(identical(other.income, income) || other.income == income)&&(identical(other.expense, expense) || other.expense == expense));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,label,income,expense);
}

@override
String toString() {
    return 'SeriesPoint(label: $label, income: $income, expense: $expense)';
}


}

/// @nodoc
abstract mixin class _$SeriesPointCopyWith<$Res> implements $SeriesPointCopyWith<$Res> {
  factory _$SeriesPointCopyWith(_SeriesPoint value, $Res Function(_SeriesPoint) _then) = __$SeriesPointCopyWithImpl;
@override @useResult
$Res call({
 String label, int income, int expense
});




}
/// @nodoc
class __$SeriesPointCopyWithImpl<$Res>
    implements _$SeriesPointCopyWith<$Res> {
  __$SeriesPointCopyWithImpl(this._self, this._then);

  final _SeriesPoint _self;
  final $Res Function(_SeriesPoint) _then;

/// Create a copy of SeriesPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? income = null,Object? expense = null,}) {
  return _then(_SeriesPoint(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as int,expense: null == expense ? _self.expense : expense // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$Streak {

 int get current; int get longest;
/// Create a copy of Streak
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StreakCopyWith<Streak> get copyWith => _$StreakCopyWithImpl<Streak>(this as Streak, _$identity);

  /// Serializes this Streak to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Streak;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Streak&&(identical(other.current, _this.current) || other.current == _this.current)&&(identical(other.longest, _this.longest) || other.longest == _this.longest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Streak;
  return Object.hash(runtimeType,_this.current,_this.longest);
}

@override
String toString() {
  final _this = this as Streak;
  return 'Streak(current: ${_this.current}, longest: ${_this.longest})';
}


}

/// @nodoc
abstract mixin class $StreakCopyWith<$Res>  {
  factory $StreakCopyWith(Streak value, $Res Function(Streak) _then) = _$StreakCopyWithImpl;
@useResult
$Res call({
 int current, int longest
});




}
/// @nodoc
class _$StreakCopyWithImpl<$Res>
    implements $StreakCopyWith<$Res> {
  _$StreakCopyWithImpl(this._self, this._then);

  final Streak _self;
  final $Res Function(Streak) _then;

/// Create a copy of Streak
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? current = null,Object? longest = null,}) {
  return _then(Streak(
current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as int,longest: null == longest ? _self.longest : longest // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Streak].
extension StreakPatterns on Streak {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Streak value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Streak() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Streak value)  $default,){
final _that = this;
switch (_that) {
case _Streak():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Streak value)?  $default,){
final _that = this;
switch (_that) {
case _Streak() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int current,  int longest)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Streak() when $default != null:
return $default(_that.current,_that.longest);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int current,  int longest)  $default,) {final _that = this;
switch (_that) {
case _Streak():
return $default(_that.current,_that.longest);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int current,  int longest)?  $default,) {final _that = this;
switch (_that) {
case _Streak() when $default != null:
return $default(_that.current,_that.longest);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Streak implements Streak {
  const _Streak({required this.current, required this.longest});
  factory _Streak.fromJson(Map<String, dynamic> json) => _$StreakFromJson(json);

@override final  int current;
@override final  int longest;

/// Create a copy of Streak
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StreakCopyWith<_Streak> get copyWith => __$StreakCopyWithImpl<_Streak>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StreakToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Streak&&(identical(other.current, current) || other.current == current)&&(identical(other.longest, longest) || other.longest == longest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,current,longest);
}

@override
String toString() {
    return 'Streak(current: $current, longest: $longest)';
}


}

/// @nodoc
abstract mixin class _$StreakCopyWith<$Res> implements $StreakCopyWith<$Res> {
  factory _$StreakCopyWith(_Streak value, $Res Function(_Streak) _then) = __$StreakCopyWithImpl;
@override @useResult
$Res call({
 int current, int longest
});




}
/// @nodoc
class __$StreakCopyWithImpl<$Res>
    implements _$StreakCopyWith<$Res> {
  __$StreakCopyWithImpl(this._self, this._then);

  final _Streak _self;
  final $Res Function(_Streak) _then;

/// Create a copy of Streak
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? current = null,Object? longest = null,}) {
  return _then(_Streak(
current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as int,longest: null == longest ? _self.longest : longest // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$Dashboard {

 int get totalBalance; List<Wallet> get wallets; MonthSummary get month; TodaySummary get today; List<SeriesPoint> get last7Days; Streak get streak;
/// Create a copy of Dashboard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardCopyWith<Dashboard> get copyWith => _$DashboardCopyWithImpl<Dashboard>(this as Dashboard, _$identity);

  /// Serializes this Dashboard to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Dashboard;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Dashboard&&(identical(other.totalBalance, _this.totalBalance) || other.totalBalance == _this.totalBalance)&&const DeepCollectionEquality().equals(other.wallets, _this.wallets)&&(identical(other.month, _this.month) || other.month == _this.month)&&(identical(other.today, _this.today) || other.today == _this.today)&&const DeepCollectionEquality().equals(other.last7Days, _this.last7Days)&&(identical(other.streak, _this.streak) || other.streak == _this.streak));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Dashboard;
  return Object.hash(runtimeType,_this.totalBalance,const DeepCollectionEquality().hash(_this.wallets),_this.month,_this.today,const DeepCollectionEquality().hash(_this.last7Days),_this.streak);
}

@override
String toString() {
  final _this = this as Dashboard;
  return 'Dashboard(totalBalance: ${_this.totalBalance}, wallets: ${_this.wallets}, month: ${_this.month}, today: ${_this.today}, last7Days: ${_this.last7Days}, streak: ${_this.streak})';
}


}

/// @nodoc
abstract mixin class $DashboardCopyWith<$Res>  {
  factory $DashboardCopyWith(Dashboard value, $Res Function(Dashboard) _then) = _$DashboardCopyWithImpl;
@useResult
$Res call({
 int totalBalance, List<Wallet> wallets, MonthSummary month, TodaySummary today, List<SeriesPoint> last7Days, Streak streak
});


$MonthSummaryCopyWith<$Res> get month;$TodaySummaryCopyWith<$Res> get today;$StreakCopyWith<$Res> get streak;

}
/// @nodoc
class _$DashboardCopyWithImpl<$Res>
    implements $DashboardCopyWith<$Res> {
  _$DashboardCopyWithImpl(this._self, this._then);

  final Dashboard _self;
  final $Res Function(Dashboard) _then;

/// Create a copy of Dashboard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalBalance = null,Object? wallets = null,Object? month = null,Object? today = null,Object? last7Days = null,Object? streak = null,}) {
  return _then(Dashboard(
totalBalance: null == totalBalance ? _self.totalBalance : totalBalance // ignore: cast_nullable_to_non_nullable
as int,wallets: null == wallets ? _self.wallets : wallets // ignore: cast_nullable_to_non_nullable
as List<Wallet>,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as MonthSummary,today: null == today ? _self.today : today // ignore: cast_nullable_to_non_nullable
as TodaySummary,last7Days: null == last7Days ? _self.last7Days : last7Days // ignore: cast_nullable_to_non_nullable
as List<SeriesPoint>,streak: null == streak ? _self.streak : streak // ignore: cast_nullable_to_non_nullable
as Streak,
  ));
}
/// Create a copy of Dashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MonthSummaryCopyWith<$Res> get month {
  
  return $MonthSummaryCopyWith<$Res>(_self.month, (value) {
    return _then(_self.copyWith(month: value));
  });
}/// Create a copy of Dashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TodaySummaryCopyWith<$Res> get today {
  
  return $TodaySummaryCopyWith<$Res>(_self.today, (value) {
    return _then(_self.copyWith(today: value));
  });
}/// Create a copy of Dashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StreakCopyWith<$Res> get streak {
  
  return $StreakCopyWith<$Res>(_self.streak, (value) {
    return _then(_self.copyWith(streak: value));
  });
}
}


/// Adds pattern-matching-related methods to [Dashboard].
extension DashboardPatterns on Dashboard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Dashboard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Dashboard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Dashboard value)  $default,){
final _that = this;
switch (_that) {
case _Dashboard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Dashboard value)?  $default,){
final _that = this;
switch (_that) {
case _Dashboard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalBalance,  List<Wallet> wallets,  MonthSummary month,  TodaySummary today,  List<SeriesPoint> last7Days,  Streak streak)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Dashboard() when $default != null:
return $default(_that.totalBalance,_that.wallets,_that.month,_that.today,_that.last7Days,_that.streak);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalBalance,  List<Wallet> wallets,  MonthSummary month,  TodaySummary today,  List<SeriesPoint> last7Days,  Streak streak)  $default,) {final _that = this;
switch (_that) {
case _Dashboard():
return $default(_that.totalBalance,_that.wallets,_that.month,_that.today,_that.last7Days,_that.streak);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalBalance,  List<Wallet> wallets,  MonthSummary month,  TodaySummary today,  List<SeriesPoint> last7Days,  Streak streak)?  $default,) {final _that = this;
switch (_that) {
case _Dashboard() when $default != null:
return $default(_that.totalBalance,_that.wallets,_that.month,_that.today,_that.last7Days,_that.streak);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Dashboard implements Dashboard {
  const _Dashboard({required this.totalBalance, required  List<Wallet> wallets, required this.month, required this.today, required  List<SeriesPoint> last7Days, required this.streak}): _wallets = wallets,_last7Days = last7Days;
  factory _Dashboard.fromJson(Map<String, dynamic> json) => _$DashboardFromJson(json);

@override final  int totalBalance;
 final  List<Wallet> _wallets;
@override List<Wallet> get wallets {
  if (_wallets is EqualUnmodifiableListView) return _wallets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_wallets);
}

@override final  MonthSummary month;
@override final  TodaySummary today;
 final  List<SeriesPoint> _last7Days;
@override List<SeriesPoint> get last7Days {
  if (_last7Days is EqualUnmodifiableListView) return _last7Days;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_last7Days);
}

@override final  Streak streak;

/// Create a copy of Dashboard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardCopyWith<_Dashboard> get copyWith => __$DashboardCopyWithImpl<_Dashboard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DashboardToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Dashboard&&(identical(other.totalBalance, totalBalance) || other.totalBalance == totalBalance)&&const DeepCollectionEquality().equals(other.wallets, _wallets)&&(identical(other.month, month) || other.month == month)&&(identical(other.today, today) || other.today == today)&&const DeepCollectionEquality().equals(other.last7Days, _last7Days)&&(identical(other.streak, streak) || other.streak == streak));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,totalBalance,const DeepCollectionEquality().hash(_wallets),month,today,const DeepCollectionEquality().hash(_last7Days),streak);
}

@override
String toString() {
    return 'Dashboard(totalBalance: $totalBalance, wallets: $wallets, month: $month, today: $today, last7Days: $last7Days, streak: $streak)';
}


}

/// @nodoc
abstract mixin class _$DashboardCopyWith<$Res> implements $DashboardCopyWith<$Res> {
  factory _$DashboardCopyWith(_Dashboard value, $Res Function(_Dashboard) _then) = __$DashboardCopyWithImpl;
@override @useResult
$Res call({
 int totalBalance, List<Wallet> wallets, MonthSummary month, TodaySummary today, List<SeriesPoint> last7Days, Streak streak
});


@override $MonthSummaryCopyWith<$Res> get month;@override $TodaySummaryCopyWith<$Res> get today;@override $StreakCopyWith<$Res> get streak;

}
/// @nodoc
class __$DashboardCopyWithImpl<$Res>
    implements _$DashboardCopyWith<$Res> {
  __$DashboardCopyWithImpl(this._self, this._then);

  final _Dashboard _self;
  final $Res Function(_Dashboard) _then;

/// Create a copy of Dashboard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalBalance = null,Object? wallets = null,Object? month = null,Object? today = null,Object? last7Days = null,Object? streak = null,}) {
  return _then(_Dashboard(
totalBalance: null == totalBalance ? _self.totalBalance : totalBalance // ignore: cast_nullable_to_non_nullable
as int,wallets: null == wallets ? _self._wallets : wallets // ignore: cast_nullable_to_non_nullable
as List<Wallet>,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as MonthSummary,today: null == today ? _self.today : today // ignore: cast_nullable_to_non_nullable
as TodaySummary,last7Days: null == last7Days ? _self._last7Days : last7Days // ignore: cast_nullable_to_non_nullable
as List<SeriesPoint>,streak: null == streak ? _self.streak : streak // ignore: cast_nullable_to_non_nullable
as Streak,
  ));
}

/// Create a copy of Dashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MonthSummaryCopyWith<$Res> get month {
  
  return $MonthSummaryCopyWith<$Res>(_self.month, (value) {
    return _then(_self.copyWith(month: value));
  });
}/// Create a copy of Dashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TodaySummaryCopyWith<$Res> get today {
  
  return $TodaySummaryCopyWith<$Res>(_self.today, (value) {
    return _then(_self.copyWith(today: value));
  });
}/// Create a copy of Dashboard
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StreakCopyWith<$Res> get streak {
  
  return $StreakCopyWith<$Res>(_self.streak, (value) {
    return _then(_self.copyWith(streak: value));
  });
}
}

// dart format on
