import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/bilingual_title.dart';
import '../../core/widgets/source_reference_card.dart';
import '../../domain/models/jatakam_models.dart';
import '../../domain/models/source_reference.dart';

class RashiDetailsScreen extends StatelessWidget {
  const RashiDetailsScreen({super.key, required this.rashi});

  final Rashi rashi;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = AppColors.rashiAccents[(rashi.index - 1) % AppColors.rashiAccents.length];

    return Scaffold(
      appBar: AppBar(title: BilingualTitle(telugu: rashi.telugu, english: rashi.name)),
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
                CircleAvatar(radius: 28, backgroundColor: accent.withValues(alpha: 0.2), child: Text(rashi.symbol, style: theme.textTheme.titleMedium?.copyWith(color: accent))),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(rashi.telugu, style: theme.textTheme.headlineSmall),
                      Text(rashi.name, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(color: theme.colorScheme.surfaceContainer, borderRadius: BorderRadius.circular(AppRadii.md)),
            child: Row(
              children: [
                Expanded(child: Text('అధిపతి గ్రహం', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant))),
                InkWell(
                  onTap: () => context.push('/jatakam/graha/${rashi.lord.name}'),
                  child: Text(
                    '${rashi.lord.telugu} (${rashi.lord.transliteration})',
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text('లక్షణాలు', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Detailed characteristics and interpretive traits for ${rashi.name} require a qualified Jyotisha '
            'reference and are not yet available in this app.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SourceReferenceCard(source: SourceReference.unverified),
        ],
      ),
    );
  }
}
