import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app_state/app_state.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/graha_indicator.dart';
import '../../core/widgets/jatakam_chart.dart';
import '../../core/widgets/mock_data_badge.dart';
import '../../core/widgets/section_header.dart';

/// Full-screen birth-chart view: the Rāśi chakra plus a house-by-house
/// breakdown, reached from the Jatakam overview.
class JatakamChartScreen extends StatelessWidget {
  const JatakamChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final jatakam = context.watch<AppState>().jatakam;
    final theme = Theme.of(context);

    if (jatakam == null) {
      return const Scaffold(body: Center(child: Text('No chart available yet')));
    }

    final byHouse = jatakam.byHouse;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Birth chart'),
        actions: const [Padding(padding: EdgeInsets.only(right: AppSpacing.lg), child: Center(child: MockDataBadge()))],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: JatakamChart(jatakam: jatakam),
          ),
          SectionHeader(title: 'Houses (Bhāvas)', teluguTitle: 'భావాలు'),
          ...List.generate(12, (i) {
            final house = i + 1;
            final positions = byHouse[house] ?? const [];
            if (positions.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
                      child: Row(
                        children: [
                          Text('House $house', style: theme.textTheme.titleSmall),
                          const SizedBox(width: 8),
                          Text(
                            positions.first.rashi.name,
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    ...positions.map((p) => GrahaIndicator(
                          position: p,
                          dense: true,
                          onTap: () => context.push('/jatakam/graha/${p.graha.name}'),
                        )),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
