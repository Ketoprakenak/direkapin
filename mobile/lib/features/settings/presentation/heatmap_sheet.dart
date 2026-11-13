import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_error.dart';
import '../../../core/format/rupiah_input.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/info_bubble.dart';
import '../../auth/data/auth_models.dart';
import '../providers/settings_providers.dart';

/// Pilihan skala heatmap pengeluaran kalender (CAL-06, D-71).
Future<void> showHeatmapSheet(BuildContext context, HeatmapSetting current) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _HeatmapSheet(current),
    );

class _HeatmapSheet extends ConsumerStatefulWidget {
  const _HeatmapSheet(this.current);

  final HeatmapSetting current;

  @override
  ConsumerState<_HeatmapSheet> createState() => _HeatmapSheetState();
}

class _HeatmapSheetState extends ConsumerState<_HeatmapSheet> {
  late HeatmapMode _mode = widget.current.mode;
  late final _limits = [
    for (final value in widget.current.thresholds)
      TextEditingController(text: rupiahInputText(value)),
  ];
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final controller in _limits) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final values = [for (final c in _limits) parseRupiah(c.text) ?? 0];
    if (_mode == HeatmapMode.fixed) {
      if (values.any((v) => v <= 0)) {
        return setState(() => _error = 'Nominal harus lebih dari 0');
      }
      if (!(values[0] < values[1] && values[1] < values[2])) {
        return setState(() => _error = 'Batas harus naik');
      }
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final navigator = Navigator.of(context);
    try {
      await ref
          .read(settingsApiProvider)
          .updateHeatmap(
            HeatmapSetting(
              mode: _mode,
              // Mode Otomatis tetap menyimpan batas lama supaya tidak hilang.
              thresholds: _mode == HeatmapMode.fixed
                  ? values
                  : widget.current.thresholds,
            ),
          );
      ref.invalidate(meProvider);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fixed = _mode == HeatmapMode.fixed;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          Spacing.lg,
          Spacing.lg,
          Spacing.lg,
          Spacing.lg + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Skala heatmap', style: theme.textTheme.titleLarge),
              const SizedBox(height: Spacing.sm),
              RadioGroup<HeatmapMode>(
                groupValue: _mode,
                onChanged: (mode) {
                  if (mode != null && !_busy) setState(() => _mode = mode);
                },
                child: const Column(
                  children: [
                    RadioListTile(
                      value: HeatmapMode.auto,
                      contentPadding: EdgeInsets.zero,
                      title: Text('Otomatis'),
                      secondary: InfoBubble(
                        label: 'Info Otomatis',
                        message:
                            'Warna dibanding hari paling boros di bulan itu. '
                            'Tanpa pengaturan.',
                      ),
                    ),
                    RadioListTile(
                      value: HeatmapMode.fixed,
                      contentPadding: EdgeInsets.zero,
                      title: Text('Nominal tetap'),
                      secondary: InfoBubble(
                        label: 'Info Nominal tetap',
                        message:
                            'Warna dari 3 batas Rupiah yang kamu atur. '
                            'Sama di semua bulan.',
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  for (final (i, controller) in _limits.indexed) ...[
                    if (i > 0) const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        enabled: fixed && !_busy,
                        keyboardType: TextInputType.number,
                        inputFormatters: const [RupiahInputFormatter()],
                        decoration: InputDecoration(
                          labelText: 'Batas ${i + 1}',
                          prefixText: 'Rp',
                        ),
                      ),
                    ),
                  ],
                ],
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
            ],
          ),
        ),
      ),
    );
  }
}
