import Foundation

/// The seven-day week (Vara). Sunday-first, matching the calendar grid.
enum Vara: Int, CaseIterable {
    case sunday, monday, tuesday, wednesday, thursday, friday, saturday

    var transliteration: String {
        ["Ravivaram", "Somavaram", "Mangalavaram", "Budhavaram", "Guruvaram", "Shukravaram", "Shanivaram"][rawValue]
    }
    var telugu: String {
        ["ఆదివారం", "సోమవారం", "మంగళవారం", "బుధవారం", "గురువారం", "శుక్రవారం", "శనివారం"][rawValue]
    }
    var short: String {
        ["ఆది", "సోమ", "మంగళ", "బుధ", "గురు", "శుక్ర", "శని"][rawValue]
    }

    static func forDate(_ date: CivilDate) -> Vara { Vara(rawValue: date.weekdayIndex)! }
}

/// Waxing (Shukla) or waning (Krishna) fortnight.
enum Paksha {
    case shukla, krishna

    var transliteration: String { self == .shukla ? "Shukla Paksham" : "Krishna Paksham" }
    var telugu: String { self == .shukla ? "శుక్ల పక్షం" : "కృష్ణ పక్షం" }
    /// "శుక్ల" / "కృష్ణ" — the first word of [telugu].
    var teluguShort: String { self == .shukla ? "శుక్ల" : "కృష్ణ" }
}

/// One of the thirty lunar days of a month. `number` runs 1..30
/// (Shukla Padyami = 1, Purnima = 15, Krishna Padyami = 16, Amavasya = 30);
/// `index` is the 1..15 position within its paksha.
struct Tithi: Hashable {
    let number: Int
    let name: String
    let telugu: String

    var paksha: Paksha { number <= 15 ? .shukla : .krishna }
    var index: Int { (number - 1) % 15 + 1 }
    var label: String { "\(paksha == .shukla ? "Shukla" : "Krishna") \(name)" }
}

/// The twelve lunar months, Chaitra (Ugadi) first. Amanta reckoning.
enum Masa: Int, CaseIterable {
    case chaitra, vaishakha, jyeshtha, ashadha, shravana, bhadrapada,
         ashwayuja, karthika, margashira, pushya, magha, phalguna

    var transliteration: String {
        ["Chaitram", "Vaishakham", "Jyeshtham", "Ashadham", "Shravanam", "Bhadrapadam",
         "Ashvayujam", "Kartikam", "Margashiram", "Pushyam", "Magham", "Phalgunam"][rawValue]
    }
    var telugu: String {
        ["చైత్రం", "వైశాఖం", "జ్యేష్ఠం", "ఆషాఢం", "శ్రావణం", "భాద్రపదం",
         "ఆశ్వయుజం", "కార్తీకం", "మార్గశిరం", "పుష్యం", "మాఘం", "ఫాల్గుణం"][rawValue]
    }
}

/// A lunar month. `isAdhika` marks an intercalary month (no solar
/// ingress inside it); `isNija` marks the regular month that follows one.
struct LunarMonth: Hashable {
    let masa: Masa
    let isAdhika: Bool
    var isNija: Bool = false

    var telugu: String {
        if isAdhika { return "అధిక \(masa.telugu)" }
        if isNija { return "నిజ \(masa.telugu)" }
        return masa.telugu
    }
    var transliteration: String {
        if isAdhika { return "Adhika \(masa.transliteration)" }
        if isNija { return "Nija \(masa.transliteration)" }
        return masa.transliteration
    }
}

/// The six seasons, reckoned by lunar month as Telugu Panchangams do.
enum Ritu: Int, CaseIterable {
    case vasanta, grishma, varsha, sharad, hemanta, shishira

    var transliteration: String {
        ["Vasanta", "Grishma", "Varsha", "Sharad", "Hemanta", "Shishira"][rawValue]
    }
    var telugu: String {
        ["వసంత ఋతువు", "గ్రీష్మ ఋతువు", "వర్ష ఋతువు", "శరదృతువు", "హేమంత ఋతువు", "శిశిర ఋతువు"][rawValue]
    }

