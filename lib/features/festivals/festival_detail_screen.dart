import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_state/app_state.dart';
import '../../app_state/repositories_scope.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/util/date_format.dart';
import '../../core/widgets/countdown_display.dart';
import '../../core/widgets/reminder_selector.dart';
import '../../core/widgets/source_reference_card.dart';
import '../../domain/models/festival_models.dart';

class FestivalDetailScreen extends StatefulWidget {
  const FestivalDetailScreen({super.key, required this.festivalId});

  final String festivalId;

  @override
  State<FestivalDetailScreen> createState() => _FestivalDetailScreenState();
}

class _FestivalDetailScreenState extends State<FestivalDetailScreen> {
  late Future<Festival?> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<Repositories>().festival.byId(widget.festivalId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Festival?>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final festival = snapshot.data;
          if (festival == null) {
            return const Center(child: Text('Festival not found'));
          }
          return _Content(festival: festival);
        },
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.festival});
  final Festival festival;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    final enabledLeadTimes = appState.reminderPreferences.leadTimesFor(festival.id);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 200,
          backgroundColor: theme.colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(left: 56, bottom: AppSpacing.md, right: AppSpacing.lg),
            title: Text(
              festival.name,
              style: theme.textTheme.titleLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [theme.colorScheme.primaryContainer, theme.colorScheme.surface],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 64, AppSpacing.lg, AppSpacing.xxxl),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  festival.teluguName,
                  style: theme.textTheme.headlineMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer),
                ),
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.calendar_today_outlined, size: 15, color: theme.colorScheme.onSurfaceVariant),
                                const SizedBox(width: 6),
                                Text(formatDateLong(festival.date), style: theme.textTheme.bodyMedium),
                              ],
                            ),
                          ],
                        ),
                      ),
                      CountdownDisplay(target: festival.date),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  _SectionTitle('Significance', 'ప్రాముఖ్యత'),
                  const SizedBox(height: AppSpacing.sm),
                  Text(festival.significance, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: AppSpacing.xxl),
                  _SectionTitle('Observance', 'ఆచరణ'),
                  const SizedBox(height: AppSpacing.sm),
                  Text(festival.observance, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: AppSpacing.xxl),
                  _SectionTitle('Preparation', 'సన్నాహం'),
                  const SizedBox(height: AppSpacing.sm),
                  Text(festival.preparation, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: AppSpacing.xxl),
                  _SectionTitle('Mantra', 'మంత్రం'),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      border: Border.all(color: theme.colorScheme.outlineVariant, style: BorderStyle.solid),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.shield_outlined, size: 18, color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Mantra text withheld pending citation from a verified traditional source.',
                            style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic, color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  _SectionTitle('Reminders', 'రిమైండర్‌లు'),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Choose when you\'d like to be reminded about this festival. Overrides the default reminder settings.',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ReminderSelector(
                    enabledLeadTimes: enabledLeadTimes,
                    enabled: appState.reminderPreferences.globallyEnabled,
                    onChanged: (updated) {
                      final removed = enabledLeadTimes.difference(updated);
                      final added = updated.difference(enabledLeadTimes);
                      for (final lt in added) {
                        appState.toggleFestivalLeadTime(festival.id, lt, true);
                      }
                      for (final lt in removed) {
                        appState.toggleFestivalLeadTime(festival.id, lt, false);
                      }
                    },
                  ),
                  if (!appState.reminderPreferences.globallyEnabled)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                      child: Text(
                        'Reminders are turned off globally. Enable them in Notification preferences.',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xxl),
                  _SectionTitle('Sources', 'ఆధారాలు'),
                  const SizedBox(height: AppSpacing.sm),
                  ...festival.sources.map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: SourceReferenceCard(source: s),
                      )),
                  ...festival.mantraSources.map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: SourceReferenceCard(source: s),
                      )),
                ],
              ),
            ),
          ]),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, this.telugu);
  final String title;
  final String telugu;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(title, style: theme.textTheme.headlineSmall),
        const SizedBox(width: AppSpacing.sm),
        Text(telugu, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}
