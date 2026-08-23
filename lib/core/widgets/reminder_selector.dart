import 'package:flutter/material.dart';
import '../../domain/models/festival_models.dart';
import '../theme/app_spacing.dart';

/// Three-way lead-time selector (7 days / 1 day / 2 hours) used both in
/// global notification preferences and per-festival overrides.
class ReminderSelector extends StatelessWidget {
  const ReminderSelector({
    super.key,
    required this.enabledLeadTimes,
    required this.onChanged,
    this.enabled = true,
  });

  final Set<ReminderLeadTime> enabledLeadTimes;
  final ValueChanged<Set<ReminderLeadTime>> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: ReminderLeadTime.values.map((lt) {
        final selected = enabledLeadTimes.contains(lt);
        return FilterChip(
          label: Text(lt.label),
          selected: selected,
          onSelected: enabled
              ? (value) {
                  final updated = Set<ReminderLeadTime>.from(enabledLeadTimes);
                  if (value) {
                    updated.add(lt);
                  } else {
                    updated.remove(lt);
                  }
                  onChanged(updated);
                }
              : null,
          avatar: selected ? const Icon(Icons.check_rounded, size: 16) : null,
        );
      }).toList(),
    );
  }
}
