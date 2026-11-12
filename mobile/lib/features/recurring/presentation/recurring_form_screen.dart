import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_error.dart';
import '../../../core/format/dates.dart';
import '../../../core/format/rupiah_input.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/money_widgets.dart';
import '../../../core/widgets/state_views.dart';
import '../../category/data/category_models.dart';
import '../../transaction/presentation/widgets/category_grid.dart';
import '../../wallet/providers/wallet_providers.dart';
import '../data/recurring_models.dart';
import '../providers/recurring_providers.dart';

/// Tambah/ubah aturan transaksi berulang. [rule] null = aturan baru.
class RecurringFormScreen extends ConsumerStatefulWidget {
  const RecurringFormScreen({super.key, this.rule});

  final Recurring? rule;

  @override
  ConsumerState<RecurringFormScreen> createState() =>
      _RecurringFormScreenState();
}

class _RecurringFormScreenState extends ConsumerState<RecurringFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TxType _type = widget.rule?.type ?? TxType.expense;
  late final _amount = TextEditingController(
    text: widget.rule == null ? null : rupiahInputText(widget.rule!.amount),
  );
  late final _note = TextEditingController(text: widget.rule?.note);
  late String? _categoryId = widget.rule?.category.id;
  late String? _walletId = widget.rule?.wallet.id;
  late int _day = widget.rule?.dayOfMonth ?? DateTime.now().day;
  late String _startMonth = widget.rule?.startMonth ?? monthKey(DateTime.now());
  late String? _endMonth = widget.rule?.endMonth;
  String? _categoryError;
  String? _error;
  bool _busy = false;

  bool get _isEdit => widget.rule != null;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  String _monthLabel(String month) => formatMonth(DateTime.parse('$month-01'));

  static const _rangeError = 'Bulan berakhir tidak boleh sebelum bulan mulai';

  bool get _rangeInvalid =>
      _endMonth != null && _endMonth!.compareTo(_startMonth) < 0;

  /// Menampilkan galat rentang bulan segera setelah salah satu bulan diganti.
  void _recheckRange() =>
      setState(() => _error = _rangeInvalid ? _rangeError : null);

  Future<String?> _pickMonth(String initial) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse('$initial-01'),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    return picked == null ? null : monthKey(picked);
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
      if (!mounted) return;
      ref.invalidate(recurringListProvider);
      ref.invalidate(recurringDueProvider);
      context.pop();
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _error = e.details.values.firstOrNull ?? e.message);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _save(String walletId) {
    final formValid = _formKey.currentState!.validate();
    setState(() {
      _categoryError = _categoryId == null ? 'Pilih kategori' : null;
      _error = null;
    });
    if (_rangeInvalid) {
      setState(() => _error = _rangeError);
      return;
    }
    if (!formValid || _categoryId == null || _busy) return;
    final note = _note.text.trim();
    final data = <String, Object?>{
      'type': _type.apiValue,
      'amount': parseRupiah(_amount.text),
      'categoryId': _categoryId,
      'walletId': walletId,
      'dayOfMonth': _day,
      'startMonth': _startMonth,
      'endMonth': _endMonth,
      // Saat edit, catatan kosong berarti dihapus.
      if (note.isNotEmpty) 'note': note else if (_isEdit) 'note': null,
    };
    final api = ref.read(recurringApiProvider);
    final rule = widget.rule;
    _run(() => rule == null ? api.create(data) : api.update(rule.id, data));
  }

  Future<void> _delete() async {
    final confirmed = await confirmDialog(
      context,
      message: 'Hapus aturan ini? Transaksi yang sudah tercatat tidak ikut terhapus.',
      confirmLabel: 'Hapus',
    );
    if (confirmed) {
      _run(() => ref.read(recurringApiProvider).delete(widget.rule!.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wallets = ref.watch(walletsProvider(includeArchived: _isEdit));
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Ubah aturan' : 'Tambah aturan'),
        actions: [
          if (_isEdit)
            IconButton(
              tooltip: 'Hapus',
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: _busy ? null : _delete,
            ),
        ],
      ),
      body: wallets.when(
        loading: () => const ListSkeleton(),
        error: (error, _) => ErrorState(
          error: error,
          onRetry: () => ref.invalidate(walletsProvider),
        ),
        data: (items) {
          final ids = items.map((wallet) => wallet.id);
          final walletId = _walletId != null && ids.contains(_walletId)
              ? _walletId!
              : (items.isEmpty ? null : items.first.id);
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(Spacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SegmentedButton<TxType>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: TxType.expense,
                        label: Text('Keluar'),
                      ),
                      ButtonSegment(value: TxType.income, label: Text('Masuk')),
                    ],
                    selected: {_type},
                    onSelectionChanged: (selected) => setState(() {
                      _type = selected.first;
                      _categoryId = null;
                      _categoryError = null;
                    }),
                  ),
                  const SizedBox(height: Spacing.lg),
                  TextFormField(
                    controller: _amount,
                    keyboardType: TextInputType.number,
                    inputFormatters: const [RupiahInputFormatter()],
                    decoration: const InputDecoration(
                      labelText: 'Nominal',
                      prefixText: 'Rp',
                    ),
                    validator: (value) {
                      final amount = parseRupiah(value ?? '');
                      return amount == null || amount <= 0
                          ? 'Nominal harus lebih dari 0'
                          : null;
                    },
                  ),
                  const SizedBox(height: Spacing.md),
                  CategoryGrid(
                    type: _type,
                    selectedId: _categoryId,
                    keepId: widget.rule?.category.id,
                    errorText: _categoryError,
                    onSelected: (id) => setState(() {
                      _categoryId = id;
                      _categoryError = null;
                    }),
                  ),
                  const SizedBox(height: Spacing.md),
                  DropdownButtonFormField<String>(
                    key: ValueKey(walletId),
                    initialValue: walletId,
                    items: [
                      for (final wallet in items)
                        DropdownMenuItem(
                          value: wallet.id,
                          child: Text(wallet.name),
                        ),
                    ],
                    decoration: const InputDecoration(labelText: 'Dompet'),
                    onChanged: (value) => setState(() => _walletId = value),
                  ),
                  const SizedBox(height: Spacing.md),
                  DropdownButtonFormField<int>(
                    initialValue: _day,
                    items: [
                      for (var day = 1; day <= 31; day++)
                        DropdownMenuItem(value: day, child: Text('$day')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Tanggal tiap bulan',
                      helperText: 'Tanggal 29-31 jatuh ke hari terakhir di bulan pendek',
                    ),
                    onChanged: (value) => setState(() => _day = value!),
                  ),
                  const SizedBox(height: Spacing.md),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Mulai bulan'),
                    subtitle: Text(_monthLabel(_startMonth)),
                    trailing: const Icon(Icons.calendar_month_rounded),
                    onTap: () async {
                      final month = await _pickMonth(_startMonth);
                      if (month == null) return;
                      _startMonth = month;
                      _recheckRange();
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Berakhir bulan'),
                    subtitle: Text(
                      _endMonth == null
                          ? 'Terus berjalan'
                          : _monthLabel(_endMonth!),
                    ),
                    trailing: _endMonth == null
                        ? const Icon(Icons.calendar_month_rounded)
                        : IconButton(
                            tooltip: 'Hapus bulan berakhir',
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => setState(() {
                              _endMonth = null;
                              _error = null;
                            }),
                          ),
                    onTap: () async {
                      final month = await _pickMonth(_endMonth ?? _startMonth);
                      if (month == null) return;
                      _endMonth = month;
                      _recheckRange();
                    },
                  ),
                  TextFormField(
                    controller: _note,
                    maxLength: 1000,
                    decoration: const InputDecoration(
                      labelText: 'Catatan (opsional)',
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: Spacing.sm),
                    Text(
                      _error!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: Spacing.md),
                  FilledButton(
                    onPressed: _busy || walletId == null
                        ? null
                        : () => _save(walletId),
                    child: const Text('Simpan'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
