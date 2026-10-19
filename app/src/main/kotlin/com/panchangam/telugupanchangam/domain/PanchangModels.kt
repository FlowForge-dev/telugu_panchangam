package com.panchangam.telugupanchangam.domain

import java.time.LocalDate
import java.time.LocalDateTime

/** The seven-day week (Vara). */
enum class Vara(val transliteration: String, val telugu: String, val short: String) {
    SUNDAY("Ravivaram", "ఆదివారం", "ఆది"),
    MONDAY("Somavaram", "సోమవారం", "సోమ"),
    TUESDAY("Mangalavaram", "మంగళవారం", "మంగళ"),
    WEDNESDAY("Budhavaram", "బుధవారం", "బుధ"),
    THURSDAY("Guruvaram", "గురువారం", "గురు"),
    FRIDAY("Shukravaram", "శుక్రవారం", "శుక్ర"),
    SATURDAY("Shanivaram", "శనివారం", "శని");

    companion object {
        /** Sunday-first index, matching the calendar grid. */
        fun forDate(date: LocalDate): Vara = entries[date.dayOfWeek.value % 7]
    }
}

/** Waxing (Shukla) or waning (Krishna) fortnight. */
enum class Paksha(val transliteration: String, val telugu: String) {
    SHUKLA("Shukla Paksham", "శుక్ల పక్షం"),
    KRISHNA("Krishna Paksham", "కృష్ణ పక్షం")
}

/**
 * One of the thirty lunar days of a month. [number] runs 1..30
 * (Shukla Padyami = 1, Purnima = 15, Krishna Padyami = 16, Amavasya = 30);
 * [index] is the 1..15 position within its paksha.
 */
data class Tithi(val number: Int, val name: String, val telugu: String) {
    val paksha: Paksha get() = if (number <= 15) Paksha.SHUKLA else Paksha.KRISHNA
    val index: Int get() = (number - 1) % 15 + 1
    val label: String get() = "${if (paksha == Paksha.SHUKLA) "Shukla" else "Krishna"} $name"
}

/** The twelve lunar months, Chaitra (Ugadi) first. Amanta reckoning. */
enum class Masa(val transliteration: String, val telugu: String) {
    CHAITRA("Chaitram", "చైత్రం"),
    VAISHAKHA("Vaishakham", "వైశాఖం"),
    JYESHTHA("Jyeshtham", "జ్యేష్ఠం"),
    ASHADHA("Ashadham", "ఆషాఢం"),
    SHRAVANA("Shravanam", "శ్రావణం"),
    BHADRAPADA("Bhadrapadam", "భాద్రపదం"),
    ASHWAYUJA("Ashvayujam", "ఆశ్వయుజం"),
    KARTHIKA("Kartikam", "కార్తీకం"),
    MARGASHIRA("Margashiram", "మార్గశిరం"),
    PUSHYA("Pushyam", "పుష్యం"),
    MAGHA("Magham", "మాఘం"),
    PHALGUNA("Phalgunam", "ఫాల్గుణం")
}

/**
 * A lunar month. [isAdhika] marks an intercalary month (no solar
 * ingress inside it); [isNija] marks the regular month that follows one.
 */
data class LunarMonth(val masa: Masa, val isAdhika: Boolean, val isNija: Boolean = false) {
    val telugu: String
        get() = when {
            isAdhika -> "అధిక ${masa.telugu}"
            isNija -> "నిజ ${masa.telugu}"
            else -> masa.telugu
        }
    val transliteration: String
        get() = when {
            isAdhika -> "Adhika ${masa.transliteration}"
            isNija -> "Nija ${masa.transliteration}"
            else -> masa.transliteration
        }
}

/** The six seasons, reckoned by lunar month as Telugu Panchangams do. */
enum class Ritu(val transliteration: String, val telugu: String) {
    VASANTA("Vasanta", "వసంత ఋతువు"),
    GRISHMA("Grishma", "గ్రీష్మ ఋతువు"),
    VARSHA("Varsha", "వర్ష ఋతువు"),
    SHARAD("Sharad", "శరదృతువు"),
    HEMANTA("Hemanta", "హేమంత ఋతువు"),
    SHISHIRA("Shishira", "శిశిర ఋతువు");

