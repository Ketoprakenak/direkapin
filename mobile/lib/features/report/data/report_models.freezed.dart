// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReportPeriod {

 String get start; String get end;
/// Create a copy of ReportPeriod
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportPeriodCopyWith<ReportPeriod> get copyWith => _$ReportPeriodCopyWithImpl<ReportPeriod>(this as ReportPeriod, _$identity);

  /// Serializes this ReportPeriod to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReportPeriod;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportPeriod&&(identical(other.start, _this.start) || other.start == _this.start)&&(identical(other.end, _this.end) || other.end == _this.end));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReportPeriod;
  return Object.hash(runtimeType,_this.start,_this.end);
}

@override
String toString() {
  final _this = this as ReportPeriod;
  return 'ReportPeriod(start: ${_this.start}, end: ${_this.end})';
}


}

/// @nodoc
abstract mixin class $ReportPeriodCopyWith<$Res>  {
  factory $ReportPeriodCopyWith(ReportPeriod value, $Res Function(ReportPeriod) _then) = _$ReportPeriodCopyWithImpl;
@useResult
$Res call({
 String start, String end
});




}
/// @nodoc
class _$ReportPeriodCopyWithImpl<$Res>
    implements $ReportPeriodCopyWith<$Res> {
  _$ReportPeriodCopyWithImpl(this._self, this._then);

  final ReportPeriod _self;
  final $Res Function(ReportPeriod) _then;

/// Create a copy of ReportPeriod
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? start = null,Object? end = null,}) {
  return _then(ReportPeriod(
start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as String,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ReportPeriod].
extension ReportPeriodPatterns on ReportPeriod {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportPeriod value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportPeriod() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportPeriod value)  $default,){
final _that = this;
switch (_that) {
case _ReportPeriod():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportPeriod value)?  $default,){
final _that = this;
switch (_that) {
case _ReportPeriod() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String start,  String end)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportPeriod() when $default != null:
return $default(_that.start,_that.end);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String start,  String end)  $default,) {final _that = this;
switch (_that) {
case _ReportPeriod():
return $default(_that.start,_that.end);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String start,  String end)?  $default,) {final _that = this;
switch (_that) {
case _ReportPeriod() when $default != null:
return $default(_that.start,_that.end);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReportPeriod implements ReportPeriod {
  const _ReportPeriod({required this.start, required this.end});
  factory _ReportPeriod.fromJson(Map<String, dynamic> json) => _$ReportPeriodFromJson(json);

@override final  String start;
@override final  String end;

/// Create a copy of ReportPeriod
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportPeriodCopyWith<_ReportPeriod> get copyWith => __$ReportPeriodCopyWithImpl<_ReportPeriod>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportPeriodToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportPeriod&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,start,end);
}

@override
String toString() {
    return 'ReportPeriod(start: $start, end: $end)';
}


}

