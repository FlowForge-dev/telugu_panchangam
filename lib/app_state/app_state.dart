// Fields are private but the constructor exposes public named parameters
// for a clean call site from main.dart, so initializing formals (which
// would force the private field name onto the parameter) are not used.
// ignore_for_file: prefer_initializing_formals
import 'package:flutter/foundation.dart';

import '../domain/models/festival_models.dart';
import '../domain/models/jatakam_models.dart';
import '../domain/models/profile_models.dart';
import '../domain/repositories/repositories.dart';

/// Single app-wide state container. Screens read this via Provider
/// instead of talking to repositories directly, so widgets never touch
/// hardcoded mock objects and the whole app reacts consistently when
/// the profile or preferences change.
class AppState extends ChangeNotifier {
  AppState({
    required ProfileRepository profileRepository,
    required JatakamRepository jatakamRepository,
    required ReminderRepository reminderRepository,
  })  : _profileRepository = profileRepository,
        _jatakamRepository = jatakamRepository,
        _reminderRepository = reminderRepository;

  final ProfileRepository _profileRepository;
  final JatakamRepository _jatakamRepository;
  final ReminderRepository _reminderRepository;

  bool _bootstrapped = false;
  bool get bootstrapped => _bootstrapped;

  bool hasSeenOnboarding = false;

  UserProfile? profile;
  Jatakam? jatakam;
  bool jatakamLoading = false;

  ReminderPreferences reminderPreferences = const ReminderPreferences();

  Future<void> bootstrap() async {
    hasSeenOnboarding = await _profileRepository.hasSeenOnboarding();
    profile = await _profileRepository.loadProfile();
    reminderPreferences = await _reminderRepository.loadPreferences();
    if (profile?.birthDetails != null) {
      await _recomputeJatakam();
    }
    _bootstrapped = true;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    hasSeenOnboarding = true;
    await _profileRepository.setSeenOnboarding();
    notifyListeners();
  }

  Future<void> saveProfile(UserProfile newProfile) async {
    profile = newProfile;
    await _profileRepository.saveProfile(newProfile);
    notifyListeners();
    if (newProfile.birthDetails != null) {
      await _recomputeJatakam();
    }
  }

  Future<void> _recomputeJatakam() async {
    final details = profile?.birthDetails;
    if (details == null) return;
    jatakamLoading = true;
    notifyListeners();
    jatakam = await _jatakamRepository.computeFor(details);
    jatakamLoading = false;
    notifyListeners();
  }

  Future<void> updateReminderPreferences(ReminderPreferences prefs) async {
    reminderPreferences = prefs;
    await _reminderRepository.savePreferences(prefs);
    notifyListeners();
  }

  Future<void> setGlobalRemindersEnabled(bool enabled) {
    return updateReminderPreferences(reminderPreferences.copyWith(globallyEnabled: enabled));
  }

  Future<void> toggleDefaultLeadTime(ReminderLeadTime leadTime, bool enabled) {
    final updated = Set<ReminderLeadTime>.from(reminderPreferences.defaultLeadTimes);
    if (enabled) {
      updated.add(leadTime);
    } else {
      updated.remove(leadTime);
    }
    return updateReminderPreferences(reminderPreferences.copyWith(defaultLeadTimes: updated));
  }

  Future<void> toggleFestivalLeadTime(String festivalId, ReminderLeadTime leadTime, bool enabled) {
    final current = reminderPreferences.leadTimesFor(festivalId);
    final updated = Set<ReminderLeadTime>.from(current);
    if (enabled) {
      updated.add(leadTime);
    } else {
      updated.remove(leadTime);
    }
    final overrides = Map<String, FestivalReminderOverride>.from(reminderPreferences.overrides);
    overrides[festivalId] = FestivalReminderOverride(festivalId: festivalId, enabledLeadTimes: updated);
    return updateReminderPreferences(reminderPreferences.copyWith(overrides: overrides));
  }
}
