import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_state/repositories_scope.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/bilingual_title.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../core/widgets/source_reference_card.dart';
import '../../domain/models/vrata_models.dart';

class VrataCollectionsScreen extends StatefulWidget {
  const VrataCollectionsScreen({super.key});

  @override
  State<VrataCollectionsScreen> createState() => _VrataCollectionsScreenState();
}

class _VrataCollectionsScreenState extends State<VrataCollectionsScreen> {
  late Future<List<VrataObservance>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<Repositories>().vrata.all();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const BilingualTitle(telugu: 'వ్రత సంకలనం', english: 'Vrat collections')),
      body: FutureBuilder<List<VrataObservance>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: const [SkeletonCard(height: 110), SizedBox(height: AppSpacing.md), SkeletonCard(height: 110)],
            );
          }
          final items = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, i) => _VrataCard(vrata: items[i]),
          );
        },
      ),
    );
  }
}

class _VrataCard extends StatelessWidget {
  const _VrataCard({required this.vrata});
  final VrataObservance vrata;

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
          Text(vrata.teluguName, style: theme.textTheme.titleLarge),
          Text(vrata.name, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.event_repeat_rounded, size: 15, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Expanded(child: Text(vrata.recurrence, style: theme.textTheme.bodySmall)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(vrata.shortInfo, style: theme.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          SourceReferenceCard(source: vrata.source),
        ],
      ),
    );
  }
}
