import Foundation

/// Fixed reference tables — the standard names and ordering of Tithis,
/// Nakshatras, Yogas, Karanas, Rashis and the sixty Samvatsaras. These
/// are stable, well-documented lists, not calculated values.
enum ReferenceTables {

    private static let tithiNames: [(String, String)] = [
        ("Padyami", "పాడ్యమి"), ("Vidiya", "విదియ"), ("Tadiya", "తదియ"), ("Chavithi", "చవితి"),
        ("Panchami", "పంచమి"), ("Shashti", "షష్ఠి"), ("Saptami", "సప్తమి"), ("Ashtami", "అష్టమి"),
        ("Navami", "నవమి"), ("Dashami", "దశమి"), ("Ekadashi", "ఏకాదశి"), ("Dwadashi", "ద్వాదశి"),
        ("Trayodashi", "త్రయోదశి"), ("Chaturdashi", "చతుర్దశి"),
    ]

    /// All thirty tithis, numbered 1..30 (Shukla Padyami .. Amavasya).
    static let tithis: [Tithi] = (1...30).map { n in
        switch n {
        case 15: return Tithi(number: 15, name: "Purnima", telugu: "పౌర్ణమి")
        case 30: return Tithi(number: 30, name: "Amavasya", telugu: "అమావాస్య")
        default:
            let pair = tithiNames[(n - 1) % 15]
            return Tithi(number: n, name: pair.0, telugu: pair.1)
        }
    }

    private static func indexed<T>(_ pairs: [(String, String)], _ make: (Int, String, String) -> T) -> [T] {
        pairs.enumerated().map { make($0.offset + 1, $0.element.0, $0.element.1) }
    }

    static let nakshatras: [Nakshatra] = indexed([
        ("Ashwini", "అశ్విని"), ("Bharani", "భరణి"), ("Krittika", "కృత్తిక"), ("Rohini", "రోహిణి"),
        ("Mrigashira", "మృగశిర"), ("Ardra", "ఆరుద్ర"), ("Punarvasu", "పునర్వసు"), ("Pushyami", "పుష్యమి"),
        ("Ashlesha", "ఆశ్లేష"), ("Magha", "మఖ"), ("Pubba", "పుబ్బ"), ("Uttara", "ఉత్తర"),
        ("Hasta", "హస్త"), ("Chitta", "చిత్త"), ("Swati", "స్వాతి"), ("Vishakha", "విశాఖ"),
        ("Anuradha", "అనూరాధ"), ("Jyeshta", "జ్యేష్ఠ"), ("Moola", "మూల"), ("Purvashadha", "పూర్వాషాఢ"),
        ("Uttarashadha", "ఉత్తరాషాఢ"), ("Shravanam", "శ్రవణం"), ("Dhanishta", "ధనిష్ఠ"),
        ("Shatabhisham", "శతభిషం"), ("Purvabhadra", "పూర్వాభాద్ర"), ("Uttarabhadra", "ఉత్తరాభాద్ర"),
        ("Revati", "రేవతి"),
    ]) { Nakshatra(index: $0, name: $1, telugu: $2) }

    static let yogas: [PanchangYoga] = indexed([
        ("Vishkambha", "విష్కంభ"), ("Priti", "ప్రీతి"), ("Ayushman", "ఆయుష్మాన్"), ("Saubhagya", "సౌభాగ్య"),
        ("Shobhana", "శోభన"), ("Atiganda", "అతిగండ"), ("Sukarma", "సుకర్మ"), ("Dhriti", "ధృతి"),
        ("Shoola", "శూల"), ("Ganda", "గండ"), ("Vriddhi", "వృద్ధి"), ("Dhruva", "ధ్రువ"),
        ("Vyaghata", "వ్యాఘాత"), ("Harshana", "హర్షణ"), ("Vajra", "వజ్ర"), ("Siddhi", "సిద్ధి"),
        ("Vyatipata", "వ్యతీపాత"), ("Variyan", "వరీయాన్"), ("Parigha", "పరిఘ"), ("Shiva", "శివ"),
        ("Siddha", "సిద్ధ"), ("Sadhya", "సాధ్య"), ("Shubha", "శుభ"), ("Shukla", "శుక్ల"),
        ("Brahma", "బ్రహ్మ"), ("Indra", "ఐంద్ర"), ("Vaidhriti", "వైధృతి"),
    ]) { PanchangYoga(index: $0, name: $1, telugu: $2) }

    private static let kimstughna = Karana(name: "Kimstughna", telugu: "కింస్తుఘ్న")
    private static let movableKaranas: [Karana] = [
        Karana(name: "Bava", telugu: "బవ"), Karana(name: "Balava", telugu: "బాలవ"),
        Karana(name: "Kaulava", telugu: "కౌలవ"), Karana(name: "Taitila", telugu: "తైతుల"),
        Karana(name: "Garaja", telugu: "గరజి"), Karana(name: "Vanija", telugu: "వణిజ"),
        Karana(name: "Vishti (Bhadra)", telugu: "విష్టి (భద్ర)"),
    ]
    private static let shakuni = Karana(name: "Shakuni", telugu: "శకుని")
    private static let chatushpada = Karana(name: "Chatushpada", telugu: "చతుష్పాత్")
    private static let naga = Karana(name: "Naga", telugu: "నాగవ")

