import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app_state/app_state.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/util/date_format.dart';
import '../../domain/models/profile_models.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    final profile = appState.profile;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppRadii.xl),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    _initials(profile?.name),
                    style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimaryContainer),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile?.name.isNotEmpty == true ? profile!.name : 'Add your name', style: theme.textTheme.titleLarge),
                      const SizedBox(height: 2),
                      Text(
                        profile?.hasBirthDetails == true
                            ? '${formatDateShort(profile!.birthDetails!.date)} · ${profile.birthDetails!.place.displayName}'
                            : 'Birth details not added yet',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => _editName(context, appState, profile),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          _MenuGroup(children: [
            _MenuTile(
              icon: Icons.badge_outlined,
              label: 'Birth details',
              subtitle: 'Date, time & place of birth',
              onTap: () => context.push('/profile/birth-details'),
            ),
            _MenuTile(
              icon: Icons.auto_awesome_outlined,
              label: 'Jatakam',
              subtitle: 'Your personalised birth chart',
              onTap: () => context.go('/jatakam'),
            ),
            _MenuTile(
              icon: Icons.notifications_none_rounded,
              label: 'Notification preferences',
              subtitle: 'Festival reminder timing',
              onTap: () => context.push('/notifications'),
            ),
          ]),
          const SizedBox(height: AppSpacing.lg),
          _MenuGroup(children: [
            _MenuTile(
              icon: Icons.menu_book_outlined,
              label: 'Sources & references',
              onTap: () => context.push('/sources'),
            ),
            _MenuTile(
              icon: Icons.settings_outlined,
              label: 'Settings',
              onTap: () => context.push('/settings'),
            ),
            _MenuTile(
              icon: Icons.info_outline_rounded,
              label: 'About & privacy',
              onTap: () => context.push('/about'),
            ),
          ]),
        ],
      ),
    );
  }

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  void _editName(BuildContext context, AppState appState, UserProfile? profile) {
    final controller = TextEditingController(text: profile?.name ?? '');
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter your name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              appState.saveProfile(
                UserProfile(name: controller.text.trim(), birthDetails: profile?.birthDetails),
              );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1) const Divider(height: 1, indent: AppSpacing.lg),
          ],
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.icon, required this.label, this.subtitle, required this.onTap});
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
