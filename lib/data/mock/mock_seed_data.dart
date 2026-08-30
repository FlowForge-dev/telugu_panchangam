import '../../domain/models/devotional_models.dart';
import '../../domain/models/festival_models.dart';
import '../../domain/models/jatakam_models.dart';
import '../../domain/models/panchang_models.dart';
import '../../domain/models/source_reference.dart';
import '../../domain/models/vrata_models.dart';

/// ---------------------------------------------------------------------
/// DEVELOPMENT MOCK DATA
///
/// Everything in this file is placeholder development data for frontend
/// work. It intentionally does NOT implement:
///   - real Panchangam/ephemeris calculations (Tithi, Nakshatra, Masa
///     are cycled deterministically just so the UI has varied values)
///   - real festival-date calculation rules
///   - real Jyotisha/astrological computation
///
/// A future deterministic backend replaces this file's role entirely;
/// repository interfaces in domain/repositories are the seam.
/// ---------------------------------------------------------------------

/// Mock anchor for "this Panchangam year". Real Ugadi dates require a
/// verified lunisolar calculation — this is a placeholder start date so
/// the Ugadi -> Ugadi calendar can be built and navigated in the UI.
final DateTime kMockUgadiStart = DateTime(2026, 3, 19);
final DateTime kMockNextUgadiStart = DateTime(2027, 4, 7);

const List<Tithi> _shuklaTithis = [
  Tithi(index: 1, name: 'Padyami', telugu: 'పాడ్యమి'),
  Tithi(index: 2, name: 'Vidiya', telugu: 'విదియ'),
  Tithi(index: 3, name: 'Tadiya', telugu: 'తదియ'),
  Tithi(index: 4, name: 'Chavithi', telugu: 'చవితి'),
  Tithi(index: 5, name: 'Panchami', telugu: 'పంచమి'),
  Tithi(index: 6, name: 'Shashti', telugu: 'షష్ఠి'),
  Tithi(index: 7, name: 'Saptami', telugu: 'సప్తమి'),
  Tithi(index: 8, name: 'Ashtami', telugu: 'అష్టమి'),
  Tithi(index: 9, name: 'Navami', telugu: 'నవమి'),
  Tithi(index: 10, name: 'Dashami', telugu: 'దశమి'),
  Tithi(index: 11, name: 'Ekadashi', telugu: 'ఏకాదశి'),
  Tithi(index: 12, name: 'Dwadashi', telugu: 'ద్వాదశి'),
  Tithi(index: 13, name: 'Trayodashi', telugu: 'త్రయోదశి'),
  Tithi(index: 14, name: 'Chaturdashi', telugu: 'చతుర్దశి'),
  Tithi(index: 15, name: 'Purnima', telugu: 'పౌర్ణమి'),
];

const List<Tithi> _krishnaTithis = [
  Tithi(index: 1, name: 'Padyami', telugu: 'పాడ్యమి'),
  Tithi(index: 2, name: 'Vidiya', telugu: 'విదియ'),
  Tithi(index: 3, name: 'Tadiya', telugu: 'తదియ'),
  Tithi(index: 4, name: 'Chavithi', telugu: 'చవితి'),
  Tithi(index: 5, name: 'Panchami', telugu: 'పంచమి'),
  Tithi(index: 6, name: 'Shashti', telugu: 'షష్ఠి'),
  Tithi(index: 7, name: 'Saptami', telugu: 'సప్తమి'),
  Tithi(index: 8, name: 'Ashtami', telugu: 'అష్టమి'),
  Tithi(index: 9, name: 'Navami', telugu: 'నవమి'),
  Tithi(index: 10, name: 'Dashami', telugu: 'దశమి'),
  Tithi(index: 11, name: 'Ekadashi', telugu: 'ఏకాదశి'),
  Tithi(index: 12, name: 'Dwadashi', telugu: 'ద్వాదశి'),
  Tithi(index: 13, name: 'Trayodashi', telugu: 'త్రయోదశి'),
  Tithi(index: 14, name: 'Chaturdashi', telugu: 'చతుర్దశి'),
  Tithi(index: 15, name: 'Amavasya', telugu: 'అమావాస్య'),
];

/// Deterministically cycles Tithi/Paksha/Nakshatra/Masa so the UI shows
/// varied, stable-per-day values. NOT a real Panchangam calculation.
PanchangDay generateMockPanchangDay(DateTime date) {
  final normalized = DateTime(date.year, date.month, date.day);
  final daysSinceAnchor = normalized.difference(kMockUgadiStart).inDays;
  final cycleDay = daysSinceAnchor % 30;
  final pakshaIndex = cycleDay < 15 ? 0 : 1;
  final tithiIndex = cycleDay % 15;
  final paksha = pakshaIndex == 0 ? Paksha.shukla : Paksha.krishna;
  final tithi = pakshaIndex == 0 ? _shuklaTithis[tithiIndex] : _krishnaTithis[tithiIndex];

  final nakshatraIndex = daysSinceAnchor.abs() % 27;
  final nak = Nakshatra.all[nakshatraIndex];
  final pada = (daysSinceAnchor.abs() % 4) + 1;

  final masaIndex = (daysSinceAnchor.abs() ~/ 30) % TeluguMasa.values.length;
  final masa = TeluguMasa.values[masaIndex];

  final vara = Vara.values[normalized.weekday % 7];

  final yoga = PanchangYogas.all[(daysSinceAnchor.abs() + 5) % PanchangYogas.all.length];
  final karana = Karanas.all[daysSinceAnchor.abs() % Karanas.all.length];

  final isOnOrAfterUgadi = normalized.month > kMockUgadiStart.month ||
      (normalized.month == kMockUgadiStart.month && normalized.day >= kMockUgadiStart.day);
  final shakaSamvatYear = normalized.year - (isOnOrAfterUgadi ? 78 : 79);

  final sunriseMinutes = 6 * 60 + (normalized.day % 5);
  final sunsetMinutes = 18 * 60 + (30 + normalized.day % 20);

  final specialType = _specialDayTypeFor(tithi, paksha);
  final festival = _festivals.where((f) => _sameDay(f.date, normalized)).toList();

  return PanchangDay(
    date: normalized,
    vara: vara,
    masa: masa,
    paksha: paksha,
    tithi: tithi,
    nakshatra: NakshatraRef(name: nak.name, telugu: nak.telugu, pada: pada),
    sunrise: _formatMinutes(sunriseMinutes),
    sunset: _formatMinutes(sunsetMinutes),
    moonrise: '${_hour12(7 + normalized.day % 12)}:15 ${normalized.day.isEven ? 'AM' : 'PM'}',
    moonset: '${_hour12(6 + normalized.day % 11)}:40 ${normalized.day.isOdd ? 'AM' : 'PM'}',
    yoga: yoga,
    karana: karana,
    shakaSamvatYear: shakaSamvatYear,
    muhurtas: [
      MuhurtaWindow(
        label: 'Rahu Kalam',
        teluguLabel: 'రాహు కాలం',
        start: _shiftTime(normalized.weekday, 0),
        end: _shiftTime(normalized.weekday, 90),
      ),
      MuhurtaWindow(
        label: 'Yamagandam',
        teluguLabel: 'యమగండం',
        start: _shiftTime(normalized.weekday, 180),
        end: _shiftTime(normalized.weekday, 270),
      ),
    ],
    choghadiya: _generateChoghadiya(vara, sunriseMinutes, sunsetMinutes),
    specialDayType: festival.isNotEmpty ? SpecialDayType.majorFestival : specialType,
    festivalId: festival.isNotEmpty ? festival.first.id : null,
  );
}

