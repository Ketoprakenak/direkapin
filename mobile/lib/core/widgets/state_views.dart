import 'package:flutter/material.dart';

import '../api/api_error.dart';
import '../theme/tokens.dart';
import 'mascot.dart';

/// State kosong: maskot tema dan ajakan mencatat.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(Spacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Mascot(size: Spacing.xxl * 2),
          const SizedBox(height: Spacing.md),
          Text(message, textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}

/// State error: pesan dari server (atau teks server offline) dan tombol coba lagi.
class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final message = error is ApiException
        ? (error as ApiException).message
        : 'Terjadi kesalahan. Coba lagi sebentar.';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: Spacing.xxl * 2, color: theme.colorScheme.outline),
            const SizedBox(height: Spacing.md),
            Text(message, textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
            const SizedBox(height: Spacing.lg),
            TextButton(onPressed: onRetry, child: const Text('Coba lagi')),
          ],
        ),
      ),
    );
  }
}

/// Kotak placeholder dengan denyut halus.
class Skeleton extends StatefulWidget {
  const Skeleton({super.key, required this.height, this.width});

  final double height;
  final double? width;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Motion.duration * 4,
    lowerBound: 0.5,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(Radii.md),
        ),
      ),
    );
  }
}

/// Skeleton untuk layar berbentuk daftar.
class ListSkeleton extends StatelessWidget {
  const ListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(Spacing.lg),
      itemCount: 6,
      separatorBuilder: (_, _) => const SizedBox(height: Spacing.md),
      itemBuilder: (_, _) => const Skeleton(height: Spacing.xxl * 2),
    );
  }
}
