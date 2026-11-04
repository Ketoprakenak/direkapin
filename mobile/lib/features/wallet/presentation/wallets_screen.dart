import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/router.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/money_widgets.dart';
import '../../../core/widgets/state_views.dart';
import '../data/wallet_models.dart';
import '../providers/wallet_providers.dart';
import 'widgets/wallet_sheet.dart';

class WalletsScreen extends ConsumerWidget {
  const WalletsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallets = ref.watch(walletsProvider(includeArchived: true));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dompet'),
        actions: [
          IconButton(
            tooltip: 'Riwayat transfer',
            icon: const Icon(Icons.swap_horiz_rounded),
            onPressed: () => context.pushNamed(Routes.transfers),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Tambah dompet',
        onPressed: () => showWalletSheet(context),
        child: const Icon(Icons.add_rounded),
      ),
      body: wallets.when(
        loading: () => const ListSkeleton(),
        error: (error, _) => ErrorState(
          error: error,
          onRetry: () => ref.invalidate(walletsProvider),
        ),
        data: (items) => items.isEmpty
            ? const Center(
                child: EmptyState(
                  message: 'Belum ada dompet. Tambah yang pertama, yuk.',
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.only(bottom: Spacing.xxl * 2),
                itemCount: items.length,
                itemBuilder: (context, index) => _WalletTile(items[index]),
              ),
      ),
    );
  }
}

class _WalletTile extends StatelessWidget {
  const _WalletTile(this.wallet);

  final Wallet wallet;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: IconCircle(icon: wallet.icon, color: wallet.color),
      title: Text(wallet.name),
      subtitle: Text(wallet.isArchived ? 'Diarsipkan' : wallet.type.label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AmountText(wallet.balance),
          IconButton(
            tooltip: 'Ubah ${wallet.name}',
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => showWalletSheet(context, wallet: wallet),
          ),
        ],
      ),
      onTap: () => context.pushNamed(
        Routes.walletTransactions,
        pathParameters: {'id': wallet.id},
        queryParameters: {'nama': wallet.name},
      ),
    );
  }
}