/// The standard day-Choghadiya name sequence for each weekday (widely
/// published reference table — not a calculation, a fixed lookup).
const Map<Vara, List<String>> _choghadiyaSequence = {
  Vara.ravivaram: ['Udveg', 'Chal', 'Labh', 'Amrit', 'Kaal', 'Shubh', 'Rog', 'Udveg'],
  Vara.somavaram: ['Amrit', 'Kaal', 'Shubh', 'Rog', 'Udveg', 'Chal', 'Labh', 'Amrit'],
  Vara.mangalavaram: ['Rog', 'Udveg', 'Chal', 'Labh', 'Amrit', 'Kaal', 'Shubh', 'Rog'],
  Vara.budhavaram: ['Labh', 'Amrit', 'Kaal', 'Shubh', 'Rog', 'Udveg', 'Chal', 'Labh'],
  Vara.guruvaram: ['Shubh', 'Rog', 'Udveg', 'Chal', 'Labh', 'Amrit', 'Kaal', 'Shubh'],
  Vara.shukravaram: ['Chal', 'Labh', 'Amrit', 'Kaal', 'Shubh', 'Rog', 'Udveg', 'Chal'],
  Vara.shanivaram: ['Kaal', 'Shubh', 'Rog', 'Udveg', 'Chal', 'Labh', 'Amrit', 'Kaal'],
};

const Map<String, String> _choghadiyaTelugu = {
  'Udveg': 'ఉద్వేగ',
  'Chal': 'చల',
  'Labh': 'లాభ',
  'Amrit': 'అమృత',
  'Kaal': 'కాల',
  'Shubh': 'శుభ',
  'Rog': 'రోగ',
};

const Map<String, ChoghadiyaQuality> _choghadiyaQuality = {
  'Udveg': ChoghadiyaQuality.inauspicious,
  'Chal': ChoghadiyaQuality.neutral,
  'Labh': ChoghadiyaQuality.good,
  'Amrit': ChoghadiyaQuality.good,
  'Kaal': ChoghadiyaQuality.inauspicious,
  'Shubh': ChoghadiyaQuality.good,
  'Rog': ChoghadiyaQuality.inauspicious,
};

List<ChoghadiyaPeriod> _generateChoghadiya(Vara vara, int sunriseMinutes, int sunsetMinutes) {
  final names = _choghadiyaSequence[vara]!;
  final totalMinutes = sunsetMinutes - sunriseMinutes;
  final slot = totalMinutes / 8;
  return List.generate(8, (i) {
    final start = (sunriseMinutes + slot * i).round();
    final end = (sunriseMinutes + slot * (i + 1)).round();
    final name = names[i];
    return ChoghadiyaPeriod(
      name: name,
      telugu: _choghadiyaTelugu[name]!,
      start: _formatMinutes(start),
      end: _formatMinutes(end),
      quality: _choghadiyaQuality[name]!,
    );
  });
}

String _formatMinutes(int totalMinutes) {
  final h = (totalMinutes ~/ 60) % 24;
  final m = totalMinutes % 60;
  final period = h >= 12 ? 'PM' : 'AM';
  final h12 = h % 12 == 0 ? 12 : h % 12;
  return '${h12.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $period';
}

/// Folds an arbitrary 0-23-ish hour value into a 1-12 12-hour-clock number.
String _hour12(int hour24) {
  final h = hour24 % 12;
  return (h == 0 ? 12 : h).toString().padLeft(2, '0');
}

String _shiftTime(int weekday, int minuteOffset) {
  final base = 9 * 60 + (weekday * 17) % 60;
  final total = (base + minuteOffset) % (24 * 60);
  final h = total ~/ 60;
  final m = total % 60;
  final period = h >= 12 ? 'PM' : 'AM';
  final h12 = h % 12 == 0 ? 12 : h % 12;
  return '${h12.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $period';
}

SpecialDayType _specialDayTypeFor(Tithi tithi, Paksha paksha) {
  if (tithi.index == 11) return SpecialDayType.ekadashi;
  if (tithi.index == 15 && paksha == Paksha.shukla) return SpecialDayType.purnima;
  if (tithi.index == 15 && paksha == Paksha.krishna) return SpecialDayType.amavasya;
  return SpecialDayType.none;
}

bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

