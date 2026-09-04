package com.panchangam.telugupanchangam.domain

import java.time.LocalDate

/** The seven-day week (Vara). */
enum class Vara(val transliteration: String, val telugu: String, val short: String) {
    SUNDAY("Ravivaram", "ఆదివారం", "ఆది"),
    MONDAY("Somavaram", "సోమవారం", "సోమ"),
    TUESDAY("Mangalavaram", "మంగళవారం", "మం"),
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

/** One of the fifteen lunar days within a paksha. */
data class Tithi(val index: Int, val name: String, val telugu: String) {
    val label: String get() = "$name ($index)"
}

/** The twelve Telugu lunar months, Ugadi (Chaitra) first. */
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

data class Nakshatra(val index: Int, val name: String, val telugu: String)

data class PanchangYoga(val index: Int, val name: String, val telugu: String)

data class Karana(val name: String, val telugu: String)

/** An inauspicious/notable time window shown on a day (e.g. Rahu Kalam). */
data class MuhurtaWindow(
    val label: String,
    val teluguLabel: String,
    val start: String,
    val end: String
)

enum class ChoghadiyaQuality { GOOD, NEUTRAL, INAUSPICIOUS }

data class ChoghadiyaPeriod(
    val name: String,
    val telugu: String,
    val start: String,
    val end: String,
    val quality: ChoghadiyaQuality
)

/** How a day should be flagged on the calendar grid. */
enum class SpecialDayType { NONE, FESTIVAL, EKADASHI, AMAVASYA, PURNIMA }

/**
 * Full Panchangam detail for a single Gregorian date.
 *
 * NOTE: every field except [date], [vara] and [festivalId] is produced by
 * the development mock generator, not a verified astronomical engine —
 * see [isMockCalculated].
 */
data class PanchangDay(
    val date: LocalDate,
    val vara: Vara,
    val masa: Masa,
    val paksha: Paksha,
    val tithi: Tithi,
    val nakshatra: Nakshatra,
    val nakshatraPada: Int,
    val yoga: PanchangYoga,
    val karana: Karana,
    val shakaSamvatYear: Int,
    val sunrise: String,
    val sunset: String,
    val moonrise: String,
    val moonset: String,
    val muhurtas: List<MuhurtaWindow> = emptyList(),
    val choghadiya: List<ChoghadiyaPeriod> = emptyList(),
    val specialDayType: SpecialDayType = SpecialDayType.NONE,
    val festivalId: String? = null,
    val isMockCalculated: Boolean = true
) {
    val isSpecial: Boolean get() = specialDayType != SpecialDayType.NONE
}
