import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_state/app_state.dart';
import '../../app_state/repositories_scope.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/util/date_format.dart';
import '../../core/widgets/bilingual_title.dart';
import '../../domain/models/profile_models.dart';

class BirthDetailsFormScreen extends StatefulWidget {
  const BirthDetailsFormScreen({super.key});

  @override
  State<BirthDetailsFormScreen> createState() => _BirthDetailsFormScreenState();
}

class _BirthDetailsFormScreenState extends State<BirthDetailsFormScreen> {
  DateTime? _date;
  TimeOfDay? _time;
  TimeAccuracy _accuracy = TimeAccuracy.exact;
  BirthPlace? _place;

  final _placeController = TextEditingController();
  Timer? _debounce;
  List<BirthPlace> _suggestions = [];
  bool _searchingPlace = false;

  @override
  void initState() {
    super.initState();
    final existing = context.read<AppState>().profile?.birthDetails;
    if (existing != null) {
      _date = existing.date;
      _time = TimeOfDay(hour: existing.time.hour, minute: existing.time.minute);
      _accuracy = existing.timeAccuracy;
      _place = existing.place;
      _placeController.text = existing.place.displayName;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _placeController.dispose();
    super.dispose();
  }

  void _onPlaceChanged(String value) {
    _place = null;
    _debounce?.cancel();
    setState(() => _searchingPlace = value.trim().isNotEmpty);
    _debounce = Timer(const Duration(milliseconds: 250), () async {
      final repos = context.read<Repositories>();
      final results = await repos.profile.suggestPlaces(value);
      if (!mounted) return;
      setState(() {
        _suggestions = results;
        _searchingPlace = false;
      });
    });
  }

  bool get _canSave => _date != null && _time != null && _place != null;

  Future<void> _save() async {
    if (!_canSave) return;
    final appState = context.read<AppState>();
    final current = appState.profile;
    final details = BirthDetails(
      date: _date!,
      time: BirthTime(hour: _time!.hour, minute: _time!.minute),
      place: _place!,
      timeAccuracy: _accuracy,
    );
    await appState.saveProfile(
      UserProfile(name: current?.name ?? '', birthDetails: details),
    );
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const BilingualTitle(telugu: 'జనన వివరాలు', english: 'Birth details')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.huge),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, size: 18, color: theme.colorScheme.onSecondaryContainer),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Exact birth time and place materially change Jyotisha calculations — especially the Lagna '
                    '(ascendant). Enter your most accurate information for a reliable Jatakam.',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSecondaryContainer),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          _FieldLabel(theme: theme, telugu: 'పుట్టిన తేదీ', english: 'Date of birth'),
          const SizedBox(height: AppSpacing.sm),
          _PickerField(
            icon: Icons.calendar_today_outlined,
            label: _date == null ? 'Select date' : formatDateLong(_date!),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _date ?? DateTime(1995, 1, 1),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (picked != null) setState(() => _date = picked);
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          _FieldLabel(theme: theme, telugu: 'పుట్టిన సమయం', english: 'Time of birth'),
          const SizedBox(height: AppSpacing.sm),
          _PickerField(
            icon: Icons.schedule_outlined,
            label: _time == null ? 'Select time' : _time!.format(context),
            onTap: () async {
              final picked = await showTimePicker(context: context, initialTime: _time ?? const TimeOfDay(hour: 6, minute: 0));
              if (picked != null) setState(() => _time = picked);
            },
          ),
          const SizedBox(height: AppSpacing.md),
          Text('How accurate is this time?', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: TimeAccuracy.values.map((a) {
              return ChoiceChip(
                label: Text(a.label),
                selected: _accuracy == a,
                onSelected: (_) => setState(() => _accuracy = a),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.xl),
          _FieldLabel(theme: theme, telugu: 'పుట్టిన స్థలం', english: 'Place of birth'),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _placeController,
            onChanged: _onPlaceChanged,
            decoration: InputDecoration(
              hintText: 'Start typing a city…',
              prefixIcon: const Icon(Icons.place_outlined),
              suffixIcon: _searchingPlace
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : null,
            ),
          ),
          if (_place != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: _ResolvedPlaceCard(place: _place!),
            ),
          if (_suggestions.isNotEmpty && _place == null)
            Container(
              margin: const EdgeInsets.only(top: AppSpacing.sm),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Column(
                children: _suggestions
                    .map((p) => ListTile(
                          leading: const Icon(Icons.location_on_outlined),
                          title: Text(p.displayName),
                          subtitle: Text(p.subtitle),
                          onTap: () {
                            setState(() {
                              _place = p;
                              _placeController.text = p.displayName;
                              _suggestions = [];
                            });
                          },
                        ))
                    .toList(),
              ),
            ),
          const SizedBox(height: AppSpacing.xxxl),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _canSave ? _save : null,
              child: const Text('సేవ్ చేయండి • Save'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.theme, required this.telugu, required this.english});
  final ThemeData theme;
  final String telugu;
  final String english;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(telugu, style: theme.textTheme.titleMedium),
        const SizedBox(width: 6),
        Text(english, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: AppSpacing.md),
            Text(label, style: theme.textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}

class _ResolvedPlaceCard extends StatelessWidget {
  const _ResolvedPlaceCard({required this.place});
  final BirthPlace place;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline_rounded, size: 18, color: theme.colorScheme.onTertiaryContainer),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Resolved: ${place.displayName}, ${place.subtitle}'
              '${place.isMockResolved ? ' — coordinates & timezone are placeholder values' : ''}',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onTertiaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}
