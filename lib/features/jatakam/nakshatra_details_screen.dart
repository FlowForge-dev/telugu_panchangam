import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/widgets/bilingual_title.dart';
import '../../core/widgets/source_reference_card.dart';
import '../../domain/models/jatakam_models.dart';
import '../../domain/models/source_reference.dart';

class NakshatraDetailsScreen extends StatelessWidget {
  const NakshatraDetailsScreen({super.key, required this.nakshatra});

  final Nakshatra nakshatra;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: BilingualTitle(telugu: nakshatra.telugu, english: nakshatra.name)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadii.xl),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nakshatra.telugu, style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
                Text(nakshatra.name, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
                const SizedBox(height: AppSpacing.md),
                Text('27లో ${nakshatra.index}వ నక్షత్రం', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(color: theme.colorScheme.surfaceContainer, borderRadius: BorderRadius.circular(AppRadii.md)),
            child: Column(
              children: [
                _Row('అధిపతి గ్రహం', '${nakshatra.ruler.telugu} (${nakshatra.ruler.transliteration})',
                    onTap: () => context.push('/jatakam/graha/${nakshatra.ruler.name}')),
                _Row('అధిదేవత', nakshatra.deity),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text('ప్రాముఖ్యత', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Detailed characteristics and interpretive significance of ${nakshatra.name} require a qualified '
            'Jyotisha reference and are not yet available in this app.',
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
  const _Row(this.label, this.value, {this.onTap});
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final child = Text(
      value,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: onTap != null ? theme.colorScheme.primary : null,
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant))),
          onTap != null ? InkWell(onTap: onTap, child: child) : child,
        ],
      ),
    );
  }
}
