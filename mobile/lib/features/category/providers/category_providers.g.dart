// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(categoryApi)
final categoryApiProvider = CategoryApiProvider._();

final class CategoryApiProvider
    extends $FunctionalProvider<CategoryApi, CategoryApi, CategoryApi>
    with $Provider<CategoryApi> {
  CategoryApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryApiHash();

  @$internal
  @override
  $ProviderElement<CategoryApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CategoryApi create(Ref ref) {
    return categoryApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CategoryApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CategoryApi>(value),
    );
  }
}

String _$categoryApiHash() => r'04ea1d0ab154cfb1cd7c28af9357287661d99be3';

@ProviderFor(categories)
final categoriesProvider = CategoriesFamily._();

final class CategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Category>>,
          List<Category>,
          FutureOr<List<Category>>
        >
    with $FutureModifier<List<Category>>, $FutureProvider<List<Category>> {
  CategoriesProvider._({
    required CategoriesFamily super.from,
    required ({TxType type, bool includeHidden}) super.argument,
  }) : super(
         retry: null,
         name: r'categoriesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$categoriesHash();

  @override
  String toString() {
    return r'categoriesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<Category>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Category>> create(Ref ref) {
    final argument = this.argument as ({TxType type, bool includeHidden});
    return categories(
      ref,
      type: argument.type,
      includeHidden: argument.includeHidden,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CategoriesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$categoriesHash() => r'3f5e1ce22f7be43106b071ac785f91b54e0191f7';

final class CategoriesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<Category>>,
          ({TxType type, bool includeHidden})
        > {
  CategoriesFamily._()
    : super(
        retry: null,
        name: r'categoriesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CategoriesProvider call({required TxType type, bool includeHidden = false}) =>
      CategoriesProvider._(
        argument: (type: type, includeHidden: includeHidden),
        from: this,
      );

  @override
  String toString() => r'categoriesProvider';
}
