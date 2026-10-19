package com.panchangam.telugupanchangam.data

import com.panchangam.telugupanchangam.astro.Astronomy
import com.panchangam.telugupanchangam.domain.Ayana
import com.panchangam.telugupanchangam.domain.ChoghadiyaPeriod
import com.panchangam.telugupanchangam.domain.ChoghadiyaQuality
import com.panchangam.telugupanchangam.domain.City
import com.panchangam.telugupanchangam.domain.DaySummary
import com.panchangam.telugupanchangam.domain.LunarMonth
import com.panchangam.telugupanchangam.domain.Masa
import com.panchangam.telugupanchangam.domain.PanchangDay
import com.panchangam.telugupanchangam.domain.PanchangRepository
import com.panchangam.telugupanchangam.domain.Ritu
import com.panchangam.telugupanchangam.domain.Span
import com.panchangam.telugupanchangam.domain.SpecialDayType
import com.panchangam.telugupanchangam.domain.TimeWindow
import com.panchangam.telugupanchangam.domain.Vara
import java.time.Instant
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.ZoneId
import kotlin.math.floor

/**
 * Computes the Panchangam from first principles for any date and city:
 * Sun and Moon positions from [Astronomy], Lahiri ayanamsa, amanta
 * lunar months with adhika-masa detection, and the sunrise-based
 * conventions used by Telugu Panchangams.
 *
 * Accuracy, checked against the Swiss Ephemeris (see README): tithi,
 * nakshatra, yoga and karana transition times within about a minute;
 * sunrise and sunset within about a minute.
 */
class AstronomicalPanchangRepository : PanchangRepository {

    private val dayCache = object : LinkedHashMap<Pair<LocalDate, String>, PanchangDay>(64, 0.75f, true) {
        override fun removeEldestEntry(eldest: MutableMap.MutableEntry<Pair<LocalDate, String>, PanchangDay>?) =
            size > 120
    }
    private val summaryCache = object : LinkedHashMap<Pair<LocalDate, String>, DaySummary>(256, 0.75f, true) {
        override fun removeEldestEntry(eldest: MutableMap.MutableEntry<Pair<LocalDate, String>, DaySummary>?) =
            size > 1200
    }

    @Synchronized
    override fun dayDetail(date: LocalDate, city: City): PanchangDay =
        dayCache.getOrPut(date to city.id) { compute(date, city) }

    @Synchronized
    override fun summaries(start: LocalDate, end: LocalDate, city: City): Map<LocalDate, DaySummary> {
        val out = LinkedHashMap<LocalDate, DaySummary>()
        var d = start
        while (!d.isAfter(end)) {
            out[d] = summaryCache.getOrPut(d to city.id) { summarise(d, city) }
            d = d.plusDays(1)
        }
        return out
    }

    // ------------------------------------------------------------------

    private fun summarise(date: LocalDate, city: City): DaySummary {
        val midnight = jdAtStartOf(date, city.zone)
        val sunrise = sunrise(midnight, city)
        val elong = Astronomy.elongation(sunrise)
        val tithi = ReferenceTables.tithis[tithiIndex(elong)]
        return DaySummary(
            date = date,
            tithi = tithi,
            lunarMonth = lunarMonth(sunrise),
            nakshatra = ReferenceTables.nakshatras[nakshatraIndex(Astronomy.moonSidereal(sunrise))],
            elongation = elong,
            specialDayType = specialDay(tithi.number)
        )
    }

