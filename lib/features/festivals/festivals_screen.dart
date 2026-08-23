import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app_state/app_state.dart';
import '../../app_state/repositories_scope.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/bilingual_title.dart';
import '../../core/widgets/festival_card.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../domain/models/festival_models.dart';

class FestivalsScreen extends StatefulWidget {
  const FestivalsScreen({super.key});

  @override
  State<FestivalsScreen> createState() => _FestivalsScreenState();
}

class _FestivalsScreenState extends State<FestivalsScreen> {
  late Future<List<Festival>> _future;
  bool _upcomingOnly = true;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Festival>> _load() {
    final repos = context.read<Repositories>();
    return _upcomingOnly ? repos.festival.upcoming(limit: 50) : repos.festival.all();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reminderPrefs = context.watch<AppState>().reminderPreferences;

    return Scaffold(
      appBar: AppBar(
        title: const BilingualTitle(telugu: 'పండుగలు', english: 'Festivals'),
        actions: [
          IconButton(icon: const Icon(Icons.search_rounded), onPressed: () => context.push('/search')),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('రాబోయేవి'),
                  selected: _upcomingOnly,
                  onSelected: (_) => setState(() {
                    _upcomingOnly = true;
                    _future = _load();
                  }),
                ),
                const SizedBox(width: AppSpacing.sm),
                ChoiceChip(
                  label: const Text('పూర్తి సంవత్సరం'),
                  selected: !_upcomingOnly,
                  onSelected: (_) => setState(() {
                    _upcomingOnly = false;
                    _future = _load();
                  }),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Festival>>(
              future: _future,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return ListView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    children: const [
                      SkeletonCard(height: 130),
                      SizedBox(height: AppSpacing.md),
                      SkeletonCard(height: 130),
                    ],
                  );
                }
                final festivals = snapshot.data!;
                if (festivals.isEmpty) {
                  return Center(
                    child: Text('No festivals found', style: theme.textTheme.bodyMedium),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xxxl),
                  itemCount: festivals.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, i) {
                    final f = festivals[i];
                    final active = reminderPrefs.globallyEnabled && reminderPrefs.leadTimesFor(f.id).isNotEmpty;
                    return FestivalCard(
                      festival: f,
                      reminderActive: active,
                      onTap: () => context.push('/festivals/${f.id}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
