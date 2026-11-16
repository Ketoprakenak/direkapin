import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/money.dart';
import '../../../core/router/router.dart';
import '../../../core/theme/app_themes.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/frame.dart';
import '../../../core/widgets/money_widgets.dart';
import '../../../core/widgets/state_views.dart';
import '../../dashboard/data/dashboard_models.dart';
import '../../dashboard/providers/dashboard_providers.dart';
import '../../transaction/presentation/transaction_form_screen.dart';
import '../../wallet/data/wallet_models.dart';
import 'savings_form_sheet.dart';

const masked = 'Rp••••••';

enum _Menu { history, deposit, spend, target, delete }

/// Rincian Saldo total = Bisa digunakan + tiap tabungan (FIN-18).
Future<void> showSavingsSheet(BuildContext context, {required bool hidden}) {
  final scheme = Theme.of(context).colorScheme;
  final style = AppStyle.of(context);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    // Di atas bottom nav, bukan di navigator tab Beranda.
    useRootNavigator: true,
    shape: RoundedRectangleBorder(
      side: BorderSide(color: scheme.onSurface, width: style.frameWidth),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(Radii.xl)),
    ),
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, controller) => _SavingsSheet(controller, hidden),
    ),
  );
}

class _SavingsSheet extends ConsumerWidget {
  const _SavingsSheet(this.controller, this.hidden);

  final ScrollController controller;
  final bool hidden;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(dashboardProvider)
      .when(
        loading: () => const ListSkeleton(),
        error: (error, _) => ErrorState(
          error: error,
          onRetry: () => ref.invalidate(dashboardProvider),
        ),
        data: (data) => _content(context, data),
      );

  Widget _content(BuildContext context, Dashboard data) {
    final theme = Theme.of(context);
    return ListView(
      controller: controller,
      padding: const EdgeInsets.all(Spacing.lg),
      children: [
        Text('Saldo total', style: theme.textTheme.bodyMedium),
        hidden
            ? Text(masked, style: theme.textTheme.displayMedium)
            : AmountText(data.totalBalance, large: true),
        const SizedBox(height: Spacing.md),
        FrameCard(
          child: Row(
            children: [
              const Icon(Icons.account_balance_wallet_rounded),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Text(
                  'Bisa digunakan',
                  style: theme.textTheme.titleMedium,
                ),
              ),
              hidden
                  ? Text(masked, style: theme.textTheme.titleSmall)
                  : AmountText(data.availableBalance),
            ],
          ),
        ),
        const SizedBox(height: Spacing.sm),
        // Berdampingan supaya daftar tabungan tetap terlihat di sheet 55%.
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _DebtTile(
                  icon: Icons.handshake_rounded,
                  label: 'Piutang',
                  amount: -data.receivableRemaining,
                  hidden: hidden,
                  tab: null,
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: _DebtTile(
                  icon: Icons.payments_rounded,
                  label: 'Utang',
                  amount: data.payableRemaining,
                  hidden: hidden,
                  tab: 'utang',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.lg),
        Text('Tabungan', style: theme.textTheme.titleMedium),
        const SizedBox(height: Spacing.sm),
        if (data.savings.isEmpty)
          const EmptyState(message: 'Belum ada tabungan')
        else
          for (final savings in data.savings)
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.sm),
              child: _SavingsTile(savings, hidden: hidden),
            ),
        const SizedBox(height: Spacing.sm),
        FilledButton.icon(
          onPressed: () => showSavingsForm(context, SavingsAction.create),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Buat tabungan'),
        ),
      ],
    );
  }
}

class _SavingsTile extends StatelessWidget {
  const _SavingsTile(this.savings, {required this.hidden});

  final Wallet savings;
  final bool hidden;

  void _onMenu(BuildContext context, _Menu menu) {
    if (menu == _Menu.history || menu == _Menu.spend) {
      final router = GoRouter.of(context);
      Navigator.pop(context);
      if (menu == _Menu.history) {
        router.pushNamed(
          Routes.savingsHistory,
          pathParameters: {'id': savings.id},
        );
      } else {
        router.pushNamed(
          Routes.transactionForm,
          extra: TransactionFormArgs(initialWalletId: savings.id),
        );
      }
      return;
    }
    final action = switch (menu) {
      _Menu.deposit => SavingsAction.deposit,
      _Menu.target => SavingsAction.target,
      _ => SavingsAction.delete,
    };
    showSavingsForm(context, action, savings: savings);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final balance = savings.balance;
    return FrameCard(
      onTap: () => _onMenu(context, _Menu.history),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.savings_rounded),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Text(
                  savings.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              hidden
                  ? Text(masked, style: theme.textTheme.titleSmall)
                  : AmountText(balance),
              PopupMenuButton<_Menu>(
                tooltip: 'Menu ${savings.name}',
                onSelected: (menu) => _onMenu(context, menu),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: _Menu.history, child: Text('Riwayat')),
                  PopupMenuItem(value: _Menu.deposit, child: Text('Setor')),
                  PopupMenuItem(
                    value: _Menu.spend,
                    child: Text('Catat pengeluaran'),
                  ),
                  PopupMenuItem(
                    value: _Menu.target,
                    child: Text('Ubah target'),
                  ),
                  PopupMenuItem(value: _Menu.delete, child: Text('Hapus')),
                ],
              ),
            ],
          ),
          SavingsProgress(savings, hidden: hidden),
        ],
      ),
    );
  }
}

/// Progres target tabungan, atau "Tanpa target".
class SavingsProgress extends StatelessWidget {
  const SavingsProgress(this.savings, {super.key, required this.hidden});

  final Wallet savings;
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final caption = theme.textTheme.labelSmall;
    final target = savings.targetAmount;
    final balance = savings.balance;
    String money(int amount) => hidden ? masked : formatRupiah(amount);
    if (target == null) return Text('Tanpa target', style: caption);
    final ratio = (balance / target).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: Spacing.xs),
        FrameBox(
          padding: EdgeInsets.zero,
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: Spacing.md,
            color: AppColors.of(context).ink,
            // Sisa bar netral (seperti budget) supaya target kosong tetap terlihat.
            backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(Radii.sm),
          ),
        ),
        const SizedBox(height: Spacing.xs),
        Row(
          children: [
            Expanded(
              child: Text(
                balance >= target
                    ? 'Tercapai'
                    : '${(ratio * 100).floor()}% dari ${money(target)}',
                style: caption,
              ),
            ),
            if (balance < target)
              Text('Kurang ${money(target - balance)}', style: caption),
          ],
        ),
      ],
    );
  }
}

/// Ringkasan piutang/utang; tap membuka layar Utang & Piutang di [tab].
class _DebtTile extends StatelessWidget {
  const _DebtTile({
    required this.icon,
    required this.label,
    required this.amount,
    required this.hidden,
    required this.tab,
  });

  final IconData icon;
  final String label;
  final int amount;
  final bool hidden;
  final String? tab;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FrameCard(
      onTap: () {
        final router = GoRouter.of(context);
        Navigator.pop(context);
        router.pushNamed(Routes.receivables, queryParameters: {'tab': ?tab});
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: Spacing.lg),
              const SizedBox(width: Spacing.xs),
              Text(label, style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: Spacing.xs),
          hidden
              ? Text(masked, style: theme.textTheme.titleSmall)
              : AmountText(amount),
        ],
      ),
    );
  }
}