/// @nodoc
abstract mixin class _$ReportPeriodCopyWith<$Res> implements $ReportPeriodCopyWith<$Res> {
  factory _$ReportPeriodCopyWith(_ReportPeriod value, $Res Function(_ReportPeriod) _then) = __$ReportPeriodCopyWithImpl;
@override @useResult
$Res call({
 String start, String end
});




}
/// @nodoc
class __$ReportPeriodCopyWithImpl<$Res>
    implements _$ReportPeriodCopyWith<$Res> {
  __$ReportPeriodCopyWithImpl(this._self, this._then);

  final _ReportPeriod _self;
  final $Res Function(_ReportPeriod) _then;

/// Create a copy of ReportPeriod
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? start = null,Object? end = null,}) {
  return _then(_ReportPeriod(
start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as String,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ReportTotals {

 int get income; int get expense; int get net; int get transactionCount;
/// Create a copy of ReportTotals
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportTotalsCopyWith<ReportTotals> get copyWith => _$ReportTotalsCopyWithImpl<ReportTotals>(this as ReportTotals, _$identity);

  /// Serializes this ReportTotals to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReportTotals;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportTotals&&(identical(other.income, _this.income) || other.income == _this.income)&&(identical(other.expense, _this.expense) || other.expense == _this.expense)&&(identical(other.net, _this.net) || other.net == _this.net)&&(identical(other.transactionCount, _this.transactionCount) || other.transactionCount == _this.transactionCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReportTotals;
  return Object.hash(runtimeType,_this.income,_this.expense,_this.net,_this.transactionCount);
}

@override
String toString() {
  final _this = this as ReportTotals;
  return 'ReportTotals(income: ${_this.income}, expense: ${_this.expense}, net: ${_this.net}, transactionCount: ${_this.transactionCount})';
}


}

/// @nodoc
abstract mixin class $ReportTotalsCopyWith<$Res>  {
  factory $ReportTotalsCopyWith(ReportTotals value, $Res Function(ReportTotals) _then) = _$ReportTotalsCopyWithImpl;
@useResult
$Res call({
 int income, int expense, int net, int transactionCount
});




}
/// @nodoc
class _$ReportTotalsCopyWithImpl<$Res>
    implements $ReportTotalsCopyWith<$Res> {
  _$ReportTotalsCopyWithImpl(this._self, this._then);

  final ReportTotals _self;
  final $Res Function(ReportTotals) _then;

/// Create a copy of ReportTotals
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? income = null,Object? expense = null,Object? net = null,Object? transactionCount = null,}) {
  return _then(ReportTotals(
income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as int,expense: null == expense ? _self.expense : expense // ignore: cast_nullable_to_non_nullable
as int,net: null == net ? _self.net : net // ignore: cast_nullable_to_non_nullable
as int,transactionCount: null == transactionCount ? _self.transactionCount : transactionCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ReportTotals].
extension ReportTotalsPatterns on ReportTotals {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportTotals value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportTotals() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportTotals value)  $default,){
final _that = this;
switch (_that) {
case _ReportTotals():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportTotals value)?  $default,){
final _that = this;
switch (_that) {
case _ReportTotals() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int income,  int expense,  int net,  int transactionCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportTotals() when $default != null:
return $default(_that.income,_that.expense,_that.net,_that.transactionCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int income,  int expense,  int net,  int transactionCount)  $default,) {final _that = this;
switch (_that) {
case _ReportTotals():
return $default(_that.income,_that.expense,_that.net,_that.transactionCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int income,  int expense,  int net,  int transactionCount)?  $default,) {final _that = this;
switch (_that) {
case _ReportTotals() when $default != null:
return $default(_that.income,_that.expense,_that.net,_that.transactionCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReportTotals implements ReportTotals {
  const _ReportTotals({required this.income, required this.expense, required this.net, required this.transactionCount});
  factory _ReportTotals.fromJson(Map<String, dynamic> json) => _$ReportTotalsFromJson(json);

@override final  int income;
@override final  int expense;
@override final  int net;
@override final  int transactionCount;

/// Create a copy of ReportTotals
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportTotalsCopyWith<_ReportTotals> get copyWith => __$ReportTotalsCopyWithImpl<_ReportTotals>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportTotalsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportTotals&&(identical(other.income, income) || other.income == income)&&(identical(other.expense, expense) || other.expense == expense)&&(identical(other.net, net) || other.net == net)&&(identical(other.transactionCount, transactionCount) || other.transactionCount == transactionCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,income,expense,net,transactionCount);
}

@override
String toString() {
    return 'ReportTotals(income: $income, expense: $expense, net: $net, transactionCount: $transactionCount)';
}


}

/// @nodoc
abstract mixin class _$ReportTotalsCopyWith<$Res> implements $ReportTotalsCopyWith<$Res> {
  factory _$ReportTotalsCopyWith(_ReportTotals value, $Res Function(_ReportTotals) _then) = __$ReportTotalsCopyWithImpl;
@override @useResult
$Res call({
 int income, int expense, int net, int transactionCount
});




}
/// @nodoc
class __$ReportTotalsCopyWithImpl<$Res>
    implements _$ReportTotalsCopyWith<$Res> {
  __$ReportTotalsCopyWithImpl(this._self, this._then);

  final _ReportTotals _self;
  final $Res Function(_ReportTotals) _then;

/// Create a copy of ReportTotals
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? income = null,Object? expense = null,Object? net = null,Object? transactionCount = null,}) {
  return _then(_ReportTotals(
income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as int,expense: null == expense ? _self.expense : expense // ignore: cast_nullable_to_non_nullable
as int,net: null == net ? _self.net : net // ignore: cast_nullable_to_non_nullable
as int,transactionCount: null == transactionCount ? _self.transactionCount : transactionCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$CategoryShare {

 CategoryRef get category; int get amount; double get share;
/// Create a copy of CategoryShare
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryShareCopyWith<CategoryShare> get copyWith => _$CategoryShareCopyWithImpl<CategoryShare>(this as CategoryShare, _$identity);

  /// Serializes this CategoryShare to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CategoryShare;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryShare&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.share, _this.share) || other.share == _this.share));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CategoryShare;
  return Object.hash(runtimeType,_this.category,_this.amount,_this.share);
}

@override
String toString() {
  final _this = this as CategoryShare;
  return 'CategoryShare(category: ${_this.category}, amount: ${_this.amount}, share: ${_this.share})';
}


}

/// @nodoc
abstract mixin class $CategoryShareCopyWith<$Res>  {
  factory $CategoryShareCopyWith(CategoryShare value, $Res Function(CategoryShare) _then) = _$CategoryShareCopyWithImpl;
@useResult
$Res call({
 CategoryRef category, int amount, double share
});


$CategoryRefCopyWith<$Res> get category;

}
/// @nodoc
class _$CategoryShareCopyWithImpl<$Res>
    implements $CategoryShareCopyWith<$Res> {
  _$CategoryShareCopyWithImpl(this._self, this._then);

  final CategoryShare _self;
  final $Res Function(CategoryShare) _then;

/// Create a copy of CategoryShare
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? category = null,Object? amount = null,Object? share = null,}) {
  return _then(CategoryShare(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as CategoryRef,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,share: null == share ? _self.share : share // ignore: cast_nullable_to_non_nullable
as double,
  ));
}
/// Create a copy of CategoryShare
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategoryRefCopyWith<$Res> get category {
  
  return $CategoryRefCopyWith<$Res>(_self.category, (value) {
    return _then(_self.copyWith(category: value));
  });
}
}


/// Adds pattern-matching-related methods to [CategoryShare].
extension CategorySharePatterns on CategoryShare {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategoryShare value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategoryShare() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategoryShare value)  $default,){
final _that = this;
switch (_that) {
case _CategoryShare():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategoryShare value)?  $default,){
final _that = this;
switch (_that) {
case _CategoryShare() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CategoryRef category,  int amount,  double share)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategoryShare() when $default != null:
return $default(_that.category,_that.amount,_that.share);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CategoryRef category,  int amount,  double share)  $default,) {final _that = this;
switch (_that) {
case _CategoryShare():
return $default(_that.category,_that.amount,_that.share);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CategoryRef category,  int amount,  double share)?  $default,) {final _that = this;
switch (_that) {
case _CategoryShare() when $default != null:
return $default(_that.category,_that.amount,_that.share);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CategoryShare implements CategoryShare {
  const _CategoryShare({required this.category, required this.amount, required this.share});
  factory _CategoryShare.fromJson(Map<String, dynamic> json) => _$CategoryShareFromJson(json);

@override final  CategoryRef category;
@override final  int amount;
@override final  double share;

/// Create a copy of CategoryShare
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryShareCopyWith<_CategoryShare> get copyWith => __$CategoryShareCopyWithImpl<_CategoryShare>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CategoryShareToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategoryShare&&(identical(other.category, category) || other.category == category)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.share, share) || other.share == share));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,category,amount,share);
}

@override
String toString() {
    return 'CategoryShare(category: $category, amount: $amount, share: $share)';
}


}

