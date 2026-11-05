import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/state_views.dart';
import '../../category/data/category_models.dart';
import '../../transaction/presentation/wallet_transactions_screen.dart';
import '../providers/report_providers.dart';

class CategoryTransactionsArgs {
  const CategoryTransactionsArgs({
    required this.category,
    required this.from,
    required this.to,
    this.walletId,
  });

  final CategoryRef category;
  final String from;
  final String to;
  final String? walletId;
}

/// Transaksi satu kategori di periode laporan (tap kategori di S-10).
class CategoryTransactionsScreen extends ConsumerWidget {
  const CategoryTransactionsScreen({super.key, required this.args});

  final CategoryTransactionsArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = periodTransactionsProvider(
      args.from,
      args.to,
      walletId: args.walletId,
      categoryId: args.category.id,
    );
    return Scaffold(
      appBar: AppBar(title: Text(args.category.name)),
      body: ref
          .watch(provider)
          .when(
            loading: () => const ListSkeleton(),
            error: (error, _) => ErrorState(
              error: error,
              onRetry: () => ref.invalidate(provider),
            ),
            data: (items) {
              // Bisa kosong setelah transaksinya dihapus atau dipindah dari layar ini.
              if (items.isEmpty) {
                return const Center(
                  child: EmptyState(
                    message: 'Belum ada transaksi di periode ini.',
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: Spacing.xl),
                itemCount: items.length,
                itemBuilder: (context, index) => TransactionTile(items[index]),
              );
            },
          ),
    );
  }
}
