import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_error.dart';
import '../../../core/format/dates.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/frame.dart';
import '../../../core/widgets/state_views.dart';
import '../data/invite_models.dart';
import '../providers/invite_providers.dart';

/// Kode undangan buatan owner (AUTH-07): buat, lihat status, salin.
class InvitesScreen extends ConsumerStatefulWidget {
  const InvitesScreen({super.key});

  @override
  ConsumerState<InvitesScreen> createState() => _InvitesScreenState();
}

class _InvitesScreenState extends ConsumerState<InvitesScreen> {
  bool _busy = false;

  Future<void> _create() async {
    if (_busy) return;
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(inviteApiProvider).create();
      ref.invalidate(invitesProvider);
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kode undangan')),
      body: ref
          .watch(invitesProvider)
          .when(
            loading: () => const ListSkeleton(),
            error: (error, _) => ErrorState(
              error: error,
              onRetry: () => ref.invalidate(invitesProvider),
            ),
            data: (items) => ListView(
              padding: const EdgeInsets.all(Spacing.lg),
              children: [
                FilledButton.icon(
                  onPressed: _busy ? null : _create,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Buat kode'),
                ),
                const SizedBox(height: Spacing.md),
                if (items.isEmpty)
                  const EmptyState(
                    message: 'Belum ada kode. Buat satu buat ngajak teman.',
                  )
                else
                  for (final invite in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: Spacing.sm),
                      child: _InviteCard(invite),
                    ),
              ],
            ),
          ),
    );
  }
}

class _InviteCard extends StatelessWidget {
  const _InviteCard(this.invite);

  final Invite invite;

  Future<void> _copy(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: invite.code));
    messenger.showSnackBar(const SnackBar(content: Text('Kode disalin')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usedBy = invite.usedByName;
    final expired = invite.isExpired(DateTime.now());
    final active = usedBy == null && !expired;
    final status = usedBy != null
        ? 'Dipakai $usedBy'
        : expired
        ? 'Kedaluwarsa'
        : 'Berlaku sampai ${formatLongDate(invite.expiresAt.toLocal())}';
    return FrameCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invite.code,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: active ? null : AppColors.of(context).textSecondary,
                  ),
                ),
                Text(status, style: theme.textTheme.labelSmall),
              ],
            ),
          ),
          if (active)
            IconButton(
              tooltip: 'Salin kode',
              onPressed: () => _copy(context),
              icon: const Icon(Icons.copy_rounded),
            ),
        ],
      ),
    );
  }
}
