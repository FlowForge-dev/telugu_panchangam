import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

/// A consistent section title used across dashboard-style screens, with
/// an optional Telugu subtitle and an optional trailing action such as
/// "See all".
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.teluguTitle,
    this.trailingLabel,
    this.onTrailingTap,
    this.padding = const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.sm),
  });

  final String title;
  final String? teluguTitle;
  final String? trailingLabel;
  final VoidCallback? onTrailingTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(teluguTitle ?? title, style: theme.textTheme.headlineSmall),
                if (teluguTitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
          if (trailingLabel != null)
            TextButton(
              onPressed: onTrailingTap,
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(trailingLabel!),
                  const SizedBox(width: 2),
                  const Icon(Icons.arrow_forward_rounded, size: 16),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
