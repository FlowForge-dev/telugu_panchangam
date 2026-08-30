import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app_state/repositories_scope.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/util/date_format.dart';
import '../../core/widgets/mock_data_badge.dart';
import '../../core/widgets/section_header.dart';
import '../../domain/models/festival_models.dart';
import '../../domain/models/panchang_models.dart';

class DayDetailScreen extends StatefulWidget {
  const DayDetailScreen({super.key, required this.date});

  final DateTime date;

  @override
  State<DayDetailScreen> createState() => _DayDetailScreenState();
}

class _DayDetailScreenState extends State<DayDetailScreen> {
  late Future<_DayData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_DayData> _load() async {
    final repos = context.read<Repositories>();
    final day = await repos.panchang.dayDetail(widget.date);
    Festival? festival;
    if (day.festivalId != null) {
      festival = await repos.festival.byId(day.festivalId!);
    }
    return _DayData(day: day, festival: festival);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(formatDayMonth(widget.date))),
      body: FutureBuilder<_DayData>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final day = snapshot.data!.day;
          final festival = snapshot.data!.festival;

          return ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppRadii.xl),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(formatDateLong(day.date), style: theme.textTheme.titleMedium)),
                          if (day.isMockCalculated) const MockDataBadge(),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '${day.masa.telugu} · ${day.paksha.telugu} · ${day.shakaSamvatYear} శక సంవత్సరం',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        children: [
                          Expanded(child: _InfoTile(label: 'వారం', value: day.vara.telugu, sub: day.vara.transliteration)),
                          Expanded(child: _InfoTile(label: 'తిథి', value: day.tithi.telugu, sub: day.tithi.label)),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        children: [
                          Expanded(
                            child: _InfoTile(
                              label: 'నక్షత్రం',
                              value: day.nakshatra.telugu,
                              sub: '${day.nakshatra.name} · Pada ${day.nakshatra.pada}',
                            ),
                          ),
                          Expanded(child: _InfoTile(label: 'యోగం', value: day.yoga.telugu, sub: day.yoga.name)),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _InfoTile(label: 'కరణం', value: day.karana.telugu, sub: day.karana.name),
                    ],
                  ),
                ),
              ),
              if (festival != null) ...[
                SectionHeader(title: 'Festival today', teluguTitle: 'నేటి పండుగ'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Material(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      onTap: () => context.push('/festivals/${festival.id}'),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(festival.name, style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
                                  Text(festival.teluguName, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_rounded, color: theme.colorScheme.onPrimaryContainer),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              SectionHeader(title: 'Sun & Moon', teluguTitle: 'సూర్య చంద్రోదయాలు'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  children: [
                    Expanded(child: _SkyTile(icon: Icons.wb_sunny_outlined, label: 'సూర్యోదయం', value: day.sunrise)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: _SkyTile(icon: Icons.wb_twilight_outlined, label: 'సూర్యాస్తమయం', value: day.sunset)),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  children: [
                    Expanded(child: _SkyTile(icon: Icons.nightlight_outlined, label: 'చంద్రోదయం', value: day.moonrise)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: _SkyTile(icon: Icons.dark_mode_outlined, label: 'చంద్రాస్తమయం', value: day.moonset)),
                  ],
                ),
              ),
              if (day.choghadiya.isNotEmpty) ...[
                SectionHeader(title: 'Choghadiya', teluguTitle: 'చౌఘడియ'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(
                    children: day.choghadiya
                        .map((c) => Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                              child: Container(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainer,
                                  borderRadius: BorderRadius.circular(AppRadii.md),
                                  border: Border(
                                    left: BorderSide(width: 4, color: _choghadiyaColor(theme, c.quality)),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(c.telugu, style: theme.textTheme.titleSmall),
                                          Text(c.name, style: theme.textTheme.bodySmall),
                                        ],
                                      ),
                                    ),
                                    Text('${c.start} – ${c.end}', style: theme.textTheme.bodyMedium),
                                  ],
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
              if (day.muhurtas.isNotEmpty) ...[
                SectionHeader(title: 'Inauspicious windows', teluguTitle: 'రాహు కాలం, యమగండం'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(
                    children: day.muhurtas
                        .map((m) => Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                              child: Container(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainer,
                                  borderRadius: BorderRadius.circular(AppRadii.md),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(m.label, style: theme.textTheme.titleSmall),
                                          Text(m.teluguLabel, style: theme.textTheme.bodySmall),
                                        ],
                                      ),
                                    ),
                                    Text('${m.start} – ${m.end}', style: theme.textTheme.bodyMedium),
                                  ],
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

Color _choghadiyaColor(ThemeData theme, ChoghadiyaQuality quality) {
  switch (quality) {
    case ChoghadiyaQuality.good:
      return theme.colorScheme.tertiary;
    case ChoghadiyaQuality.neutral:
      return theme.colorScheme.secondary;
    case ChoghadiyaQuality.inauspicious:
      return theme.colorScheme.onSurfaceVariant;
  }
}

class _DayData {
  const _DayData({required this.day, required this.festival});
  final PanchangDay day;
  final Festival? festival;
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value, required this.sub});
  final String label;
  final String value;
  final String sub;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 2),
        Text(value, style: theme.textTheme.titleMedium),
        Text(sub, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class _SkyTile extends StatelessWidget {
  const _SkyTile({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: AppSpacing.sm),
          Text(label, style: theme.textTheme.bodySmall),
          Text(value, style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}
