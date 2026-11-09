import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_error.dart';
import '../../../core/format/dates.dart';
import '../../../core/format/money.dart';
import '../../../core/router/router.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/money_widgets.dart';
import '../../activity/data/activity_models.dart';
import '../../activity/presentation/activity_form_screen.dart';
import '../../activity/providers/activity_providers.dart';
import '../../attachment/data/attachment_models.dart';
import '../../attachment/presentation/widgets/attachment_image.dart';
import '../../category/data/category_models.dart';
import '../../dashboard/providers/dashboard_providers.dart';
import '../../wallet/data/wallet_models.dart';
import '../../wallet/providers/wallet_providers.dart';
import '../data/transaction_models.dart';
import '../providers/transaction_providers.dart';
import 'transaction_form_screen.dart';

Map<String, String> _whenRows(DateTime occurredAt) {
  final when = occurredAt.toLocal();
  return {'Tanggal': formatLongDate(when), 'Jam': formatTime(when)};
}

class _AmountHeader extends StatelessWidget {
  const _AmountHeader(this.amount, {required this.signed});

  final int amount;
  final bool signed;

  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.scaleDown,
    alignment: Alignment.centerLeft,
    child: AmountText(amount, signed: signed, large: true),
  );
}

class TransactionDetailScreen extends ConsumerWidget {
  const TransactionDetailScreen({super.key, required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isIncome = transaction.type == TxType.income;
    return _DetailView(
      title: 'Detail transaksi',
      header: _AmountHeader(
        isIncome ? transaction.amount : -transaction.amount,
        signed: true,
      ),
      rows: {
        'Tipe': isIncome ? 'Masuk' : 'Keluar',
        'Kategori': transaction.category.name,
        'Dompet': transaction.wallet.name,
        ..._whenRows(transaction.occurredAt),
        'Catatan': ?transaction.note,
      },
      attachments: transaction.attachments,
      editRoute: Routes.transactionForm,
      editArgs: TransactionFormArgs(transaction: transaction),
      deleteMessage: 'Hapus transaksi ini? Foto struknya juga ikut terhapus.',
      deletedMessage: 'Transaksi terhapus',
      onDelete: () => ref.read(transactionApiProvider).delete(transaction.id),
    );
  }
}

class TransferDetailScreen extends ConsumerWidget {
  const TransferDetailScreen({super.key, required this.transfer});

  final Transfer transfer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _DetailView(
      title: 'Detail transfer',
      header: _AmountHeader(transfer.amount, signed: false),
      rows: {
        'Dari dompet': transfer.fromWallet.name,
        'Ke dompet': transfer.toWallet.name,
        if (transfer.fee > 0)
          'Biaya admin':
              '${formatRupiah(transfer.fee)}, dipotong dari '
              '${transfer.feePaidBy == FeePaidBy.from ? transfer.fromWallet.name : transfer.toWallet.name}',
        ..._whenRows(transfer.occurredAt),
        'Catatan': ?transfer.note,
      },
      editRoute: Routes.transactionForm,
      editArgs: TransactionFormArgs(transfer: transfer),
      deleteMessage: 'Hapus transfer ini?',
      deletedMessage: 'Transfer terhapus',
      onDelete: () => ref.read(walletApiProvider).deleteTransfer(transfer.id),
    );
  }
}

class ActivityDetailScreen extends ConsumerWidget {
  const ActivityDetailScreen({super.key, required this.activity});

  final Activity activity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return _DetailView(
      title: 'Detail kegiatan',
      header: Row(
        children: [
          Expanded(
            child: Text(activity.title, style: theme.textTheme.titleLarge),
          ),
          if (activity.isImportant)
            Icon(
              Icons.star_rounded,
              color: AppColors.of(context).important,
              semanticLabel: 'Penting',
            ),
        ],
      ),
      rows: {
        'Tanggal': formatLongDate(DateTime.parse(activity.date)),
        'Jam': formatActivityTime(activity.time),
        'Lokasi': ?activity.location,
        'Deskripsi': ?activity.description,
      },
      attachments: activity.attachments,
      editRoute: Routes.activityForm,
      editArgs: ActivityFormArgs(activity: activity),
      deleteMessage: 'Hapus kegiatan ini? Fotonya juga ikut terhapus.',
      deletedMessage: 'Kegiatan terhapus',
      onDelete: () => ref.read(activityApiProvider).delete(activity.id),
    );
  }
}

class _DetailView extends ConsumerWidget {
  const _DetailView({
    required this.title,
    required this.header,
    required this.rows,
    this.attachments = const [],
    required this.editRoute,
    required this.editArgs,
    required this.deleteMessage,
    required this.deletedMessage,
    required this.onDelete,
  });

  final String title;
  final Widget header;
  final Map<String, String> rows;
  final List<Attachment> attachments;
  final String editRoute;
  final Object editArgs;
  final String deleteMessage;
  final String deletedMessage;
  final Future<void> Function() onDelete;

  Future<void> _edit(BuildContext context) async {
    final saved = await context.pushNamed<bool>(editRoute, extra: editArgs);
    // Data di layar ini sudah usang, jadi kembali ke layar asal (S-08).
    if (saved == true && context.mounted) context.pop();
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await confirmDialog(
      context,
      message: deleteMessage,
      confirmLabel: 'Hapus',
    );
    if (!confirmed || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await onDelete();
      refreshMoney(ref);
      messenger.showSnackBar(SnackBar(content: Text(deletedMessage)));
      if (context.mounted) context.pop();
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          header,
          const SizedBox(height: Spacing.xl),
          for (final row in rows.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row.key,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.of(context).textSecondary,
                    ),
                  ),
                  Text(row.value, style: theme.textTheme.bodyLarge),
                ],
              ),
            ),
          if (attachments.isNotEmpty) ...[
            const SizedBox(height: Spacing.sm),
            PhotoGallery(attachments),
            const SizedBox(height: Spacing.md),
          ],
          const SizedBox(height: Spacing.md),
          FilledButton(
            onPressed: () => _edit(context),
            child: const Text('Ubah'),
          ),
          const SizedBox(height: Spacing.sm),
          TextButton(
            onPressed: () => _delete(context, ref),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
