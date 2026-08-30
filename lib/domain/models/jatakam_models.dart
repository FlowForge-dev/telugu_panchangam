import 'source_reference.dart';

/// The nine classical grahas used in a Jatakam. Rahu/Ketu are the lunar
/// nodes, included per standard Jyotisha practice.
enum Graha {
  surya('Surya', 'సూర్యుడు', 'Sun'),
  chandra('Chandra', 'చంద్రుడు', 'Moon'),
  kuja('Kuja', 'కుజుడు', 'Mars'),
  budha('Budha', 'బుధుడు', 'Mercury'),
  guru('Guru', 'గురువు', 'Jupiter'),
  shukra('Shukra', 'శుక్రుడు', 'Venus'),
  shani('Shani', 'శని', 'Saturn'),
  rahu('Rahu', 'రాహువు', 'North Node'),
  ketu('Ketu', 'కేతువు', 'South Node');

  const Graha(this.transliteration, this.telugu, this.westernName);
  final String transliteration;
  final String telugu;
  final String westernName;
}

/// The twelve Rāśi (zodiac signs).
class Rashi {
  const Rashi({required this.index, required this.name, required this.telugu, required this.symbol, required this.lord});

  /// 1-12, Mesha first.
  final int index;
  final String name;
  final String telugu;

  /// A short glyph/abbreviation used in compact chart cells.
  final String symbol;
  final Graha lord;

  static const List<Rashi> all = [
    Rashi(index: 1, name: 'Mesha', telugu: 'మేషం', symbol: 'Ari', lord: Graha.kuja),
    Rashi(index: 2, name: 'Vrishabha', telugu: 'వృషభం', symbol: 'Tau', lord: Graha.shukra),
    Rashi(index: 3, name: 'Mithuna', telugu: 'మిథునం', symbol: 'Gem', lord: Graha.budha),
    Rashi(index: 4, name: 'Karkataka', telugu: 'కర్కాటకం', symbol: 'Can', lord: Graha.chandra),
    Rashi(index: 5, name: 'Simha', telugu: 'సింహం', symbol: 'Leo', lord: Graha.surya),
    Rashi(index: 6, name: 'Kanya', telugu: 'కన్య', symbol: 'Vir', lord: Graha.budha),
    Rashi(index: 7, name: 'Tula', telugu: 'తుల', symbol: 'Lib', lord: Graha.shukra),
    Rashi(index: 8, name: 'Vrishchika', telugu: 'వృశ్చికం', symbol: 'Sco', lord: Graha.kuja),
    Rashi(index: 9, name: 'Dhanus', telugu: 'ధనుస్సు', symbol: 'Sag', lord: Graha.guru),
    Rashi(index: 10, name: 'Makara', telugu: 'మకరం', symbol: 'Cap', lord: Graha.shani),
    Rashi(index: 11, name: 'Kumbha', telugu: 'కుంభం', symbol: 'Aqu', lord: Graha.shani),
    Rashi(index: 12, name: 'Meena', telugu: 'మీనం', symbol: 'Pis', lord: Graha.guru),
  ];
}

/// One of the 27 Nakshatras, with the ruling graha used for Vimshottari
/// Dasha in a full implementation.
class Nakshatra {
  const Nakshatra({required this.index, required this.name, required this.telugu, required this.ruler, required this.deity});

  final int index;
  final String name;
  final String telugu;
  final Graha ruler;

  /// Presiding deity — commonly listed alongside a Nakshatra; kept as a
  /// short label only, not an interpretive claim.
  final String deity;

