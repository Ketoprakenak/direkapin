import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/router.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/frame.dart';
import '../../../core/widgets/money_widgets.dart';
import '../../../core/widgets/state_views.dart';
import '../../category/data/category_models.dart';
import '../data/recurring_models.dart';
import '../providers/recurring_providers.dart';

/// Daftar aturan transaksi berulang (FIN-15).
class RecurringListScreen extends ConsumerWidget {
  const RecurringListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaksi berulang')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Tambah aturan',
        onPressed: () => context.pushNamed(Routes.recurringForm),
        child: const Icon(Icons.add_rounded),
      ),
      body: ref
          .watch(recurringListProvider)
          .when(
            loading: () => const ListSkeleton(),
            error: (error, _) => ErrorState(
              error: error,
              onRetry: () => ref.invalidate(recurringListProvider),
            ),
            data: (rules) => rules.isEmpty
                ? const Center(
                    child: EmptyState(
                      message: 'Belum ada aturan. Tambah tagihan atau gaji yang rutin tiap bulan.',
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => ref.refresh(recurringListProvider.future),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        Spacing.lg,
                        Spacing.lg,
                        Spacing.lg,
                        Spacing.xxl * 2,
                      ),
                      itemCount: rules.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: Spacing.md),
                      itemBuilder: (context, index) => _RuleCard(rules[index]),
                    ),
                  ),
          ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  const _RuleCard(this.rule);

  final Recurring rule;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FrameCard(
      onTap: () => context.pushNamed(Routes.recurringForm, extra: rule),
      padding: const EdgeInsets.all(Spacing.lg),
      child: Row(
        children: [
          IconCircle(icon: rule.category.icon, color: rule.category.color),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rule.category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  'Tiap tanggal ${rule.dayOfMonth} · ${rule.wallet.name}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          AmountText(
            rule.type == TxType.income ? rule.amount : -rule.amount,
            signed: true,
          ),
        ],
      ),
    );
  }
}
