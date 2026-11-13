import 'package:flutter/material.dart';

import '../theme/app_themes.dart';
import '../theme/tokens.dart';

/// Tab kapsul berframe dalam; tab aktif = blok penuh warna teks tema.
class PillTabs<T> extends StatelessWidget {
  const PillTabs({
    super.key,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  final Map<T, String> labels;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // Garis sama dengan FrameBox, tapi radius penuh (kapsul).
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: scheme.surface,
        shape: StadiumBorder(
          side: BorderSide(
            color: scheme.onSurface,
            width: AppStyle.of(context).frameWidth,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xs),
        child: Row(
          children: [
            for (final MapEntry(key: type, value: label) in labels.entries)
              Expanded(
                child: Semantics(
                  button: true,
                  selected: type == selected,
                  inMutuallyExclusiveGroup: true,
                  child: Material(
                    type: type == selected
                        ? MaterialType.canvas
                        : MaterialType.transparency,
                    color: scheme.onSurface,
                    shape: const StadiumBorder(),
                    child: InkWell(
                      customBorder: const StadiumBorder(),
                      onTap: () => onChanged(type),
                      child: Container(
                        constraints: const BoxConstraints(
                          minHeight: kMinInteractiveDimension,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: type == selected
                                ? scheme.surface
                                : scheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
