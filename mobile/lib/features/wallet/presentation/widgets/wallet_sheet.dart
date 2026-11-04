import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_error.dart';
import '../../../../core/format/rupiah_input.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/money_widgets.dart';
import '../../../dashboard/providers/dashboard_providers.dart';
import '../../data/wallet_models.dart';
import '../../providers/wallet_providers.dart';

Future<void> showWalletSheet(BuildContext context, {Wallet? wallet}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _WalletSheet(wallet),
    );

class _WalletSheet extends ConsumerStatefulWidget {
  const _WalletSheet(this.wallet);

  final Wallet? wallet;

  @override
  ConsumerState<_WalletSheet> createState() => _WalletSheetState();
}

class _WalletSheetState extends ConsumerState<_WalletSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.wallet?.name);
  late final _balance = TextEditingController(
    text: widget.wallet == null
        ? ''
        : const RupiahInputFormatter(allowNegative: true)
              .formatEditUpdate(
                TextEditingValue.empty,
                TextEditingValue(text: '${widget.wallet!.initialBalance}'),
              )
              .text,
  );
  late WalletType _type = widget.wallet?.type ?? WalletType.cash;
  late String _color = widget.wallet?.color ?? colorToHex(categoryPalette[4]);
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _balance.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final navigator = Navigator.of(context);
    try {
      await action();
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

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final api = ref.read(walletApiProvider);
    final data = {
      'name': _name.text.trim(),
      'type': _type.apiValue,
      'initialBalance': parseRupiah(_balance.text) ?? 0,
      'icon': _type.icon,
      'color': _color,
    };
    final wallet = widget.wallet;
    _run(() => wallet == null ? api.create(data) : api.update(wallet.id, data));
  }

  Future<void> _delete() async {
    final wallet = widget.wallet!;
    final confirmed = await confirmDialog(
      context,
      message: 'Hapus dompet ${wallet.name}?',
      confirmLabel: 'Hapus',
    );
    if (confirmed) _run(() => ref.read(walletApiProvider).delete(wallet.id));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wallet = widget.wallet;
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
                  wallet == null ? 'Tambah dompet' : 'Ubah dompet',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: Spacing.lg),
                TextFormField(
                  controller: _name,
                  maxLength: 30,
                  decoration: const InputDecoration(labelText: 'Nama dompet'),
                  validator: (value) =>
                      (value ?? '').trim().isEmpty ? 'Nama wajib diisi' : null,
                ),
                SegmentedButton<WalletType>(
                  showSelectedIcon: false,
                  segments: [
                    for (final type in WalletType.values)
                      ButtonSegment(value: type, label: Text(type.label)),
                  ],
                  selected: {_type},
                  onSelectionChanged: (selected) =>
                      setState(() => _type = selected.first),
                ),
                const SizedBox(height: Spacing.md),
                TextFormField(
                  controller: _balance,
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: true,
                  ),
                  inputFormatters: const [
                    RupiahInputFormatter(allowNegative: true),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Saldo awal',
                    prefixText: 'Rp',
                  ),
                ),
                const SizedBox(height: Spacing.md),
                ColorPicker(
                  selected: _color,
                  onChanged: (color) => setState(() => _color = color),
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
                  onPressed: _busy ? null : _save,
                  child: const Text('Simpan'),
                ),
                if (wallet != null) ...[
                  const SizedBox(height: Spacing.sm),
                  OutlinedButton(
                    onPressed: _busy
                        ? null
                        : () => _run(
                            () => ref.read(walletApiProvider).update(
                              wallet.id,
                              {'isArchived': !wallet.isArchived},
                            ),
                          ),
                    child: Text(
                      wallet.isArchived ? 'Aktifkan lagi' : 'Arsipkan',
                    ),
                  ),
                  TextButton(
                    onPressed: _busy ? null : _delete,
                    child: const Text('Hapus'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