  static const List<Nakshatra> all = [
    Nakshatra(index: 1, name: 'Ashwini', telugu: 'అశ్విని', ruler: Graha.ketu, deity: 'Ashwini Devatas'),
    Nakshatra(index: 2, name: 'Bharani', telugu: 'భరణి', ruler: Graha.shukra, deity: 'Yama'),
    Nakshatra(index: 3, name: 'Krittika', telugu: 'కృత్తిక', ruler: Graha.surya, deity: 'Agni'),
    Nakshatra(index: 4, name: 'Rohini', telugu: 'రోహిణి', ruler: Graha.chandra, deity: 'Brahma'),
    Nakshatra(index: 5, name: 'Mrigashira', telugu: 'మృగశిర', ruler: Graha.kuja, deity: 'Soma'),
    Nakshatra(index: 6, name: 'Ardra', telugu: 'ఆరుద్ర', ruler: Graha.rahu, deity: 'Rudra'),
    Nakshatra(index: 7, name: 'Punarvasu', telugu: 'పునర్వసు', ruler: Graha.guru, deity: 'Aditi'),
    Nakshatra(index: 8, name: 'Pushyami', telugu: 'పుష్యమి', ruler: Graha.shani, deity: 'Brihaspati'),
    Nakshatra(index: 9, name: 'Ashlesha', telugu: 'ఆశ్లేష', ruler: Graha.budha, deity: 'Nagas'),
    Nakshatra(index: 10, name: 'Magha', telugu: 'మఖ', ruler: Graha.ketu, deity: 'Pitrs'),
    Nakshatra(index: 11, name: 'Pubba', telugu: 'పుబ్బ', ruler: Graha.shukra, deity: 'Bhaga'),
    Nakshatra(index: 12, name: 'Uttara', telugu: 'ఉత్తర', ruler: Graha.surya, deity: 'Aryaman'),
    Nakshatra(index: 13, name: 'Hastha', telugu: 'హస్త', ruler: Graha.chandra, deity: 'Savitr'),
    Nakshatra(index: 14, name: 'Chitta', telugu: 'చిత్త', ruler: Graha.kuja, deity: 'Tvashtar'),
    Nakshatra(index: 15, name: 'Swati', telugu: 'స్వాతి', ruler: Graha.rahu, deity: 'Vayu'),
    Nakshatra(index: 16, name: 'Vishakha', telugu: 'విశాఖ', ruler: Graha.guru, deity: 'Indra-Agni'),
    Nakshatra(index: 17, name: 'Anuradha', telugu: 'అనూరాధ', ruler: Graha.shani, deity: 'Mitra'),
    Nakshatra(index: 18, name: 'Jyeshta', telugu: 'జ్యేష్ఠ', ruler: Graha.budha, deity: 'Indra'),
    Nakshatra(index: 19, name: 'Moola', telugu: 'మూల', ruler: Graha.ketu, deity: 'Nirriti'),
    Nakshatra(index: 20, name: 'Purvashadha', telugu: 'పూర్వాషాఢ', ruler: Graha.shukra, deity: 'Apas'),
    Nakshatra(index: 21, name: 'Uttarashadha', telugu: 'ఉత్తరాషాఢ', ruler: Graha.surya, deity: 'Vishvadevas'),
    Nakshatra(index: 22, name: 'Shravanam', telugu: 'శ్రవణం', ruler: Graha.chandra, deity: 'Vishnu'),
    Nakshatra(index: 23, name: 'Dhanishta', telugu: 'ధనిష్ఠ', ruler: Graha.kuja, deity: 'Vasus'),
    Nakshatra(index: 24, name: 'Shatabhisham', telugu: 'శతభిషం', ruler: Graha.rahu, deity: 'Varuna'),
    Nakshatra(index: 25, name: 'Poorvabhadra', telugu: 'పూర్వాభాద్ర', ruler: Graha.guru, deity: 'Aja Ekapada'),
    Nakshatra(index: 26, name: 'Uttarabhadra', telugu: 'ఉత్తరాభాద్ర', ruler: Graha.shani, deity: 'Ahirbudhnya'),
    Nakshatra(index: 27, name: 'Revati', telugu: 'రేవతి', ruler: Graha.budha, deity: 'Pushan'),
  ];
}

