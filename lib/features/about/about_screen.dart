import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/bilingual_title.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const BilingualTitle(telugu: 'గురించి & గోప్యత', english: 'About & privacy')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('Telugu Panchangam & Jatakam', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text('Version 1.0.0 (development preview)', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: AppSpacing.xxl),
          _Card(
            title: 'About this build',
            body: 'This is a frontend-only development preview. Festival dates from 19 Mar 2026 through '
                '24 Dec 2026 are taken from a real published almanac (see Sources & references); daily '
                'Tithi/Nakshatra/Yoga/Karana values and Jatakam charts still come from a placeholder mock data '
                'layer pending a verified calculation engine. Values marked "Preview calculation" or '
                '"[VERIFIED CONTENT REQUIRED]" are not to be relied on for religious observance.',
          ),
          const SizedBox(height: AppSpacing.lg),
          _Card(
            title: 'Privacy',
            body: 'Your name, birth details and preferences are stored locally on this device only. Nothing is '
                'sent to a server — this app does not yet connect to any backend.',
          ),
          const SizedBox(height: AppSpacing.lg),
          _Card(
            title: 'Content approach',
            body: 'We treat mantras, festival rules and Jyotisha interpretation as content requiring citation from '
                'a qualified, authoritative source before it is shown as fact. See Sources & references for the '
                'current status of each citation.',
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(body, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
