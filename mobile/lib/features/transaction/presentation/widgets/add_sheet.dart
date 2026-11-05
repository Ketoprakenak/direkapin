import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/router.dart';
import '../../../activity/presentation/activity_form_screen.dart';
import '../transaction_form_screen.dart';

/// Pilihan FAB: Transaksi atau Kegiatan. [date] mengisi tanggal awal form.
void showAddSheet(BuildContext context, {DateTime? date}) {
  showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.receipt_long_rounded),
            title: const Text('Transaksi'),
            onTap: () {
              Navigator.pop(sheetContext);
              context.pushNamed(
                Routes.transactionForm,
                extra: TransactionFormArgs(initialDate: date),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.event_note_rounded),
            title: const Text('Kegiatan'),
            onTap: () {
              Navigator.pop(sheetContext);
              context.pushNamed(
                Routes.activityForm,
                extra: ActivityFormArgs(initialDate: date),
              );
            },
          ),
        ],
      ),
    ),
  );
}
