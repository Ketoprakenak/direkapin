import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_error.dart';
import '../../../core/format/dates.dart';
import '../../../core/format/money.dart';
import '../../../core/format/rupiah_input.dart';
import '../../../core/router/router.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/state_views.dart';
import '../../attachment/presentation/photo_edits.dart';
import '../../attachment/presentation/widgets/photo_picker_row.dart';
import '../../attachment/providers/attachment_providers.dart';
import '../../category/data/category_models.dart';
import '../../dashboard/providers/dashboard_providers.dart';
import '../../wallet/data/wallet_models.dart';
import '../../wallet/providers/wallet_providers.dart';
import '../data/transaction_models.dart';
import '../providers/transaction_providers.dart';
import 'widgets/category_grid.dart';

enum _Mode { expense, income, transfer }

const _photoLimit = 3;

/// Tambah baru (opsional dengan [initialDate]), atau edit [transaction] / [transfer].
class TransactionFormArgs {
  const TransactionFormArgs({
    this.transaction,
    this.transfer,
    this.initialDate,
  });

  final Transaction? transaction;
  final Transfer? transfer;
  final DateTime? initialDate;
}

class TransactionFormScreen extends ConsumerStatefulWidget {
  const TransactionFormScreen({
    super.key,
    this.args = const TransactionFormArgs(),
  });

  final TransactionFormArgs args;

