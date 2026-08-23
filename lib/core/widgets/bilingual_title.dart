import 'package:flutter/material.dart';

/// An AppBar title that leads with the Telugu label and shows the
/// English label as a small caption underneath, keeping Telugu the
/// primary reading language throughout the app's chrome.
class BilingualTitle extends StatelessWidget {
  const BilingualTitle({super.key, required this.telugu, required this.english});

  final String telugu;
  final String english;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(telugu, style: theme.textTheme.headlineSmall),
        Text(
          english,
          style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