/// @nodoc
abstract mixin class _$CategoryShareCopyWith<$Res> implements $CategoryShareCopyWith<$Res> {
  factory _$CategoryShareCopyWith(_CategoryShare value, $Res Function(_CategoryShare) _then) = __$CategoryShareCopyWithImpl;
@override @useResult
$Res call({
 CategoryRef category, int amount, double share
});


@override $CategoryRefCopyWith<$Res> get category;

}
/// @nodoc
class __$CategoryShareCopyWithImpl<$Res>
    implements _$CategoryShareCopyWith<$Res> {
  __$CategoryShareCopyWithImpl(this._self, this._then);

  final _CategoryShare _self;
  final $Res Function(_CategoryShare) _then;

/// Create a copy of CategoryShare
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? category = null,Object? amount = null,Object? share = null,}) {
  return _then(_CategoryShare(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as CategoryRef,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,share: null == share ? _self.share : share // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

/// Create a copy of CategoryShare
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategoryRefCopyWith<$Res> get category {
  
  return $CategoryRefCopyWith<$Res>(_self.category, (value) {
    return _then(_self.copyWith(category: value));
  });
}
}


/// @nodoc
mixin _$ReportComparison {

 int get previousExpense; double? get changePct;
/// Create a copy of ReportComparison
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportComparisonCopyWith<ReportComparison> get copyWith => _$ReportComparisonCopyWithImpl<ReportComparison>(this as ReportComparison, _$identity);

  /// Serializes this ReportComparison to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReportComparison;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportComparison&&(identical(other.previousExpense, _this.previousExpense) || other.previousExpense == _this.previousExpense)&&(identical(other.changePct, _this.changePct) || other.changePct == _this.changePct));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReportComparison;
  return Object.hash(runtimeType,_this.previousExpense,_this.changePct);
}

@override
String toString() {
  final _this = this as ReportComparison;
  return 'ReportComparison(previousExpense: ${_this.previousExpense}, changePct: ${_this.changePct})';
}


}

/// @nodoc
abstract mixin class $ReportComparisonCopyWith<$Res>  {
  factory $ReportComparisonCopyWith(ReportComparison value, $Res Function(ReportComparison) _then) = _$ReportComparisonCopyWithImpl;
@useResult
$Res call({
 int previousExpense, double? changePct
});




}
/// @nodoc
class _$ReportComparisonCopyWithImpl<$Res>
    implements $ReportComparisonCopyWith<$Res> {
  _$ReportComparisonCopyWithImpl(this._self, this._then);

  final ReportComparison _self;
  final $Res Function(ReportComparison) _then;

/// Create a copy of ReportComparison
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? previousExpense = null,Object? changePct = freezed,}) {
  return _then(ReportComparison(
previousExpense: null == previousExpense ? _self.previousExpense : previousExpense // ignore: cast_nullable_to_non_nullable
as int,changePct: freezed == changePct ? _self.changePct : changePct // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [ReportComparison].
extension ReportComparisonPatterns on ReportComparison {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportComparison value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportComparison() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportComparison value)  $default,){
final _that = this;
switch (_that) {
case _ReportComparison():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportComparison value)?  $default,){
final _that = this;
switch (_that) {
case _ReportComparison() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int previousExpense,  double? changePct)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportComparison() when $default != null:
return $default(_that.previousExpense,_that.changePct);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int previousExpense,  double? changePct)  $default,) {final _that = this;
switch (_that) {
case _ReportComparison():
return $default(_that.previousExpense,_that.changePct);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int previousExpense,  double? changePct)?  $default,) {final _that = this;
switch (_that) {
case _ReportComparison() when $default != null:
return $default(_that.previousExpense,_that.changePct);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReportComparison implements ReportComparison {
  const _ReportComparison({required this.previousExpense, this.changePct});
  factory _ReportComparison.fromJson(Map<String, dynamic> json) => _$ReportComparisonFromJson(json);

@override final  int previousExpense;
@override final  double? changePct;

/// Create a copy of ReportComparison
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportComparisonCopyWith<_ReportComparison> get copyWith => __$ReportComparisonCopyWithImpl<_ReportComparison>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportComparisonToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportComparison&&(identical(other.previousExpense, previousExpense) || other.previousExpense == previousExpense)&&(identical(other.changePct, changePct) || other.changePct == changePct));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,previousExpense,changePct);
}

@override
String toString() {
    return 'ReportComparison(previousExpense: $previousExpense, changePct: $changePct)';
}


}