const SourceReference _pendingAlmanac = SourceReference(
  title: '[AUTHORITATIVE SOURCE REQUIRED]',
  notes: 'Detailed shastric significance and exact observance rules are pending review by a qualified Panchangam authority.',
  status: VerificationStatus.pendingVerification,
);

const SourceReference _pendingMantra = SourceReference(
  title: '[AUTHORITATIVE SOURCE REQUIRED]',
  language: 'Sanskrit / Telugu',
  notes: 'Mantra text withheld pending citation from a verified traditional source.',
  status: VerificationStatus.pendingVerification,
);

/// Dates in this list (Mar 2026 – Dec 2026) are taken from the "2026
/// Drik Panchang Hindu Calendar" (Amanta system, Hyderabad, Telangana,
/// v1.0.4) supplied by the user — a real published almanac, not a
/// guess. Interpretive significance/observance prose is still ours in
/// summary form and mantra text remains withheld; only the date and
/// name of each occasion is drawn from that source.
const SourceReference _drikPanchang2026 = SourceReference(
  title: '2026 Drik Panchang Hindu Calendar',
  edition: 'v1.0.4, Hyderabad, Telangana (Amanta system)',
  language: 'English',
  notes: 'Confirms the date and name of each occasion. Detailed shastric significance, observance rules and mantra '
      'text still require separate citation from a qualified source.',
  status: VerificationStatus.verified,
);

