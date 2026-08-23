import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_state/app_state.dart';
import '../../app_state/repositories_scope.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/bilingual_title.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../core/widgets/source_reference_card.dart';
import '../../domain/models/jatakam_models.dart';

class JapaScreen extends StatefulWidget {
  const JapaScreen({super.key});

  @override
  State<JapaScreen> createState() => _JapaScreenState();
}

class _JapaScreenState extends State<JapaScreen> {
  late Future<List<JapaRecommendation>> _future;

  @override
  void initState() {
    super.initState();
    final jatakam = context.read<AppState>().jatakam;
    final repos = context.read<Repositories>();
    _future = jatakam != null ? repos.japa.recommendationsFor(jatakam) : repos.japa.general();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const BilingualTitle(telugu: 'జప నియమాలు', english: 'Japa & observance')),
      body: FutureBuilder<List<JapaRecommendation>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: const [SkeletonCard(height: 160), SizedBox(height: AppSpacing.md), SkeletonCard(height: 160)],
            );
          }
          final items = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
            itemBuilder: (context, i) => _JapaCard(recommendation: items[i]),
          );
        },
      ),
    );
  }
}

class _JapaCard extends StatelessWidget {
  const _JapaCard({required this.recommendation});
  final JapaRecommendation recommendation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(recommendation.teluguTitle, style: theme.textTheme.titleLarge),
          Text(recommendation.title, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: AppSpacing.md),
          _field(context, Icons.event_available_outlined, 'వర్తించేది', recommendation.applicability),
          _field(context, Icons.help_outline_rounded, 'కారణం', recommendation.reason),
          _field(context, Icons.spa_outlined, 'సన్నాహం', recommendation.preparation),
          _field(context, Icons.repeat_rounded, 'పునరావృతం', recommendation.repetitionInfo),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.shield_outlined, size: 16, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'మంత్రం • Mantra: ${recommendation.mantraPlaceholder}',
                    style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic, color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SourceReferenceCard(source: recommendation.source),
        ],
      ),
    );
  }

  Widget _field(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface),
                children: [
                  TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.w700)),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
