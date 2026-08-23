import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

/// Shows a live "days / hours / minutes" countdown to a target date,
/// updating once a minute. Falls back to "Today" / "Tomorrow" copy for
/// near-term dates so the home screen reads naturally.
class CountdownDisplay extends StatefulWidget {
  const CountdownDisplay({super.key, required this.target, this.compact = false});

  final DateTime target;
  final bool compact;

  @override
  State<CountdownDisplay> createState() => _CountdownDisplayState();
}

class _CountdownDisplayState extends State<CountdownDisplay> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final target = DateTime(widget.target.year, widget.target.month, widget.target.day);
    final today = DateTime(now.year, now.month, now.day);
    final diffDays = target.difference(today).inDays;

    String headline;
    String? sub;
    if (diffDays == 0) {
      headline = 'Today';
    } else if (diffDays == 1) {
      headline = 'Tomorrow';
    } else if (diffDays > 1) {
      headline = '$diffDays days away';
      final weeks = diffDays ~/ 7;
      if (weeks >= 1) sub = '$weeks week${weeks > 1 ? 's' : ''} to go';
    } else {
      headline = 'Passed';
    }

    if (widget.compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: Text(
          headline,
          style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer, letterSpacing: 0),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(headline, style: theme.textTheme.displaySmall?.copyWith(color: theme.colorScheme.primary)),
        if (sub != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(sub, style: theme.textTheme.bodySmall),
          ),
      ],
    );
  }
}
