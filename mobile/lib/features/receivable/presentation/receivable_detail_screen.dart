import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_error.dart';
import '../../../core/api/client_id.dart';
import '../../../core/format/dates.dart';
import '../../../core/format/money.dart';
import '../../../core/format/rupiah_input.dart';
import '../../../core/router/router.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/frame.dart';
import '../../../core/widgets/money_widgets.dart';
import '../../../core/widgets/state_views.dart';
import '../../category/data/category_models.dart';
import '../../category/providers/category_providers.dart';
import '../../dashboard/providers/dashboard_providers.dart';
import '../../wallet/providers/wallet_providers.dart';
import '../data/receivable_models.dart';
import '../providers/receivable_providers.dart';
import 'receivables_screen.dart';

enum _Menu { edit, delete }

/// Detail talangan/utang: sisa tiap orang, tombol Bayar, riwayat cicilan (FIN-19, FIN-20).
class ReceivableDetailScreen extends ConsumerWidget {
  const ReceivableDetailScreen({super.key, required this.receivableId});

  final String receivableId;

  Future<void> _onMenu(
    BuildContext context,
    WidgetRef ref,
    Receivable r,
    _Menu menu,
  ) async {
    if (menu == _Menu.edit) {
      context.pushNamed(Routes.receivableForm, extra: r);
      return;
    }
    final confirmed = await confirmDialog(
      context,
      message: r.direction.isPayable
          ? 'Hapus utang ${r.title}? Pinjaman dan cicilan yang sudah '
                'tercatat tetap ada di dompet.'
          : 'Hapus piutang ${r.title}? Pembayaran yang sudah diterima tetap '
                'tercatat di dompet.',
      confirmLabel: 'Hapus',
    );
    if (!confirmed || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    try {
      await ref.read(receivableApiProvider).delete(r.id);
      refreshMoney(ref);
      router.pop();
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Arah tidak ada di URL: cari di daftar piutang lalu utang.
    final receivables = receivablesProvider(all: true);
    final payables = receivablesProvider(
      all: true,
      direction: ReceivableDirection.payable,
    );
    final state = ref.watch(receivables);
    final other = ref.watch(payables);
    final receivable = [
      ...?state.value?.items,
      ...?other.value?.items,
    ].where((r) => r.id == receivableId).firstOrNull;
    return Scaffold(
      appBar: AppBar(
        title: Text(receivable?.title ?? 'Utang & Piutang'),
        actions: [
          if (receivable != null)
            PopupMenuButton<_Menu>(
              tooltip: 'Menu',
              onSelected: (menu) => _onMenu(context, ref, receivable, menu),
              itemBuilder: (_) => const [
                PopupMenuItem(value: _Menu.edit, child: Text('Ubah')),
                PopupMenuItem(value: _Menu.delete, child: Text('Hapus')),
              ],
            ),
        ],
      ),
      // Tampilkan begitu ketemu di salah satu daftar; refresh tidak memunculkan skeleton.
      body: switch ((receivable, state, other)) {
        (final r?, _, _) => _Detail(r),
        (_, AsyncValue(hasValue: false, hasError: false), _) ||
        (
          _,
          _,
          AsyncValue(hasValue: false, hasError: false),
        ) => const ListSkeleton(),
        (_, AsyncValue(:final error?), _) ||
        (_, _, AsyncValue(:final error?)) => ErrorState(
          error: error,
          onRetry: () => ref
            ..invalidate(receivables)
            ..invalidate(payables),
        ),
        _ => const Center(
          child: EmptyState(message: 'Catatan ini sudah dihapus.'),
        ),
      },
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail(this.receivable);

  final Receivable receivable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = receivable;
    final payable = r.direction.isPayable;
    return ListView(
      padding: const EdgeInsets.all(Spacing.lg),
      children: [
        FrameCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sisa', style: theme.textTheme.bodyMedium),
                        AmountText(
                          payable ? r.remaining : -r.remaining,
                          large: true,
                        ),
                      ],
                    ),
                  ),
                  if (r.remaining == 0) const PaidStamp(large: true),
                ],
              ),
              Text(
                '${formatLongDate(DateTime.parse(r.date))} · '
                'total ${formatRupiah(r.total)}',
                style: theme.textTheme.labelSmall,
              ),
              if (r.loan case final loan?)
                Text(
                  'Pinjaman masuk ke ${loan.wallet.name}',
                  style: theme.textTheme.labelSmall,
                ),
              if (r.note != null) ...[
                const SizedBox(height: Spacing.xs),
                Text(r.note!, style: theme.textTheme.bodyMedium),
              ],
            ],
          ),
        ),
        const SizedBox(height: Spacing.md),
        for (final debtor in r.debtors)
          Padding(
            padding: const EdgeInsets.only(bottom: Spacing.sm),
            child: _DebtorCard(debtor, payable: payable),
          ),
      ],
    );
  }
}

class _DebtorCard extends StatelessWidget {
  const _DebtorCard(this.debtor, {required this.payable});

