import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/bilingual_title.dart';
import '../../core/widgets/mock_data_badge.dart';
import '../../core/widgets/source_reference_card.dart';
import '../../domain/models/jatakam_models.dart';
import '../../domain/models/source_reference.dart';

class GrahaDetailsScreen extends StatelessWidget {
  const GrahaDetailsScreen({super.key, required this.graha});

  final Graha graha;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final jatakam = context.watch<AppState>().jatakam;
    final position = jatakam?.positionOf(graha);
    final accent = position != null
        ? AppColors.rashiAccents[(position.rashi.index - 1) % AppColors.rashiAccents.length]
        : theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: BilingualTitle(telugu: graha.telugu, english: graha.transliteration)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadii.xl),
              border: Border.all(color: accent.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: accent.withValues(alpha: 0.2),
                  child: Text(
                    graha.transliteration.substring(0, 2),
                    style: theme.textTheme.headlineSmall?.copyWith(color: accent),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(graha.telugu, style: theme.textTheme.headlineSmall),
                      Text('${graha.transliteration} · ${graha.westernName}', style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          if (position != null) ...[
            Row(
              children: [
                Text('మీ చక్రంలో స్థానం', style: theme.textTheme.titleMedium),
                const Spacer(),
                if (jatakam!.isMockCalculated) const MockDataBadge(),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Column(
                children: [
                  _Row('రాశి', '${position.rashi.telugu} (${position.rashi.name})'),
                  _Row('భావం', 'Bhāva ${position.house}'),
                  _Row('డిగ్రీ', '${position.degree.toStringAsFixed(2)}°'),
                  if (position.nakshatra != null) _Row('నక్షత్రం', '${position.nakshatra!.name} · Pada ${position.pada}'),
                  _Row('గమనం', position.isRetrograde ? 'వక్రి • Retrograde' : 'మార్గి • Direct'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
          Text('${graha.telugu} గురించి', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Interpretive significance of this graha\'s placement requires a qualified Jyotisha reference and is '
            'not yet available in this app.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SourceReferenceCard(source: SourceReference.unverified),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant))),
          Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
