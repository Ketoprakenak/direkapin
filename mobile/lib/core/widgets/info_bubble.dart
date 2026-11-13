import 'package:flutter/material.dart';

import '../theme/app_themes.dart';
import '../theme/tokens.dart';

/// Ikon (i) yang membuka balon penjelasan singkat. Balon tetap tampil sampai
/// ikon ditap lagi atau user menyentuh tempat lain.
class InfoBubble extends StatefulWidget {
  const InfoBubble({super.key, required this.label, required this.message});

  /// Dibacakan pembaca layar, mis. "Info Otomatis".
  final String label;
  final String message;

  @override
  State<InfoBubble> createState() => _InfoBubbleState();
}

class _InfoBubbleState extends State<InfoBubble> {
  final _bubble = OverlayPortalController();
  final _link = LayerLink();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final style = AppStyle.of(context);
    return TapRegion(
      groupId: _link,
      onTapOutside: (_) => _bubble.hide(),
      child: CompositedTransformTarget(
        link: _link,
        child: OverlayPortal(
          controller: _bubble,
          overlayChildBuilder: (context) => Align(
            alignment: Alignment.topLeft,
            child: CompositedTransformFollower(
              link: _link,
              targetAnchor: Alignment.bottomRight,
              followerAnchor: Alignment.topRight,
              child: TapRegion(
                groupId: _link,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: Spacing.xxl * 5),
                  child: Material(
                    color: theme.colorScheme.inverseSurface,
                    borderRadius: BorderRadius.circular(style.dateRadius / 2),
                    child: Padding(
                      padding: const EdgeInsets.all(Spacing.sm),
                      child: Text(
                        widget.message,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onInverseSurface,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          child: IconButton(
            onPressed: _bubble.toggle,
            icon: Icon(
              Icons.info_outline_rounded,
              color: colors.textSecondary,
              semanticLabel: widget.label,
            ),
          ),
        ),
      ),
    );
  }
}
