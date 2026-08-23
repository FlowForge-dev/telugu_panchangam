import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_state/app_state.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/bilingual_title.dart';
import '../../core/widgets/reminder_selector.dart';

class NotificationPreferencesScreen extends StatelessWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    final prefs = appState.reminderPreferences;

    return Scaffold(
      appBar: AppBar(title: const BilingualTitle(telugu: 'నోటిఫికేషన్ ప్రాధాన్యతలు', english: 'Notification preferences')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Festival reminders'),
              subtitle: const Text('Turn all reminders on or off across the app'),
              value: prefs.globallyEnabled,
              onChanged: (value) => appState.setGlobalRemindersEnabled(value),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text('Default reminder timing', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Applied to every festival unless you set a custom reminder on its detail page.',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.md),
          Opacity(
            opacity: prefs.globallyEnabled ? 1 : 0.5,
            child: ReminderSelector(
              enabledLeadTimes: prefs.defaultLeadTimes,
              enabled: prefs.globallyEnabled,
              onChanged: (updated) {
                final removed = prefs.defaultLeadTimes.difference(updated);
                final added = updated.difference(prefs.defaultLeadTimes);
                for (final lt in added) {
                  appState.toggleDefaultLeadTime(lt, true);
                }
                for (final lt in removed) {
                  appState.toggleDefaultLeadTime(lt, false);
                }
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, size: 18, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'These preferences configure the reminder UI. Reliable background notification scheduling '
                    'will be connected in a future release.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          if (prefs.overrides.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xxl),
            Text('Per-festival overrides', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            ...prefs.overrides.values.map((o) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: ListTile(
                    tileColor: theme.colorScheme.surfaceContainer,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
                    title: Text(o.festivalId),
                    subtitle: Text(o.enabledLeadTimes.map((e) => e.label).join(', ').ifEmpty('No reminders')),
                  ),
                )),
          ],
        ],
      ),
    );
  }
}

extension _StringExt on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