/// @nodoc
abstract mixin class _$ReportComparisonCopyWith<$Res> implements $ReportComparisonCopyWith<$Res> {
  factory _$ReportComparisonCopyWith(_ReportComparison value, $Res Function(_ReportComparison) _then) = __$ReportComparisonCopyWithImpl;
@override @useResult
$Res call({
 int previousExpense, double? changePct
});




}
/// @nodoc
class __$ReportComparisonCopyWithImpl<$Res>
    implements _$ReportComparisonCopyWith<$Res> {
  __$ReportComparisonCopyWithImpl(this._self, this._then);

  final _ReportComparison _self;
  final $Res Function(_ReportComparison) _then;

/// Create a copy of ReportComparison
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? previousExpense = null,Object? changePct = freezed,}) {
  return _then(_ReportComparison(
previousExpense: null == previousExpense ? _self.previousExpense : previousExpense // ignore: cast_nullable_to_non_nullable
as int,changePct: freezed == changePct ? _self.changePct : changePct // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$Report {

 ReportPeriod get period; ReportTotals get totals; List<SeriesPoint> get series; List<CategoryShare> get byCategory; ReportComparison? get comparison;
/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportCopyWith<Report> get copyWith => _$ReportCopyWithImpl<Report>(this as Report, _$identity);

  /// Serializes this Report to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Report;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Report&&(identical(other.period, _this.period) || other.period == _this.period)&&(identical(other.totals, _this.totals) || other.totals == _this.totals)&&const DeepCollectionEquality().equals(other.series, _this.series)&&const DeepCollectionEquality().equals(other.byCategory, _this.byCategory)&&(identical(other.comparison, _this.comparison) || other.comparison == _this.comparison));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Report;
  return Object.hash(runtimeType,_this.period,_this.totals,const DeepCollectionEquality().hash(_this.series),const DeepCollectionEquality().hash(_this.byCategory),_this.comparison);
}

@override
String toString() {
  final _this = this as Report;
  return 'Report(period: ${_this.period}, totals: ${_this.totals}, series: ${_this.series}, byCategory: ${_this.byCategory}, comparison: ${_this.comparison})';
}


}

/// @nodoc
abstract mixin class $ReportCopyWith<$Res>  {
  factory $ReportCopyWith(Report value, $Res Function(Report) _then) = _$ReportCopyWithImpl;
@useResult
$Res call({
 ReportPeriod period, ReportTotals totals, List<SeriesPoint> series, List<CategoryShare> byCategory, ReportComparison? comparison
});


$ReportPeriodCopyWith<$Res> get period;$ReportTotalsCopyWith<$Res> get totals;$ReportComparisonCopyWith<$Res>? get comparison;

}
/// @nodoc
class _$ReportCopyWithImpl<$Res>
    implements $ReportCopyWith<$Res> {
  _$ReportCopyWithImpl(this._self, this._then);

  final Report _self;
  final $Res Function(Report) _then;

/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? period = null,Object? totals = null,Object? series = null,Object? byCategory = null,Object? comparison = freezed,}) {
  return _then(Report(
period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as ReportPeriod,totals: null == totals ? _self.totals : totals // ignore: cast_nullable_to_non_nullable
as ReportTotals,series: null == series ? _self.series : series // ignore: cast_nullable_to_non_nullable
as List<SeriesPoint>,byCategory: null == byCategory ? _self.byCategory : byCategory // ignore: cast_nullable_to_non_nullable
as List<CategoryShare>,comparison: freezed == comparison ? _self.comparison : comparison // ignore: cast_nullable_to_non_nullable
as ReportComparison?,
  ));
}
/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReportPeriodCopyWith<$Res> get period {
  
  return $ReportPeriodCopyWith<$Res>(_self.period, (value) {
    return _then(_self.copyWith(period: value));
  });
}/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReportTotalsCopyWith<$Res> get totals {
  
  return $ReportTotalsCopyWith<$Res>(_self.totals, (value) {
    return _then(_self.copyWith(totals: value));
  });
}/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReportComparisonCopyWith<$Res>? get comparison {
    if (_self.comparison == null) {
    return null;
  }

  return $ReportComparisonCopyWith<$Res>(_self.comparison!, (value) {
    return _then(_self.copyWith(comparison: value));
  });
}
}


