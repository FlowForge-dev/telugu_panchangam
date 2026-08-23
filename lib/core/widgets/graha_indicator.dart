import 'package:flutter/material.dart';
import '../../domain/models/jatakam_models.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// A compact row summarising one graha's placement — used in the
/// Jatakam overview list and the Graha detail screen header.
class GrahaIndicator extends StatelessWidget {
  const GrahaIndicator({super.key, required this.position, this.onTap, this.dense = false});

  final GrahaPosition position;
  final VoidCallback? onTap;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = AppColors.rashiAccents[(position.rashi.index - 1) % AppColors.rashiAccents.length];

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: dense ? AppSpacing.sm : AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Text(
                position.graha.transliteration.substring(0, 2),
                style: theme.textTheme.labelLarge?.copyWith(color: accent, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(position.graha.transliteration, style: theme.textTheme.titleMedium),
                      const SizedBox(width: 6),
                      Text(position.graha.telugu, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      if (position.isRetrograde) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                          ),
                          child: Text('R', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onErrorContainer)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${position.rashi.name} · House ${position.house} · ${position.degree.toStringAsFixed(1)}°',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (onTap != null) Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant, size: 20),
          ],
        ),
      ),
    );
  }
}
