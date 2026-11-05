import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/money_widgets.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../category/data/category_models.dart';
import '../../../category/providers/category_providers.dart';

/// Pemilih kategori: grid 4 kolom, yang terpilih berbingkai primary.
class CategoryGrid extends ConsumerWidget {
  const CategoryGrid({
    super.key,
    required this.type,
    required this.selectedId,
    required this.onSelected,
    this.keepId,
    this.errorText,
  });

  final TxType type;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  /// Kategori tersembunyi yang tetap ditampilkan karena sedang dipakai (D-34).
  final String? keepId;
  final String? errorText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return ref
        .watch(categoriesProvider(type: type, includeHidden: keepId != null))
        .when(
          loading: () => const Skeleton(height: Spacing.xxl * 4),
          error: (error, _) => ErrorState(
            error: error,
            onRetry: () => ref.invalidate(categoriesProvider),
          ),
          data: (categories) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: Spacing.xs,
                crossAxisSpacing: Spacing.xs,
                childAspectRatio: 0.85,
                children: [
                  for (final category in categories)
                    if (!category.isHidden || category.id == keepId)
                      InkWell(
                        borderRadius: BorderRadius.circular(Radii.md),
                        onTap: () => onSelected(category.id),
                        child: Container(
                          padding: const EdgeInsets.all(Spacing.xs),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Radii.md),
                            border: Border.all(
                              width: 2,
                              color: category.id == selectedId
                                  ? theme.colorScheme.primary
                                  : Colors.transparent,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconCircle(
                                icon: category.icon,
                                color: category.color,
                              ),
                              const SizedBox(height: Spacing.xs),
                              Text(
                                category.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.labelSmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                ],
              ),
              if (errorText != null)
                Text(
                  errorText!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
            ],
          ),
        );
  }
}
