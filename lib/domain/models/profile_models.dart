/// A resolved geographic location for a birthplace. Latitude/longitude
/// /timezone are placeholders here — the real implementation will come
/// from a geocoding backend; the mock resolver just fabricates
/// plausible-looking values so downstream UI/data-flow can be exercised.
class BirthPlace {
  const BirthPlace({
    required this.displayName,
    required this.region,
    required this.country,
    this.latitude,
    this.longitude,
    this.timezone,
    this.isMockResolved = true,
  });

  final String displayName;
  final String region;
  final String country;
  final double? latitude;
  final double? longitude;
  final String? timezone;

  /// True while lat/long/timezone come from the mock location lookup
  /// rather than a real geocoding + timezone service.
  final bool isMockResolved;

  String get subtitle => [region, country].where((s) => s.isNotEmpty).join(', ');
}

/// Birth details entered by the user. Accuracy of [time] and
/// [place] materially affects any future Jyotisha calculation, so the
/// form UI must make their importance obvious.
class BirthDetails {
  const BirthDetails({
    required this.date,
    required this.time,
    required this.place,
    this.timeAccuracy = TimeAccuracy.exact,
  });

  final DateTime date;

  /// Local clock time at [place], stored as hour/minute.
  final BirthTime time;
  final BirthPlace place;
  final TimeAccuracy timeAccuracy;

  BirthDetails copyWith({
    DateTime? date,
    BirthTime? time,
    BirthPlace? place,
    TimeAccuracy? timeAccuracy,
  }) {
    return BirthDetails(
      date: date ?? this.date,
      time: time ?? this.time,
      place: place ?? this.place,
      timeAccuracy: timeAccuracy ?? this.timeAccuracy,
    );
  }
}

class BirthTime {
  const BirthTime({required this.hour, required this.minute});
  final int hour;
  final int minute;

  String get formatted12h {
    final period = hour >= 12 ? 'PM' : 'AM';
    final h12 = hour % 12 == 0 ? 12 : hour % 12;
    return '${h12.toString()}:${minute.toString().padLeft(2, '0')} $period';
  }
}

/// How precisely the user knows their birth time — later feeds into how
/// confidently a real engine can compute Lagna (ascendant).
enum TimeAccuracy {
  exact('Exact, from a record', 'ఖచ్చితమైనది'),
  approximate('Approximate (± 15-30 min)', 'సుమారుగా'),
  unknown('Not known', 'తెలియదు');

  const TimeAccuracy(this.label, this.telugu);
  final String label;
  final String telugu;
}

/// The user's overall profile.
class UserProfile {
  const UserProfile({required this.name, this.birthDetails});

  final String name;
  final BirthDetails? birthDetails;

  bool get hasBirthDetails => birthDetails != null;

  UserProfile copyWith({String? name, BirthDetails? birthDetails}) {
    return UserProfile(
      name: name ?? this.name,
      birthDetails: birthDetails ?? this.birthDetails,
    );
  }
}
