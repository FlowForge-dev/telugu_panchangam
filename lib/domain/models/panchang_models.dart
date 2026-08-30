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

/// One of the 27 Yogas (Sun+Moon longitude combination).
class PanchangYoga {
  const PanchangYoga({required this.index, required this.name, required this.telugu});

  /// 1-27.
  final int index;
  final String name;
  final String telugu;
}

/// One of the 11 Karanas (half-Tithi division).
class Karana {
  const Karana({required this.name, required this.telugu});
  final String name;
  final String telugu;
}

/// A single Choghadiya window used for coarse day/night muhurta planning.
enum ChoghadiyaQuality { good, neutral, inauspicious }

class ChoghadiyaPeriod {
  const ChoghadiyaPeriod({
    required this.name,
    required this.telugu,
    required this.start,
    required this.end,
    required this.quality,
  });
  final String name;
  final String telugu;
  final String start;
  final String end;
  final ChoghadiyaQuality quality;
}

/// The 27 Yogas, in standard order.
class PanchangYogas {
  PanchangYogas._();
  static const List<PanchangYoga> all = [
    PanchangYoga(index: 1, name: 'Vishkambha', telugu: 'విష్కంభ'),
    PanchangYoga(index: 2, name: 'Priti', telugu: 'ప్రీతి'),
    PanchangYoga(index: 3, name: 'Ayushman', telugu: 'ఆయుష్మాన్'),
    PanchangYoga(index: 4, name: 'Saubhagya', telugu: 'సౌభాగ్య'),
    PanchangYoga(index: 5, name: 'Shobhana', telugu: 'శోభన'),
    PanchangYoga(index: 6, name: 'Atiganda', telugu: 'అతిగండ'),
    PanchangYoga(index: 7, name: 'Sukarma', telugu: 'సుకర్మ'),
    PanchangYoga(index: 8, name: 'Dhriti', telugu: 'ధృతి'),
    PanchangYoga(index: 9, name: 'Shoola', telugu: 'శూల'),
    PanchangYoga(index: 10, name: 'Ganda', telugu: 'గండ'),
    PanchangYoga(index: 11, name: 'Vriddhi', telugu: 'వృద్ధి'),
    PanchangYoga(index: 12, name: 'Dhruva', telugu: 'ధ్రువ'),
    PanchangYoga(index: 13, name: 'Vyaghata', telugu: 'వ్యాఘాత'),
    PanchangYoga(index: 14, name: 'Harshana', telugu: 'హర్షణ'),
    PanchangYoga(index: 15, name: 'Vajra', telugu: 'వజ్ర'),
    PanchangYoga(index: 16, name: 'Siddhi', telugu: 'సిద్ధి'),
    PanchangYoga(index: 17, name: 'Vyatipata', telugu: 'వ్యతీపాత'),
    PanchangYoga(index: 18, name: 'Variyana', telugu: 'వరీయాన్'),
    PanchangYoga(index: 19, name: 'Parigha', telugu: 'పరిఘ'),
    PanchangYoga(index: 20, name: 'Shiva', telugu: 'శివ'),
    PanchangYoga(index: 21, name: 'Siddha', telugu: 'సిద్ధ'),
    PanchangYoga(index: 22, name: 'Sadhya', telugu: 'సాధ్య'),
    PanchangYoga(index: 23, name: 'Shubha', telugu: 'శుభ'),
    PanchangYoga(index: 24, name: 'Shukla', telugu: 'శుక్ల'),
    PanchangYoga(index: 25, name: 'Brahma', telugu: 'బ్రహ్మ'),
    PanchangYoga(index: 26, name: 'Indra', telugu: 'ఇంద్ర'),
    PanchangYoga(index: 27, name: 'Vaidhriti', telugu: 'వైధృతి'),
  ];
}

/// The 11 Karanas — 7 repeating (movable) followed by 4 fixed ones.
class Karanas {
  Karanas._();
  static const List<Karana> movable = [
    Karana(name: 'Bava', telugu: 'బవ'),
    Karana(name: 'Balava', telugu: 'బాలవ'),
    Karana(name: 'Kaulava', telugu: 'కౌలవ'),
    Karana(name: 'Taitila', telugu: 'తైతిల'),
    Karana(name: 'Garaja', telugu: 'గరజ'),
    Karana(name: 'Vanija', telugu: 'వణిజ'),
    Karana(name: 'Vishti', telugu: 'విష్టి'),
  ];
  static const List<Karana> fixed = [
    Karana(name: 'Shakuni', telugu: 'శకుని'),
    Karana(name: 'Chatushpada', telugu: 'చతుష్పాద'),
    Karana(name: 'Naga', telugu: 'నాగ'),
    Karana(name: 'Kimstughna', telugu: 'కింస్తుఘ్న'),
  ];
  static const List<Karana> all = [...movable, ...fixed];
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
    required this.yoga,
    required this.karana,
    required this.shakaSamvatYear,
    this.muhurtas = const [],
    this.choghadiya = const [],
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
  final PanchangYoga yoga;
  final Karana karana;

  /// Shaka calendar year (e.g. 1948 Śaka Samvatsara) shown alongside the
  /// Gregorian date on the day-detail header, per common Panchangam
  /// convention.
  final int shakaSamvatYear;
  final List<MuhurtaWindow> muhurtas;
  final List<ChoghadiyaPeriod> choghadiya;
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
    required this.yoga,
    required this.karana,
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
  final PanchangYoga yoga;
  final Karana karana;
  final bool isMockCalculated;
}
