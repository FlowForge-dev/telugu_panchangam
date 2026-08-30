import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app_state/repositories_scope.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/bilingual_title.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../domain/models/devotional_models.dart';

class DevotionalLyricsScreen extends StatefulWidget {
  const DevotionalLyricsScreen({super.key});

  @override
  State<DevotionalLyricsScreen> createState() => _DevotionalLyricsScreenState();
}

class _DevotionalLyricsScreenState extends State<DevotionalLyricsScreen> {
  late Future<List<DevotionalText>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<Repositories>().devotional.all();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const BilingualTitle(telugu: 'భక్తి గీతాలు', english: 'Devotional lyrics')),
      body: FutureBuilder<List<DevotionalText>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: const [SkeletonCard(height: 70), SizedBox(height: AppSpacing.sm), SkeletonCard(height: 70)],
            );
          }
          final items = snapshot.data!;
          final byCategory = <DevotionalCategory, List<DevotionalText>>{};
          for (final item in items) {
            byCategory.putIfAbsent(item.category, () => []).add(item);
          }
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            children: [
              for (final category in DevotionalCategory.values)
                if (byCategory[category] != null) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
                    child: Text(
                      '${category.telugu} · ${category.label}',
                      style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.secondary),
                    ),
                  ),
                  ...byCategory[category]!.map((d) => ListTile(
                        title: Text(d.teluguTitle),
                        subtitle: Text('${d.title} · ${d.deity}'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => context.push('/devotional/${d.id}'),
                      )),
                ],
            ],
          );
        },
      ),
    );
  }
}
