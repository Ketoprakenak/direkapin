import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/update/app_update.dart';

/// Banner versi baru. "Nanti" berlaku sampai aplikasi dibuka lagi.
class UpdateBanner extends ConsumerStatefulWidget {
  const UpdateBanner({super.key});

  @override
  ConsumerState<UpdateBanner> createState() => _UpdateBannerState();
}

class _UpdateBannerState extends ConsumerState<UpdateBanner> {
  var _dismissed = false;

  Future<void> _open(String url) async {
    final messenger = ScaffoldMessenger.of(context);
    if (!await openDownloadLink(url)) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Link update nggak bisa dibuka.')),
      );
    }
  }

  /// Ada catatan update: tampilkan dulu, download dari dialog.
  Future<void> _update(AppUpdate update) async {
    if (update.notes.isEmpty) return _open(update.url);
    final download = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Yang baru di ${update.version}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final note in update.notes) ...[
                if (update.notes.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(top: Spacing.sm),
                    child: Text(
                      note.version,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                for (final item in note.items)
                  Padding(
                    padding: const EdgeInsets.only(top: Spacing.xs),
                    child: Text('• $item'),
                  ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Nanti'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Download'),
          ),
        ],
      ),
    );
    if (download == true && mounted) await _open(update.url);
  }

  @override
  Widget build(BuildContext context) {
    final update = ref.watch(availableUpdateProvider).value;
    if (update == null || _dismissed) return const SizedBox.shrink();
    return MaterialBanner(
      content: Text('Versi baru ${update.version} sudah ada.'),
      actions: [
        TextButton(
          onPressed: () => setState(() => _dismissed = true),
          child: const Text('Nanti'),
        ),
        TextButton(
          onPressed: () => _update(update),
          child: const Text('Update'),
        ),
      ],
    );
  }
}
