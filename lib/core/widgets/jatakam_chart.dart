import 'package:flutter/material.dart';
import '../../domain/models/jatakam_models.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Renders a traditional South-Indian style Rāśi chart (fixed-sign
/// grid — each box is always the same Rāśi, unlike a North-Indian
/// chart where the Lagna box rotates). This is the layout most commonly
/// used in Telugu Jyotisha practice.
///
/// The widget only lays out whatever [Jatakam] it is given — house and
/// sign placement will come from a real engine later without any
/// change here.
class JatakamChart extends StatelessWidget {
  const JatakamChart({super.key, required this.jatakam});

  final Jatakam jatakam;

  // Fixed grid position (row, col) for each Rāśi index (1-12), 4x4 grid
  // with the four centre cells left open.
  static const Map<int, List<int>> _gridPosition = {
    12: [0, 0], 1: [0, 1], 2: [0, 2], 3: [0, 3],
    11: [1, 0],                       4: [1, 3],
    10: [2, 0],                       5: [2, 3],
    9: [3, 0], 8: [3, 1], 7: [3, 2], 6: [3, 3],
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final byRashi = <int, List<GrahaPosition>>{};
    for (final p in jatakam.grahaPositions) {
      byRashi.putIfAbsent(p.rashi.index, () => []).add(p);
    }

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline, width: 1.5),
          borderRadius: BorderRadius.circular(AppRadii.md),
          color: theme.colorScheme.surface,
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
          itemCount: 16,
          itemBuilder: (context, i) {
            final row = i ~/ 4;
            final col = i % 4;
            final isCenter = row >= 1 && row <= 2 && col >= 1 && col <= 2;
            if (isCenter) {
              return _CenterCell(showTitle: row == 1 && col == 1);
            }
            final rashiIndex = _gridPosition.entries.firstWhere((e) => e.value[0] == row && e.value[1] == col).key;
            final rashi = Rashi.all[rashiIndex - 1];
            final isLagna = rashi.index == jatakam.lagna.index;
            return _RashiCell(
              rashi: rashi,
              grahas: byRashi[rashi.index] ?? const [],
              isLagna: isLagna,
            );
          },
        ),
      ),
    );
  }
}

class _CenterCell extends StatelessWidget {
  const _CenterCell({required this.showTitle});
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (!showTitle) return const SizedBox.shrink();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Text(
          'రాశి చక్రం',
          textAlign: TextAlign.center,
          style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}

class _RashiCell extends StatelessWidget {
  const _RashiCell({required this.rashi, required this.grahas, required this.isLagna});
  final Rashi rashi;
  final List<GrahaPosition> grahas;
  final bool isLagna;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = AppColors.rashiAccents[(rashi.index - 1) % AppColors.rashiAccents.length];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 0.7),
        color: isLagna ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5) : null,
      ),
      padding: const EdgeInsets.all(3),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            ),
          ),
          if (isLagna)
            Positioned(
              top: 0,
              right: 0,
              child: Text('Asc', style: theme.textTheme.labelSmall?.copyWith(fontSize: 8, color: theme.colorScheme.primary)),
            ),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 2,
              runSpacing: 1,
              children: grahas
                  .map((g) => Text(
                        _grahaAbbr(g.graha) + (g.isRetrograde ? '(R)' : ''),
                        style: theme.textTheme.labelSmall?.copyWith(fontSize: 10, fontWeight: FontWeight.w700),
                      ))
                  .toList(),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Text(
              rashi.symbol,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(fontSize: 8.5, color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  String _grahaAbbr(Graha g) {
    switch (g) {
      case Graha.surya:
        return 'Su';
      case Graha.chandra:
        return 'Mo';
      case Graha.kuja:
        return 'Ma';
      case Graha.budha:
        return 'Me';
      case Graha.guru:
        return 'Ju';
      case Graha.shukra:
        return 'Ve';
      case Graha.shani:
        return 'Sa';
      case Graha.rahu:
        return 'Ra';
      case Graha.ketu:
        return 'Ke';
    }
  }
}
