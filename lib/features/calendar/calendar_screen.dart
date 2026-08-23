import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app_state/repositories_scope.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/util/date_format.dart';
import '../../core/widgets/calendar_day_cell.dart';
import '../../data/mock/mock_seed_data.dart';
import '../../domain/models/panchang_models.dart';

const _weekdayHeaders = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _month;
  DateTime? _selected;
  Map<DateTime, PanchangDay> _days = {};
  bool _loading = true;

  late final DateTime _rangeStart = DateTime(kMockUgadiStart.year, kMockUgadiStart.month, 1);
  late final DateTime _rangeEnd = DateTime(kMockNextUgadiStart.year, kMockNextUgadiStart.month, 1);

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    _month = currentMonth.isBefore(_rangeStart)
        ? _rangeStart
        : (currentMonth.isAfter(_rangeEnd) ? _rangeEnd : currentMonth);
    _selected = isSameDay(now, DateTime.now()) && !currentMonth.isBefore(_rangeStart) && !currentMonth.isAfter(_rangeEnd) ? now : null;
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final repos = context.read<Repositories>();
    final gridStart = _gridStart(_month);
    final gridEnd = gridStart.add(const Duration(days: 41));
    final map = await repos.panchang.monthRange(gridStart, gridEnd);
    if (!mounted) return;
    setState(() {
      _days = map;
      _loading = false;
    });
  }

  DateTime _gridStart(DateTime month) {
    final firstOfMonth = DateTime(month.year, month.month, 1);
    final offset = firstOfMonth.weekday % 7; // Sunday = 0
    return firstOfMonth.subtract(Duration(days: offset));
  }

  void _changeMonth(int delta) {
    final next = DateTime(_month.year, _month.month + delta, 1);
    if (next.isBefore(_rangeStart) || next.isAfter(_rangeEnd)) return;
    setState(() => _month = next);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gridStart = _gridStart(_month);
    final canGoPrev = !DateTime(_month.year, _month.month - 1, 1).isBefore(_rangeStart);
    final canGoNext = !DateTime(_month.year, _month.month + 1, 1).isAfter(_rangeEnd);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search_rounded),
            onPressed: () => context.push('/search'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
              child: Row(
                children: [
                  Icon(Icons.brightness_low_rounded, size: 14, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Ugadi year: ${formatDateShort(kMockUgadiStart)} → ${formatDateShort(kMockNextUgadiStart)}',
                      style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: canGoPrev ? () => _changeMonth(-1) : null,
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Column(
                  children: [
                    Text(formatMonthYear(_month), style: theme.textTheme.headlineSmall),
                    if (_days[_month]?.masa != null)
                      Text(
                        _days[_month]!.masa.transliteration,
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                  ],
                ),
                IconButton(
                  onPressed: canGoNext ? () => _changeMonth(1) : null,
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                for (final w in _weekdayHeaders)
                  Expanded(
                    child: Center(
                      child: Text(w, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 0.82),
                      itemCount: 42,
                      itemBuilder: (context, i) {
                        final date = gridStart.add(Duration(days: i));
                        final day = _days[DateTime(date.year, date.month, date.day)];
                        final inCurrentMonth = date.month == _month.month;
                        final isToday = isSameDay(date, DateTime.now());
                        final isSelected = _selected != null && isSameDay(date, _selected!);
                        return CalendarDayCell(
                          date: date,
                          panchangDay: day,
                          isSelected: isSelected,
                          isToday: isToday,
                          inCurrentMonth: inCurrentMonth,
                          onTap: () {
                            setState(() => _selected = date);
                            context.push('/calendar/day/${date.toIso8601String().split('T').first}');
                          },
                        );
                      },
                    ),
                  ),
          ),
          _CalendarLegend(theme: theme),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}

class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    Widget dot(Color c) => Container(width: 6, height: 6, margin: const EdgeInsets.only(right: 5), decoration: BoxDecoration(color: c, shape: BoxShape.circle));
    Widget item(Color c, String label) => Padding(
          padding: const EdgeInsets.only(right: AppSpacing.md),
          child: Row(mainAxisSize: MainAxisSize.min, children: [dot(c), Text(label, style: theme.textTheme.labelSmall)]),
        );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          item(theme.colorScheme.primary, 'Festival'),
          item(theme.colorScheme.secondary, 'Ekadashi / Purnima'),
          item(theme.colorScheme.tertiary, 'Observance'),
          item(theme.colorScheme.onSurfaceVariant, 'Amavasya'),
        ],
      ),
    );
  }
}