    /// Karana for half-tithi `k` (0..59, counted from the new moon): the
    /// first half of Shukla Padyami is Kimstughna, then the seven movable
    /// karanas repeat eight times, and the last three halves are Shakuni,
    /// Chatushpada and Naga.
    static func karana(_ k: Int) -> Karana {
        switch k {
        case 0: return kimstughna
        case 57: return shakuni
        case 58: return chatushpada
        case 59: return naga
        default: return movableKaranas[(k - 1) % 7]
        }
    }

    static let rashis: [Rashi] = indexed([
        ("Mesha", "మేషం"), ("Vrishabha", "వృషభం"), ("Mithuna", "మిథునం"), ("Karkataka", "కర్కాటకం"),
        ("Simha", "సింహం"), ("Kanya", "కన్య"), ("Tula", "తుల"), ("Vrishchika", "వృశ్చికం"),
        ("Dhanus", "ధనుస్సు"), ("Makara", "మకరం"), ("Kumbha", "కుంభం"), ("Meena", "మీనం"),
    ]) { Rashi(index: $0, name: $1, telugu: $2) }

    private static let samvatsaraNames: [(String, String)] = [
        ("Prabhava", "ప్రభవ"), ("Vibhava", "విభవ"), ("Shukla", "శుక్ల"), ("Pramoduta", "ప్రమోదూత"),
        ("Prajotpatti", "ప్రజోత్పత్తి"), ("Angirasa", "ఆంగీరస"), ("Shrimukha", "శ్రీముఖ"), ("Bhava", "భావ"),
        ("Yuva", "యువ"), ("Dhatu", "ధాత"), ("Ishvara", "ఈశ్వర"), ("Bahudhanya", "బహుధాన్య"),
        ("Pramadi", "ప్రమాది"), ("Vikrama", "విక్రమ"), ("Vrisha", "వృష"), ("Chitrabhanu", "చిత్రభాను"),
        ("Svabhanu", "స్వభాను"), ("Tarana", "తారణ"), ("Parthiva", "పార్థివ"), ("Vyaya", "వ్యయ"),
        ("Sarvajit", "సర్వజిత్"), ("Sarvadhari", "సర్వధారి"), ("Virodhi", "విరోధి"), ("Vikruti", "వికృతి"),
        ("Khara", "ఖర"), ("Nandana", "నందన"), ("Vijaya", "విజయ"), ("Jaya", "జయ"),
        ("Manmatha", "మన్మథ"), ("Durmukhi", "దుర్ముఖి"), ("Hevilambi", "హేవిళంబి"), ("Vilambi", "విళంబి"),
        ("Vikari", "వికారి"), ("Sharvari", "శార్వరి"), ("Plava", "ప్లవ"), ("Shubhakrit", "శుభకృత్"),
        ("Shobhakrit", "శోభకృత్"), ("Krodhi", "క్రోధి"), ("Vishvavasu", "విశ్వావసు"), ("Parabhava", "పరాభవ"),
        ("Plavanga", "ప్లవంగ"), ("Kilaka", "కీలక"), ("Saumya", "సౌమ్య"), ("Sadharana", "సాధారణ"),
        ("Virodhikrit", "విరోధికృత్"), ("Paridhavi", "పరీధావి"), ("Pramadicha", "ప్రమాదీచ"), ("Ananda", "ఆనంద"),
        ("Rakshasa", "రాక్షస"), ("Nala", "నల"), ("Pingala", "పింగళ"), ("Kalayukti", "కాళయుక్తి"),
        ("Siddharthi", "సిద్ధార్థి"), ("Raudri", "రౌద్రి"), ("Durmati", "దుర్మతి"), ("Dundubhi", "దుందుభి"),
        ("Rudhirodgari", "రుధిరోద్గారి"), ("Raktakshi", "రక్తాక్షి"), ("Krodhana", "క్రోధన"), ("Akshaya", "అక్షయ"),
    ]

    /// Samvatsara of a Shaka year as used in the Telugu (southern, lunar)
    /// reckoning: Shaka 1948 (Ugadi 2026 – Ugadi 2027) is Parabhava, the
    /// 40th — matching the year name in Sringeri Sharada Peetham's own
    /// 2026 announcements.
    static func samvatsara(_ shakaYear: Int) -> Samvatsara {
        let i = floorMod(shakaYear + 11, 60)
        let (name, telugu) = samvatsaraNames[i]
        return Samvatsara(number: i + 1, name: name, telugu: telugu)
    }

    /// Standard day-Choghadiya starting name per weekday (Sunday = 0).
    private static let dayCycle = ["Udveg", "Chal", "Labh", "Amrit", "Kaal", "Shubh", "Rog"]
    private static let dayStart = [0, 3, 6, 2, 5, 1, 4]

    /// The eight day-Choghadiya names for a weekday (Sunday = 0).
    static func dayChoghadiya(_ weekday: Int) -> [String] {
        (0..<8).map { dayCycle[(dayStart[weekday] + $0) % 7] }
    }

    /// Night Choghadiyas run through the cycle in steps of −2 (mod 7),
    /// starting from the name that opens the day four weekdays later.
    static func nightChoghadiya(_ weekday: Int) -> [String] {
        let first = dayStart[(weekday + 4) % 7]
        return (0..<8).map { dayCycle[floorMod(first - 2 * $0, 7)] }
    }

    static let choghadiyaTelugu: [String: String] = [
        "Udveg": "ఉద్వేగ", "Chal": "చర", "Labh": "లాభ", "Amrit": "అమృత",
        "Kaal": "కాల", "Shubh": "శుభ", "Rog": "రోగ",
    ]

    static func floorMod(_ a: Int, _ n: Int) -> Int { ((a % n) + n) % n }
}
