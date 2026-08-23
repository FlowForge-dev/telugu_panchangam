import 'package:flutter/material.dart';
import '../../domain/models/panchang_models.dart';
import '../theme/app_spacing.dart';
import 'mock_data_badge.dart';

/// The "Today" Panchangam summary shown on Home — Tithi, Nakshatra,
/// Vara and sunrise/sunset at a glance, in a calm two-row layout rather
/// than a dense table.
class PanchangSummaryCardWidget extends StatelessWidget {
  const PanchangSummaryCardWidget({super.key, required this.summary});

  final PanchangSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${summary.masa.transliteration} · ${summary.paksha.transliteration}',
                  style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.secondary),
                ),
              ),
              if (summary.isMockCalculated) const MockDataBadge(),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(summary.tithi.label, style: theme.textTheme.displaySmall),
          Text(
            summary.tithi.telugu,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _Fact(
                  icon: Icons.brightness_5_outlined,
                  label: summary.vara.transliteration,
                  sub: summary.vara.telugu,
                ),
              ),
              Expanded(
                child: _Fact(
                  icon: Icons.nights_stay_outlined,
                  label: summary.nakshatra.name,
                  sub: '${summary.nakshatra.telugu} · Pada ${summary.nakshatra.pada}',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(child: _Fact(icon: Icons.wb_sunny_outlined, label: 'Sunrise', sub: summary.sunrise)),
              Expanded(child: _Fact(icon: Icons.wb_twilight_outlined, label: 'Sunset', sub: summary.sunset)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.label, required this.sub});
  final IconData icon;
  final String label;
  final String sub;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurface)),
              Text(sub, style: theme.textTheme.bodySmall, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}