/// Adds pattern-matching-related methods to [Report].
extension ReportPatterns on Report {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Report value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Report() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Report value)  $default,){
final _that = this;
switch (_that) {
case _Report():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Report value)?  $default,){
final _that = this;
switch (_that) {
case _Report() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ReportPeriod period,  ReportTotals totals,  List<SeriesPoint> series,  List<CategoryShare> byCategory,  ReportComparison? comparison)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Report() when $default != null:
return $default(_that.period,_that.totals,_that.series,_that.byCategory,_that.comparison);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ReportPeriod period,  ReportTotals totals,  List<SeriesPoint> series,  List<CategoryShare> byCategory,  ReportComparison? comparison)  $default,) {final _that = this;
switch (_that) {
case _Report():
return $default(_that.period,_that.totals,_that.series,_that.byCategory,_that.comparison);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ReportPeriod period,  ReportTotals totals,  List<SeriesPoint> series,  List<CategoryShare> byCategory,  ReportComparison? comparison)?  $default,) {final _that = this;
switch (_that) {
case _Report() when $default != null:
return $default(_that.period,_that.totals,_that.series,_that.byCategory,_that.comparison);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Report implements Report {
  const _Report({required this.period, required this.totals, required  List<SeriesPoint> series, required  List<CategoryShare> byCategory, this.comparison}): _series = series,_byCategory = byCategory;
  factory _Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);

@override final  ReportPeriod period;
@override final  ReportTotals totals;
 final  List<SeriesPoint> _series;
@override List<SeriesPoint> get series {
  if (_series is EqualUnmodifiableListView) return _series;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_series);
}

 final  List<CategoryShare> _byCategory;
@override List<CategoryShare> get byCategory {
  if (_byCategory is EqualUnmodifiableListView) return _byCategory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_byCategory);
}

