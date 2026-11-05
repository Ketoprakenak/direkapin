import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
          onPressed: () => _open(update.url),
          child: const Text('Update'),
        ),
      ],
    );
  }
}
