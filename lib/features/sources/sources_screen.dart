import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_state/repositories_scope.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/bilingual_title.dart';
import '../../core/widgets/source_reference_card.dart';
import '../../domain/models/source_reference.dart';

class SourcesScreen extends StatefulWidget {
  const SourcesScreen({super.key});

  @override
  State<SourcesScreen> createState() => _SourcesScreenState();
}

class _SourcesScreenState extends State<SourcesScreen> {
  late Future<List<SourceReference>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<SourceReference>> _load() async {
    final repos = context.read<Repositories>();
    final festivals = await repos.festival.all();
    final japa = await repos.japa.general();
    final sources = <SourceReference>[];
    for (final f in festivals) {
      sources.addAll(f.sources);
      sources.addAll(f.mantraSources);
    }
    for (final j in japa) {
      sources.add(j.source);
    }
    // De-duplicate by title+notes for a clean overview list.
    final seen = <String>{};
    return sources.where((s) => seen.add('${s.title}|${s.notes}')).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const BilingualTitle(telugu: 'ఆధారాలు', english: 'Sources & references')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('How we handle provenance', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Every mantra, festival rule and Jyotisha statement in this app is meant to carry a source — '
                  'title, section, edition, language and a verification status. This build ships with the '
                  'provenance framework wired up, but no specific citations have been reviewed and approved yet, '
                  'so every entry below is marked pending verification.',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text('Referenced across this app', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          FutureBuilder<List<SourceReference>>(
            future: _future,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final sources = snapshot.data!;
              return Column(
                children: sources
                    .map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: SourceReferenceCard(source: s),
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
