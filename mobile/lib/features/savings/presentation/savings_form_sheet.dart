import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_error.dart';
import '../../../core/api/client_id.dart';
import '../../../core/format/money.dart';
import '../../../core/format/rupiah_input.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/state_views.dart';
import '../../dashboard/providers/dashboard_providers.dart';
import '../../wallet/data/wallet_models.dart';
import '../../wallet/providers/wallet_providers.dart';

enum SavingsAction { create, deposit, target, delete }

/// Form tabungan (FIN-18): buat, setor, ubah target, atau hapus dengan sisa saldo.
Future<void> showSavingsForm(
  BuildContext context,
  SavingsAction action, {
  Wallet? savings,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (_) => _SavingsForm(action, savings),
);

class _SavingsForm extends ConsumerStatefulWidget {
  const _SavingsForm(this.action, this.savings);

  final SavingsAction action;
  final Wallet? savings;

  @override
  ConsumerState<_SavingsForm> createState() => _SavingsFormState();
}

class _SavingsFormState extends ConsumerState<_SavingsForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _amount = TextEditingController();
  late final _target = TextEditingController(
    text: widget.savings?.targetAmount == null
        ? ''
        : rupiahInputText(widget.savings!.targetAmount!),
  );
  final _clientId = newClientId();
  String? _walletId;
  bool _busy = false;
  String? _error;

  SavingsAction get _action => widget.action;
  int get _rest => widget.savings?.balance ?? 0;

  /// Dompet sumber/tujuan hanya perlu kalau ada uang yang pindah.
  bool get _needsWallet => switch (_action) {
    SavingsAction.create => (parseRupiah(_amount.text) ?? 0) > 0,
    SavingsAction.deposit => true,
    SavingsAction.target => false,
    SavingsAction.delete => _rest != 0,
  };

  @override
  void initState() {
    super.initState();
    _amount.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    _target.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final api = ref.read(walletApiProvider);
    final id = widget.savings?.id;
    final amount = parseRupiah(_amount.text) ?? 0;
    final target = parseRupiah(_target.text);
    final navigator = Navigator.of(context);
    try {
      await switch (_action) {
        SavingsAction.create => api.createSavings({
          'name': _name.text.trim(),
          'targetAmount': ?target,
          'initialAmount': amount,
          if (amount > 0) 'fromWalletId': _walletId,
        }),
        SavingsAction.deposit => api.createTransfer({
          'fromWalletId': _walletId,
          'toWalletId': id,
          'amount': amount,
          'occurredAt': DateTime.now().toUtc().toIso8601String(),
          'clientId': _clientId,
        }),
        SavingsAction.target => api.updateSavingsTarget(id!, target),
        SavingsAction.delete => api.deleteSavings(
          id!,
          toWalletId: _needsWallet ? _walletId : null,
        ),
      };
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

  String? _positive(String? value) {
    final amount = parseRupiah(value ?? '');
    return amount == null || amount <= 0 ? 'Nominal harus lebih dari 0' : null;
  }

  Widget _amountField(
    TextEditingController controller,
    String label, {
    FormFieldValidator<String>? validator,
  }) => TextFormField(
    controller: controller,
    keyboardType: TextInputType.number,
    inputFormatters: const [RupiahInputFormatter()],
    decoration: InputDecoration(labelText: label, prefixText: 'Rp'),
    validator: validator,
  );

  Widget _walletField() {
    final wallets = ref.watch(walletsProvider());
    return wallets.when(
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
        decoration: InputDecoration(
          labelText: _action == SavingsAction.delete
              ? 'Sisa dikembalikan ke'
              : 'Dari dompet',
        ),
        onChanged: (value) => setState(() => _walletId = value),
        validator: (value) => value == null ? 'Pilih dompet' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = widget.savings?.name ?? '';
    final (title, button) = switch (_action) {
      SavingsAction.create => ('Buat tabungan', 'Simpan'),
      SavingsAction.deposit => ('Setor ke $name', 'Setor'),
      SavingsAction.target => ('Target $name', 'Simpan'),
      SavingsAction.delete => ('Hapus tabungan $name?', 'Hapus'),
    };
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
                Text(title, style: theme.textTheme.titleLarge),
                const SizedBox(height: Spacing.lg),
                if (_action == SavingsAction.create) ...[
                  TextFormField(
                    controller: _name,
                    maxLength: 30,
                    decoration: const InputDecoration(labelText: 'Nama'),
                    validator: (value) => (value ?? '').trim().isEmpty
                        ? 'Nama wajib diisi'
                        : null,
                  ),
                  _amountField(_target, 'Target (opsional)'),
                  const SizedBox(height: Spacing.md),
                  _amountField(_amount, 'Setoran awal (opsional)'),
                ],
                if (_action == SavingsAction.deposit)
                  _amountField(_amount, 'Nominal', validator: _positive),
                if (_action == SavingsAction.target) ...[
                  _amountField(_target, 'Target'),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    'Kosongkan untuk tanpa target.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
                if (_action == SavingsAction.delete)
                  Text(
                    _rest == 0
                        ? 'Riwayat pengeluarannya tetap ada di laporan.'
                        : 'Sisa ${formatRupiah(_rest)} dipindah ke dompet '
                              'pilihan. Riwayat pengeluarannya tetap ada '
                              'di laporan.',
                    style: theme.textTheme.bodyMedium,
                  ),
                if (_needsWallet) ...[
                  const SizedBox(height: Spacing.md),
                  _walletField(),
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
                const SizedBox(height: Spacing.lg),
                FilledButton(
                  style: _action == SavingsAction.delete
                      ? FilledButton.styleFrom(
                          backgroundColor: theme.colorScheme.error,
                          foregroundColor: theme.colorScheme.onError,
                        )
                      : null,
                  onPressed: _busy ? null : _save,
                  child: Text(button),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
