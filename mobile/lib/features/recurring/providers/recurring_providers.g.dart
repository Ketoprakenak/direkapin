// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(recurringApi)
final recurringApiProvider = RecurringApiProvider._();

final class RecurringApiProvider
    extends $FunctionalProvider<RecurringApi, RecurringApi, RecurringApi>
    with $Provider<RecurringApi> {
  RecurringApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recurringApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recurringApiHash();

  @$internal
  @override
  $ProviderElement<RecurringApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RecurringApi create(Ref ref) {
    return recurringApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecurringApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecurringApi>(value),
    );
  }
}

String _$recurringApiHash() => r'ee3287598429f27b57d4ff8aa1169312271a6cb1';

@ProviderFor(recurringList)
final recurringListProvider = RecurringListProvider._();

final class RecurringListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Recurring>>,
          List<Recurring>,
          FutureOr<List<Recurring>>
        >
    with $FutureModifier<List<Recurring>>, $FutureProvider<List<Recurring>> {
  RecurringListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recurringListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recurringListHash();

  @$internal
  @override
  $FutureProviderElement<List<Recurring>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Recurring>> create(Ref ref) {
    return recurringList(ref);
  }
}

String _$recurringListHash() => r'06eec647ae804f0b01cad439afce63feabe3a222';

@ProviderFor(recurringDue)
final recurringDueProvider = RecurringDueProvider._();

final class RecurringDueProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RecurringDue>>,
          List<RecurringDue>,
          FutureOr<List<RecurringDue>>
        >
    with
        $FutureModifier<List<RecurringDue>>,
        $FutureProvider<List<RecurringDue>> {
  RecurringDueProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recurringDueProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recurringDueHash();

  @$internal
  @override
  $FutureProviderElement<List<RecurringDue>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<RecurringDue>> create(Ref ref) {
    return recurringDue(ref);
  }
}

String _$recurringDueHash() => r'c8ac7d5ec6ae7d9b065d017205230304786c4f8a';
