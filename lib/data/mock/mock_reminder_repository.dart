import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/festival_models.dart';
import '../../domain/repositories/repositories.dart';

class MockReminderRepository implements ReminderRepository {
  static const _kPrefsKey = 'mock_reminder_preferences_v1';

  @override
  Future<ReminderPreferences> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kPrefsKey);
    if (raw == null) return const ReminderPreferences();
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final defaultLeadTimes = (map['defaultLeadTimes'] as List)
          .map((i) => ReminderLeadTime.values[i as int])
          .toSet();
      final overridesMap = <String, FestivalReminderOverride>{};
      final overridesRaw = map['overrides'] as Map<String, dynamic>? ?? {};
      overridesRaw.forEach((key, value) {
        final leadTimes = (value as List).map((i) => ReminderLeadTime.values[i as int]).toSet();
        overridesMap[key] = FestivalReminderOverride(festivalId: key, enabledLeadTimes: leadTimes);
      });
      return ReminderPreferences(
        globallyEnabled: map['globallyEnabled'] as bool? ?? true,
        defaultLeadTimes: defaultLeadTimes,
        overrides: overridesMap,
      );
    } catch (_) {
      return const ReminderPreferences();
    }
  }

  @override
  Future<void> savePreferences(ReminderPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    final map = {
      'globallyEnabled': preferences.globallyEnabled,
      'defaultLeadTimes': preferences.defaultLeadTimes.map((e) => e.index).toList(),
      'overrides': preferences.overrides.map(
        (key, value) => MapEntry(key, value.enabledLeadTimes.map((e) => e.index).toList()),
      ),
    };
    await prefs.setString(_kPrefsKey, jsonEncode(map));
  }
}
