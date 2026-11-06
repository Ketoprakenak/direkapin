import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_error.dart';
import '../../../core/auth/session_provider.dart';
import '../../../core/format/dates.dart';
import '../../../core/notifications/reminder_service.dart';
import '../../../core/router/router.dart';
import '../../../core/theme/tokens.dart';
import '../../auth/data/auth_models.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/settings_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        children: [
          const _ProfileHeader(),
          const _ReminderTile(),
          const _ThemeTile(),
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
          ListTile(
            leading: const Icon(Icons.inventory_2_rounded),
            title: const Text('Arsip foto'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.pushNamed(Routes.archives),
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

class _ProfileHeader extends ConsumerWidget {
  const _ProfileHeader();

  Future<void> _edit(BuildContext context, WidgetRef ref, User user) async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => _NameDialog(user.name),
    );
    if (name == null || name == user.name || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(settingsApiProvider).updateName(name);
      ref.invalidate(meProvider);
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(meProvider);
    final user = me.value;
    if (user == null) {
      return me.hasError
          ? ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person_rounded)),
              title: const Text('Profil gagal dimuat'),
              trailing: const Text('Coba lagi'),
              onTap: () => ref.invalidate(meProvider),
            )
          : const ListTile(
              leading: CircleAvatar(child: Icon(Icons.person_rounded)),
            );
    }
    return ListTile(
      leading: CircleAvatar(
        child: Text(user.name.characters.first.toUpperCase()),
      ),
      title: Text(user.name),
      subtitle: Text(user.email),
      trailing: IconButton(
        tooltip: 'Ubah nama',
        icon: const Icon(Icons.edit_rounded),
        onPressed: () => _edit(context, ref, user),
      ),
    );
  }
}

class _NameDialog extends StatefulWidget {
  const _NameDialog(this.initial);

  final String initial;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final _controller = TextEditingController(text: widget.initial);
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.length < 2 || name.length > 50) {
      setState(() => _error = 'Nama 2 sampai 50 karakter');
      return;
    }
    Navigator.pop(context, name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ubah nama'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(labelText: 'Nama', errorText: _error),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        TextButton(onPressed: _submit, child: const Text('Simpan')),
      ],
    );
  }
}

class _ThemeTile extends ConsumerWidget {
  const _ThemeTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appThemeModeProvider).value ?? ThemeMode.system;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.lg,
        vertical: Spacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tema'),
          const SizedBox(height: Spacing.sm),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<ThemeMode>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: ThemeMode.system, label: Text('Sistem')),
                ButtonSegment(value: ThemeMode.light, label: Text('Terang')),
                ButtonSegment(value: ThemeMode.dark, label: Text('Gelap')),
              ],
              selected: {mode},
              onSelectionChanged: (selected) => ref
                  .read(appThemeModeProvider.notifier)
                  .set(selected.single),
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
