import 'package:flutter/material.dart';
import '../../domain/models/festival_models.dart';
import '../theme/app_spacing.dart';
import '../util/date_format.dart';

/// A single row in the "Upcoming events" timeline on Home / Festivals.
/// Deliberately compact — the timeline connector communicates sequence
/// without needing repeated card chrome per row.
class UpcomingEventTile extends StatelessWidget {
  const UpcomingEventTile({
    super.key,
    required this.festival,
    required this.onTap,
    this.isFirst = false,
    this.isLast = false,
  });

  final Festival festival;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dotColor = switch (festival.importance) {
      FestivalImportance.major => theme.colorScheme.primary,
      FestivalImportance.moderate => theme.colorScheme.secondary,
      FestivalImportance.observance => theme.colorScheme.tertiary,
    };

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 56,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${festival.date.day}',
                      style: theme.textTheme.titleLarge?.copyWith(height: 1),
                    ),
                    Text(
                      formatDayMonth(festival.date).split(' ').last,
                      style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 1.4,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(festival.name, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        festival.shortSignificance,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
