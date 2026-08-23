import 'source_reference.dart';

enum FestivalImportance { major, moderate, observance }

/// A single configurable reminder lead-time.
enum ReminderLeadTime {
  sevenDays('7 days before', '1 వారం ముందు'),
  oneDay('1 day before', '1 రోజు ముందు'),
  twoHours('2 hours before', '2 గంటల ముందు');

  const ReminderLeadTime(this.label, this.teluguLabel);
  final String label;
  final String teluguLabel;
}

/// A festival / Parva Dinam entry.
class Festival {
  const Festival({
    required this.id,
    required this.name,
    required this.teluguName,
    required this.date,
    required this.importance,
    required this.shortSignificance,
    required this.significance,
    required this.observance,
    required this.preparation,
    this.mantraSources = const [],
    this.sources = const [],
    this.isMockCalculated = true,
  });

  final String id;
  final String name;
  final String teluguName;
  final DateTime date;
  final FestivalImportance importance;

  /// One-line summary for cards/timeline tiles.
  final String shortSignificance;

  /// Longer explanatory paragraph(s) for the detail screen.
  final String significance;
  final String observance;
  final String preparation;

  /// Mantra placeholders paired with the source they will eventually
  /// cite — content strings must remain "[VERIFIED CONTENT REQUIRED]"
  /// until a qualified source is attached.
  final List<SourceReference> mantraSources;
  final List<SourceReference> sources;

  /// True while the date is produced by the mock calendar generator
  /// rather than a verified Panchangam calculation.
  final bool isMockCalculated;
}

/// Per-festival override of the global reminder defaults.
class FestivalReminderOverride {
  const FestivalReminderOverride({required this.festivalId, required this.enabledLeadTimes});
  final String festivalId;
  final Set<ReminderLeadTime> enabledLeadTimes;

  FestivalReminderOverride copyWith({Set<ReminderLeadTime>? enabledLeadTimes}) {
    return FestivalReminderOverride(
      festivalId: festivalId,
      enabledLeadTimes: enabledLeadTimes ?? this.enabledLeadTimes,
    );
  }
}

/// Global + per-festival notification configuration.
class ReminderPreferences {
  const ReminderPreferences({
    this.globallyEnabled = true,
    this.defaultLeadTimes = const {ReminderLeadTime.oneDay, ReminderLeadTime.twoHours},
    this.overrides = const {},
  });

  final bool globallyEnabled;
  final Set<ReminderLeadTime> defaultLeadTimes;

  /// Keyed by festival id.
  final Map<String, FestivalReminderOverride> overrides;

  Set<ReminderLeadTime> leadTimesFor(String festivalId) {
    return overrides[festivalId]?.enabledLeadTimes ?? defaultLeadTimes;
  }

  ReminderPreferences copyWith({
    bool? globallyEnabled,
    Set<ReminderLeadTime>? defaultLeadTimes,
    Map<String, FestivalReminderOverride>? overrides,
  }) {
    return ReminderPreferences(
      globallyEnabled: globallyEnabled ?? this.globallyEnabled,
      defaultLeadTimes: defaultLeadTimes ?? this.defaultLeadTimes,
      overrides: overrides ?? this.overrides,
    );
  }
}
