import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/util/date_format.dart';
import '../../core/widgets/bilingual_title.dart';
import '../../core/widgets/mock_data_badge.dart';
import '../../domain/models/jatakam_models.dart';

/// Vimshottari Mahadasha timeline — the 120-year graha-period cycle
/// derived from the birth Nakshatra's ruling graha.
class DashaTimelineScreen extends StatelessWidget {
  const DashaTimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final jatakam = context.watch<AppState>().jatakam;
    if (jatakam == null || jatakam.dashaPeriods.isEmpty) {
      return const Scaffold(body: Center(child: Text('No dasha timeline available yet')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const BilingualTitle(telugu: 'విమ్శోత్తరి దశ', english: 'Vimshottari Dasha'),
        actions: const [Padding(padding: EdgeInsets.only(right: AppSpacing.lg), child: Center(child: MockDataBadge()))],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: jatakam.dashaPeriods.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, i) => _DashaTile(period: jatakam.dashaPeriods[i]),
      ),
    );
  }
}

class _DashaTile extends StatelessWidget {
  const _DashaTile({required this.period});
  final DashaPeriod period;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rashiIndex = period.graha.index % AppColors.rashiAccents.length;
    final accent = AppColors.rashiAccents[rashiIndex];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: period.isCurrent ? theme.colorScheme.primaryContainer : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: period.isCurrent ? theme.colorScheme.primary : theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: accent.withValues(alpha: 0.18), shape: BoxShape.circle),
            child: Text(
              period.graha.transliteration.substring(0, 2),
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
                    Text(period.graha.telugu, style: theme.textTheme.titleMedium),
                    const SizedBox(width: 6),
                    Text(period.graha.transliteration, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    if (period.isCurrent) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(AppRadii.pill)),
                        child: Text(
                          'ప్రస్తుతం • Current',
                          style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onPrimary),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${formatDateShort(period.startDate)} – ${formatDateShort(period.endDate)} · ${period.years} yrs',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
