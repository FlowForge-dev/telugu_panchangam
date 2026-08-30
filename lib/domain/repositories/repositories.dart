/// Repository interfaces (ports). The presentation layer depends only
/// on these abstractions; `data/mock/*` provides today's implementation
/// and a future `data/live/*` package can swap in a deterministic
/// Panchangam/Jyotisha backend without any UI changes.
library;

import '../models/panchang_models.dart';
import '../models/festival_models.dart';
import '../models/profile_models.dart';
import '../models/jatakam_models.dart';
import '../models/vrata_models.dart';
import '../models/devotional_models.dart';

abstract class PanchangRepository {
  /// The Panchangam year is anchored Ugadi -> next Ugadi rather than a
  /// Gregorian calendar year.
  Future<DateTime> ugadiStartFor(DateTime withinGregorianYear);

  Future<PanchangSummary> summaryFor(DateTime date);

  Future<PanchangDay> dayDetail(DateTime date);

  /// All days between [start] and [end] inclusive, keyed by midnight
  /// UTC-normalized date, for calendar-grid rendering.
  Future<Map<DateTime, PanchangDay>> monthRange(DateTime start, DateTime end);
}

abstract class FestivalRepository {
  Future<List<Festival>> all();

  Future<Festival?> byId(String id);

  Future<Festival?> nextUpcoming({DateTime? from});

  Future<List<Festival>> upcoming({DateTime? from, int limit = 10});

  Future<List<Festival>> search(String query);
}

abstract class ProfileRepository {
  Future<UserProfile?> loadProfile();

  Future<void> saveProfile(UserProfile profile);

  Future<BirthPlace> resolvePlace(String query);

  Future<List<BirthPlace>> suggestPlaces(String query);

  Future<bool> hasSeenOnboarding();

  Future<void> setSeenOnboarding();
}

abstract class JatakamRepository {
  /// Derives a mock Jatakam deterministically from [details] so the UI
  /// consistently shows the "same" chart for the same birth details
  /// during this frontend-only phase.
  Future<Jatakam> computeFor(BirthDetails details);
}

abstract class JapaRepository {
  Future<List<JapaRecommendation>> recommendationsFor(Jatakam jatakam);

  Future<List<JapaRecommendation>> general();
}

abstract class ReminderRepository {
  Future<ReminderPreferences> loadPreferences();

  Future<void> savePreferences(ReminderPreferences preferences);
}

abstract class VrataRepository {
  Future<List<VrataObservance>> all();
}

abstract class DevotionalRepository {
  Future<List<DevotionalText>> all();

  Future<DevotionalText?> byId(String id);
}