  final Debtor debtor;
  final bool payable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final caption = theme.textTheme.labelSmall;
    final d = debtor;
    return FrameCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  d.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: 'Ubah ${d.name}',
                visualDensity: VisualDensity.compact,
                onPressed: () =>
                    _showDebtorSheet(context, d, pay: false, payable: payable),
                icon: const Icon(Icons.edit_rounded),
              ),
              if (d.remaining > 0)
                FilledButton(
                  // Tema membuat tombol selebar layar; di dalam Row harus diberi ukuran.
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(Spacing.xxl, Spacing.xxl),
                  ),
                  onPressed: () =>
                      _showDebtorSheet(context, d, pay: true, payable: payable),
                  child: const Text('Bayar'),
                )
              else
                const PaidLabel(),
            ],
          ),
          PaidBar(paid: d.paid, total: d.amount),
          Text(
            d.remaining == 0
                ? '${formatRupiah(d.paid)} dari ${formatRupiah(d.amount)}'
                : '${formatRupiah(d.paid)} dari ${formatRupiah(d.amount)} · '
                      'Sisa ${formatRupiah(d.remaining)}',
            style: caption,
          ),
          for (final p in d.payments)
            Padding(
              padding: const EdgeInsets.only(top: Spacing.xs),
              child: Row(
                children: [
                  // Ikon ikut arah uang: piutang masuk, cicilan utang keluar.
                  Icon(
                    payable
                        ? Icons.north_east_rounded
                        : Icons.south_west_rounded,
                    size: Spacing.lg,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Expanded(
                    child: Text(
                      '${formatShortDate(p.occurredAt.toLocal())} · '
                      '${formatRupiah(p.amount)} '
                      '${payable ? 'dari' : 'ke'} ${p.wallet.name}',
                      style: caption,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

Future<void> _showDebtorSheet(
  BuildContext context,
  Debtor debtor, {
  required bool pay,
  required bool payable,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (_) => _DebtorSheet(debtor, pay: pay, payable: payable),
);

/// [pay] true = catat cicilan; false = ubah nama/nominal orang.
/// [payable] = utang: cicilan keluar dari dompet sebagai pengeluaran berkategori.
class _DebtorSheet extends ConsumerStatefulWidget {
  const _DebtorSheet(this.debtor, {required this.pay, required this.payable});

  final Debtor debtor;
  final bool pay;
  final bool payable;

  @override
  ConsumerState<_DebtorSheet> createState() => _DebtorSheetState();
}

class _DebtorSheetState extends ConsumerState<_DebtorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.debtor.name);
  late final _amount = TextEditingController(
    text: rupiahInputText(
      widget.pay ? widget.debtor.remaining : widget.debtor.amount,
    ),
  );
  final _clientId = newClientId();
  String? _walletId;
  String? _categoryId;
  bool _busy = false;
  String? _error;

  Debtor get _debtor => widget.debtor;

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  String? _validateAmount(String? value) {
    final amount = parseRupiah(value ?? '') ?? 0;
    if (amount <= 0) return 'Nominal harus lebih dari 0';
    if (widget.pay && amount > _debtor.remaining) {
      return 'Melebihi sisa utang ${formatRupiah(_debtor.remaining)}';
    }
    if (!widget.pay && amount < _debtor.paid) {
      return 'Nominal tidak boleh kurang dari yang sudah dibayar';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final api = ref.read(receivableApiProvider);
    final amount = parseRupiah(_amount.text);
    final navigator = Navigator.of(context);
    try {
      if (widget.pay) {
        await api.pay(_debtor.id, {
          'amount': amount,
          'walletId': _walletId,
          if (widget.payable) 'categoryId': _categoryId,
          'occurredAt': DateTime.now().toUtc().toIso8601String(),
          'clientId': _clientId,
        });
      } else {
        await api.updateDebtor(_debtor.id, {
          'name': _name.text.trim(),
          'amount': amount,
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

  Widget _categoryField() {
    final provider = categoriesProvider(type: TxType.expense);
    return ref
        .watch(provider)
        .when(
          loading: () => const LinearProgressIndicator(),
          error: (error, _) =>
              ErrorState(error: error, onRetry: () => ref.invalidate(provider)),
          data: (items) => DropdownButtonFormField<String>(
            initialValue: _categoryId,
            isExpanded: true,
            items: [
              for (final category in items)
                DropdownMenuItem(
                  value: category.id,
                  child: Text(category.name, overflow: TextOverflow.ellipsis),
                ),
            ],
            decoration: const InputDecoration(labelText: 'Kategori'),
            onChanged: (value) => setState(() => _categoryId = value),
            validator: (value) => value == null ? 'Pilih kategori' : null,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wallets = ref.watch(walletsProvider(includeSavings: true));
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
                  !widget.pay
                      ? 'Ubah ${_debtor.name}'
                      : widget.payable
                      ? 'Bayar utang ke ${_debtor.name}'
                      : '${_debtor.name} bayar',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: Spacing.lg),
                if (!widget.pay)
                  TextFormField(
                    controller: _name,
                    maxLength: 30,
                    decoration: const InputDecoration(labelText: 'Nama'),
                    validator: (value) => (value ?? '').trim().isEmpty
                        ? 'Nama wajib diisi'
                        : null,
                  ),
                TextFormField(
                  controller: _amount,
                  keyboardType: TextInputType.number,
                  inputFormatters: const [RupiahInputFormatter()],
                  decoration: InputDecoration(
                    labelText: 'Nominal',
                    prefixText: 'Rp',
                    helperText: widget.pay
                        ? 'Sisa ${formatRupiah(_debtor.remaining)}'
                        : 'Sudah dibayar ${formatRupiah(_debtor.paid)}',
                  ),
                  validator: _validateAmount,
                ),
                if (widget.pay) ...[
                  const SizedBox(height: Spacing.md),
                  wallets.when(
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
                        labelText: widget.payable
                            ? 'Dari dompet'
                            : 'Masuk ke dompet',
                      ),
                      onChanged: (value) => setState(() => _walletId = value),
                      validator: (value) =>
                          value == null ? 'Pilih dompet' : null,
                    ),
                  ),
                  if (widget.payable) ...[
                    const SizedBox(height: Spacing.md),
                    _categoryField(),
                  ],
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
                  onPressed: _busy ? null : _save,
                  child: const Text('Simpan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
