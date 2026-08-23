import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app_state/app_state.dart';
import '../../app_state/repositories_scope.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/countdown_display.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/jatakam_summary_card.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../core/widgets/panchang_summary_card.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/upcoming_event_tile.dart';
import '../../domain/models/festival_models.dart';
import '../../domain/models/panchang_models.dart';
import '../../core/util/date_format.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<_HomeData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_HomeData> _load() async {
    final repos = context.read<Repositories>();
    final now = DateTime.now();
    final summary = await repos.panchang.summaryFor(now);
    final upcoming = await repos.festival.upcoming(from: now, limit: 5);
    return _HomeData(summary: summary, upcoming: upcoming);
  }

  Future<void> _refresh() async {
    final next = _load();
    setState(() => _future = next);
    await next;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_greeting(appState.profile?.name)),
            Text(formatDateLong(DateTime.now()), style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search_rounded),
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            tooltip: 'Notification preferences',
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () => context.push('/notifications'),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<_HomeData>(
          future: _future,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: const [
                  SkeletonCard(height: 220),
                  SizedBox(height: AppSpacing.lg),
                  SkeletonCard(height: 140),
                ],
              );
            }
            final data = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
                  child: PanchangSummaryCardWidget(summary: data.summary),
                ),
                if (data.upcoming.isNotEmpty) ...[
                  SectionHeader(title: 'Next important event', teluguTitle: 'తదుపరి పర్వదినం'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: _NextEventCard(festival: data.upcoming.first),
                  ),
                ],
                if (data.upcoming.length > 1) ...[
                  SectionHeader(
                    title: 'Upcoming events',
                    teluguTitle: 'రాబోయే పండుగలు',
                    trailingLabel: 'See all',
                    onTrailingTap: () => context.go('/festivals'),
                  ),
                  ...List.generate(data.upcoming.length - 1, (i) {
                    final list = data.upcoming.sublist(1);
                    return UpcomingEventTile(
                      festival: list[i],
                      isFirst: i == 0,
                      isLast: i == list.length - 1,
                      onTap: () => context.push('/festivals/${list[i].id}'),
                    );
                  }),
                ],
                SectionHeader(title: 'Your Jatakam', teluguTitle: 'మీ జాతకం'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: _PersonalSection(appState: appState),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _greeting(String? name) {
    final hour = DateTime.now().hour;
    final base = hour < 12 ? 'శుభోదయం' : (hour < 17 ? 'శుభ మధ్యాహ్నం' : 'శుభ సాయంత్రం');
    if (name == null || name.trim().isEmpty) return base;
    return '$base, ${name.split(' ').first}';
  }
}

class _HomeData {
  const _HomeData({required this.summary, required this.upcoming});
  final PanchangSummary summary;
  final List<Festival> upcoming;
}

class _NextEventCard extends StatelessWidget {
  const _NextEventCard({required this.festival});
  final Festival festival;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(AppRadii.xl),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        onTap: () => context.push('/festivals/${festival.id}'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatDateLong(festival.date),
                      style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer),
                    ),
                    const SizedBox(height: 4),
                    Text(festival.teluguName, style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
                    Text(festival.name, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      festival.shortSignificance,
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.9)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              CountdownDisplay(target: festival.date),
            ],
          ),
        ),
      ),
    );
  }
}

class _PersonalSection extends StatelessWidget {
  const _PersonalSection({required this.appState});
  final AppState appState;

  @override
  Widget build(BuildContext context) {
    if (appState.jatakamLoading) {
      return const SkeletonCard(height: 150);
    }
    if (appState.jatakam == null) {
      return EmptyState(
        icon: Icons.auto_awesome_outlined,
        title: 'జనన వివరాలు జోడించండి',
        message: 'Enter your date, time and place of birth to see your personalised Rāśi, Nakshatra and full Jatakam.',
        actionLabel: 'జోడించండి • Add details',
        onAction: () => context.push('/profile/birth-details'),
      );
    }
    return JatakamSummaryCard(jatakam: appState.jatakam!, onTap: () => context.go('/jatakam'));
  }
}
