import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/dates.dart';
import '../../../core/format/money.dart';
import '../../../core/router/router.dart';
import '../../../core/theme/app_themes.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/frame.dart';
import '../../../core/widgets/money_widgets.dart';
import '../../../core/widgets/state_views.dart';
import '../data/receivable_models.dart';
import '../providers/receivable_providers.dart';

/// Daftar piutang talangan (FIN-19) dan utang (FIN-20).
class ReceivablesScreen extends ConsumerStatefulWidget {
  const ReceivablesScreen({
    super.key,
    this.initial = ReceivableDirection.receivable,
  });

  final ReceivableDirection initial;

  @override
  ConsumerState<ReceivablesScreen> createState() => _ReceivablesScreenState();
}

class _ReceivablesScreenState extends ConsumerState<ReceivablesScreen> {
  bool _all = false;
  late ReceivableDirection _direction = widget.initial;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final payable = _direction.isPayable;
    final provider = receivablesProvider(all: _all, direction: _direction);
    return Scaffold(
      appBar: AppBar(title: const Text('Utang & Piutang')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            context.pushNamed(Routes.receivableForm, extra: _direction),
        icon: const Icon(Icons.add_rounded),
        label: Text(payable ? 'Catat utang' : 'Catat piutang'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.lg,
              Spacing.sm,
              Spacing.lg,
              0,
            ),
            child: SegmentedButton<ReceivableDirection>(
              showSelectedIcon: false,
              expandedInsets: EdgeInsets.zero,
              segments: const [
                ButtonSegment(
                  value: ReceivableDirection.receivable,
                  label: Text('Piutang'),
                ),
                ButtonSegment(
                  value: ReceivableDirection.payable,
                  label: Text('Utang'),
                ),
              ],
              selected: {_direction},
              onSelectionChanged: (selected) =>
                  setState(() => _direction = selected.first),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.lg,
              Spacing.sm,
              Spacing.lg,
              Spacing.md,
            ),
            child: SegmentedButton<bool>(
              showSelectedIcon: false,
              expandedInsets: EdgeInsets.zero,
              segments: const [
                ButtonSegment(value: false, label: Text('Belum lunas')),
                ButtonSegment(value: true, label: Text('Semua')),
              ],
              selected: {_all},
              onSelectionChanged: (selected) =>
                  setState(() => _all = selected.first),
            ),
          ),
          Expanded(
            child: ref
                .watch(provider)
                .when(
                  loading: () => const ListSkeleton(),
                  error: (error, _) => ErrorState(
                    error: error,
                    onRetry: () => ref.invalidate(provider),
                  ),
                  data: (data) => ListView(
                    padding: const EdgeInsets.fromLTRB(
                      Spacing.lg,
                      0,
                      Spacing.lg,
                      Spacing.xxl * 2,
                    ),
                    children: [
                      FrameCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              payable ? 'Total utang' : 'Total belum dibayar',
                              style: theme.textTheme.bodyMedium,
                            ),
                            AmountText(
                              payable
                                  ? data.totalRemaining
                                  : -data.totalRemaining,
                              large: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Spacing.md),
                      if (data.items.isEmpty)
                        EmptyState(
                          message: payable
                              ? 'Belum ada utang. Catat kalau ada yang '
                                    'nalangin atau minjemin kamu.'
                              : 'Belum ada piutang. Catat waktu kamu '
                                    'nalangin teman.',
                        )
                      else
                        for (final item in data.items)
                          Padding(
                            padding: const EdgeInsets.only(bottom: Spacing.sm),
                            child: _ReceivableCard(item),
                          ),
                    ],
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

class _ReceivableCard extends StatelessWidget {
  const _ReceivableCard(this.receivable);

  final Receivable receivable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final caption = theme.textTheme.labelSmall;
    final r = receivable;
    final paid = r.total - r.remaining;
    return FrameCard(
      onTap: () => context.pushNamed(
        Routes.receivableDetail,
        pathParameters: {'id': r.id},
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  r.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              if (r.remaining == 0)
                const PaidStamp()
              else
                Text(formatShortDate(DateTime.parse(r.date)), style: caption),
            ],
          ),
          PaidBar(paid: paid, total: r.total),
          Text(
            r.remaining == 0
                ? '${formatRupiah(paid)} dari ${formatRupiah(r.total)} · '
                      '${formatShortDate(DateTime.parse(r.date))}'
                : '${formatRupiah(paid)} dari ${formatRupiah(r.total)} '
                      'dibayar · Sisa ${formatRupiah(r.remaining)}',
            style: caption,
          ),
          const SizedBox(height: Spacing.xs),
          Wrap(
            spacing: Spacing.xs,
            runSpacing: Spacing.xs,
            children: [
              for (final d in r.debtors)
                d.remaining == 0
                    ? PaidLabel(text: d.name)
                    : FrameBox(
                        child: Text(
                          '${d.name} · ${formatRupiah(d.remaining)}',
                          style: caption,
                        ),
                      ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Garis tipis hijau di atas latar kartu: penanda lunas yang tidak
/// bersaing dengan garis tinta tebal kartu dan bar (DESIGN.md, pengecualian
/// warna masuk untuk status lunas).
BoxDecoration _paidDecoration(BuildContext context) => BoxDecoration(
  color: Theme.of(context).colorScheme.surface,
  borderRadius: BorderRadius.circular(AppStyle.of(context).cardRadius / 2),
  border: Border.all(
    color: AppColors.of(context).income,
    width: AppStyle.of(context).frameWidth * 0.75,
  ),
);

/// Cap miring tanda utang/piutang sudah lunas.
class PaidStamp extends StatelessWidget {
  const PaidStamp({super.key, this.large = false});

  final bool large;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final income = AppColors.of(context).income;
    final style = large
        ? theme.textTheme.titleSmall
        : theme.textTheme.labelSmall;
    // Rotasi tidak memakan tempat di layout: sisakan ruang atas/bawah supaya
    // sudut cap tidak menabrak bar di bawahnya.
    return Padding(
      padding: EdgeInsets.symmetric(vertical: large ? Spacing.lg : Spacing.md),
      child: Transform.rotate(
        angle: -0.1,
        child: DecoratedBox(
          decoration: _paidDecoration(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm,
              vertical: Spacing.xs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_rounded,
                  size: large ? Spacing.lg : Spacing.md,
                  color: income,
                ),
                const SizedBox(width: Spacing.xs),
                Text('LUNAS TERBAYAR', style: style?.copyWith(color: income)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Label tegak berisi centang + teks, sewarna dengan [PaidStamp], untuk orang yang lunas.
class PaidLabel extends StatelessWidget {
  const PaidLabel({super.key, this.text = 'Lunas'});

  final String text;

  @override
  Widget build(BuildContext context) {
    final income = AppColors.of(context).income;
    return DecoratedBox(
      decoration: _paidDecoration(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm,
          vertical: Spacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_rounded, size: Spacing.md, color: income),
            const SizedBox(width: Spacing.xs),
            Text(
              text,
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(color: income),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bar terbayar dengan outline neubrutalism; sisa bar netral.
class PaidBar extends StatelessWidget {
  const PaidBar({super.key, required this.paid, required this.total});

  final int paid;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
      child: FrameBox(
        padding: EdgeInsets.zero,
        child: LinearProgressIndicator(
          value: total == 0 ? 0 : (paid / total).clamp(0.0, 1.0),
          minHeight: Spacing.md,
          color: AppColors.of(context).ink,
          backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(Radii.sm),
        ),
      ),
    );
  }
}