    private fun compute(date: LocalDate, city: City): PanchangDay {
        val zone = city.zone
        val midnight = jdAtStartOf(date, zone)
        val sunrise = sunrise(midnight, city)
        val sunset = Astronomy.findCrossing(sunrise, midnight + 1.0, Astronomy.SUN_RISE_ALTITUDE, rising = false) {
            Astronomy.sunAltitude(it, city.latitude, city.longitude)
        } ?: (sunrise + 0.5)
        val nextSunrise = sunrise(midnight + 1.0, city)

        val moonAlt = { jd: Double -> Astronomy.moonAltitude(jd, city.latitude, city.longitude) }
        val moonrise = Astronomy.findCrossing(midnight, midnight + 1.0, Astronomy.MOON_RISE_ALTITUDE, true, moonAlt)
        val moonset = Astronomy.findCrossing(midnight, midnight + 1.0, Astronomy.MOON_RISE_ALTITUDE, false, moonAlt)

        fun t(jd: Double) = toLocal(jd, zone)

        val tithis = spans(sunrise, nextSunrise, 12.0, Astronomy.MOON_SUN_RATE, Astronomy::elongation) { i ->
            ReferenceTables.tithis[i % 30]
        }.map { Span(it.first, t(it.second), t(it.third)) }

        val nakshatras = spans(sunrise, nextSunrise, 360.0 / 27, Astronomy.MOON_RATE, Astronomy::moonSidereal) { i ->
            ReferenceTables.nakshatras[i % 27]
        }.map { Span(it.first, t(it.second), t(it.third)) }

        val yogas = spans(sunrise, nextSunrise, 360.0 / 27, Astronomy.YOGA_RATE, Astronomy::yogaArgument) { i ->
            ReferenceTables.yogas[i % 27]
        }.map { Span(it.first, t(it.second), t(it.third)) }

        val karanas = spans(sunrise, nextSunrise, 6.0, Astronomy.MOON_SUN_RATE, Astronomy::elongation) { i ->
            ReferenceTables.karana(i % 60)
        }.map { Span(it.first, t(it.second), t(it.third)) }

        val month = lunarMonth(sunrise)
        val shaka = shakaYear(date, month.masa)
        val sunLon = Astronomy.sunSidereal(sunrise)
        val vara = Vara.forDate(date)
        val w = vara.ordinal

        // ---- Kalams: the day split into eight equal parts ------------
        val day = sunset - sunrise
        val part = day / 8.0
        fun part(n: Int) = t(sunrise + part * (n - 1)) to t(sunrise + part * n)
        val rahu = part(intArrayOf(8, 2, 7, 5, 6, 4, 3)[w])
        val yama = part(intArrayOf(5, 4, 3, 2, 1, 7, 6)[w])
        val gulika = part(intArrayOf(7, 6, 5, 4, 3, 2, 1)[w])

        // ---- Muhurtas: day and night each split into fifteen ---------
        val dayMuhurta = day / 15.0
        val nightMuhurta = (nextSunrise - sunset) / 15.0

        val inauspicious = listOf(
            TimeWindow("Rahu Kalam", "రాహు కాలం", rahu.first, rahu.second, false),
            TimeWindow("Yamagandam", "యమగండం", yama.first, yama.second, false),
            TimeWindow("Gulika Kalam", "గుళిక కాలం", gulika.first, gulika.second, false)
        )
        val auspicious = listOf(
            TimeWindow(
                "Brahma Muhurtam", "బ్రాహ్మీ ముహూర్తం",
                t(sunrise - 2 * nightMuhurta), t(sunrise - nightMuhurta), true
            ),
            TimeWindow(
                "Abhijit Muhurtam", "అభిజిత్ ముహూర్తం",
                t(sunrise + 7 * dayMuhurta), t(sunrise + 8 * dayMuhurta), true
            )
        )

        val dayChoghadiya = choghadiya(ReferenceTables.dayChoghadiya(w), sunrise, sunset, false, zone)
        val nightChoghadiya = choghadiya(ReferenceTables.nightChoghadiya(w), sunset, nextSunrise, true, zone)

        val elong = Astronomy.elongation(sunrise)
        return PanchangDay(
            date = date,
            city = city,
            vara = vara,
            samvatsara = ReferenceTables.samvatsara(shaka),
            shakaYear = shaka,
            ayana = if (sunLon >= 270.0 || sunLon < 90.0) Ayana.UTTARAYANA else Ayana.DAKSHINAYANA,
            ritu = Ritu.forMasa(month.masa),
            lunarMonth = month,
            paksha = tithis.first().item.paksha,
            tithis = tithis,
            nakshatras = nakshatras,
            yogas = yogas,
            karanas = karanas,
            sunRashi = ReferenceTables.rashis[(sunLon / 30.0).toInt() % 12],
            moonRashi = ReferenceTables.rashis[(Astronomy.moonSidereal(sunrise) / 30.0).toInt() % 12],
            sunrise = t(sunrise),
            sunset = t(sunset),
            nextSunrise = t(nextSunrise),
            moonrise = moonrise?.let(::t),
            moonset = moonset?.let(::t),
            inauspicious = inauspicious,
            auspicious = auspicious,
            dayChoghadiya = dayChoghadiya,
            nightChoghadiya = nightChoghadiya,
            elongation = elong,
            specialDayType = specialDay(tithis.first().item.number)
        )
    }

    // ------------------------------------------------------------------

