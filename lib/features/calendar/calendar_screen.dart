import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app_state/repositories_scope.dart';
import '../../core/util/date_format.dart';
import '../../data/mock/mock_seed_data.dart';
import '../../domain/models/panchang_models.dart';

const _weekdayHeaders = ['ఆది', 'సోమ', 'మం', 'బుధ', 'గురు', 'శుక్ర', 'శని'];

/// A clean, Google-Calendar-style month grid on a white background,
/// showing Telugu Panchangam context (tithi + festival) per day.
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
    _selected = !currentMonth.isBefore(_rangeStart) && !currentMonth.isAfter(_rangeEnd) ? now : null;
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

  void _goToday() {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    if (currentMonth.isBefore(_rangeStart) || currentMonth.isAfter(_rangeEnd)) return;
    setState(() {
      _month = currentMonth;
      _selected = now;
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF000000);
    const gridLine = Color(0xFFE0E0E0);
    const accent = Color(0xFF000000);

    final gridStart = _gridStart(_month);
    final canGoPrev = !DateTime(_month.year, _month.month - 1, 1).isBefore(_rangeStart);
    final canGoNext = !DateTime(_month.year, _month.month + 1, 1).isAfter(_rangeEnd);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        titleSpacing: 4,
        title: Row(
          children: [
            OutlinedButton(
              onPressed: _goToday,
              style: OutlinedButton.styleFrom(
                foregroundColor: ink,
                side: const BorderSide(color: gridLine),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: const Text('ఈరోజు'),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: canGoPrev ? () => _changeMonth(-1) : null,
              icon: const Icon(Icons.chevron_left_rounded),
              color: ink,
            ),
            IconButton(
              onPressed: canGoNext ? () => _changeMonth(1) : null,
              icon: const Icon(Icons.chevron_right_rounded),
              color: ink,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatMonthYear(_month),
                    style: const TextStyle(color: ink, fontSize: 20, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _days[_month]?.masa.telugu ?? '',
                    style: const TextStyle(color: Color(0xFF70757A), fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search_rounded, color: ink),
            onPressed: () => context.push('/search'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: gridLine))),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                for (final w in _weekdayHeaders)
                  Expanded(
                    child: Center(
                      child: Text(
                        w,
                        style: const TextStyle(color: Color(0xFF70757A), fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: List.generate(6, (row) {
                      return Expanded(
                        child: Row(
                          children: List.generate(7, (col) {
                            final i = row * 7 + col;
                            final date = gridStart.add(Duration(days: i));
                            final day = _days[DateTime(date.year, date.month, date.day)];
                            final inCurrentMonth = date.month == _month.month;
                            final isToday = isSameDay(date, DateTime.now());
                            final isSelected = _selected != null && isSameDay(date, _selected!);
                            return Expanded(
                              child: _GoogleStyleDayCell(
                                date: date,
                                panchangDay: day,
                                inCurrentMonth: inCurrentMonth,
                                isToday: isToday,
                                isSelected: isSelected,
                                accent: accent,
                                gridLine: gridLine,
                                ink: ink,
                                onTap: () {
                                  setState(() => _selected = date);
                                  context.push('/calendar/day/${date.toIso8601String().split('T').first}');
                                },
                              ),
                            );
                          }),
                        ),
                      );
                    }),
                  ),
          ),
        ],
      ),
    );
  }
}

class _GoogleStyleDayCell extends StatelessWidget {
  const _GoogleStyleDayCell({
    required this.date,
    required this.panchangDay,
    required this.inCurrentMonth,
    required this.isToday,
    required this.isSelected,
    required this.accent,
    required this.gridLine,
    required this.ink,
    required this.onTap,
  });

  final DateTime date;
  final PanchangDay? panchangDay;
  final bool inCurrentMonth;
  final bool isToday;
  final bool isSelected;
  final Color accent;
  final Color gridLine;
  final Color ink;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final numberColor = !inCurrentMonth ? const Color(0xFFBDBDBD) : (isToday ? Colors.white : ink);
    final hasFestival = panchangDay?.festivalId != null;

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: gridLine, width: 0.5),
          color: isSelected ? const Color(0xFFF0F0F0) : Colors.white,
        ),
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isToday ? accent : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${date.day}',
                style: TextStyle(color: numberColor, fontSize: 13, fontWeight: isToday ? FontWeight.w700 : FontWeight.w400),
              ),
            ),
            if (panchangDay != null && inCurrentMonth) ...[
              const SizedBox(height: 2),
              Text(
                'తి.${panchangDay!.tithi.index}',
                style: const TextStyle(color: Color(0xFF70757A), fontSize: 9.5),
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (hasFestival && inCurrentMonth) ...[
              const SizedBox(height: 2),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(3)),
                child: const Text(
                  'పండుగ',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white, fontSize: 9),
                ),
              ),
            ] else if (panchangDay?.isSpecial == true && inCurrentMonth) ...[
              const SizedBox(height: 2),
              Container(width: 5, height: 5, decoration: const BoxDecoration(color: Color(0xFF757575), shape: BoxShape.circle)),
            ],
          ],
        ),
      ),
    );
  }
}
