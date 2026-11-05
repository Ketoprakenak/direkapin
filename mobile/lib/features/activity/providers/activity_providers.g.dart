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
