import 'package:flutter/material.dart';
import '../../domain/models/panchang_models.dart';
import '../theme/app_spacing.dart';

/// A single day cell in the Panchangam calendar grid. Shows the
/// Gregorian day number plus the Tithi index as small Telugu-calendar
/// context, and a restrained dot/ring language for special days so the
/// grid stays legible rather than noisy.
class CalendarDayCell extends StatelessWidget {
  const CalendarDayCell({
    super.key,
    required this.date,
    required this.panchangDay,
    required this.isSelected,
    required this.isToday,
    required this.inCurrentMonth,
    required this.onTap,
  });

  final DateTime date;
  final PanchangDay? panchangDay;
  final bool isSelected;
  final bool isToday;
  final bool inCurrentMonth;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    Color bg = Colors.transparent;
    Color fg = inCurrentMonth ? scheme.onSurface : scheme.onSurfaceVariant.withValues(alpha: 0.35);
    Border? border;

    if (isSelected) {
      bg = scheme.primary;
      fg = scheme.onPrimary;
    } else if (isToday) {
      border = Border.all(color: scheme.primary, width: 1.4);
    }

    final indicatorColor = _indicatorColor(scheme);

    return Semantics(
      label: _semanticLabel(),
      button: true,
      selected: isSelected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          margin: const EdgeInsets.all(2),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: border,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${date.day}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: fg,
                  fontWeight: isToday || isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              if (panchangDay != null)
                Text(
                  'T${panchangDay!.tithi.index}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 9,
                    color: isSelected ? scheme.onPrimary.withValues(alpha: 0.85) : scheme.onSurfaceVariant.withValues(alpha: 0.8),
                  ),
                )
              else
                const SizedBox(height: 11),
              const SizedBox(height: 3),
              SizedBox(
                height: 5,
                child: indicatorColor != null
                    ? Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: isSelected ? scheme.onPrimary : indicatorColor,
                          shape: BoxShape.circle,
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color? _indicatorColor(ColorScheme scheme) {
    final day = panchangDay;
    if (day == null) return null;
    switch (day.specialDayType) {
      case SpecialDayType.majorFestival:
        return scheme.primary;
      case SpecialDayType.observance:
        return scheme.tertiary;
      case SpecialDayType.ekadashi:
        return scheme.secondary;
      case SpecialDayType.amavasya:
        return scheme.onSurfaceVariant;
      case SpecialDayType.purnima:
        return scheme.secondary;
      case SpecialDayType.sankranthi:
        return scheme.primary;
      case SpecialDayType.none:
        return null;
    }
  }

  String _semanticLabel() {
    final base = '${date.day}';
    if (panchangDay == null) return base;
    return '$base, Tithi ${panchangDay!.tithi.name}${panchangDay!.isSpecial ? ', special day' : ''}';
  }
}
