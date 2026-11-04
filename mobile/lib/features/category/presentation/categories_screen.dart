import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/money_widgets.dart';
import '../../../core/widgets/state_views.dart';
import '../data/category_models.dart';
import '../providers/category_providers.dart';
import 'widgets/category_sheet.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Kategori'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Keluar'),
                Tab(text: 'Masuk'),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            tooltip: 'Tambah kategori',
            onPressed: () => showCategorySheet(
              context,
              type: DefaultTabController.of(context).index == 0
                  ? TxType.expense
                  : TxType.income,
            ),
            child: const Icon(Icons.add_rounded),
          ),
          body: const TabBarView(
            children: [
              _CategoryList(TxType.expense),
              _CategoryList(TxType.income),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryList extends ConsumerWidget {
  const _CategoryList(this.type);

  final TxType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = categoriesProvider(type: type, includeHidden: true);
    return ref.watch(provider).when(
      loading: () => const ListSkeleton(),
      error: (error, _) => ErrorState(
        error: error,
        onRetry: () => ref.invalidate(provider),
      ),
      data: (items) => ListView.builder(
        padding: const EdgeInsets.only(bottom: Spacing.xxl * 2),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final category = items[index];
          return ListTile(
            leading: IconCircle(icon: category.icon, color: category.color),
            title: Text(category.name),
            subtitle: category.isHidden
                ? const Text('Disembunyikan')
                : (category.isDefault ? const Text('Bawaan') : null),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => showCategorySheet(context, type: type, category: category),
          );
        },
      ),
    );
  }
}