    /**
     * Splits [from, to) into the successive divisions of an angle that
     * grows at about [rate] °/day, each [size]° wide. Returns
     * (item, startJd, endJd) triples; the first starts before [from].
     */
    private fun <T> spans(
        from: Double, to: Double, size: Double, rate: Double,
        angle: (Double) -> Double, item: (Int) -> T
    ): List<Triple<T, Double, Double>> {
        val out = ArrayList<Triple<T, Double, Double>>(3)
        var index = floor(angle(from) / size).toInt()
        var start = Astronomy.previousTimeAngleReached(from, index * size, rate, angle)
        var cursor = from
        while (cursor < to && out.size < 4) {
            val end = Astronomy.nextTimeAngleReaches(cursor, Astronomy.norm360((index + 1) * size), rate, angle)
            out += Triple(item(index), start, end)
            start = end
            cursor = end + 1e-6
            index += 1
        }
        return out
    }

    private fun choghadiya(
        names: List<String>, from: Double, to: Double, night: Boolean, zone: ZoneId
    ): List<ChoghadiyaPeriod> {
        val slot = (to - from) / 8.0
        return names.mapIndexed { i, name ->
            ChoghadiyaPeriod(
                name = name,
                telugu = ReferenceTables.choghadiyaTelugu.getValue(name),
                start = toLocal(from + slot * i, zone),
                end = toLocal(from + slot * (i + 1), zone),
                quality = when (name) {
                    "Labh", "Amrit", "Shubh" -> ChoghadiyaQuality.GOOD
                    "Chal" -> ChoghadiyaQuality.NEUTRAL
                    else -> ChoghadiyaQuality.INAUSPICIOUS
                },
                isNight = night
            )
        }
    }

    /**
     * Amanta month containing [jd]: named after the sidereal sign the Sun
     * occupies at the opening new moon, plus one (Sun in Meena → Chaitra).
     * A lunar month with no solar ingress is adhika; the month after an
     * adhika month of the same name is nija.
     */
    private fun lunarMonth(jd: Double): LunarMonth {
        val nmBefore = Astronomy.previousTimeAngleReached(jd, 0.0, Astronomy.MOON_SUN_RATE, Astronomy::elongation)
        val nmAfter = Astronomy.nextTimeAngleReaches(nmBefore + 20.0, 0.0, Astronomy.MOON_SUN_RATE, Astronomy::elongation)
        val signStart = sign(nmBefore)
        val signEnd = sign(nmAfter)
        val masa = Masa.entries[(signStart + 1) % 12]
        if (signStart == signEnd) return LunarMonth(masa, isAdhika = true)
        val nmPrevious = Astronomy.previousTimeAngleReached(nmBefore - 10.0, 0.0, Astronomy.MOON_SUN_RATE, Astronomy::elongation)
        return LunarMonth(masa, isAdhika = false, isNija = sign(nmPrevious) == signStart)
    }

    private fun sign(jd: Double): Int = (Astronomy.sunSidereal(jd) / 30.0).toInt() % 12

    /**
     * Shaka year, which turns over at Ugadi: months from Margashira to
     * Phalguna that fall early in the Gregorian year still belong to the
     * previous Shaka year.
     */
    private fun shakaYear(date: LocalDate, masa: Masa): Int =
        if (date.monthValue <= 4 && masa.ordinal >= Masa.MARGASHIRA.ordinal) date.year - 79 else date.year - 78

    private fun sunrise(midnightJd: Double, city: City): Double =
        Astronomy.findCrossing(midnightJd, midnightJd + 1.0, Astronomy.SUN_RISE_ALTITUDE, rising = true) {
            Astronomy.sunAltitude(it, city.latitude, city.longitude)
        } ?: (midnightJd + 0.25)

    private fun tithiIndex(elong: Double) = (elong / 12.0).toInt().coerceIn(0, 29)
    private fun nakshatraIndex(lon: Double) = (lon / (360.0 / 27)).toInt().coerceIn(0, 26)

    private fun specialDay(tithiNumber: Int) = when (tithiNumber) {
        11, 26 -> SpecialDayType.EKADASHI
        15 -> SpecialDayType.PURNIMA
        30 -> SpecialDayType.AMAVASYA
        else -> SpecialDayType.NONE
    }

    companion object {
        private const val UNIX_EPOCH_JD = 2440587.5

        fun jdAtStartOf(date: LocalDate, zone: ZoneId): Double =
            date.atStartOfDay(zone).toInstant().toEpochMilli() / 86_400_000.0 + UNIX_EPOCH_JD

        fun toLocal(jd: Double, zone: ZoneId): LocalDateTime =
            LocalDateTime.ofInstant(Instant.ofEpochMilli(((jd - UNIX_EPOCH_JD) * 86_400_000.0).toLong()), zone)
    }
}