/// Festival calendar for the Ugadi -> Ugadi year. Dates from
/// 19 Mar 2026 through 24 Dec 2026 are verified against
/// [_drikPanchang2026]; the remaining few (Jan–Apr 2027) fall outside
/// that source's coverage and stay placeholder estimates — see each
/// entry's [Festival.isMockCalculated].
final List<Festival> _festivals = [
  Festival(
    id: 'ugadi',
    name: 'Ugadi',
    teluguName: 'ఉగాది',
    date: kMockUgadiStart,
    importance: FestivalImportance.major,
    shortSignificance: 'Telugu New Year — start of the calendrical cycle.',
    significance:
        'Ugadi marks the traditional start of the new year in the Telugu lunisolar calendar. '
        'It is widely observed with the preparation of Ugadi pachadi, a dish combining several '
        'tastes said to represent the varied experiences of the year ahead.\n\n'
        'Detailed shastric significance: [VERIFIED CONTENT REQUIRED]',
    observance: 'Households commonly clean and decorate the home, wear new clothing, and prepare Ugadi pachadi. '
        'Exact ritual sequence and timing: [VERIFIED CONTENT REQUIRED]',
    preparation: 'Home cleaning, mango-leaf toranam at the entrance, and gathering pachadi ingredients '
        '(neem, jaggery, tamarind, raw mango, chilli, salt) the evening before.',
    mantraSources: [_pendingMantra],
    sources: [_drikPanchang2026],
    isMockCalculated: false,
  ),
  Festival(
    id: 'sri-rama-navami',
    name: 'Sri Rama Navami',
    teluguName: 'శ్రీరామ నవమి',
    date: DateTime(2026, 3, 26),
    importance: FestivalImportance.major,
    shortSignificance: 'Commemorates the birth of Sri Rama.',
    significance: 'Observed as the birth anniversary of Sri Rama. Many temples hold Kalyanam (ceremonial wedding) '
        'observances on this day.\n\nDetailed shastric significance: [VERIFIED CONTENT REQUIRED]',
    observance: 'Temple visits and Kalyanotsavam. Exact ritual sequence: [VERIFIED CONTENT REQUIRED]',
    preparation: 'Fasting practices vary by household and tradition. [VERIFIED CONTENT REQUIRED]',
    mantraSources: [_pendingMantra],
    sources: [_drikPanchang2026],
    isMockCalculated: false,
  ),
  Festival(
    id: 'hanuman-jayanti',
    name: 'Hanuman Jayanti',
    teluguName: 'హనుమాన్ జయంతి',
    date: DateTime(2026, 4, 2),
    importance: FestivalImportance.moderate,
    shortSignificance: 'Birth anniversary of Sri Hanuman.',
    significance: 'Observed by many as the birth anniversary of Hanuman, on Chaitra Purnima. Regional dates and '
        'traditions vary.\n\nDetailed shastric significance: [VERIFIED CONTENT REQUIRED]',
    observance: '[VERIFIED CONTENT REQUIRED]',
    preparation: '[VERIFIED CONTENT REQUIRED]',
    mantraSources: [_pendingMantra],
    sources: [_drikPanchang2026],
    isMockCalculated: false,
  ),
  Festival(
    id: 'akshaya-tritiya',
    name: 'Akshaya Tritiya',
    teluguName: 'అక్షయ తృతీయ',
    date: DateTime(2026, 4, 19),
    importance: FestivalImportance.moderate,
    shortSignificance: 'Considered an auspicious day for new beginnings.',
    significance: 'Widely regarded as an auspicious day for new ventures, purchases and charitable giving.\n\n'
        'Detailed shastric significance: [VERIFIED CONTENT REQUIRED]',
    observance: '[VERIFIED CONTENT REQUIRED]',
    preparation: '[VERIFIED CONTENT REQUIRED]',
    mantraSources: [_pendingMantra],
    sources: [_drikPanchang2026],
    isMockCalculated: false,
  ),
  Festival(
    id: 'narasimha-jayanti',
    name: 'Narasimha Jayanti',
    teluguName: 'నృసింహ జయంతి',
    date: DateTime(2026, 4, 30),
    importance: FestivalImportance.moderate,
    shortSignificance: 'Commemorates the Narasimha avatar of Vishnu.',
    significance: 'Observed as the appearance day of Sri Narasimha.\n\nDetailed shastric significance: [VERIFIED CONTENT REQUIRED]',
    observance: '[VERIFIED CONTENT REQUIRED]',
    preparation: '[VERIFIED CONTENT REQUIRED]',
    mantraSources: [_pendingMantra],
    sources: [_drikPanchang2026],
    isMockCalculated: false,
  ),
  Festival(
    id: 'buddha-purnima',
    name: 'Buddha Purnima',
    teluguName: 'బుద్ధ పౌర్ణమి',
    date: DateTime(2026, 5, 1),
    importance: FestivalImportance.moderate,
    shortSignificance: 'Vaishakha Purnima; also observed as Buddha Purnima.',
    significance: 'The full-moon day of Vaishakha masam.\n\nDetailed shastric significance: [VERIFIED CONTENT REQUIRED]',
    observance: '[VERIFIED CONTENT REQUIRED]',
    preparation: '[VERIFIED CONTENT REQUIRED]',
    mantraSources: [_pendingMantra],
    sources: [_drikPanchang2026],
    isMockCalculated: false,
  ),
  Festival(
    id: 'nirjala-ekadashi',
    name: 'Nirjala Ekadashi',
    teluguName: 'నిర్జల ఏకాదశి',
    date: DateTime(2026, 6, 25),
    importance: FestivalImportance.observance,
    shortSignificance: 'The most rigorous of the year\'s Ekadashi observances.',
    significance: 'Observed with a waterless fast; widely considered the most demanding Ekadashi of the year.\n\n'
        'Detailed shastric significance: [VERIFIED CONTENT REQUIRED]',
    observance: '[VERIFIED CONTENT REQUIRED]',
    preparation: 'Fasting practices vary by tradition. [VERIFIED CONTENT REQUIRED]',
    mantraSources: [_pendingMantra],
    sources: [_drikPanchang2026],
    isMockCalculated: false,
  ),
  Festival(
    id: 'jagannath-rathayatra',
    name: 'Jagannath Rathayatra',
    teluguName: 'జగన్నాథ రథయాత్ర',
    date: DateTime(2026, 7, 16),
    importance: FestivalImportance.moderate,
    shortSignificance: 'Chariot festival of Lord Jagannath.',
    significance: 'A chariot procession observance associated with Lord Jagannath.\n\n'
        'Detailed shastric significance: [VERIFIED CONTENT REQUIRED]',
    observance: '[VERIFIED CONTENT REQUIRED]',
    preparation: '[VERIFIED CONTENT REQUIRED]',
    mantraSources: [_pendingMantra],
    sources: [_drikPanchang2026],
    isMockCalculated: false,
  ),
  Festival(
    id: 'devshayani-ekadashi',
    name: 'Devshayani Ekadashi',
    teluguName: 'దేవశయని ఏకాదశి',
    date: DateTime(2026, 7, 25),
    importance: FestivalImportance.observance,
    shortSignificance: 'Marks the start of the Chaturmasya period.',
    significance: 'Traditionally marks the beginning of Chaturmasya, a four-month observance period.\n\n'
        'Detailed shastric significance: [VERIFIED CONTENT REQUIRED]',
    observance: '[VERIFIED CONTENT REQUIRED]',
    preparation: '[VERIFIED CONTENT REQUIRED]',
    mantraSources: [_pendingMantra],
    sources: [_drikPanchang2026],
    isMockCalculated: false,
  ),
  Festival(
    id: 'guru-purnima',
    name: 'Guru Purnima',
    teluguName: 'గురు పౌర్ణమి',
    date: DateTime(2026, 7, 29),
    importance: FestivalImportance.moderate,
    shortSignificance: 'Ashadha Purnima; a day of reverence for one\'s teachers, also observed as Vyasa Puja.',
    significance: 'Observed as Vyasa Puja and a day of reverence for one\'s teachers/guru.\n\n'
        'Detailed shastric significance: [VERIFIED CONTENT REQUIRED]',
    observance: '[VERIFIED CONTENT REQUIRED]',
    preparation: '[VERIFIED CONTENT REQUIRED]',
    mantraSources: [_pendingMantra],
    sources: [_drikPanchang2026],
    isMockCalculated: false,
  ),
  Festival(
    id: 'varalakshmi-vratam',
    name: 'Varalakshmi Vratam',
    teluguName: 'వరలక్ష్మి వ్రతం',
    date: DateTime(2026, 8, 28),
    importance: FestivalImportance.major,
    shortSignificance: 'Vratam dedicated to Goddess Varalakshmi.',
    significance: 'A widely observed vratam dedicated to Goddess Varalakshmi, performed by many households on a '
        'Friday of Shravana masam. Some traditions (e.g. Sringeri) observe it on a different Friday than the '
        'general Amanta-calendar date used here.\n\nDetailed shastric significance: [VERIFIED CONTENT REQUIRED]',
    observance: 'Exact vratam procedure and timing: [VERIFIED CONTENT REQUIRED]',
    preparation: 'Kalasham setup and household preparation vary by family tradition. [VERIFIED CONTENT REQUIRED]',
    mantraSources: [_pendingMantra],
    sources: [_drikPanchang2026],
    isMockCalculated: false,
  ),
  Festival(
    id: 'raksha-bandhan',
    name: 'Raksha Bandhan',
    teluguName: 'రాఖీ పౌర్ణమి',
    date: DateTime(2026, 8, 28),
    importance: FestivalImportance.moderate,
    shortSignificance: 'Shravana Purnima; siblings tie the rakhi thread.',
    significance: 'Observed on Shravana Purnima, this occasion coincides with Varalakshmi Vratam this year.\n\n'
        'Detailed shastric significance: [VERIFIED CONTENT REQUIRED]',
    observance: '[VERIFIED CONTENT REQUIRED]',
    preparation: '[VERIFIED CONTENT REQUIRED]',
    mantraSources: [_pendingMantra],
    sources: [_drikPanchang2026],
    isMockCalculated: false,
  ),
  Festival(
    id: 'krishna-janmashtami',
    name: 'Krishna Janmashtami',
    teluguName: 'శ్రీకృష్ణాష్టమి',
    date: DateTime(2026, 9, 4),
    importance: FestivalImportance.major,
    shortSignificance: 'Celebrates the birth of Sri Krishna.',
    significance: 'Observed as the birth anniversary of Sri Krishna, typically marked with fasting until midnight '
        'and devotional singing.\n\nDetailed shastric significance: [VERIFIED CONTENT REQUIRED]',
    observance: 'Exact fasting/ritual rules vary by tradition. [VERIFIED CONTENT REQUIRED]',
    preparation: '[VERIFIED CONTENT REQUIRED]',
    mantraSources: [_pendingMantra],
    sources: [_drikPanchang2026],
    isMockCalculated: false,
  ),
  Festival(
    id: 'vinayaka-chavithi',
    name: 'Vinayaka Chavithi',
    teluguName: 'వినాయక చవితి',
    date: DateTime(2026, 9, 14),
    importance: FestivalImportance.major,
    shortSignificance: 'Ganesh Chaturthi — worship of Lord Ganesha.',
    significance: 'A major household and community festival honouring Lord Ganesha, typically involving a clay '
        'idol installed at home or in a pandal for a set number of days.\n\n'
        'Detailed shastric significance: [VERIFIED CONTENT REQUIRED]',
    observance: 'Exact puja vidhi and immersion (visarjan) timing: [VERIFIED CONTENT REQUIRED]',
    preparation: 'Idol/pandal arrangements, modakam or kudumu preparation traditions vary by family.',
    mantraSources: [_pendingMantra],
    sources: [_drikPanchang2026],
    isMockCalculated: false,
  ),
  Festival(
    id: 'ganesh-visarjan',
    name: 'Ganesh Visarjan',
    teluguName: 'గణేశ నిమజ్జనం',
    date: DateTime(2026, 9, 25),
    importance: FestivalImportance.moderate,
    shortSignificance: 'Anant Chaturdashi — immersion of the Ganesha idol.',
    significance: 'Marks the conclusion of the Vinayaka Chavithi observance with idol immersion.\n\n'
        'Detailed shastric significance: [VERIFIED CONTENT REQUIRED]',
    observance: '[VERIFIED CONTENT REQUIRED]',
    preparation: '[VERIFIED CONTENT REQUIRED]',
    mantraSources: [_pendingMantra],
    sources: [_drikPanchang2026],
    isMockCalculated: false,
  ),
  Festival(
    id: 'sarannavaratri',
    name: 'Sharan Navaratri',
    teluguName: 'శరన్నవరాత్రులు',
    date: DateTime(2026, 10, 11),
    importance: FestivalImportance.major,
    shortSignificance: 'Nine nights honouring the Goddess.',
    significance: 'A nine-night observance honouring the Goddess in her various forms, culminating in Vijayadashami.\n\n'
        'Detailed shastric significance: [VERIFIED CONTENT REQUIRED]',
    observance: 'Day-by-day alankaram/observance sequence: [VERIFIED CONTENT REQUIRED]',
    preparation: '[VERIFIED CONTENT REQUIRED]',
    mantraSources: [_pendingMantra],
    sources: [_drikPanchang2026],
    isMockCalculated: false,
  ),
  Festival(
    id: 'vijayadashami',
    name: 'Vijayadashami',
    teluguName: 'విజయదశమి',
    date: DateTime(2026, 10, 20),
    importance: FestivalImportance.major,
    shortSignificance: 'Dasara — marks the victory of good over evil.',
    significance: 'Marks the culmination of Navaratri and is widely associated with the victory of good over evil.\n\n'
        'Detailed shastric significance: [VERIFIED CONTENT REQUIRED]',
    observance: '[VERIFIED CONTENT REQUIRED]',
    preparation: '[VERIFIED CONTENT REQUIRED]',
    mantraSources: [_pendingMantra],
    sources: [_drikPanchang2026],
    isMockCalculated: false,
  ),
  Festival(
    id: 'sharad-purnima',
    name: 'Sharad Purnima',
    teluguName: 'శరత్ పౌర్ణమి',
    date: DateTime(2026, 10, 25),
    importance: FestivalImportance.moderate,
    shortSignificance: 'Kojagara Puja; full moon of Ashwina masam.',
    significance: 'The full-moon day of Ashwina masam, observed as Kojagara Puja in several traditions.\n\n'
        'Detailed shastric significance: [VERIFIED CONTENT REQUIRED]',
    observance: '[VERIFIED CONTENT REQUIRED]',
    preparation: '[VERIFIED CONTENT REQUIRED]',
    mantraSources: [_pendingMantra],
    sources: [_drikPanchang2026],
    isMockCalculated: false,
  ),
  Festival(
    id: 'karwa-chauth',
    name: 'Karwa Chauth',
    teluguName: 'కర్వా చౌత్',
    date: DateTime(2026, 10, 29),
    importance: FestivalImportance.observance,
    shortSignificance: 'A fasting observance, more widely kept in North India.',
    significance: 'A fasting observance widely kept in North India; not a traditional Telugu-calendar occasion, '
        'shown here for completeness.\n\nDetailed shastric significance: [VERIFIED CONTENT REQUIRED]',
    observance: '[VERIFIED CONTENT REQUIRED]',
    preparation: '[VERIFIED CONTENT REQUIRED]',
    mantraSources: [_pendingMantra],
    sources: [_drikPanchang2026],
    isMockCalculated: false,
  ),
  Festival(
    id: 'dhanteras',
    name: 'Dhanteras',
    teluguName: 'ధనత్రయోదశి',
    date: DateTime(2026, 11, 6),
    importance: FestivalImportance.moderate,
    shortSignificance: 'Opens the Deepavali festival period.',
    significance: 'Traditionally regarded as an auspicious day for purchases, opening the Deepavali period.\n\n'
        'Detailed shastric significance: [VERIFIED CONTENT REQUIRED]',
    observance: '[VERIFIED CONTENT REQUIRED]',
    preparation: '[VERIFIED CONTENT REQUIRED]',
    mantraSources: [_pendingMantra],
    sources: [_drikPanchang2026],
    isMockCalculated: false,
  ),
  Festival(
    id: 'deepavali',
    name: 'Deepavali',
    teluguName: 'దీపావళి',
    date: DateTime(2026, 11, 8),
    importance: FestivalImportance.major,
    shortSignificance: 'Festival of lights.',
    significance: 'Widely observed festival of lights, marked with the lighting of diyas, sharing of sweets and '
        'family gatherings.\n\nDetailed shastric significance: [VERIFIED CONTENT REQUIRED]',
    observance: 'Naraka Chaturdashi and Lakshmi Puja timing details: [VERIFIED CONTENT REQUIRED]',
    preparation: 'Home cleaning and decoration with diyas/rangoli.',
    mantraSources: [_pendingMantra],
    sources: [_drikPanchang2026],
    isMockCalculated: false,
  ),
  Festival(
    id: 'govardhan-puja',
    name: 'Govardhan Puja',
    teluguName: 'బలిపాడ్యమి',
    date: DateTime(2026, 11, 10),
    importance: FestivalImportance.moderate,
    shortSignificance: 'Bali Padyami — the day after the main Deepavali observance.',
    significance: 'Observed the day after the main Deepavali night.\n\nDetailed shastric significance: [VERIFIED CONTENT REQUIRED]',
    observance: '[VERIFIED CONTENT REQUIRED]',
    preparation: '[VERIFIED CONTENT REQUIRED]',
    mantraSources: [_pendingMantra],
    sources: [_drikPanchang2026],
    isMockCalculated: false,
  ),
  Festival(
    id: 'bhai-dooj',
    name: 'Bhai Dooj',
    teluguName: 'భాయి దూజ్',
    date: DateTime(2026, 11, 11),
    importance: FestivalImportance.observance,
    shortSignificance: 'A day honouring the sibling bond, more widely kept in North India.',
    significance: 'Not a traditional Telugu-calendar occasion, shown here for completeness.\n\n'
        'Detailed shastric significance: [VERIFIED CONTENT REQUIRED]',
    observance: '[VERIFIED CONTENT REQUIRED]',
    preparation: '[VERIFIED CONTENT REQUIRED]',
    mantraSources: [_pendingMantra],
    sources: [_drikPanchang2026],
    isMockCalculated: false,
  ),
  Festival(
    id: 'devutthana-ekadashi',
    name: 'Devutthana Ekadashi',
    teluguName: 'దేవోత్థాన ఏకాదశి',
    date: DateTime(2026, 11, 20),
    importance: FestivalImportance.observance,
    shortSignificance: 'Traditionally marks the end of the Chaturmasya period.',
    significance: 'Traditionally regarded as the close of Chaturmasya.\n\nDetailed shastric significance: [VERIFIED CONTENT REQUIRED]',
    observance: '[VERIFIED CONTENT REQUIRED]',
    preparation: '[VERIFIED CONTENT REQUIRED]',
    mantraSources: [_pendingMantra],
    sources: [_drikPanchang2026],
    isMockCalculated: false,
  ),
  Festival(
    id: 'tulasi-vivah',
    name: 'Tulasi Vivah',
    teluguName: 'తులసి వివాహం',
    date: DateTime(2026, 11, 21),
    importance: FestivalImportance.moderate,
    shortSignificance: 'Ceremonial wedding of the Tulasi plant.',
    significance: 'A household observance marking the ceremonial wedding of the Tulasi plant.\n\n'
        'Detailed shastric significance: [VERIFIED CONTENT REQUIRED]',
    observance: '[VERIFIED CONTENT REQUIRED]',
    preparation: '[VERIFIED CONTENT REQUIRED]',
    mantraSources: [_pendingMantra],
    sources: [_drikPanchang2026],
    isMockCalculated: false,
  ),
  Festival(
    id: 'karthika-pournami',
    name: 'Karthika Pournami',
    teluguName: 'కార్తీక పౌర్ణమి',
    date: DateTime(2026, 11, 24),
    importance: FestivalImportance.moderate,
    shortSignificance: 'Full moon of Karthika masam; also observed as Dev Diwali.',
    significance: 'The full-moon day of Karthika masam, traditionally associated with lighting lamps at home and '
        'in temples.\n\nDetailed shastric significance: [VERIFIED CONTENT REQUIRED]',
    observance: '[VERIFIED CONTENT REQUIRED]',
    preparation: '[VERIFIED CONTENT REQUIRED]',
    mantraSources: [_pendingMantra],
    sources: [_drikPanchang2026],
    isMockCalculated: false,
  ),
  Festival(
    id: 'vivah-panchami',
    name: 'Vivah Panchami',
    teluguName: 'వివాహ పంచమి',
    date: DateTime(2026, 12, 14),
    importance: FestivalImportance.observance,
    shortSignificance: 'Commemorates the wedding of Sri Rama and Sita.',
    significance: 'Observed in commemoration of the wedding of Sri Rama and Sita.\n\n'
        'Detailed shastric significance: [VERIFIED CONTENT REQUIRED]',
    observance: '[VERIFIED CONTENT REQUIRED]',
    preparation: '[VERIFIED CONTENT REQUIRED]',
    mantraSources: [_pendingMantra],
    sources: [_drikPanchang2026],
    isMockCalculated: false,
  ),
  Festival(
    id: 'subrahmanya-shashti',
    name: 'Subrahmanya Shashti',
    teluguName: 'సుబ్రహ్మణ్య షష్ఠి',
    date: DateTime(2026, 12, 15),
    importance: FestivalImportance.moderate,
    shortSignificance: 'Also observed as Champa Shashthi; dedicated to Lord Subrahmanya.',
    significance: 'A day dedicated to Lord Subrahmanya (Skanda/Kartikeya).\n\nDetailed shastric significance: [VERIFIED CONTENT REQUIRED]',
    observance: '[VERIFIED CONTENT REQUIRED]',
    preparation: '[VERIFIED CONTENT REQUIRED]',
    mantraSources: [_pendingMantra],
    sources: [_drikPanchang2026],
    isMockCalculated: false,
  ),
  Festival(
    id: 'dhanurmasam-begins',
    name: 'Dhanurmasam Begins',
    teluguName: 'ధనుర్మాసం ప్రారంభం',
    date: DateTime(2026, 12, 16),
    importance: FestivalImportance.observance,
    shortSignificance: 'Sun\'s transit into Dhanu Rashi; a month of daily temple observances.',
    significance: 'Marks the Sun\'s transit into Dhanu Rashi, beginning a month widely observed with daily dawn '
        'temple visits.\n\nDetailed shastric significance: [VERIFIED CONTENT REQUIRED]',
    observance: '[VERIFIED CONTENT REQUIRED]',
    preparation: '[VERIFIED CONTENT REQUIRED]',
    mantraSources: [_pendingMantra],
    sources: [_drikPanchang2026],
    isMockCalculated: false,
  ),
  Festival(
    id: 'mukkoti-ekadashi',
    name: 'Mukkoti Ekadashi',
    teluguName: 'ముక్కోటి ఏకాదశి',
    date: DateTime(2026, 12, 20),
    importance: FestivalImportance.observance,
    shortSignificance: 'Vaikunta Ekadashi observance; also Gita Jayanti.',
    significance: 'Also known as Vaikunta Ekadashi, observed with visits to Vishnu temples through the "Uttara '
        'Dwaram" (northern gateway) at many shrines. Coincides with Gita Jayanti this year.\n\n'
        'Detailed shastric significance: [VERIFIED CONTENT REQUIRED]',
    observance: '[VERIFIED CONTENT REQUIRED]',
    preparation: 'Ekadashi fasting practices vary by tradition. [VERIFIED CONTENT REQUIRED]',
    mantraSources: [_pendingMantra],
    sources: [_drikPanchang2026],
    isMockCalculated: false,
  ),
  Festival(
    id: 'dattatreya-jayanti',
    name: 'Dattatreya Jayanti',
    teluguName: 'దత్తాత్రేయ జయంతి',
    date: DateTime(2026, 12, 23),
    importance: FestivalImportance.moderate,
    shortSignificance: 'Commemorates the appearance of Lord Dattatreya.',
    significance: 'Observed as the appearance day of Lord Dattatreya, on Margashirsha Purnima eve.\n\n'
        'Detailed shastric significance: [VERIFIED CONTENT REQUIRED]',
    observance: '[VERIFIED CONTENT REQUIRED]',
    preparation: '[VERIFIED CONTENT REQUIRED]',
    mantraSources: [_pendingMantra],
    sources: [_drikPanchang2026],
    isMockCalculated: false,
  ),
  Festival(
    id: 'margashirsha-purnima',
    name: 'Margashirsha Purnima',
    teluguName: 'మార్గశిర పౌర్ణమి',
    date: DateTime(2026, 12, 24),
    importance: FestivalImportance.moderate,
    shortSignificance: 'Full moon of Margashira masam, within the Dhanurmasam/Arudra period.',
    significance: 'The full-moon day of Margashira masam.\n\nDetailed shastric significance: [VERIFIED CONTENT REQUIRED]',
    observance: '[VERIFIED CONTENT REQUIRED]',
    preparation: '[VERIFIED CONTENT REQUIRED]',
    mantraSources: [_pendingMantra],
    sources: [_drikPanchang2026],
    isMockCalculated: false,
  ),
  Festival(
    id: 'sankranthi',
    name: 'Makara Sankranthi',
    teluguName: 'మకర సంక్రాంతి',
    date: DateTime(2027, 1, 14),
    importance: FestivalImportance.major,
    shortSignificance: 'Harvest festival marking the Sun\'s transit into Makara.',
    significance: 'A major harvest festival marking the Sun\'s transit into Makara Rashi. Celebrated over multiple '
        'days across Telugu households including Bhogi and Kanuma. This date falls outside the range covered by '
        'the Drik Panchang document provided and is an estimate pending confirmation.\n\n'
        'Detailed shastric significance: [VERIFIED CONTENT REQUIRED]',
    observance: 'Bhogi mantalu, Gobbemmalu/Muggu, and Haridasu traditions vary by region. [VERIFIED CONTENT REQUIRED]',
    preparation: 'Home cleaning, rangoli (muggu), and harvest-related preparations.',
    mantraSources: [_pendingMantra],
    sources: [_pendingAlmanac],
  ),
  Festival(
    id: 'maha-shivaratri',
    name: 'Maha Shivaratri',
    teluguName: 'మహా శివరాత్రి',
    date: DateTime(2027, 2, 15),
    importance: FestivalImportance.major,
    shortSignificance: 'Night dedicated to Lord Shiva.',
    significance: 'A major observance dedicated to Lord Shiva, widely marked with night-long vigil and worship. '
        'This date falls outside the range covered by the Drik Panchang document provided and is an estimate '
        'pending confirmation.\n\nDetailed shastric significance: [VERIFIED CONTENT REQUIRED]',
    observance: 'Jagarana and four-yama puja timing details: [VERIFIED CONTENT REQUIRED]',
    preparation: 'Fasting practices vary by tradition. [VERIFIED CONTENT REQUIRED]',
    mantraSources: [_pendingMantra],
    sources: [_pendingAlmanac],
  ),
  Festival(
    id: 'ugadi-next',
    name: 'Ugadi',
    teluguName: 'ఉగాది',
    date: kMockNextUgadiStart,
    importance: FestivalImportance.major,
    shortSignificance: 'Telugu New Year — start of the next calendrical cycle.',
    significance: 'Marks the start of the next Panchangam year. This date falls outside the range covered by the '
        'Drik Panchang document provided and is an estimate pending confirmation.\n\n'
        'Detailed shastric significance: [VERIFIED CONTENT REQUIRED]',
    observance: '[VERIFIED CONTENT REQUIRED]',
    preparation: '[VERIFIED CONTENT REQUIRED]',
    mantraSources: [_pendingMantra],
    sources: [_pendingAlmanac],
  ),
];

