import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_error.dart';
import '../../../core/format/dates.dart';
import '../../../core/router/router.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/money_widgets.dart';
import '../../attachment/data/attachment_models.dart';
import '../../attachment/presentation/widgets/attachment_image.dart';
import '../../category/data/category_models.dart';
import '../../dashboard/providers/dashboard_providers.dart';
import '../../wallet/data/wallet_models.dart';
import '../../wallet/providers/wallet_providers.dart';
import '../data/transaction_models.dart';
import '../providers/transaction_providers.dart';
import 'transaction_form_screen.dart';

class TransactionDetailScreen extends ConsumerWidget {
  const TransactionDetailScreen({super.key, required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isIncome = transaction.type == TxType.income;
    return _DetailView(
      title: 'Detail transaksi',
      amount: isIncome ? transaction.amount : -transaction.amount,
      signed: true,
      occurredAt: transaction.occurredAt,
      note: transaction.note,
      rows: {
        'Tipe': isIncome ? 'Masuk' : 'Keluar',
        'Kategori': transaction.category.name,
        'Dompet': transaction.wallet.name,
      },
      attachments: transaction.attachments,
      formArgs: TransactionFormArgs(transaction: transaction),
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
      amount: transfer.amount,
      signed: false,
      occurredAt: transfer.occurredAt,
      note: transfer.note,
      rows: {
        'Dari dompet': transfer.fromWallet.name,
        'Ke dompet': transfer.toWallet.name,
      },
      formArgs: TransactionFormArgs(transfer: transfer),
      deleteMessage: 'Hapus transfer ini?',
      deletedMessage: 'Transfer terhapus',
      onDelete: () => ref.read(walletApiProvider).deleteTransfer(transfer.id),
    );
  }
}

class _DetailView extends ConsumerWidget {
  const _DetailView({
    required this.title,
    required this.amount,
    required this.signed,
    required this.occurredAt,
    required this.note,
    required this.rows,
    this.attachments = const [],
    required this.formArgs,
    required this.deleteMessage,
    required this.deletedMessage,
    required this.onDelete,
  });

  final String title;
  final int amount;
  final bool signed;
  final DateTime occurredAt;
  final String? note;
  final Map<String, String> rows;
  final List<Attachment> attachments;
  final TransactionFormArgs formArgs;
  final String deleteMessage;
  final String deletedMessage;
  final Future<void> Function() onDelete;

  Future<void> _edit(BuildContext context) async {
    final saved = await context.pushNamed<bool>(
      Routes.transactionForm,
      extra: formArgs,
    );
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
    final when = occurredAt.toLocal();
    final allRows = {
      ...rows,
      'Tanggal': formatLongDate(when),
      'Jam': formatTime(when),
      'Catatan': ?note,
    };
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: AmountText(amount, signed: signed, large: true),
          ),
          const SizedBox(height: Spacing.xl),
          for (final row in allRows.entries)
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
