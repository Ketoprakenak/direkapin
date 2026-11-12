import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_error.dart';
import '../../../core/format/dates.dart';
import '../../../core/format/money.dart';
import '../../../core/format/rupiah_input.dart';
import '../../../core/icons.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/frame.dart';
import '../../../core/widgets/money_widgets.dart';
import '../../../core/widgets/state_views.dart';
import '../../category/data/category_models.dart';
import '../../category/providers/category_providers.dart';
import '../data/budget_models.dart';
import '../providers/budget_providers.dart';

/// Kategori biaya admin transfer (D-56) tidak bisa dipilih untuk budget (D-60).
const _feeCategoryName = 'Biaya Admin';

/// Kelola budget (FIN-12), dibuka dari bagian Budget di Laporan Bulanan.
/// [initialMonth] = `YYYY-MM`; bulan bisa digeser di layar ini.
class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key, required this.initialMonth});

  final String initialMonth;

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  // Tanggal 1: geser bulan dari tanggal 31 bisa melompati bulan pendek.
  late DateTime _month = DateTime.parse('${widget.initialMonth}-01');

  void _shift(int delta) =>
      setState(() => _month = DateTime(_month.year, _month.month + delta));

  @override
  Widget build(BuildContext context) {
    final month = monthKey(_month);
    final provider = budgetsProvider(month);
    return Scaffold(
      appBar: AppBar(title: const Text('Budget')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Tambah budget',
        onPressed: () => _showBudgetSheet(context, month: month),
        child: const Icon(Icons.add_rounded),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Bulan sebelumnya',
                  icon: const Icon(Icons.chevron_left_rounded),
                  onPressed: () => _shift(-1),
                ),
                Expanded(
                  child: Text(
                    formatMonth(_month),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Bulan berikutnya',
                  icon: const Icon(Icons.chevron_right_rounded),
                  onPressed: () => _shift(1),
                ),
              ],
            ),
          ),
          Expanded(child: _body(month, provider)),
        ],
      ),
    );
  }

  Widget _body(String month, BudgetsProvider provider) {
    return ref
        .watch(provider)
        .when(
          loading: () => const ListSkeleton(),
          error: (error, _) =>
              ErrorState(error: error, onRetry: () => ref.invalidate(provider)),
          data: (budgets) => budgets.isEmpty
              ? const Center(
                  child: EmptyState(
                    message: 'Belum ada budget. Tambah budget untuk kategori yang mau dijaga.',
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => ref.refresh(provider.future),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      Spacing.lg,
                      Spacing.lg,
                      Spacing.lg,
                      Spacing.xxl * 2,
                    ),
                    itemCount: budgets.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: Spacing.md),
                    itemBuilder: (context, index) => BudgetCard(
                      budgets[index],
                      onTap: () => _showBudgetSheet(
                        context,
                        month: month,
                        budget: budgets[index],
                      ),
                    ),
                  ),
                ),
        );
  }
}

/// Kartu satu budget: sisa, persen, dan ikon peringatan 80%/100%.
class BudgetCard extends StatelessWidget {
  const BudgetCard(this.budget, {super.key, required this.onTap});