List<Festival> get mockFestivals => List.unmodifiable(_festivals);

/// Mock Japa/observance recommendations. Applicability text references
/// Rāśi/Nakshatra generically; mantra content is always withheld.
final List<JapaRecommendation> mockJapaRecommendations = [
  JapaRecommendation(
    id: 'japa-nakshatra-birthstar',
    title: 'Birth-star (Janma Nakshatra) observance',
    teluguTitle: 'జన్మ నక్షత్ర ఆరాధన',
    applicability: 'Recommended on the day your birth Nakshatra recurs each month.',
    reason: 'Traditionally considered a personally significant day for reflection and worship. '
        'Specific rule and rationale: [VERIFIED CONTENT REQUIRED]',
    mantraPlaceholder: '[VERIFIED CONTENT REQUIRED]',
    repetitionInfo: '[VERIFIED CONTENT REQUIRED]',
    preparation: '[VERIFIED CONTENT REQUIRED]',
    source: _pendingAlmanac,
  ),
  JapaRecommendation(
    id: 'japa-rashi-lord',
    title: 'Rāśi-lord observance',
    teluguTitle: 'రాశి అధిపతి ఆరాధన',
    applicability: 'Tied to the graha that rules your Moon Rāśi.',
    reason: 'Some traditions recommend honouring the ruling graha of one\'s Moon sign on its associated weekday. '
        'Specific rule and rationale: [VERIFIED CONTENT REQUIRED]',
    mantraPlaceholder: '[VERIFIED CONTENT REQUIRED]',
    repetitionInfo: '[VERIFIED CONTENT REQUIRED]',
    preparation: '[VERIFIED CONTENT REQUIRED]',
    source: _pendingAlmanac,
  ),
  JapaRecommendation(
    id: 'japa-ekadashi',
    title: 'Ekadashi observance',
    teluguTitle: 'ఏకాదశి వ్రతం',
    applicability: 'Applies on Ekadashi tithi days, shown on the calendar.',
    reason: 'Widely observed across traditions; specific rules vary by sampradaya. '
        'Exact rule and rationale: [VERIFIED CONTENT REQUIRED]',
    mantraPlaceholder: '[VERIFIED CONTENT REQUIRED]',
    repetitionInfo: '[VERIFIED CONTENT REQUIRED]',
    preparation: '[VERIFIED CONTENT REQUIRED]',
    source: _pendingAlmanac,
  ),
];

