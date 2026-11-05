import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_error.dart';
import '../../../core/format/dates.dart';
import '../../../core/format/rupiah_input.dart';
import '../../../core/router/router.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/state_views.dart';
import '../../category/data/category_models.dart';
import '../../dashboard/providers/dashboard_providers.dart';
import '../../wallet/data/wallet_models.dart';
import '../../wallet/providers/wallet_providers.dart';
import '../data/transaction_models.dart';
import '../providers/transaction_providers.dart';
import 'widgets/category_grid.dart';

enum _Mode { expense, income, transfer }

/// Tambah baru (opsional dengan [initialDate]), atau edit [transaction] / [transfer].
class TransactionFormArgs {
  const TransactionFormArgs({this.transaction, this.transfer, this.initialDate});

  final Transaction? transaction;
  final Transfer? transfer;
  final DateTime? initialDate;
}

class TransactionFormScreen extends ConsumerStatefulWidget {
  const TransactionFormScreen({super.key, this.args = const TransactionFormArgs()});

  final TransactionFormArgs args;

  @override
  ConsumerState<TransactionFormScreen> createState() =>
      _TransactionFormScreenState();
}

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _note = TextEditingController();

  _Mode _mode = _Mode.expense;
  String? _walletId;
  String? _toWalletId;
  String? _categoryId;
  late DateTime _occurredAt;
  bool _busy = false;
  String? _categoryError;
  String? _error;

  Transaction? get _transaction => widget.args.transaction;
  Transfer? get _transfer => widget.args.transfer;
  bool get _isEdit => _transaction != null || _transfer != null;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final date = widget.args.initialDate;
    _occurredAt = date?.copyWith(hour: now.hour, minute: now.minute) ?? now;

    final transaction = _transaction;
    if (transaction != null) {
      _mode = transaction.type == TxType.income ? _Mode.income : _Mode.expense;
      _walletId = transaction.wallet.id;
      _categoryId = transaction.category.id;
      _occurredAt = transaction.occurredAt.toLocal();
      _amount.text = rupiahInputText(transaction.amount);
      _note.text = transaction.note ?? '';
    }
    final transfer = _transfer;
    if (transfer != null) {
      _mode = _Mode.transfer;
      _walletId = transfer.fromWallet.id;
      _toWalletId = transfer.toWallet.id;
      _occurredAt = transfer.occurredAt.toLocal();
      _amount.text = rupiahInputText(transfer.amount);
      _note.text = transfer.note ?? '';
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  /// Dompet arsip hanya muncul jika sedang dipakai data yang diedit (D-34).
  List<Wallet> _options(List<Wallet> wallets) {
    final current = {
      _transaction?.wallet.id,
      _transfer?.fromWallet.id,
      _transfer?.toWallet.id,
    };
    return [
      for (final wallet in wallets)
        if (!wallet.isArchived || current.contains(wallet.id)) wallet,
    ];
  }

  /// Pilihan user, atau dompet transaksi terakhir, atau dompet aktif pertama (D-31).
  String _selectedWallet(List<Wallet> wallets) {
    final ids = wallets.map((wallet) => wallet.id);
    if (_walletId != null && ids.contains(_walletId)) return _walletId!;
    final last = ref.watch(lastUsedWalletIdProvider).value;
    return last != null && ids.contains(last) ? last : wallets.first.id;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _occurredAt,
      firstDate: DateTime(2000),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      _occurredAt = picked.copyWith(
        hour: _occurredAt.hour,
        minute: _occurredAt.minute,
      );
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_occurredAt),
    );
    if (picked == null) return;
    setState(() {
      _occurredAt = _occurredAt.copyWith(hour: picked.hour, minute: picked.minute);
    });
  }

  Future<void> _send(String walletId, Map<String, Object?> common) async {
    final transactions = ref.read(transactionApiProvider);
    final wallets = ref.read(walletApiProvider);
    if (_mode == _Mode.transfer) {
      final data = {
        ...common,
        'fromWalletId': walletId,
        'toWalletId': _toWalletId,
      };
      final transfer = _transfer;
      await (transfer == null
          ? wallets.createTransfer(data)
          : wallets.updateTransfer(transfer.id, data));
      return;
    }
    final data = {
      ...common,
      'walletId': walletId,
      'categoryId': _categoryId,
      'type': (_mode == _Mode.income ? TxType.income : TxType.expense).apiValue,
    };
    final transaction = _transaction;
    await (transaction == null
        ? transactions.create(data)
        : transactions.update(transaction.id, data));
  }

  Future<void> _submit(List<Wallet> wallets) async {
    final formValid = _formKey.currentState!.validate();
    final categoryMissing = _mode != _Mode.transfer && _categoryId == null;
    setState(() {
      _categoryError = categoryMissing ? 'Pilih kategori' : null;
      _error = null;
    });
    if (!formValid || categoryMissing || _busy) return;

    setState(() => _busy = true);
    final note = _note.text.trim();
    final common = <String, Object?>{
      'amount': parseRupiah(_amount.text),
      'occurredAt': _occurredAt.toUtc().toIso8601String(),
      // Saat edit, catatan kosong berarti dihapus.
      if (note.isNotEmpty) 'note': note else if (_isEdit) 'note': null,
    };
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _send(_selectedWallet(wallets), common);
      refreshMoney(ref);
      final subject = _mode == _Mode.transfer ? 'Transfer' : 'Transaksi';
      messenger.showSnackBar(SnackBar(content: Text('$subject tersimpan')));
      if (mounted) context.pop(true);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.details.values.firstOrNull ?? e.message;
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallets = ref.watch(walletsProvider(includeArchived: _isEdit));
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEdit
              ? (_transfer != null ? 'Ubah transfer' : 'Ubah transaksi')
              : 'Tambah transaksi',
        ),
      ),
      body: wallets.when(
        error: (error, _) => ErrorState(
          error: error,
          onRetry: () => ref.invalidate(walletsProvider),
        ),
        loading: () => const ListSkeleton(),
        data: (all) {
          final options = _options(all);
          if (options.isNotEmpty) return _buildForm(options);
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const EmptyState(
                  message: 'Belum ada dompet aktif. Tambah dompet dulu, yuk.',
                ),
                TextButton(
                  onPressed: () => context.pushNamed(Routes.wallets),
                  child: const Text('Kelola dompet'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildForm(List<Wallet> wallets) {
    final theme = Theme.of(context);
    final fromWallet = _selectedWallet(wallets);
    final items = [
      for (final wallet in wallets)
        DropdownMenuItem(value: wallet.id, child: Text(wallet.name)),
    ];

    return Form(
      key: _formKey,
      // Bukan ListView: field yang ter-scroll keluar layar tetap harus ikut divalidasi.
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<_Mode>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: _Mode.expense,
                  enabled: _transfer == null,
                  label: const Text('Keluar'),
                ),
                ButtonSegment(
                  value: _Mode.income,
                  enabled: _transfer == null,
                  label: const Text('Masuk'),
                ),
                ButtonSegment(
                  value: _Mode.transfer,
                  enabled: _transaction == null,
                  label: const Text('Transfer'),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (selected) => setState(() {
                _mode = selected.first;
                _categoryId = null;
                _categoryError = null;
              }),
            ),
            const SizedBox(height: Spacing.lg),
            TextFormField(
              controller: _amount,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.end,
              style: theme.textTheme.displayMedium,
              autofocus: !_isEdit,
              inputFormatters: const [RupiahInputFormatter()],
              decoration: InputDecoration(
                labelText: 'Nominal',
                prefixText: 'Rp',
                prefixStyle: theme.textTheme.displayMedium,
              ),
              validator: (value) {
                final amount = parseRupiah(value ?? '');
                return amount == null || amount <= 0
                    ? 'Nominal harus lebih dari 0'
                    : null;
              },
            ),
            const SizedBox(height: Spacing.md),
            DropdownButtonFormField<String>(
              key: ValueKey(fromWallet),
              initialValue: fromWallet,
              items: items,
              decoration: InputDecoration(
                labelText: _mode == _Mode.transfer ? 'Dari dompet' : 'Dompet',
              ),
              onChanged: (value) => setState(() => _walletId = value),
            ),
            const SizedBox(height: Spacing.md),
            if (_mode == _Mode.transfer)
              DropdownButtonFormField<String>(
                initialValue: _toWalletId,
                items: items,
                decoration: const InputDecoration(labelText: 'Ke dompet'),
                onChanged: (value) => setState(() => _toWalletId = value),
                validator: (value) {
                  if (value == null) return 'Pilih dompet';
                  return value == fromWallet
                      ? 'Dompet asal dan tujuan harus berbeda'
                      : null;
                },
              )
            else
              CategoryGrid(
                type: _mode == _Mode.income ? TxType.income : TxType.expense,
                selectedId: _categoryId,
                keepId: _transaction?.category.id,
                errorText: _categoryError,
                onSelected: (id) => setState(() {
                  _categoryId = id;
                  _categoryError = null;
                }),
              ),
            const SizedBox(height: Spacing.sm),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_rounded),
              title: Text(formatLongDate(_occurredAt)),
              onTap: _pickDate,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule_rounded),
              title: Text(formatTime(_occurredAt)),
              onTap: _pickTime,
            ),
            TextFormField(
              controller: _note,
              maxLength: 1000,
              maxLines: null,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              decoration: const InputDecoration(labelText: 'Catatan (opsional)'),
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
              onPressed: _busy ? null : () => _submit(wallets),
              child: _busy
                  ? const SizedBox.square(
                      dimension: Spacing.xl,
                      child: CircularProgressIndicator(),
                    )
                  : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