    companion object {
        fun forMasa(masa: Masa): Ritu = entries[masa.ordinal / 2]
    }
}

enum class Ayana(val transliteration: String, val telugu: String) {
    UTTARAYANA("Uttarayanam", "ఉత్తరాయణం"),
    DAKSHINAYANA("Dakshinayanam", "దక్షిణాయనం")
}

/** The 60-year Jovian cycle; [number] is 1..60 with Prabhava = 1. */
data class Samvatsara(val number: Int, val name: String, val telugu: String)

data class Nakshatra(val index: Int, val name: String, val telugu: String)

data class PanchangYoga(val index: Int, val name: String, val telugu: String)

data class Karana(val name: String, val telugu: String)

data class Rashi(val index: Int, val name: String, val telugu: String)

/**
 * One limb of the Panchangam with the interval it holds. [start] can
 * fall before sunrise and [end] after the next sunrise.
 */
data class Span<T>(val item: T, val start: LocalDateTime, val end: LocalDateTime)

/** A named time window (Rahu Kalam, Abhijit, ...). */
data class TimeWindow(
    val label: String,
    val teluguLabel: String,
    val start: LocalDateTime,
    val end: LocalDateTime,
    val auspicious: Boolean
)

enum class ChoghadiyaQuality { GOOD, NEUTRAL, INAUSPICIOUS }

data class ChoghadiyaPeriod(
    val name: String,
    val telugu: String,
    val start: LocalDateTime,
    val end: LocalDateTime,
    val quality: ChoghadiyaQuality,
    val isNight: Boolean
)

/** How a day should be flagged on the calendar grid. */
enum class SpecialDayType { NONE, EKADASHI, PURNIMA, AMAVASYA }

/** Light calendar-grid data for a date: what holds at local sunrise. */
data class DaySummary(
    val date: LocalDate,
    val tithi: Tithi,
    val lunarMonth: LunarMonth,
    val nakshatra: Nakshatra,
    /** Moon − Sun elongation at sunrise, 0..360°, for drawing the phase. */
    val elongation: Double,
    val specialDayType: SpecialDayType
)

/**
 * Full Panchangam for a civil date at a [City]: the five limbs as they
 * run from this sunrise to the next, plus the derived time windows.
 * Computed astronomically; see `astro/Astronomy.kt` for the method.
 */
data class PanchangDay(
    val date: LocalDate,
    val city: City,
    val vara: Vara,
    val samvatsara: Samvatsara,
    val shakaYear: Int,
    val ayana: Ayana,
    val ritu: Ritu,
    val lunarMonth: LunarMonth,
    val paksha: Paksha,
    val tithis: List<Span<Tithi>>,
    val nakshatras: List<Span<Nakshatra>>,
    val yogas: List<Span<PanchangYoga>>,
    val karanas: List<Span<Karana>>,
    val sunRashi: Rashi,
    val moonRashi: Rashi,
    val sunrise: LocalDateTime,
    val sunset: LocalDateTime,
    val nextSunrise: LocalDateTime,
    val moonrise: LocalDateTime?,
    val moonset: LocalDateTime?,
    val inauspicious: List<TimeWindow>,
    val auspicious: List<TimeWindow>,
    val dayChoghadiya: List<ChoghadiyaPeriod>,
    val nightChoghadiya: List<ChoghadiyaPeriod>,
    val elongation: Double,
    val specialDayType: SpecialDayType
) {
    /** The tithi prevailing at sunrise — the one the day is named after. */
    val tithi: Tithi get() = tithis.first().item
    val nakshatra: Nakshatra get() = nakshatras.first().item
    val yoga: PanchangYoga get() = yogas.first().item
    val karana: Karana get() = karanas.first().item
}
