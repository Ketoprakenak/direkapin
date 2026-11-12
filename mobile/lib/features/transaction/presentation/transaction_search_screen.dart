import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/dates.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/state_views.dart';
import '../../category/data/category_models.dart';
import '../../category/providers/category_providers.dart';
import '../../wallet/providers/wallet_providers.dart';
import '../providers/transaction_providers.dart';
import 'wallet_transactions_screen.dart';

/// Cari & filter transaksi (FIN-11): kata kunci catatan, jenis, kategori, dompet, tanggal.
class TransactionSearchScreen extends ConsumerStatefulWidget {
  const TransactionSearchScreen({super.key});

  @override
  ConsumerState<TransactionSearchScreen> createState() =>
      _TransactionSearchScreenState();
}

class _TransactionSearchScreenState
    extends ConsumerState<TransactionSearchScreen> {
  final _query = TextEditingController();
  String? _submitted;
  TxType? _type;
  String? _categoryId;
  String? _walletId;
  DateTimeRange? _range;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: _range,
    );
    if (picked != null) setState(() => _range = picked);
  }

  @override
  Widget build(BuildContext context) {
    final range = _range;
    final provider = searchTransactionsProvider(
      query: _submitted,
      walletId: _walletId,
      categoryId: _categoryId,
      type: _type?.apiValue,
      from: range == null ? null : dateKey(range.start),
      to: range == null ? null : dateKey(range.end),
    );
    final wallets = ref.watch(walletsProvider(includeArchived: true)).value;
    final type = _type;
    final categories = type == null
        ? null
        : ref.watch(categoriesProvider(type: type, includeHidden: true)).value;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _query,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Cari di catatan',
            border: InputBorder.none,
          ),
          onSubmitted: (value) => setState(() {
            final text = value.trim();
            _submitted = text.isEmpty ? null : text;
          }),
        ),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
            child: Row(
              children: [
                SegmentedButton<TxType?>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: null, label: Text('Semua')),
                    ButtonSegment(value: TxType.expense, label: Text('Keluar')),
                    ButtonSegment(value: TxType.income, label: Text('Masuk')),
                  ],
                  selected: {_type},
                  onSelectionChanged: (selected) => setState(() {
                    _type = selected.first;
                    _categoryId = null;
                  }),
                ),
                const SizedBox(width: Spacing.sm),
                if (categories != null)
                  DropdownButton<String?>(
                    value: _categoryId,
                    hint: const Text('Semua kategori'),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Semua kategori'),
                      ),
                      for (final category in categories)
                        DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        ),
                    ],
                    onChanged: (value) => setState(() => _categoryId = value),
                  ),
                const SizedBox(width: Spacing.sm),
                if (wallets != null)
                  DropdownButton<String?>(
                    value: _walletId,
                    hint: const Text('Semua dompet'),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Semua dompet'),
                      ),
                      for (final wallet in wallets)
                        DropdownMenuItem(
                          value: wallet.id,
                          child: Text(wallet.name),
                        ),
                    ],
                    onChanged: (value) => setState(() => _walletId = value),
                  ),
                const SizedBox(width: Spacing.sm),
                InputChip(
                  avatar: const Icon(Icons.date_range_rounded),
                  label: Text(
                    range == null
                        ? 'Semua tanggal'
                        : '${formatShortDate(range.start)} – ${formatShortDate(range.end)}',
                  ),
                  onPressed: _pickRange,
                  onDeleted: range == null
                      ? null
                      : () => setState(() => _range = null),
                ),
              ],
            ),
          ),
          Expanded(
            child: ref
                .watch(provider)
                .when(
                  loading: () => const ListSkeleton(),
                  error: (error, _) => ErrorState(
                    error: error,
                    onRetry: () => ref.invalidate(provider),
                  ),
                  data: (items) => items.isEmpty
                      ? const Center(
                          child: EmptyState(
                            message: 'Tidak ada transaksi yang cocok.',
                          ),
                        )
                      : ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) =>
                              TransactionTile(items[index]),
                        ),
                ),
          ),
        ],
      ),
    );
  }
}
