import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../data/wallet_api.dart';
import '../data/wallet_models.dart';

part 'wallet_providers.g.dart';

@riverpod
WalletApi walletApi(Ref ref) => WalletApi(ref.watch(apiClientProvider));

@riverpod
Future<List<Wallet>> wallets(Ref ref, {bool includeArchived = false}) =>
    ref.watch(walletApiProvider).list(includeArchived: includeArchived);

@riverpod
Future<List<Transfer>> transfers(Ref ref) =>
    ref.watch(walletApiProvider).transfers();