    static func forMasa(_ masa: Masa) -> Ritu { Ritu(rawValue: masa.rawValue / 2)! }
}

enum Ayana: String {
    case uttarayana = "UTTARAYANA"
    case dakshinayana = "DAKSHINAYANA"

    var transliteration: String { self == .uttarayana ? "Uttarayanam" : "Dakshinayanam" }
    var telugu: String { self == .uttarayana ? "ఉత్తరాయణం" : "దక్షిణాయనం" }
}

/// The 60-year Jovian cycle; `number` is 1..60 with Prabhava = 1.
struct Samvatsara: Hashable {
    let number: Int
    let name: String
    let telugu: String
}

struct Nakshatra: Hashable {
    let index: Int
    let name: String
    let telugu: String
}

struct PanchangYoga: Hashable {
    let index: Int
    let name: String
    let telugu: String
}

struct Karana: Hashable {
    let name: String
    let telugu: String
}

struct Rashi: Hashable {
    let index: Int
    let name: String
    let telugu: String
}

/// One limb of the Panchangam with the interval it holds. `start` can
/// fall before sunrise and `end` after the next sunrise.
struct Span<T> {
    let item: T
    let start: Date
    let end: Date

    func contains(_ t: Date) -> Bool { t >= start && t < end }
}

/// A named time window (Rahu Kalam, Abhijit, ...).
struct TimeWindow {
    let label: String
    let teluguLabel: String
    let start: Date
    let end: Date
    let auspicious: Bool

    func contains(_ t: Date) -> Bool { t >= start && t < end }
}

enum ChoghadiyaQuality: CaseIterable {
    case good, neutral, inauspicious

    var telugu: String {
        switch self {
        case .good: return "శుభం"
        case .neutral: return "సమం"
        case .inauspicious: return "అశుభం"
        }
    }
}

struct ChoghadiyaPeriod {
    let name: String
    let telugu: String
    let start: Date
    let end: Date
    let quality: ChoghadiyaQuality
    let isNight: Bool

    func contains(_ t: Date) -> Bool { t >= start && t < end }
}

/// How a day should be flagged on the calendar grid.
enum SpecialDayType {
    case none, ekadashi, purnima, amavasya
}

/// Light calendar-grid data for a date: what holds at local sunrise.
struct DaySummary {
    let date: CivilDate
    let tithi: Tithi
    let lunarMonth: LunarMonth
    let nakshatra: Nakshatra
    /// Moon − Sun elongation at sunrise, 0..360°, for drawing the phase.
    let elongation: Double
    let specialDayType: SpecialDayType
}

/// Full Panchangam for a civil date at a `City`: the five limbs as they
/// run from this sunrise to the next, plus the derived time windows.
/// All instants are absolute `Date`s; display them in `city.zone`.
struct PanchangDay {
    let date: CivilDate
    let city: City
    let vara: Vara
    let samvatsara: Samvatsara
    let shakaYear: Int
    let ayana: Ayana
    let ritu: Ritu
    let lunarMonth: LunarMonth
    let paksha: Paksha
    let tithis: [Span<Tithi>]
    let nakshatras: [Span<Nakshatra>]
    let yogas: [Span<PanchangYoga>]
    let karanas: [Span<Karana>]
    let sunRashi: Rashi
    let moonRashi: Rashi
    let sunrise: Date
    let sunset: Date
    let nextSunrise: Date
    let moonrise: Date?
    let moonset: Date?
    let inauspicious: [TimeWindow]
    let auspicious: [TimeWindow]
    let dayChoghadiya: [ChoghadiyaPeriod]
    let nightChoghadiya: [ChoghadiyaPeriod]
    let elongation: Double
    let specialDayType: SpecialDayType

    /// The tithi prevailing at sunrise — the one the day is named after.
    var tithi: Tithi { tithis[0].item }
    var nakshatra: Nakshatra { nakshatras[0].item }
    var yoga: PanchangYoga { yogas[0].item }
    var karana: Karana { karanas[0].item }
}
