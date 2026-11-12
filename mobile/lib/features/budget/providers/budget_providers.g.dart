// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(budgetApi)
final budgetApiProvider = BudgetApiProvider._();

final class BudgetApiProvider
    extends $FunctionalProvider<BudgetApi, BudgetApi, BudgetApi>
    with $Provider<BudgetApi> {
  BudgetApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetApiHash();

  @$internal
  @override
  $ProviderElement<BudgetApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BudgetApi create(Ref ref) {
    return budgetApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BudgetApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BudgetApi>(value),
    );
  }
}

String _$budgetApiHash() => r'ef18719a879b9d15974368c3f16537dfb1b5ebe4';

/// [month] = `YYYY-MM`.

@ProviderFor(budgets)
final budgetsProvider = BudgetsFamily._();

/// [month] = `YYYY-MM`.

final class BudgetsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Budget>>,
          List<Budget>,
          FutureOr<List<Budget>>
        >
    with $FutureModifier<List<Budget>>, $FutureProvider<List<Budget>> {
  /// [month] = `YYYY-MM`.
  BudgetsProvider._({
    required BudgetsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'budgetsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$budgetsHash();

  @override
  String toString() {
    return r'budgetsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Budget>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Budget>> create(Ref ref) {
    final argument = this.argument as String;
    return budgets(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BudgetsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$budgetsHash() => r'bc1d76f0521bd66e657e5748ef18ad9f07b1cbfe';

/// [month] = `YYYY-MM`.

final class BudgetsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Budget>>, String> {
  BudgetsFamily._()
    : super(
        retry: null,
        name: r'budgetsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// [month] = `YYYY-MM`.

  BudgetsProvider call(String month) =>
      BudgetsProvider._(argument: month, from: this);

  @override
  String toString() => r'budgetsProvider';
}
