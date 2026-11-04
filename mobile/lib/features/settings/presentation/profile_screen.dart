import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/session_provider.dart';
import '../../../core/router/router.dart';
import '../../../core/theme/tokens.dart';
import '../../auth/providers/auth_providers.dart';

/// Isi lengkap S-14 menyusul di Slice 8.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_rounded),
            title: const Text('Dompet'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.pushNamed(Routes.wallets),
          ),
          ListTile(
            leading: const Icon(Icons.category_rounded),
            title: const Text('Kategori'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.pushNamed(Routes.categories),
          ),
          Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: OutlinedButton(
              onPressed: () async {
                await ref.read(authRepositoryProvider).logout();
                ref.read(sessionProvider.notifier).markLoggedOut();
              },
              child: const Text('Keluar'),
            ),
          ),
        ],
      ),
    );
  }
}
