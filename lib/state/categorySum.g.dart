// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'categorySum.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$categorySumHash() => r'80c2cf41cc8ae73d1e855a7b11bd2bd8af1ab07d';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [categorySum].
@ProviderFor(categorySum)
const categorySumProvider = CategorySumFamily();

/// See also [categorySum].
class CategorySumFamily extends Family<double> {
  /// See also [categorySum].
  const CategorySumFamily();

  /// See also [categorySum].
  CategorySumProvider call(
    String category,
  ) {
    return CategorySumProvider(
      category,
    );
  }

  @override
  CategorySumProvider getProviderOverride(
    covariant CategorySumProvider provider,
  ) {
    return call(
      provider.category,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'categorySumProvider';
}

/// See also [categorySum].
class CategorySumProvider extends AutoDisposeProvider<double> {
  /// See also [categorySum].
  CategorySumProvider(
    String category,
  ) : this._internal(
          (ref) => categorySum(
            ref as CategorySumRef,
            category,
          ),
          from: categorySumProvider,
          name: r'categorySumProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$categorySumHash,
          dependencies: CategorySumFamily._dependencies,
          allTransitiveDependencies:
              CategorySumFamily._allTransitiveDependencies,
          category: category,
        );

  CategorySumProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.category,
  }) : super.internal();

  final String category;

  @override
  Override overrideWith(
    double Function(CategorySumRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CategorySumProvider._internal(
        (ref) => create(ref as CategorySumRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        category: category,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<double> createElement() {
    return _CategorySumProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CategorySumProvider && other.category == category;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, category.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CategorySumRef on AutoDisposeProviderRef<double> {
  /// The parameter `category` of this provider.
  String get category;
}

class _CategorySumProviderElement extends AutoDisposeProviderElement<double>
    with CategorySumRef {
  _CategorySumProviderElement(super.provider);

  @override
  String get category => (origin as CategorySumProvider).category;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
