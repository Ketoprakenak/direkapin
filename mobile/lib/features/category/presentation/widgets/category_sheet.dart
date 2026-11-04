import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_error.dart';
import '../../../../core/icons.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/money_widgets.dart';
import '../../../dashboard/providers/dashboard_providers.dart';
import '../../data/category_models.dart';
import '../../providers/category_providers.dart';

Future<void> showCategorySheet(
  BuildContext context, {
  required TxType type,
  Category? category,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (_) => _CategorySheet(type, category),
);

class _CategorySheet extends ConsumerStatefulWidget {
  const _CategorySheet(this.type, this.category);

  final TxType type;
  final Category? category;

  @override
  ConsumerState<_CategorySheet> createState() => _CategorySheetState();
}

class _CategorySheetState extends ConsumerState<_CategorySheet> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.category?.name);
  late String _icon = widget.category?.icon ?? categoryIconNames.first;
  late String _color =
      widget.category?.color ?? colorToHex(categoryPalette.first);
  late bool _hidden = widget.category?.isHidden ?? false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
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
      ref.invalidate(categoriesProvider);
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
    final api = ref.read(categoryApiProvider);
    final category = widget.category;
    final common = {'icon': _icon, 'color': _color};
    _run(() {
      if (category == null) {
        return api.create({
          ...common,
          'name': _name.text.trim(),
          'type': widget.type.apiValue,
        });
      }
      return api.update(category.id, {
        ...common,
        'isHidden': _hidden,
        if (!category.isDefault) 'name': _name.text.trim(),
      });
    });
  }

  Future<void> _delete() async {
    final category = widget.category!;
    final confirmed = await confirmDialog(
      context,
      message:
          'Hapus kategori ${category.name}? Transaksinya pindah ke "Lainnya".',
      confirmLabel: 'Hapus',
    );
    if (confirmed) {
      _run(() => ref.read(categoryApiProvider).delete(category.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = widget.category;
    final isDefault = category?.isDefault ?? false;
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
                  category == null ? 'Tambah kategori' : 'Ubah kategori',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: Spacing.lg),
                TextFormField(
                  controller: _name,
                  enabled: !isDefault,
                  maxLength: 30,
                  decoration: const InputDecoration(labelText: 'Nama kategori'),
                  validator: (value) =>
                      (value ?? '').trim().isEmpty ? 'Nama wajib diisi' : null,
                ),
                Wrap(
                  spacing: Spacing.xs,
                  children: [
                    for (final name in categoryIconNames)
                      IconButton(
                        tooltip: name,
                        isSelected: name == _icon,
                        color: name == _icon ? theme.colorScheme.primary : null,
                        icon: Icon(iconFor(name)),
                        onPressed: () => setState(() => _icon = name),
                      ),
                  ],
                ),
                const SizedBox(height: Spacing.sm),
                ColorPicker(
                  selected: _color,
                  onChanged: (color) => setState(() => _color = color),
                ),
                if (category != null)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Sembunyikan dari pilihan'),
                    value: _hidden,
                    onChanged: (value) => setState(() => _hidden = value),
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
                if (category != null && !isDefault)
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
