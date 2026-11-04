import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/session_provider.dart';
import '../../../core/theme/tokens.dart';
import '../../auth/providers/auth_providers.dart';

/// Baru berisi logout; isi lengkap S-14 menyusul di Slice 8.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          OutlinedButton(
            onPressed: () async {
              await ref.read(authRepositoryProvider).logout();
              ref.read(sessionProvider.notifier).markLoggedOut();
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}
