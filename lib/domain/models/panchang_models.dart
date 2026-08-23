/// Domain models describing a single Panchangam day and its summary
/// elements (Tithi, Vara, Nakshatra, Paksha, Masa).
///
/// NOTE: All calculated field values produced by the mock data layer are
/// placeholder development data — see [PanchangDay.isMockCalculated].
/// A future deterministic Panchangam engine will populate these same
/// fields without any change to consuming widgets.
library;

/// The seven-day week (Vara), Telugu names included for display.
enum Vara {
  ravivaram('Ravivāram', 'ఆదివారం'),
  somavaram('Somavāram', 'సోమవారం'),
  mangalavaram('Mangaḷavāram', 'మంగళవారం'),
  budhavaram('Budhavāram', 'బుధవారం'),
  guruvaram('Guruvāram', 'గురువారం'),
  shukravaram('Śukravāram', 'శుక్రవారం'),
  shanivaram('Śanivāram', 'శనివారం');

  const Vara(this.transliteration, this.telugu);
  final String transliteration;
  final String telugu;
}

/// Waxing (Śukla) or waning (Kṛṣṇa) fortnight.
enum Paksha {
  shukla('Śukla Pakṣam', 'శుక్ల పక్షం'),
  krishna('Kṛṣṇa Pakṣam', 'కృష్ణ పక్షం');

  const Paksha(this.transliteration, this.telugu);
  final String transliteration;
  final String telugu;
}

/// One of the fifteen lunar days within a Paksha.
class Tithi {
  const Tithi({required this.index, required this.name, required this.telugu});

  /// 1-15 within the paksha.
  final int index;
  final String name;
  final String telugu;

  String get label => '$name ($index)';
}

/// The twelve Telugu lunar months, Ugadi (Chaitra) first.
enum TeluguMasa {
  chaitra('Chaitram', 'చైత్రం'),
  vaisakha('Vaiśākham', 'వైశాఖం'),
  jyeshtha('Jyēṣṭham', 'జ్యేష్ఠం'),
  ashadha('Āṣāḍham', 'ఆషాఢం'),
  shravana('Śrāvaṇam', 'శ్రావణం'),
  bhadrapada('Bhādrapadam', 'భాద్రపదం'),
  ashwayuja('Āśvayujam', 'ఆశ్వయుజం'),
  karthika('Kārtīkam', 'కార్తీకం'),
  margashira('Mārgaśiram', 'మార్గశిరం'),
  pushya('Puṣyam', 'పుష్యం'),
  magha('Māgham', 'మాఘం'),
  phalguna('Phālgunam', 'ఫాల్గుణం');

  const TeluguMasa(this.transliteration, this.telugu);
  final String transliteration;
  final String telugu;
}

/// A named Nakshatra reference used inside a Panchangam day (lightweight
/// — the richer [Nakshatra] domain model lives in jatakam_models.dart).
class NakshatraRef {
  const NakshatraRef({required this.name, required this.telugu, required this.pada});
  final String name;
  final String telugu;

  /// Which of the four padas (quarters) is active, 1-4.
  final int pada;
}

/// Auspicious/inauspicious time window shown on a day (e.g. Rāhu Kālam).
class MuhurtaWindow {
  const MuhurtaWindow({required this.label, required this.teluguLabel, required this.start, required this.end, this.isInauspicious = true});
  final String label;
  final String teluguLabel;
  final String start;
  final String end;
  final bool isInauspicious;
}

/// Category used to render a distinct, low-noise indicator on the
/// calendar grid for a given day.
enum SpecialDayType {
  none,
  majorFestival,
  observance,
  ekadashi,
  amavasya,
  purnima,
  sankranthi,
}

/// Full Panchangam detail for a single Gregorian date.
class PanchangDay {
  const PanchangDay({
    required this.date,
    required this.vara,
    required this.masa,
    required this.paksha,
    required this.tithi,
    required this.nakshatra,
    required this.sunrise,
    required this.sunset,
    required this.moonrise,
    required this.moonset,
    this.muhurtas = const [],
    this.specialDayType = SpecialDayType.none,
    this.festivalId,
    this.isMockCalculated = true,
  });

  final DateTime date;
  final Vara vara;
  final TeluguMasa masa;
  final Paksha paksha;
  final Tithi tithi;
  final NakshatraRef nakshatra;
  final String sunrise;
  final String sunset;
  final String moonrise;
  final String moonset;
  final List<MuhurtaWindow> muhurtas;
  final SpecialDayType specialDayType;
  final String? festivalId;

  /// True while values come from the mock generator rather than a real
  /// astronomical/Panchangam calculation engine.
  final bool isMockCalculated;

  bool get isSpecial => specialDayType != SpecialDayType.none;
}

/// Compact summary used on the Home dashboard "Today" card.
class PanchangSummary {
  const PanchangSummary({
    required this.date,
    required this.vara,
    required this.masa,
    required this.paksha,
    required this.tithi,
    required this.nakshatra,
    required this.sunrise,
    required this.sunset,
    this.isMockCalculated = true,
  });

  final DateTime date;
  final Vara vara;
  final TeluguMasa masa;
  final Paksha paksha;
  final Tithi tithi;
  final NakshatraRef nakshatra;
  final String sunrise;
  final String sunset;
  final bool isMockCalculated;
}