/// Placement of a single graha within a chart, expressed by Rāśi + house
/// so it can drive both the North-Indian chart layout and any tabular
/// view.
class GrahaPosition {
  const GrahaPosition({
    required this.graha,
    required this.rashi,
    required this.house,
    required this.degree,
    this.isRetrograde = false,
    this.nakshatra,
    this.pada,
  });

  final Graha graha;
  final Rashi rashi;

  /// 1-12, relative to the Lagna.
  final int house;

  /// Degree within the rashi, 0-30.
  final double degree;
  final bool isRetrograde;
  final Nakshatra? nakshatra;
  final int? pada;
}

/// One Vimshottari Mahadasha period ruled by a single graha. The 120-year
/// total cycle and each graha's fixed number of years are the standard,
/// well-documented Vimshottari system definition — not an interpretive
/// claim. The actual start date (which depends on the Moon's precise
/// position at birth) is mock-derived here; see [Jatakam.isMockCalculated].
class DashaPeriod {
  const DashaPeriod({
    required this.graha,
    required this.years,
    required this.startDate,
    required this.endDate,
    required this.isCurrent,
  });

  final Graha graha;
  final int years;
  final DateTime startDate;
  final DateTime endDate;
  final bool isCurrent;
}

/// Fixed Vimshottari Mahadasha durations (years), standard system order.
const Map<Graha, int> kVimshottariYears = {
  Graha.ketu: 7,
  Graha.shukra: 20,
  Graha.surya: 6,
  Graha.chandra: 10,
  Graha.kuja: 7,
  Graha.rahu: 18,
  Graha.guru: 16,
  Graha.shani: 19,
  Graha.budha: 17,
};

/// A full birth chart. Field shapes mirror what a deterministic
/// Jyotisha engine would return so the mock data can be swapped later
/// without touching chart/summary widgets.
class Jatakam {
  const Jatakam({
    required this.moonRashi,
    required this.birthNakshatra,
    required this.birthNakshatraPada,
    required this.lagna,
    required this.grahaPositions,
    this.dashaPeriods = const [],
    this.isMockCalculated = true,
  });

  final Rashi moonRashi;
  final Nakshatra birthNakshatra;
  final int birthNakshatraPada;

  /// Ascendant sign at birth.
  final Rashi lagna;
  final List<GrahaPosition> grahaPositions;

  /// The Vimshottari Mahadasha sequence, oldest first.
  final List<DashaPeriod> dashaPeriods;

  /// True while these values are produced by the mock generator rather
  /// than a real ephemeris-based Jyotisha calculation.
  final bool isMockCalculated;

  GrahaPosition? positionOf(Graha graha) {
    for (final p in grahaPositions) {
      if (p.graha == graha) return p;
    }
    return null;
  }

  /// Houses 1-12, each with the grahas placed there.
  Map<int, List<GrahaPosition>> get byHouse {
    final map = <int, List<GrahaPosition>>{for (var h = 1; h <= 12; h++) h: []};
    for (final p in grahaPositions) {
      map[p.house]!.add(p);
    }
    return map;
  }
}

/// A Japa/observance recommendation card's data — deliberately shaped so
/// every field can carry a [SourceReference] and the mantra text can be
/// withheld pending verification.
class JapaRecommendation {
  const JapaRecommendation({
    required this.id,
    required this.title,
    required this.teluguTitle,
    required this.applicability,
    required this.reason,
    required this.mantraPlaceholder,
    required this.repetitionInfo,
    required this.preparation,
    required this.source,
  });

  final String id;
  final String title;
  final String teluguTitle;

  /// Who/when this applies to (e.g. tied to a Rāśi, Nakshatra, or day).
  final String applicability;
  final String reason;

  /// Always a bracketed placeholder until verified content is supplied.
  final String mantraPlaceholder;
  final String repetitionInfo;
  final String preparation;
  final SourceReference source;
}
