// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(activityApi)
final activityApiProvider = ActivityApiProvider._();

final class ActivityApiProvider
    extends $FunctionalProvider<ActivityApi, ActivityApi, ActivityApi>
    with $Provider<ActivityApi> {
  ActivityApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activityApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activityApiHash();

  @$internal
  @override
  $ProviderElement<ActivityApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ActivityApi create(Ref ref) {
    return activityApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ActivityApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ActivityApi>(value),
    );
  }
}

String _$activityApiHash() => r'784d7e7e3094a50fa5b55b54687a41ba4e1de625';

/// Kegiatan satu bulan penuh; [month] = `YYYY-MM`.

@ProviderFor(monthActivities)
final monthActivitiesProvider = MonthActivitiesFamily._();

/// Kegiatan satu bulan penuh; [month] = `YYYY-MM`.

final class MonthActivitiesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Activity>>,
          List<Activity>,
          FutureOr<List<Activity>>
        >
    with $FutureModifier<List<Activity>>, $FutureProvider<List<Activity>> {
  /// Kegiatan satu bulan penuh; [month] = `YYYY-MM`.
  MonthActivitiesProvider._({
    required MonthActivitiesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'monthActivitiesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$monthActivitiesHash();

  @override
  String toString() {
    return r'monthActivitiesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Activity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Activity>> create(Ref ref) {
    final argument = this.argument as String;
    return monthActivities(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MonthActivitiesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$monthActivitiesHash() => r'7958cab1f6bbfa4228fef70db3f1b0ad38258916';

/// Kegiatan satu bulan penuh; [month] = `YYYY-MM`.

final class MonthActivitiesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Activity>>, String> {
  MonthActivitiesFamily._()
    : super(
        retry: null,
        name: r'monthActivitiesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Kegiatan satu bulan penuh; [month] = `YYYY-MM`.

  MonthActivitiesProvider call(String month) =>
      MonthActivitiesProvider._(argument: month, from: this);

  @override
  String toString() => r'monthActivitiesProvider';
}
