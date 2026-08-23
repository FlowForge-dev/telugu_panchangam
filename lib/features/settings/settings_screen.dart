import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_state/theme_controller.dart';
import '../../core/theme/app_spacing.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeController = context.watch<ThemeController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('Appearance', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: RadioGroup<ThemeMode>(
              groupValue: themeController.mode,
              onChanged: (value) => themeController.setMode(value!),
              child: Column(
                children: ThemeMode.values.map((mode) {
                  return RadioListTile<ThemeMode>(
                    value: mode,
                    title: Text(_label(mode)),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text('Language', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Row(
              children: [
                Icon(Icons.translate_rounded, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'English with Telugu labels shown throughout. A full Telugu interface language is planned.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text('Data', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Row(
              children: [
                Icon(Icons.cloud_off_outlined, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Your profile and preferences are stored only on this device. This app does not use any '
                    'backend service yet.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _label(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Match system';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }
}