/// Recurring fasting/observance days. Recurrence descriptions are
/// general-knowledge calendar facts (which Tithi a vrata falls on);
/// exact rules and significance remain pending verification.
final List<VrataObservance> mockVrataObservances = [
  VrataObservance(
    id: 'vrata-ekadashi',
    name: 'Ekadashi Vratam',
    teluguName: 'ఏకాదశి వ్రతం',
    recurrence: 'Twice a month, on the 11th tithi of each paksha',
    shortInfo: 'Widely observed across traditions. Exact rules: [VERIFIED CONTENT REQUIRED]',
    source: _pendingAlmanac,
  ),
  VrataObservance(
    id: 'vrata-sankashti',
    name: 'Sankashti Chaturthi',
    teluguName: 'సంకష్ట చతుర్థి',
    recurrence: 'Monthly, on Krishna Paksha Chaturthi',
    shortInfo: 'Dedicated to Lord Ganesha. Exact rules: [VERIFIED CONTENT REQUIRED]',
    source: _pendingAlmanac,
  ),
  VrataObservance(
    id: 'vrata-pradosha',
    name: 'Pradosha Vratam',
    teluguName: 'ప్రదోష వ్రతం',
    recurrence: 'Twice a month, on Trayodashi tithi',
    shortInfo: 'Dedicated to Lord Shiva. Exact rules: [VERIFIED CONTENT REQUIRED]',
    source: _pendingAlmanac,
  ),
  VrataObservance(
    id: 'vrata-purnima',
    name: 'Purnima Vratam',
    teluguName: 'పౌర్ణమి వ్రతం',
    recurrence: 'Monthly, on the full-moon tithi',
    shortInfo: 'Observed across many traditions. Exact rules: [VERIFIED CONTENT REQUIRED]',
    source: _pendingAlmanac,
  ),
];

