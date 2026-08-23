import 'package:flutter/material.dart';
import '../../domain/models/jatakam_models.dart';
import '../theme/app_spacing.dart';
import 'mock_data_badge.dart';

/// Tasteful "at a glance" Jatakam summary — Rāśi, Nakshatra, Lagna —
/// used on Home's personal section and atop the Jatakam overview.
class JatakamSummaryCard extends StatelessWidget {
  const JatakamSummaryCard({super.key, required this.jatakam, this.onTap});

  final Jatakam jatakam;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadii.xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.xl),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text('Your Jatakam', style: theme.textTheme.titleLarge)),
                  if (jatakam.isMockCalculated) const MockDataBadge(),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: _Stat(label: 'Rāśi', value: jatakam.moonRashi.name, sub: jatakam.moonRashi.telugu),
                  ),
                  Expanded(
                    child: _Stat(
                      label: 'Nakshatra',
                      value: jatakam.birthNakshatra.name,
                      sub: '${jatakam.birthNakshatra.telugu} · Pada ${jatakam.birthNakshatraPada}',
                    ),
                  ),
                  Expanded(
                    child: _Stat(label: 'Lagna', value: jatakam.lagna.name, sub: jatakam.lagna.telugu),
                  ),
                ],
              ),
              if (onTap != null) ...[
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Text('View full chart', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 16, color: theme.colorScheme.primary),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.sub});
  final String label;
  final String value;
  final String sub;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(sub, style: theme.textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }
}
