import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_error.dart';
import '../../../core/auth/session_provider.dart';
import '../../../core/format/dates.dart';
import '../../../core/notifications/reminder_service.dart';
import '../../../core/router/router.dart';
import '../../../core/theme/tokens.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/settings_providers.dart';

/// Isi lengkap S-14 menyusul di Slice 8.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        children: [
          const _ReminderTile(),
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

class _ReminderTile extends ConsumerWidget {
  const _ReminderTile();

  Future<void> _pick(BuildContext context, WidgetRef ref, String current) async {
    final [hour, minute] = current.split(':').map(int.parse).toList();
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
    );
    if (picked == null || !context.mounted) return;
    String pad(int value) => value.toString().padLeft(2, '0');
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(settingsApiProvider)
          .updateReminderTime('${pad(picked.hour)}:${pad(picked.minute)}');
      // AppShell memasang ulang jadwal saat data profil baru masuk.
      ref.invalidate(meProvider);
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(meProvider);
    final enabled = ref.watch(notificationsEnabledProvider).value ?? true;
    final time = me.value?.reminderTime;
    return ListTile(
      leading: const Icon(Icons.notifications_rounded),
      title: const Text('Jam pengingat'),
      subtitle: enabled
          ? null
          : const Text('Izin notifikasi mati. Aktifkan di pengaturan HP.'),
      trailing: time != null
          ? Text(formatActivityTime(time))
          : me.hasError
          ? const Text('Coba lagi')
          : null,
      onTap: time != null
          ? () => _pick(context, ref, time)
          : me.hasError
          ? () => ref.invalidate(meProvider)
          : null,
    );
  }
}