/// Devotional text listings. Titles/categories only — actual verse
/// content is intentionally never generated; see
/// [DevotionalText.contentPlaceholder].
final List<DevotionalText> mockDevotionalTexts = [
  DevotionalText(
    id: 'dev-ganesha-aarti',
    title: 'Ganesha Aarti',
    teluguTitle: 'గణేశ హారతి',
    category: DevotionalCategory.aarti,
    deity: 'Ganesha',
    source: _pendingMantra,
  ),
  DevotionalText(
    id: 'dev-hanuman-chalisa',
    title: 'Hanuman Chalisa',
    teluguTitle: 'హనుమాన్ చాలీసా',
    category: DevotionalCategory.chalisa,
    deity: 'Hanuman',
    source: _pendingMantra,
  ),
  DevotionalText(
    id: 'dev-lalitha-sahasranamam',
    title: 'Lalitha Sahasranamam',
    teluguTitle: 'లలితా సహస్రనామం',
    category: DevotionalCategory.stotram,
    deity: 'Lalitha Devi',
    source: _pendingMantra,
  ),
  DevotionalText(
    id: 'dev-vishnu-ashtottaram',
    title: 'Vishnu Ashtottara Shatanamavali',
    teluguTitle: 'విష్ణు అష్టోత్తర శతనామావళి',
    category: DevotionalCategory.ashtottaram,
    deity: 'Vishnu',
    source: _pendingMantra,
  ),
  DevotionalText(
    id: 'dev-shiva-aarti',
    title: 'Shiva Aarti',
    teluguTitle: 'శివ హారతి',
    category: DevotionalCategory.aarti,
    deity: 'Shiva',
    source: _pendingMantra,
  ),
  DevotionalText(
    id: 'dev-venkateswara-suprabhatam',
    title: 'Venkateswara Suprabhatam',
    teluguTitle: 'వేంకటేశ్వర సుప్రభాతం',
    category: DevotionalCategory.stotram,
    deity: 'Venkateswara',
    source: _pendingMantra,
  ),
];
