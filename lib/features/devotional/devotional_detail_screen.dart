import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_state/repositories_scope.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/source_reference_card.dart';
import '../../domain/models/devotional_models.dart';

class DevotionalDetailScreen extends StatefulWidget {
  const DevotionalDetailScreen({super.key, required this.id});

  final String id;

  @override
  State<DevotionalDetailScreen> createState() => _DevotionalDetailScreenState();
}

class _DevotionalDetailScreenState extends State<DevotionalDetailScreen> {
  late Future<DevotionalText?> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<Repositories>().devotional.byId(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DevotionalText?>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final item = snapshot.data;
        if (item == null) {
          return const Scaffold(body: Center(child: Text('Not found')));
        }
        return _Content(item: item);
      },
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.item});
  final DevotionalText item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(item.teluguTitle)),
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
                Text(item.teluguTitle, style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
                Text(item.title, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${item.category.telugu} · దైవం: ${item.deity}',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onPrimaryContainer),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('పాఠం • Text', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.shield_outlined, size: 18, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    DevotionalText.contentPlaceholder,
                    style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic, color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('ఆధారం • Source', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          SourceReferenceCard(source: item.source),
        ],
      ),
    );
  }
}
