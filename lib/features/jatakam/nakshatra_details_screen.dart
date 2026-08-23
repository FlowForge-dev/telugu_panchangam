import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_spacing.dart';
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
      appBar: AppBar(title: Text(nakshatra.name)),
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
                Text(nakshatra.name, style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
                Text(nakshatra.telugu, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
                const SizedBox(height: AppSpacing.md),
                Text('Nakshatra ${nakshatra.index} of 27', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(color: theme.colorScheme.surfaceContainer, borderRadius: BorderRadius.circular(AppRadii.md)),
            child: Column(
              children: [
                _Row('Ruling graha', '${nakshatra.ruler.transliteration} (${nakshatra.ruler.telugu})',
                    onTap: () => context.push('/jatakam/graha/${nakshatra.ruler.name}')),
                _Row('Presiding deity', nakshatra.deity),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text('Significance', style: theme.textTheme.titleMedium),
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
