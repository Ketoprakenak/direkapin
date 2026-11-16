import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_error.dart';
import '../../../core/api/client_id.dart';
import '../../../core/format/dates.dart';
import '../../../core/format/money.dart';
import '../../../core/format/rupiah_input.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/frame.dart';
import '../../../core/widgets/state_views.dart';
import '../../dashboard/providers/dashboard_providers.dart';
import '../../wallet/providers/wallet_providers.dart';
import '../data/receivable_models.dart';
import '../providers/receivable_providers.dart';

/// Catat talangan/utang baru, atau ubah judul/tanggal/catatan [receivable].
class ReceivableFormScreen extends ConsumerStatefulWidget {
  const ReceivableFormScreen({
    super.key,
    this.receivable,
    this.direction = ReceivableDirection.receivable,
  });

  final Receivable? receivable;

  /// Arah catatan baru; diabaikan saat mengubah [receivable].
  final ReceivableDirection direction;

  @override
  ConsumerState<ReceivableFormScreen> createState() =>
      _ReceivableFormScreenState();
}

class _Row {
  final name = TextEditingController();
  final amount = TextEditingController();

  void dispose() {
    name.dispose();
    amount.dispose();
  }
}

class _ReceivableFormScreenState extends ConsumerState<ReceivableFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.receivable?.title);
  late final _note = TextEditingController(text: widget.receivable?.note);
  late DateTime _date = widget.receivable == null
      ? DateTime.now()
      : DateTime.parse(widget.receivable!.date);
  final _rows = [_Row()];
  // Sekali per form: Simpan ulang setelah timeout tidak membuat catatan dobel (D-58).
  final _clientId = newClientId();
  bool _cash = false;
  String? _walletId;
  bool _busy = false;
  String? _error;

  bool get _isEdit => widget.receivable != null;

  bool get _payable =>
      (widget.receivable?.direction ?? widget.direction).isPayable;

  int get _total =>
      _rows.fold(0, (sum, row) => sum + (parseRupiah(row.amount.text) ?? 0));

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  void _addRow() => setState(() => _rows.add(_Row()));

  void _removeRow(_Row row) => setState(() {
    _rows.remove(row);
    row.dispose();
  });

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final api = ref.read(receivableApiProvider);
    final note = _note.text.trim();
    final data = <String, Object?>{
      'title': _title.text.trim(),
      'date': dateKey(_date),
    };
    final navigator = Navigator.of(context);
    try {
      if (_isEdit) {
        await api.update(widget.receivable!.id, {
          ...data,
          'note': note.isEmpty ? null : note,
        });
      } else {
        await api.create({
          ...data,
          'clientId': _clientId,
          if (_payable) 'direction': 'PAYABLE',
          if (_payable && _cash) 'loanWalletId': _walletId,
          if (note.isNotEmpty) 'note': note,
          'debtors': [
            for (final row in _rows)
              {
                'name': row.name.text.trim(),
                'amount': parseRupiah(row.amount.text),
              },
          ],
        });
      }
      refreshMoney(ref);
      navigator.pop();
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.details.values.firstOrNull ?? e.message;
          _busy = false;
        });
      }
    }
  }

  /// Utang: ditalangin (tanpa uang masuk) atau pinjam tunai ke dompet (D-78).
  List<Widget> _loanFields(BuildContext context) => [
    const SizedBox(height: Spacing.sm),
    SegmentedButton<bool>(
      showSelectedIcon: false,
      expandedInsets: EdgeInsets.zero,
      segments: const [
        ButtonSegment(value: false, label: Text('Ditalangin')),
        ButtonSegment(value: true, label: Text('Pinjam tunai')),
      ],
      selected: {_cash},
      onSelectionChanged: (selected) => setState(() => _cash = selected.first),
    ),
    if (_cash) ...[
      const SizedBox(height: Spacing.md),
      ref
          .watch(walletsProvider(includeSavings: true))
          .when(
            loading: () => const LinearProgressIndicator(),
            error: (error, _) => ErrorState(
              error: error,
              onRetry: () => ref.invalidate(walletsProvider),
            ),
            data: (items) => DropdownButtonFormField<String>(
              initialValue: _walletId,
              isExpanded: true,
              items: [
                for (final wallet in items)
                  DropdownMenuItem(
                    value: wallet.id,
                    child: Text(
                      '${wallet.name} · ${formatRupiah(wallet.balance)}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              decoration: const InputDecoration(labelText: 'Masuk ke dompet'),
              onChanged: (value) => setState(() => _walletId = value),
              validator: (value) => value == null ? 'Pilih dompet' : null,
            ),
          ),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final noun = _payable ? 'utang' : 'piutang';
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Ubah $noun' : 'Catat $noun')),
      body: Form(
        key: _formKey,
        // Bukan ListView: baris yang ter-scroll keluar layar tetap harus divalidasi.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _title,
                maxLength: 60,
                decoration: const InputDecoration(labelText: 'Judul'),
                validator: (value) =>
                    (value ?? '').trim().isEmpty ? 'Judul wajib diisi' : null,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_rounded),
                title: Text(formatLongDate(_date)),
                onTap: _pickDate,
              ),
              TextFormField(
                controller: _note,
                maxLength: 1000,
                maxLines: null,
                decoration: const InputDecoration(
                  labelText: 'Catatan (opsional)',
                ),
              ),
              if (!_isEdit) ...[
                const SizedBox(height: Spacing.md),
                if (!_payable) ...[
                  Text('Siapa saja', style: theme.textTheme.titleMedium),
                  const SizedBox(height: Spacing.sm),
                ],
                for (final (index, row) in _rows.indexed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Spacing.sm),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: TextFormField(
                            controller: row.name,
                            maxLength: 30,
                            decoration: InputDecoration(
                              labelText: _payable
                                  ? 'Utang ke'
                                  : 'Nama ${index + 1}',
                              counterText: '',
                            ),
                            validator: (value) => (value ?? '').trim().isEmpty
                                ? 'Nama wajib diisi'
                                : null,
                          ),
                        ),
                        const SizedBox(width: Spacing.sm),
                        Expanded(
                          flex: 4,
                          child: TextFormField(
                            controller: row.amount,
                            keyboardType: TextInputType.number,
                            inputFormatters: const [RupiahInputFormatter()],
                            decoration: const InputDecoration(
                              labelText: 'Nominal',
                              prefixText: 'Rp',
                            ),
                            onChanged: (_) => setState(() {}),
                            validator: (value) =>
                                (parseRupiah(value ?? '') ?? 0) <= 0
                                ? 'Nominal harus lebih dari 0'
                                : null,
                          ),
                        ),
                        if (!_payable)
                          IconButton(
                            tooltip: 'Hapus baris ${index + 1}',
                            onPressed: _rows.length == 1
                                ? null
                                : () => _removeRow(row),
                            icon: const Icon(Icons.delete_outline_rounded),
                          ),
                      ],
                    ),
                  ),
                if (_payable) ..._loanFields(context),
              ],
              if (!_isEdit && !_payable) ...[
                OutlinedButton.icon(
                  onPressed: _rows.length >= 20 ? null : _addRow,
                  icon: const Icon(Icons.person_add_alt_rounded),
                  label: const Text('Tambah orang'),
                ),
                const SizedBox(height: Spacing.md),
                FrameCard(
                  child: Row(
                    children: [
                      const Expanded(child: Text('Total piutang')),
                      Text(
                        formatRupiah(_total),
                        style: theme.textTheme.titleSmall,
                      ),
                    ],
                  ),
                ),
              ],
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
                onPressed: _busy ? null : _save,
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
