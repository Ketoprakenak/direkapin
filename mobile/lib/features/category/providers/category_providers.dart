import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../data/category_api.dart';
import '../data/category_models.dart';

part 'category_providers.g.dart';

@riverpod
CategoryApi categoryApi(Ref ref) => CategoryApi(ref.watch(apiClientProvider));

@riverpod
Future<List<Category>> categories(
  Ref ref, {
  required TxType type,
  bool includeHidden = false,
}) => ref
    .watch(categoryApiProvider)
    .list(type: type, includeHidden: includeHidden);
