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

/// Bagi rata ke [friends] teman + owner; sisa pembulatan milik owner (D-79).
List<int> splitEvenly(int total, int friends) =>
    List.filled(friends, total ~/ (friends + 1));

/// Catat talangan/utang baru, atau ubah judul/tanggal/catatan [receivable].
/// Dengan [source]: "Bagi ke teman" dari pengeluaran (FIN-21).
class ReceivableFormScreen extends ConsumerStatefulWidget {
  const ReceivableFormScreen({
    super.key,
    this.receivable,
    this.direction = ReceivableDirection.receivable,
    this.source,
  });

  final Receivable? receivable;
  final ReceivableSource? source;

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
  late final _title = TextEditingController(
    text: widget.receivable?.title ?? widget.source?.categoryName,
  );
  late final _note = TextEditingController(text: widget.receivable?.note);
  late DateTime _date = switch ((widget.receivable, widget.source)) {
    (final r?, _) => DateTime.parse(r.date),
    (_, final s?) => DateTime.parse(s.date),
    _ => DateTime.now(),
  };
  final _rows = [_Row()];
  // Sekali per form: Simpan ulang setelah timeout tidak membuat catatan dobel (D-58).
  final _clientId = newClientId();
  bool _cash = false;
  String? _walletId;
  bool _busy = false;
  String? _error;

  bool get _isEdit => widget.receivable != null;

  /// Piutang baru dari menu = pinjamkan uang, selalu dari dompet (D-86).
  bool get _lend => !_isEdit && !_payable && widget.source == null;

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

  void _splitEvenly() => setState(() {
    final shares = splitEvenly(widget.source!.amount, _rows.length);
    for (final (index, row) in _rows.indexed) {
      row.amount.text = rupiahInputText(shares[index]);
    }
  });

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
    final source = widget.source;
    if (source != null && _total > source.amount) {
      setState(
        () => _error =
            'Melebihi nominal pengeluaran ${formatRupiah(source.amount)}',
      );
      return;
    }
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
          if ((_payable && _cash) || _lend) 'loanWalletId': _walletId,
          'sourceTransactionId': ?widget.source?.transactionId,
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
      _walletField('Masuk ke dompet'),
    ],
  ];

  Widget _walletField(String label) => ref
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
          decoration: InputDecoration(labelText: label),
          onChanged: (value) => setState(() => _walletId = value),
          validator: (value) => value == null ? 'Pilih dompet' : null,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final noun = _payable ? 'utang' : 'piutang';
    final source = widget.source;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          source != null
              ? 'Bagi ke teman'
              : _isEdit
              ? 'Ubah $noun'
              : 'Catat $noun',
        ),
      ),
      body: Form(
        key: _formKey,
        // Bukan ListView: baris yang ter-scroll keluar layar tetap harus divalidasi.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (source != null) ...[
                FrameCard(
                  child: Row(
                    children: [
                      const Icon(Icons.receipt_long_rounded),
                      const SizedBox(width: Spacing.md),
                      Expanded(
                        child: Text(
                          'Dari pengeluaran ${source.categoryName} '
                          '${formatRupiah(source.amount)}',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Spacing.md),
              ],
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
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _rows.length >= 20 ? null : _addRow,
                        icon: const Icon(Icons.person_add_alt_rounded),
                        label: const Text('Tambah orang'),
                      ),
                    ),
                    if (source != null) ...[
                      const SizedBox(width: Spacing.sm),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _splitEvenly,
                          icon: const Icon(Icons.call_split_rounded),
                          label: const Text('Bagi rata'),
                        ),
                      ),
                    ],
                  ],
                ),
                if (_lend) ...[
                  const SizedBox(height: Spacing.md),
                  _walletField('Dari dompet'),
                ],
                const SizedBox(height: Spacing.md),
                FrameCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Expanded(child: Text('Total piutang')),
                          Text(
                            formatRupiah(_total),
                            style: theme.textTheme.titleSmall,
                          ),
                        ],
                      ),
                      if (source != null)
                        Text(
                          'Bagian kamu ${formatRupiah(source.amount - _total)}',
                          style: theme.textTheme.labelSmall,
                        ),
                      if (_lend)
                        Text(
                          'Dicatat sebagai pengeluaran "Piutang diberikan"',
                          style: theme.textTheme.labelSmall,
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