  final Budget budget;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final level = budgetLevel(budget.ratio);
    final color = switch (level) {
      BudgetLevel.normal => colors.ink,
      BudgetLevel.warning => colors.important,
      BudgetLevel.over => colors.expense,
    };
    final percent = (budget.ratio * 100).floor();
    return FrameCard(
      onTap: onTap,
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  budget.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              if (level != BudgetLevel.normal) ...[
                Icon(
                  Icons.warning_rounded,
                  color: color,
                  semanticLabel: level == BudgetLevel.over
                      ? 'Budget terlewati'
                      : 'Budget hampir habis',
                ),
                const SizedBox(width: Spacing.xs),
              ],
              Text(
                '$percent%',
                style: theme.textTheme.titleSmall?.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          // Terisi dari 0 saat tampil; sisa bar = warna netral sesuai tema.
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: budget.ratio.clamp(0, 1)),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              color: color,
              backgroundColor: theme.colorScheme.onSurface.withValues(
                alpha: 0.1,
              ),
              minHeight: Spacing.sm,
              borderRadius: BorderRadius.circular(Radii.sm),
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            level == BudgetLevel.over
                ? 'Lewat ${formatRupiah(-budget.remaining)}'
                : 'Sisa budget bulan ini: ${formatRupiah(budget.remaining)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: level == BudgetLevel.over ? color : null,
            ),
          ),
          Text(
            '${formatRupiah(budget.spent)} dari '
            '${formatRupiah(budget.limitAmount)} · '
            '${budget.categories.map((c) => c.name).join(', ')}',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

Future<void> _showBudgetSheet(
  BuildContext context, {
  required String month,
  Budget? budget,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (_) => _BudgetSheet(month: month, budget: budget),
);

class _BudgetSheet extends ConsumerStatefulWidget {
  const _BudgetSheet({required this.month, this.budget});

  final String month;
  final Budget? budget;

  @override
  ConsumerState<_BudgetSheet> createState() => _BudgetSheetState();
}

class _BudgetSheetState extends ConsumerState<_BudgetSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.budget?.name);
  late final _limit = TextEditingController(
    text: widget.budget == null
        ? null
        : formatRupiah(widget.budget!.limitAmount).replaceFirst('Rp', ''),
  );
  late final Set<String> _categoryIds = {
    ...?widget.budget?.categories.map((c) => c.id),
  };
  bool _busy = false;
  String? _error;

  String get _monthName => formatMonth(DateTime.parse('${widget.month}-01'));

  @override
  void dispose() {
    _name.dispose();
    _limit.dispose();
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
      ref.invalidate(budgetsProvider);
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
    final formValid = _formKey.currentState!.validate();
    if (_categoryIds.isEmpty) {
      setState(() => _error = 'Pilih minimal satu kategori');
    }
    if (!formValid || _categoryIds.isEmpty) return;
    final api = ref.read(budgetApiProvider);
    final data = {
      'name': _name.text.trim(),
      'limitAmount': parseRupiah(_limit.text),
      'categoryIds': _categoryIds.toList(),
      'month': widget.month,
    };
    final budget = widget.budget;
    _run(() => budget == null ? api.create(data) : api.update(budget.id, data));
  }

  Future<void> _delete() async {
    final budget = widget.budget!;
    final confirmed = await confirmDialog(
      context,
      message:
          'Hapus budget ${budget.name} mulai $_monthName? '
          'Bulan-bulan sebelumnya tetap tercatat.',
      confirmLabel: 'Hapus',
    );
    if (confirmed) {
      _run(() => ref.read(budgetApiProvider).delete(budget.id, widget.month));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final budget = widget.budget;
    final categories = ref.watch(
      categoriesProvider(type: TxType.expense, includeHidden: true),
    );
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
                  budget == null ? 'Tambah budget' : 'Ubah budget',
                  style: theme.textTheme.titleLarge,
                ),
                Text(
                  'Berlaku mulai $_monthName dan bulan-bulan berikutnya.',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: Spacing.lg),
                TextFormField(
                  controller: _name,
                  maxLength: 40,
                  decoration: const InputDecoration(
                    labelText: 'Nama budget',
                    hintText: 'Contoh: Makan & Transport',
                  ),
                  validator: (value) =>
                      (value ?? '').trim().isEmpty ? 'Nama wajib diisi' : null,
                ),
                TextFormField(
                  controller: _limit,
                  keyboardType: TextInputType.number,
                  inputFormatters: const [RupiahInputFormatter()],
                  decoration: const InputDecoration(
                    labelText: 'Batas per bulan',
                    prefixText: 'Rp',
                  ),
                  validator: (value) {
                    final amount = parseRupiah(value ?? '');
                    return amount == null || amount <= 0
                        ? 'Nominal harus lebih dari 0'
                        : null;
                  },
                ),
                const SizedBox(height: Spacing.lg),
                Text('Kategori', style: theme.textTheme.titleSmall),
                const SizedBox(height: Spacing.sm),
                categories.when(
                  loading: () => const Skeleton(height: Spacing.xxl * 2),
                  error: (error, _) => ErrorState(
                    error: error,
                    onRetry: () => ref.invalidate(categoriesProvider),
                  ),
                  data: (items) => Wrap(
                    spacing: Spacing.sm,
                    runSpacing: Spacing.sm,
                    children: [
                      for (final category in items)
                        if (category.name != _feeCategoryName &&
                            (!category.isHidden ||
                                _categoryIds.contains(category.id)))
                          FilterChip(
                            avatar: Icon(
                              iconFor(category.icon),
                              color: colorFromHex(category.color),
                            ),
                            label: Text(category.name),
                            selected: _categoryIds.contains(category.id),
                            onSelected: (selected) => setState(() {
                              selected
                                  ? _categoryIds.add(category.id)
                                  : _categoryIds.remove(category.id);
                            }),
                          ),
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
                const SizedBox(height: Spacing.md),
                FilledButton(
                  onPressed: _busy ? null : _save,
                  child: const Text('Simpan'),
                ),
                if (budget != null)
                  TextButton(
                    onPressed: _busy ? null : _delete,
                    child: const Text('Hapus'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
