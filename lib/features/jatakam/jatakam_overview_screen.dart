import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app_state/app_state.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/bilingual_title.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/graha_indicator.dart';
import '../../core/widgets/jatakam_chart.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../core/widgets/mock_data_badge.dart';
import '../../core/widgets/section_header.dart';

class JatakamOverviewScreen extends StatelessWidget {
  const JatakamOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const BilingualTitle(telugu: 'జాతకం', english: 'Jatakam')),
      body: _buildBody(context, appState),
    );
  }

  Widget _buildBody(BuildContext context, AppState appState) {
    if (appState.profile?.hasBirthDetails != true) {
      return EmptyState(
        icon: Icons.auto_awesome_outlined,
        title: 'జనన వివరాలు లేవు',
        message: 'Add your date, time and place of birth to generate your personalised Jatakam.',
        actionLabel: 'జోడించండి • Add details',
        onAction: () => context.push('/profile/birth-details'),
      );
    }
    if (appState.jatakamLoading || appState.jatakam == null) {
      return ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: const [SkeletonCard(height: 320)],
      );
    }

    final jatakam = appState.jatakam!;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
          child: Row(
            children: [
              Expanded(child: Text('రాశి చక్రం', style: theme.textTheme.headlineSmall)),
              if (jatakam.isMockCalculated) const MockDataBadge(),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: JatakamChart(jatakam: jatakam),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => context.push('/jatakam/chart'),
              icon: const Icon(Icons.table_rows_outlined, size: 16),
              label: const Text('పూర్తి చక్రం • Full chart'),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: _QuickLink(
                  icon: Icons.brightness_2_outlined,
                  label: jatakam.moonRashi.telugu,
                  sub: 'రాశి • Rāśi',
                  onTap: () => context.push('/jatakam/rashi/${jatakam.moonRashi.index}'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _QuickLink(
                  icon: Icons.star_border_rounded,
                  label: jatakam.birthNakshatra.telugu,
                  sub: 'నక్షత్రం • Nakshatra',
                  onTap: () => context.push('/jatakam/nakshatra/${jatakam.birthNakshatra.index}'),
                ),
              ),
            ],
          ),
        ),
        SectionHeader(
          title: 'Graha positions',
          teluguTitle: 'గ్రహ స్థానాలు',
        ),
        ...jatakam.grahaPositions.map(
          (p) => GrahaIndicator(
            position: p,
            onTap: () => context.push('/jatakam/graha/${p.graha.name}'),
          ),
        ),
        SectionHeader(title: 'Japa & observance', teluguTitle: 'జప నియమాలు'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: _JapaLinkCard(onTap: () => context.push('/jatakam/japa')),
        ),
      ],
    );
  }
}

class _QuickLink extends StatelessWidget {
  const _QuickLink({required this.icon, required this.label, required this.sub, required this.onTap});
  final IconData icon;
  final String label;
  final String sub;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sub.toUpperCase(), style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    Text(label, style: theme.textTheme.titleMedium, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JapaLinkCard extends StatelessWidget {
  const _JapaLinkCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.tertiaryContainer,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Icon(Icons.self_improvement_rounded, color: theme.colorScheme.onTertiaryContainer),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'View recommended observances based on your chart',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onTertiaryContainer),
                ),
              ),
              Icon(Icons.arrow_forward_rounded, color: theme.colorScheme.onTertiaryContainer),
            ],
          ),
        ),
      ),
    );
  }
}
