package com.panchangam.telugupanchangam.data

import com.panchangam.telugupanchangam.domain.City
import com.panchangam.telugupanchangam.domain.Masa
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import java.time.Duration
import java.time.LocalDate
import java.time.LocalDateTime
import kotlin.math.abs

/**
 * Pins the engine to independently computed reference values. Every
 * expected value below was produced with the Swiss Ephemeris 2.10
 * (pyswisseph, Moshier ephemeris, SIDM_LAHIRI, upper-limb sunrise with
 * standard refraction) — not with this code.
 */
class AstronomicalPanchangRepositoryTest {

    private data class Ref(
        val city: String,
        val date: String,
        val sunrise: String,
        val tithi: Int,
        val tithiEnds: String,
        val nakshatra: Int
    )

    private val refs = listOf(
        Ref("hyderabad", "2026-03-19", sunrise = "2026-03-19T06:21", tithi = 30, tithiEnds = "2026-03-19T06:53", nakshatra = 26),
        Ref("hyderabad", "2026-03-27", sunrise = "2026-03-27T06:14", tithi = 9, tithiEnds = "2026-03-27T10:07", nakshatra = 7),
        Ref("hyderabad", "2026-04-21", sunrise = "2026-04-21T05:56", tithi = 5, tithiEnds = "2026-04-22T01:20", nakshatra = 5),
        Ref("hyderabad", "2026-08-21", sunrise = "2026-08-21T06:00", tithi = 9, tithiEnds = "2026-08-21T23:36", nakshatra = 17),
        Ref("hyderabad", "2026-09-14", sunrise = "2026-09-14T06:03", tithi = 3, tithiEnds = "2026-09-14T07:07", nakshatra = 14),
        Ref("hyderabad", "2026-10-20", sunrise = "2026-10-20T06:10", tithi = 9, tithiEnds = "2026-10-20T12:50", nakshatra = 22),
        Ref("hyderabad", "2026-11-08", sunrise = "2026-11-08T06:17", tithi = 29, tithiEnds = "2026-11-08T11:28", nakshatra = 15),
        Ref("hyderabad", "2026-12-20", sunrise = "2026-12-20T06:40", tithi = 11, tithiEnds = "2026-12-20T20:15", nakshatra = 1),
        Ref("hyderabad", "2027-01-15", sunrise = "2027-01-15T06:49", tithi = 7, tithiEnds = "2027-01-15T14:13", nakshatra = 27),
        Ref("hyderabad", "2027-03-06", sunrise = "2027-03-06T06:31", tithi = 28, tithiEnds = "2027-03-06T12:04", nakshatra = 23),
        Ref("hyderabad", "2027-04-07", sunrise = "2027-04-07T06:06", tithi = 1, tithiEnds = "2027-04-08T04:29", nakshatra = 27),
        Ref("sringeri", "2026-10-21", sunrise = "2026-10-21T06:20", tithi = 10, tithiEnds = "2026-10-21T14:12", nakshatra = 23),
        Ref("sringeri", "2026-07-29", sunrise = "2026-07-29T06:13", tithi = 15, tithiEnds = "2026-07-29T20:05", nakshatra = 21)
    )

    private val repo = AstronomicalPanchangRepository()

    private fun assertClose(expected: String, actual: LocalDateTime, label: String) {
        val minutes = Duration.between(LocalDateTime.parse(expected), actual).toMinutes()
        assertTrue("$label: expected ~$expected, got $actual", abs(minutes) <= 2)
    }

    @Test
    fun matchesSwissEphemerisReference() {
        for (r in refs) {
            val day = repo.dayDetail(LocalDate.parse(r.date), City.byId(r.city))
            val where = "${r.city} ${r.date}"
            assertClose(r.sunrise, day.sunrise, "$where sunrise")
            assertEquals("$where tithi", r.tithi, day.tithi.number)
            assertClose(r.tithiEnds, day.tithis.first().end, "$where tithi end")
            assertEquals("$where nakshatra", r.nakshatra, day.nakshatra.index)
        }
    }

    @Test
    fun detectsAdhikaJyeshtha2026() {
        val hyd = City.HYDERABAD
        val adhika = repo.dayDetail(LocalDate.of(2026, 5, 25), hyd).lunarMonth
        assertEquals(Masa.JYESHTHA, adhika.masa)
        assertTrue(adhika.isAdhika)
        val nija = repo.dayDetail(LocalDate.of(2026, 6, 25), hyd).lunarMonth
        assertEquals(Masa.JYESHTHA, nija.masa)
        assertTrue(nija.isNija)
    }

    @Test
    fun samvatsaraTurnsAtUgadi() {
        val hyd = City.HYDERABAD
        assertEquals("Vishvavasu", repo.dayDetail(LocalDate.of(2026, 3, 1), hyd).samvatsara.name)
        assertEquals("Parabhava", repo.dayDetail(LocalDate.of(2026, 3, 20), hyd).samvatsara.name)
        assertEquals("Parabhava", repo.dayDetail(LocalDate.of(2027, 2, 1), hyd).samvatsara.name)
        assertEquals("Plavanga", repo.dayDetail(LocalDate.of(2027, 4, 7), hyd).samvatsara.name)
    }

    @Test
    fun spansCoverSunriseToSunrise() {
        val day = repo.dayDetail(LocalDate.of(2026, 10, 19), City.HYDERABAD)
        for (spans in listOf(day.tithis, day.nakshatras, day.yogas, day.karanas)) {
            assertTrue(!spans.first().start.isAfter(day.sunrise))
            assertTrue(!spans.last().end.isBefore(day.nextSunrise))
            spans.zipWithNext().forEach { (a, b) -> assertEquals(a.end, b.start) }
        }
    }

    @Test
    fun rahuKalamFollowsWeekdayRule() {
        // Monday: the 2nd of eight parts of the day.
        val day = repo.dayDetail(LocalDate.of(2026, 10, 19), City.HYDERABAD)
        val part = Duration.between(day.sunrise, day.sunset).dividedBy(8)
        val rahu = day.inauspicious.first { it.label == "Rahu Kalam" }
        assertTrue(abs(Duration.between(day.sunrise.plus(part), rahu.start).seconds) <= 1)
    }
}