  @override
  ConsumerState<TransactionFormScreen> createState() =>
      _TransactionFormScreenState();
}

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  final _fee = TextEditingController();
  FeePaidBy _feePaidBy = FeePaidBy.to;

  _Mode _mode = _Mode.expense;
  String? _walletId;
  String? _toWalletId;
  String? _categoryId;
  late DateTime _occurredAt;
  bool _busy = false;
  String? _categoryError;
  String? _error;

  late final PhotoEdits _photos;

  /// Terisi setelah transaksi tersimpan; sejak itu Simpan tidak boleh mengirim ulang.
  String? _savedId;

  Transaction? get _transaction => widget.args.transaction;
  Transfer? get _transfer => widget.args.transfer;
  bool get _isEdit => _transaction != null || _transfer != null;

  void _rebuild() => setState(() {});

  @override
  void initState() {
    super.initState();
    _photos = PhotoEdits(_transaction?.attachments ?? const [])
      ..addListener(_rebuild);
    // Teks "Diterima" di form transfer mengikuti nominal dan biaya.
    _amount.addListener(_rebuild);
    _fee.addListener(_rebuild);
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
      if (transfer.fee > 0) _fee.text = rupiahInputText(transfer.fee);
      _feePaidBy = transfer.feePaidBy ?? FeePaidBy.to;
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    _fee.dispose();
    _photos.dispose();
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
      _occurredAt = _occurredAt.copyWith(
        hour: picked.hour,
        minute: picked.minute,
      );
    });
  }

  Future<void> _syncPhotos() async {
    setState(() => _busy = true);
    final done = await _photos.sync(
      ref.read(attachmentApiProvider),
      transactionId: _savedId,
      subject: 'Transaksi',
    );
    if (!mounted) return;
    if (done) return _finish();
    refreshMoney(ref);
    setState(() => _busy = false);
  }

  void _finish() {
    refreshMoney(ref);
    final subject = _mode == _Mode.transfer ? 'Transfer' : 'Transaksi';
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$subject tersimpan')));
    context.pop(true);
  }

  /// ID transaksi yang tersimpan; null untuk transfer.
  Future<String?> _send(String walletId, Map<String, Object?> common) async {
    final transactions = ref.read(transactionApiProvider);
    final wallets = ref.read(walletApiProvider);
    if (_mode == _Mode.transfer) {
      final data = {
        ...common,
        'fromWalletId': walletId,
        'toWalletId': _toWalletId,
        'fee': parseRupiah(_fee.text) ?? 0,
        'feePaidBy': _feePaidBy.apiValue,
      };
      final transfer = _transfer;
      await (transfer == null
          ? wallets.createTransfer(data)
          : wallets.updateTransfer(transfer.id, data));
      return null;
    }
    final data = {
      ...common,
      'walletId': walletId,
      'categoryId': _categoryId,
      'type': (_mode == _Mode.income ? TxType.income : TxType.expense).apiValue,
    };
    final transaction = _transaction;
    if (transaction == null) return transactions.create(data);
    await transactions.update(transaction.id, data);
    return transaction.id;
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
    final String? savedId;
    try {
      savedId = await _send(_selectedWallet(wallets), common);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.details.values.firstOrNull ?? e.message;
          _busy = false;
        });
      }
      return;
    }
    if (!mounted) return;
    if (savedId == null) return _finish();
    setState(() => _savedId = savedId);
    await _syncPhotos();
  }

  @override
  Widget build(BuildContext context) {
    final wallets = ref.watch(walletsProvider(includeArchived: _isEdit));
    return PopScope(
      // Transaksi sudah tersimpan: keluar harus lewat _finish supaya layar asal ikut segar.
      canPop: _savedId == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_busy) _finish();
      },
      child: Scaffold(
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
      ),
    );
  }

  /// Biaya admin transfer (FIN-17): dicatat sebagai pengeluaran "Biaya Admin".
  List<Widget> _feeFields(ThemeData theme) {
    final fee = parseRupiah(_fee.text) ?? 0;
    final amount = parseRupiah(_amount.text) ?? 0;
    final paidByTo = _feePaidBy == FeePaidBy.to;
    return [
      const SizedBox(height: Spacing.md),
      TextFormField(
        controller: _fee,
        keyboardType: TextInputType.number,
        inputFormatters: const [RupiahInputFormatter()],
        decoration: const InputDecoration(
          labelText: 'Biaya admin (opsional)',
          prefixText: 'Rp',
        ),
        validator: (value) {
          final fee = parseRupiah(value ?? '') ?? 0;
          final amount = parseRupiah(_amount.text) ?? 0;
          return _feePaidBy == FeePaidBy.to && fee > 0 && fee >= amount
              ? 'Biaya admin harus lebih kecil dari nominal transfer'
              : null;
        },
      ),
      if (fee > 0) ...[
        const SizedBox(height: Spacing.sm),
        Text('Dipotong dari', style: theme.textTheme.bodyMedium),
        const SizedBox(height: Spacing.xs),
        SegmentedButton<FeePaidBy>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: FeePaidBy.from, label: Text('Dompet asal')),
            ButtonSegment(value: FeePaidBy.to, label: Text('Dompet tujuan')),
          ],
          selected: {_feePaidBy},
          onSelectionChanged: (selected) =>
              setState(() => _feePaidBy = selected.first),
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          paidByTo
              ? 'Diterima: ${formatRupiah(amount - fee)}'
              : 'Total keluar dari dompet asal: ${formatRupiah(amount + fee)}',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    ];
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
            IgnorePointer(
              ignoring: _savedId != null,
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
                      labelText: _mode == _Mode.transfer
                          ? 'Dari dompet'
                          : 'Dompet',
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
                    ),
                  if (_mode == _Mode.transfer) ..._feeFields(theme)
                  else
                    CategoryGrid(
                      type: _mode == _Mode.income
                          ? TxType.income
                          : TxType.expense,
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
                    decoration: const InputDecoration(
                      labelText: 'Catatan (opsional)',
                    ),
                  ),
                  if (_mode != _Mode.transfer) ...[
                    const SizedBox(height: Spacing.sm),
                    PhotoPickerRow(
                      edits: _photos,
                      label: 'Foto struk',
                      limit: _photoLimit,
                      locked: _savedId != null,
                    ),
                  ],
                ],
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
            PhotoSaveButtons(
              edits: _photos,
              busy: _busy,
              onSave: () => _submit(wallets),
              onRetry: _syncPhotos,
              onSkip: _finish,
            ),
          ],
        ),
      ),
    );
  }
}
