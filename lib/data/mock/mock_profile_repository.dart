import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/profile_models.dart';
import '../../domain/repositories/repositories.dart';

/// Known settlements used by the mock location lookup. A real backend
/// would call a geocoding service; here we just match against a small
/// fixture list and fabricate plausible-looking lat/long/timezone so
/// the rest of the pipeline can be exercised end-to-end.
const List<BirthPlace> _mockPlaces = [
  BirthPlace(displayName: 'Hyderabad', region: 'Telangana', country: 'India', latitude: 17.3850, longitude: 78.4867, timezone: 'Asia/Kolkata'),
  BirthPlace(displayName: 'Secunderabad', region: 'Telangana', country: 'India', latitude: 17.4399, longitude: 78.4983, timezone: 'Asia/Kolkata'),
  BirthPlace(displayName: 'Warangal', region: 'Telangana', country: 'India', latitude: 17.9689, longitude: 79.5941, timezone: 'Asia/Kolkata'),
  BirthPlace(displayName: 'Vijayawada', region: 'Andhra Pradesh', country: 'India', latitude: 16.5062, longitude: 80.6480, timezone: 'Asia/Kolkata'),
  BirthPlace(displayName: 'Visakhapatnam', region: 'Andhra Pradesh', country: 'India', latitude: 17.6868, longitude: 83.2185, timezone: 'Asia/Kolkata'),
  BirthPlace(displayName: 'Tirupati', region: 'Andhra Pradesh', country: 'India', latitude: 13.6288, longitude: 79.4192, timezone: 'Asia/Kolkata'),
  BirthPlace(displayName: 'Guntur', region: 'Andhra Pradesh', country: 'India', latitude: 16.3067, longitude: 80.4365, timezone: 'Asia/Kolkata'),
  BirthPlace(displayName: 'Kakinada', region: 'Andhra Pradesh', country: 'India', latitude: 16.9891, longitude: 82.2475, timezone: 'Asia/Kolkata'),
  BirthPlace(displayName: 'Nellore', region: 'Andhra Pradesh', country: 'India', latitude: 14.4426, longitude: 79.9865, timezone: 'Asia/Kolkata'),
  BirthPlace(displayName: 'Chennai', region: 'Tamil Nadu', country: 'India', latitude: 13.0827, longitude: 80.2707, timezone: 'Asia/Kolkata'),
  BirthPlace(displayName: 'Bengaluru', region: 'Karnataka', country: 'India', latitude: 12.9716, longitude: 77.5946, timezone: 'Asia/Kolkata'),
  BirthPlace(displayName: 'Mumbai', region: 'Maharashtra', country: 'India', latitude: 19.0760, longitude: 72.8777, timezone: 'Asia/Kolkata'),
  BirthPlace(displayName: 'New Delhi', region: 'Delhi', country: 'India', latitude: 28.6139, longitude: 77.2090, timezone: 'Asia/Kolkata'),
];

class MockProfileRepository implements ProfileRepository {
  static const _kProfileName = 'mock_profile_name';
  static const _kBirthDate = 'mock_profile_birth_date';
  static const _kBirthHour = 'mock_profile_birth_hour';
  static const _kBirthMinute = 'mock_profile_birth_minute';
  static const _kBirthAccuracy = 'mock_profile_birth_accuracy';
  static const _kPlaceName = 'mock_profile_place_name';
  static const _kOnboarding = 'mock_onboarding_seen';

  @override
  Future<UserProfile?> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_kProfileName);
    if (name == null) return null;

    BirthDetails? birthDetails;
    final dateMillis = prefs.getInt(_kBirthDate);
    if (dateMillis != null) {
      final placeName = prefs.getString(_kPlaceName);
      final place = _mockPlaces.firstWhere(
        (p) => p.displayName == placeName,
        orElse: () => _mockPlaces.first,
      );
      birthDetails = BirthDetails(
        date: DateTime.fromMillisecondsSinceEpoch(dateMillis),
        time: BirthTime(hour: prefs.getInt(_kBirthHour) ?? 6, minute: prefs.getInt(_kBirthMinute) ?? 0),
        place: place,
        timeAccuracy: TimeAccuracy.values[prefs.getInt(_kBirthAccuracy) ?? 0],
      );
    }
    return UserProfile(name: name, birthDetails: birthDetails);
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kProfileName, profile.name);
    final details = profile.birthDetails;
    if (details != null) {
      await prefs.setInt(_kBirthDate, details.date.millisecondsSinceEpoch);
      await prefs.setInt(_kBirthHour, details.time.hour);
      await prefs.setInt(_kBirthMinute, details.time.minute);
      await prefs.setInt(_kBirthAccuracy, details.timeAccuracy.index);
      await prefs.setString(_kPlaceName, details.place.displayName);
    }
  }

  @override
  Future<BirthPlace> resolvePlace(String query) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final matches = await suggestPlaces(query);
    if (matches.isNotEmpty) return matches.first;
    return BirthPlace(
      displayName: query,
      region: '',
      country: '',
      isMockResolved: true,
    );
  }

  @override
  Future<List<BirthPlace>> suggestPlaces(String query) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];
    return _mockPlaces.where((p) => p.displayName.toLowerCase().contains(q)).toList();
  }

  @override
  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kOnboarding) ?? false;
  }

  @override
  Future<void> setSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboarding, true);
  }
}
