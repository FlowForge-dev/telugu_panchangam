import 'package:flutter/material.dart';
import '../../domain/models/festival_models.dart';
import '../theme/app_spacing.dart';
import '../util/date_format.dart';
import 'countdown_display.dart';

/// A rich card for a single festival — used on the Festivals list and
/// as the "Next important event" feature on Home.
class FestivalCard extends StatelessWidget {
  const FestivalCard({
    super.key,
    required this.festival,
    required this.onTap,
    this.showCountdown = true,
    this.reminderActive = false,
  });

  final Festival festival;
  final VoidCallback onTap;
  final bool showCountdown;
  final bool reminderActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateLabel = formatDateShort(festival.date);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ImportanceMark(importance: festival.importance),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(festival.name, style: theme.textTheme.titleLarge),
                        const SizedBox(height: 2),
                        Text(
                          festival.teluguName,
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  if (reminderActive)
                    Icon(Icons.notifications_active_rounded, size: 18, color: theme.colorScheme.secondary),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                festival.shortSignificance,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 14, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text(dateLabel, style: theme.textTheme.labelMedium),
                  const Spacer(),
                  if (showCountdown) CountdownDisplay(target: festival.date, compact: true),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImportanceMark extends StatelessWidget {
  const _ImportanceMark({required this.importance});
  final FestivalImportance importance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = switch (importance) {
      FestivalImportance.major => theme.colorScheme.primary,
      FestivalImportance.moderate => theme.colorScheme.secondary,
      FestivalImportance.observance => theme.colorScheme.tertiary,
    };
    return Container(
      width: 6,
      height: 44,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(AppRadii.pill)),
    );
  }
}
