// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(calendarMonth)
final calendarMonthProvider = CalendarMonthFamily._();

final class CalendarMonthProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CalendarDay>>,
          List<CalendarDay>,
          FutureOr<List<CalendarDay>>
        >
    with
        $FutureModifier<List<CalendarDay>>,
        $FutureProvider<List<CalendarDay>> {
  CalendarMonthProvider._({
    required CalendarMonthFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'calendarMonthProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$calendarMonthHash();

  @override
  String toString() {
    return r'calendarMonthProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<CalendarDay>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CalendarDay>> create(Ref ref) {
    final argument = this.argument as String;
    return calendarMonth(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CalendarMonthProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$calendarMonthHash() => r'551f48e7a9f9d29a2ea801dae0b1259ea5731c1c';

final class CalendarMonthFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<CalendarDay>>, String> {
  CalendarMonthFamily._()
    : super(
        retry: null,
        name: r'calendarMonthProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CalendarMonthProvider call(String month) =>
      CalendarMonthProvider._(argument: month, from: this);

  @override
  String toString() => r'calendarMonthProvider';
}

@ProviderFor(dayDetail)
final dayDetailProvider = DayDetailFamily._();

final class DayDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<DayDetail>,
          DayDetail,
          FutureOr<DayDetail>
        >
    with $FutureModifier<DayDetail>, $FutureProvider<DayDetail> {
  DayDetailProvider._({
    required DayDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'dayDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$dayDetailHash();

  @override
  String toString() {
    return r'dayDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<DayDetail> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<DayDetail> create(Ref ref) {
    final argument = this.argument as String;
    return dayDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DayDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dayDetailHash() => r'd394a7fc1433f323d3103ad4204695f7a3efbfdb';

final class DayDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<DayDetail>, String> {
  DayDetailFamily._()
    : super(
        retry: null,
        name: r'dayDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DayDetailProvider call(String date) =>
      DayDetailProvider._(argument: date, from: this);

  @override
  String toString() => r'dayDetailProvider';
}
