import '../../domain/models/festival_models.dart';
import '../../domain/models/jatakam_models.dart';
import '../../domain/models/panchang_models.dart';
import '../../domain/models/source_reference.dart';

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

  final specialType = _specialDayTypeFor(tithi, paksha);
  final festival = _festivals.where((f) => _sameDay(f.date, normalized)).toList();

  return PanchangDay(
    date: normalized,
    vara: vara,
    masa: masa,
    paksha: paksha,
    tithi: tithi,
    nakshatra: NakshatraRef(name: nak.name, telugu: nak.telugu, pada: pada),
    sunrise: '06:0${(normalized.day % 5)} AM',
    sunset: '06:${30 + (normalized.day % 20)} PM',
    moonrise: '${_hour12(7 + normalized.day % 12)}:15 ${normalized.day.isEven ? 'AM' : 'PM'}',
    moonset: '${_hour12(6 + normalized.day % 11)}:40 ${normalized.day.isOdd ? 'AM' : 'PM'}',
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
    specialDayType: festival.isNotEmpty ? SpecialDayType.majorFestival : specialType,
    festivalId: festival.isNotEmpty ? festival.first.id : null,
  );
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

/// Festival calendar for the mock Ugadi -> Ugadi year. Dates are
/// placeholders for UI development, NOT the result of a verified
/// Panchangam calculation — see [Festival.isMockCalculated].
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
    sources: [_pendingAlmanac],
  ),
  Festival(
    id: 'sri-rama-navami',
    name: 'Sri Rama Navami',
    teluguName: 'శ్రీరామ నవమి',
    date: kMockUgadiStart.add(const Duration(days: 8)),
    importance: FestivalImportance.major,
    shortSignificance: 'Commemorates the birth of Sri Rama.',
    significance: 'Observed as the birth anniversary of Sri Rama. Many temples hold Kalyanam (ceremonial wedding) '
        'observances on this day.\n\nDetailed shastric significance: [VERIFIED CONTENT REQUIRED]',
    observance: 'Temple visits and Kalyanotsavam. Exact ritual sequence: [VERIFIED CONTENT REQUIRED]',
    preparation: 'Fasting practices vary by household and tradition. [VERIFIED CONTENT REQUIRED]',
    mantraSources: [_pendingMantra],
    sources: [_pendingAlmanac],
  ),
  Festival(
    id: 'hanuman-jayanti',
    name: 'Hanuman Jayanti',
    teluguName: 'హనుమాన్ జయంతి',
    date: kMockUgadiStart.add(const Duration(days: 22)),
    importance: FestivalImportance.moderate,
    shortSignificance: 'Birth anniversary of Sri Hanuman.',
    significance: 'Observed by many as the birth anniversary of Hanuman. Regional dates and traditions vary.\n\n'
        'Detailed shastric significance: [VERIFIED CONTENT REQUIRED]',
    observance: '[VERIFIED CONTENT REQUIRED]',
    preparation: '[VERIFIED CONTENT REQUIRED]',
    mantraSources: [_pendingMantra],
    sources: [_pendingAlmanac],
  ),
  Festival(
    id: 'varalakshmi-vratam',
    name: 'Varalakshmi Vratam',
    teluguName: 'వరలక్ష్మి వ్రతం',
    date: DateTime(2026, 8, 21),
    importance: FestivalImportance.major,
    shortSignificance: 'Vratam dedicated to Goddess Varalakshmi.',
    significance: 'A widely observed vratam dedicated to Goddess Varalakshmi, performed by many households on the '
        'Friday before the full moon of Shravana masam.\n\nDetailed shastric significance: [VERIFIED CONTENT REQUIRED]',
    observance: 'Exact vratam procedure and timing: [VERIFIED CONTENT REQUIRED]',
    preparation: 'Kalasham setup and household preparation vary by family tradition. [VERIFIED CONTENT REQUIRED]',
    mantraSources: [_pendingMantra],
    sources: [_pendingAlmanac],
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
    sources: [_pendingAlmanac],
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
    sources: [_pendingAlmanac],
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
    sources: [_pendingAlmanac],
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
    sources: [_pendingAlmanac],
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
    sources: [_pendingAlmanac],
  ),
  Festival(
    id: 'karthika-pournami',
    name: 'Karthika Pournami',
    teluguName: 'కార్తీక పౌర్ణమి',
    date: DateTime(2026, 12, 4),
    importance: FestivalImportance.moderate,
    shortSignificance: 'Full moon of Karthika masam.',
    significance: 'The full-moon day of Karthika masam, traditionally associated with lighting lamps at home and '
        'in temples.\n\nDetailed shastric significance: [VERIFIED CONTENT REQUIRED]',
    observance: '[VERIFIED CONTENT REQUIRED]',
    preparation: '[VERIFIED CONTENT REQUIRED]',
    mantraSources: [_pendingMantra],
    sources: [_pendingAlmanac],
  ),
  Festival(
    id: 'mukkoti-ekadashi',
    name: 'Mukkoti Ekadashi',
    teluguName: 'ముక్కోటి ఏకాదశి',
    date: DateTime(2026, 12, 19),
    importance: FestivalImportance.observance,
    shortSignificance: 'Vaikunta Ekadashi observance.',
    significance: 'Also known as Vaikunta Ekadashi, observed with visits to Vishnu temples through the "Uttara '
        'Dwaram" (northern gateway) at many shrines.\n\nDetailed shastric significance: [VERIFIED CONTENT REQUIRED]',
    observance: '[VERIFIED CONTENT REQUIRED]',
    preparation: 'Ekadashi fasting practices vary by tradition. [VERIFIED CONTENT REQUIRED]',
    mantraSources: [_pendingMantra],
    sources: [_pendingAlmanac],
  ),
  Festival(
    id: 'sankranthi',
    name: 'Makara Sankranthi',
    teluguName: 'మకర సంక్రాంతి',
    date: DateTime(2027, 1, 14),
    importance: FestivalImportance.major,
    shortSignificance: 'Harvest festival marking the Sun\'s transit into Makara.',
    significance: 'A major harvest festival marking the Sun\'s transit into Makara Rashi. Celebrated over multiple '
        'days across Telugu households including Bhogi and Kanuma.\n\n'
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
    significance: 'A major observance dedicated to Lord Shiva, widely marked with night-long vigil and worship.\n\n'
        'Detailed shastric significance: [VERIFIED CONTENT REQUIRED]',
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
    significance: 'Marks the start of the next Panchangam year.\n\nDetailed shastric significance: [VERIFIED CONTENT REQUIRED]',
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
