import 'package:flutter/material.dart';

import '../../../../core/format/dates.dart';
import '../../../../core/format/rupiah_input.dart';
import '../../../../core/theme/tokens.dart';
import '../../data/recurring_models.dart';

/// Konfirmasi nominal & tanggal sebelum mencatat kejadian berulang (FIN-15).
/// Hasil: nominal dan tanggal terpilih, atau null jika dibatalkan.
Future<({int amount, DateTime date})?> showRecordSheet(
  BuildContext context,
  RecurringDue due,
) => showModalBottomSheet<({int amount, DateTime date})>(
  context: context,
  isScrollControlled: true,
  builder: (_) => _RecordSheet(due),
);

class _RecordSheet extends StatefulWidget {
  const _RecordSheet(this.due);

  final RecurringDue due;

  @override
  State<_RecordSheet> createState() => _RecordSheetState();
}

class _RecordSheetState extends State<_RecordSheet> {
  late final _amount = TextEditingController(
    text: rupiahInputText(widget.due.recurring.amount),
  );
  late DateTime _date = DateTime.parse(widget.due.dueDate);
  final _formKey = GlobalKey<FormState>();
  bool _done = false;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isAfter(now) ? now : _date,
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save() {
    if (_done || !_formKey.currentState!.validate()) return;
    _done = true;
    Navigator.pop(context, (
      amount: parseRupiah(_amount.text)!,
      // Tengah hari supaya tanggal aman dari pergeseran zona waktu.
      date: DateTime(_date.year, _date.month, _date.day, 12),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          Spacing.lg,
          Spacing.lg,
          Spacing.lg,
          Spacing.lg + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Catat ${widget.due.recurring.category.name}',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: Spacing.lg),
                TextFormField(
                  controller: _amount,
                  keyboardType: TextInputType.number,
                  inputFormatters: const [RupiahInputFormatter()],
                  decoration: const InputDecoration(
                    labelText: 'Nominal',
                    prefixText: 'Rp ',
                  ),
                  validator: (value) => (parseRupiah(value ?? '') ?? 0) <= 0
                      ? 'Nominal wajib diisi'
                      : null,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today_rounded),
                  title: Text(formatLongDate(_date)),
                  onTap: _pickDate,
                ),
                const SizedBox(height: Spacing.sm),
                FilledButton(onPressed: _save, child: const Text('Simpan')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
