package com.panchangam.telugupanchangam.data

import com.panchangam.telugupanchangam.domain.City
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import java.time.LocalDate

class FestivalDataTest {

    private val festivals = FestivalData.festivals
    private val engine = AstronomicalPanchangRepository()

    @Test
    fun idsAreUniqueAndListIsSorted() {
        assertEquals(festivals.size, festivals.map { it.id }.toSet().size)
        assertEquals(festivals.sortedBy { it.date }, festivals)
    }

    @Test
    fun everyFestivalIsInRangeAndCited() {
        for (f in festivals) {
            assertTrue(f.id, !f.date.isBefore(FestivalData.ugadiStart) && !f.date.isAfter(FestivalData.nextUgadi))
            assertTrue("${f.id} has no source", f.sources.isNotEmpty())
        }
    }

    /** Spot-checks that corrected dates agree with the computed tithi. */
    @Test
    fun correctedDatesMatchTheirTithiRule() {
        val hyd = City.HYDERABAD
        fun tithiAtSunrise(d: LocalDate) = engine.dayDetail(d, hyd).tithi.number

        // Sri Rama Navami: Chaitra Shukla Navami (9) at sunrise.
        assertEquals(9, tithiAtSunrise(LocalDate.of(2026, 3, 27)))
        // Maha Shivaratri: Krishna Chaturdashi (29) holds at local midnight of 6 Mar 2027.
        val shivaratri = engine.dayDetail(LocalDate.of(2027, 3, 6), hyd)
        val midnight = LocalDate.of(2027, 3, 7).atStartOfDay()
        assertTrue(shivaratri.tithis.any { it.item.number == 29 && !midnight.isBefore(it.start) && midnight.isBefore(it.end) })
        // Makara Sankranti 2027: Uttarayana begins with the sunrise of 15 Jan.
        assertEquals("DAKSHINAYANA", engine.dayDetail(LocalDate.of(2027, 1, 14), hyd).ayana.name)
        assertEquals("UTTARAYANA", engine.dayDetail(LocalDate.of(2027, 1, 15), hyd).ayana.name)
        // Ugadi 2027: Chaitra Shukla Padyami at sunrise.
        assertEquals(1, tithiAtSunrise(LocalDate.of(2027, 4, 7)))
    }
}
