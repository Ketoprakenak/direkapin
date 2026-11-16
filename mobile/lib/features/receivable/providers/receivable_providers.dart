import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../data/receivable_api.dart';
import '../data/receivable_models.dart';

part 'receivable_providers.g.dart';

@riverpod
ReceivableApi receivableApi(Ref ref) =>
    ReceivableApi(ref.watch(apiClientProvider));

/// [all] = false hanya catatan yang masih ada orang belum lunas.
@riverpod
Future<({List<Receivable> items, int totalRemaining})> receivables(
  Ref ref, {
  bool all = false,
  ReceivableDirection direction = ReceivableDirection.receivable,
}) => ref.watch(receivableApiProvider).list(all: all, direction: direction);
