import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_error.dart';
import '../../../core/auth/session_provider.dart';
import '../../../core/format/dates.dart';
import '../../../core/media/photo_service.dart';
import '../../../core/notifications/reminder_service.dart';
import '../../../core/router/router.dart';
import '../../../core/theme/app_themes.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/frame.dart';
import '../../../core/widgets/mascot.dart';
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
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          const FrameCard(
            padding: EdgeInsets.zero,
            child: Column(children: [_ProfileHeader(), _ReminderTile()]),
          ),
          const SizedBox(height: Spacing.lg),
          FrameCard(
            padding: EdgeInsets.zero,
            child: Column(
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
                ListTile(
                  leading: const Icon(Icons.event_repeat_rounded),
                  title: const Text('Transaksi berulang'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.pushNamed(Routes.recurring),
                ),
                const _ThemeTile(),
                ListTile(
                  leading: const Icon(Icons.inventory_2_rounded),
                  title: const Text('Arsip foto'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.pushNamed(Routes.archives),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: Spacing.lg),
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

enum _AvatarAction { camera, gallery, remove }

class _ProfileHeader extends ConsumerStatefulWidget {
  const _ProfileHeader();

  @override
  ConsumerState<_ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends ConsumerState<_ProfileHeader> {
  static const _avatarTouchSize = Spacing.xxl + Spacing.lg;
  var _busy = false;

  Future<void> _edit(User user) async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => _NameDialog(user.name),
    );
    if (name == null || name == user.name || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(settingsApiProvider).updateName(name);
      ref.invalidate(meProvider);
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _changeAvatar(User user) async {
    final action = await showModalBottomSheet<_AvatarAction>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded),
              title: const Text('Ambil foto'),
              onTap: () => Navigator.pop(context, _AvatarAction.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Pilih dari galeri'),
              onTap: () => Navigator.pop(context, _AvatarAction.gallery),
            ),
            if (user.hasAvatar)
              ListTile(
                leading: const Icon(Icons.delete_rounded),
                title: const Text('Hapus foto'),
                onTap: () => Navigator.pop(context, _AvatarAction.remove),
              ),
          ],
        ),
      ),
    );
    if (action == null || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      final api = ref.read(settingsApiProvider);
      if (action == _AvatarAction.remove) {
        await api.deleteAvatar();
      } else {
        final picked = await ref
            .read(photoServiceProvider)
            .pick(
              action == _AvatarAction.camera
                  ? ImageSource.camera
                  : ImageSource.gallery,
              limit: 1,
            );
        if (picked.paths.isEmpty) return;
        await api.uploadAvatar(picked.paths.first);
      }
      ref.invalidate(avatarProvider);
      ref.invalidate(meProvider);
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } on Exception {
      messenger.showSnackBar(
        const SnackBar(content: Text('Foto gagal diambil')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
    // Memuat atau gagal: tetap inisial.
    final bytes = user.hasAvatar ? ref.watch(avatarProvider).value : null;
    return ListTile(
      leading: Semantics(
        button: true,
        label: 'Ubah foto profil',
        excludeSemantics: true,
        child: InkResponse(
          onTap: _busy ? null : () => _changeAvatar(user),
          child: SizedBox.square(
            dimension: _avatarTouchSize,
            child: Center(
              child: CircleAvatar(
                backgroundImage: bytes == null ? null : MemoryImage(bytes),
                child: _busy
                    ? const CircularProgressIndicator()
                    : bytes == null
                    ? Text(user.name.characters.first.toUpperCase())
                    : null,
              ),
            ),
          ),
        ),
      ),
      title: Text(user.name),
      subtitle: Text(user.email),
      onTap: () => _edit(user),
      trailing: IconButton(
        tooltip: 'Ubah nama',
        icon: const Icon(Icons.edit_rounded),
        onPressed: () => _edit(user),
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

class _ReminderTile extends ConsumerWidget {
  const _ReminderTile();

  Future<void> _pick(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
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

class _ThemeTile extends ConsumerWidget {
  const _ThemeTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(appThemeChoiceProvider).value ?? appThemes.first;
    return ListTile(
      leading: const Mascot(size: Spacing.xl),
      title: const Text('Tema'),
      subtitle: Text(active.name),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => context.pushNamed(Routes.themes),
    );
  }
}
