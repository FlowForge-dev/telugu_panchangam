import 'package:flutter/material.dart';
import '../../domain/models/source_reference.dart';
import '../theme/app_spacing.dart';

/// Displays a single [SourceReference] with a clear verification-status
/// indicator. Source provenance is a first-class feature: this card is
/// used anywhere religious/astrological content is shown.
class SourceReferenceCard extends StatelessWidget {
  const SourceReferenceCard({super.key, required this.source});

  final SourceReference source;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = _statusMeta(theme, source.status);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  source.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: source.status == VerificationStatus.pendingVerification
                        ? theme.colorScheme.onSurfaceVariant
                        : theme.colorScheme.onSurface,
                    fontStyle: source.status == VerificationStatus.pendingVerification ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
                decoration: BoxDecoration(
                  color: status.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(status.icon, size: 12, color: status.color),
                    const SizedBox(width: 4),
                    Text(status.label, style: theme.textTheme.labelSmall?.copyWith(color: status.color)),
                  ],
                ),
              ),
            ],
          ),
          if (source.sectionOrChapter != null || source.edition != null || source.language != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: 4,
              children: [
                if (source.sectionOrChapter != null) _MetaItem(icon: Icons.bookmark_border_rounded, label: source.sectionOrChapter!),
                if (source.edition != null) _MetaItem(icon: Icons.menu_book_outlined, label: source.edition!),
                if (source.language != null) _MetaItem(icon: Icons.translate_rounded, label: source.language!),
              ],
            ),
          ],
          if (source.notes != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(source.notes!, style: theme.textTheme.bodySmall),
          ],
        ],
      ),
    );
  }

  _StatusMeta _statusMeta(ThemeData theme, VerificationStatus status) {
    switch (status) {
      case VerificationStatus.verified:
        return _StatusMeta('Verified', Icons.verified_rounded, const Color(0xFF4B7A4E));
      case VerificationStatus.pendingVerification:
        return _StatusMeta('Pending verification', Icons.hourglass_top_rounded, theme.colorScheme.secondary);
      case VerificationStatus.variesByTradition:
        return _StatusMeta('Varies by tradition', Icons.call_split_rounded, theme.colorScheme.tertiary);
    }
  }
}

class _StatusMeta {
  const _StatusMeta(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
