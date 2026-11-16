// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'savings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(savingsHistory)
final savingsHistoryProvider = SavingsHistoryFamily._();

final class SavingsHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SavingsEntry>>,
          List<SavingsEntry>,
          FutureOr<List<SavingsEntry>>
        >
    with
        $FutureModifier<List<SavingsEntry>>,
        $FutureProvider<List<SavingsEntry>> {
  SavingsHistoryProvider._({
    required SavingsHistoryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'savingsHistoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$savingsHistoryHash();

  @override
  String toString() {
    return r'savingsHistoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<SavingsEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SavingsEntry>> create(Ref ref) {
    final argument = this.argument as String;
    return savingsHistory(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SavingsHistoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$savingsHistoryHash() => r'275f795854812a5ad028b632cb4d6aacbb95e079';

final class SavingsHistoryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<SavingsEntry>>, String> {
  SavingsHistoryFamily._()
    : super(
        retry: null,
        name: r'savingsHistoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SavingsHistoryProvider call(String savingsId) =>
      SavingsHistoryProvider._(argument: savingsId, from: this);

  @override
  String toString() => r'savingsHistoryProvider';
}