@override final  ReportComparison? comparison;

/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportCopyWith<_Report> get copyWith => __$ReportCopyWithImpl<_Report>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Report&&(identical(other.period, period) || other.period == period)&&(identical(other.totals, totals) || other.totals == totals)&&const DeepCollectionEquality().equals(other.series, _series)&&const DeepCollectionEquality().equals(other.byCategory, _byCategory)&&(identical(other.comparison, comparison) || other.comparison == comparison));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,period,totals,const DeepCollectionEquality().hash(_series),const DeepCollectionEquality().hash(_byCategory),comparison);
}

@override
String toString() {
    return 'Report(period: $period, totals: $totals, series: $series, byCategory: $byCategory, comparison: $comparison)';
}


}

/// @nodoc
abstract mixin class _$ReportCopyWith<$Res> implements $ReportCopyWith<$Res> {
  factory _$ReportCopyWith(_Report value, $Res Function(_Report) _then) = __$ReportCopyWithImpl;
@override @useResult
$Res call({
 ReportPeriod period, ReportTotals totals, List<SeriesPoint> series, List<CategoryShare> byCategory, ReportComparison? comparison
});


@override $ReportPeriodCopyWith<$Res> get period;@override $ReportTotalsCopyWith<$Res> get totals;@override $ReportComparisonCopyWith<$Res>? get comparison;

}
/// @nodoc
class __$ReportCopyWithImpl<$Res>
    implements _$ReportCopyWith<$Res> {
  __$ReportCopyWithImpl(this._self, this._then);

  final _Report _self;
  final $Res Function(_Report) _then;

/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? period = null,Object? totals = null,Object? series = null,Object? byCategory = null,Object? comparison = freezed,}) {
  return _then(_Report(
period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as ReportPeriod,totals: null == totals ? _self.totals : totals // ignore: cast_nullable_to_non_nullable
as ReportTotals,series: null == series ? _self._series : series // ignore: cast_nullable_to_non_nullable
as List<SeriesPoint>,byCategory: null == byCategory ? _self._byCategory : byCategory // ignore: cast_nullable_to_non_nullable
as List<CategoryShare>,comparison: freezed == comparison ? _self.comparison : comparison // ignore: cast_nullable_to_non_nullable
as ReportComparison?,
  ));
}

/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReportPeriodCopyWith<$Res> get period {
  
  return $ReportPeriodCopyWith<$Res>(_self.period, (value) {
    return _then(_self.copyWith(period: value));
  });
}/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReportTotalsCopyWith<$Res> get totals {
  
  return $ReportTotalsCopyWith<$Res>(_self.totals, (value) {
    return _then(_self.copyWith(totals: value));
  });
}/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReportComparisonCopyWith<$Res>? get comparison {
    if (_self.comparison == null) {
    return null;
  }

  return $ReportComparisonCopyWith<$Res>(_self.comparison!, (value) {
    return _then(_self.copyWith(comparison: value));
  });
}
}

// dart format on
