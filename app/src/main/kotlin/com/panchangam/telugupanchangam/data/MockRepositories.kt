package com.panchangam.telugupanchangam.data

import com.panchangam.telugupanchangam.domain.ChoghadiyaPeriod
import com.panchangam.telugupanchangam.domain.ChoghadiyaQuality
import com.panchangam.telugupanchangam.domain.Festival
import com.panchangam.telugupanchangam.domain.FestivalRepository
import com.panchangam.telugupanchangam.domain.Masa
import com.panchangam.telugupanchangam.domain.MuhurtaWindow
import com.panchangam.telugupanchangam.domain.Paksha
import com.panchangam.telugupanchangam.domain.PanchangDay
import com.panchangam.telugupanchangam.domain.PanchangRepository
import com.panchangam.telugupanchangam.domain.SpecialDayType
import com.panchangam.telugupanchangam.domain.Vara
import java.time.LocalDate
import java.time.temporal.ChronoUnit
import kotlin.math.abs

/**
 * ---------------------------------------------------------------------
 * DEVELOPMENT MOCK DATA
 *
 * Cycles Tithi / Paksha / Nakshatra / Masa / Yoga / Karana
 * deterministically so the UI has stable, varied values per day. This is
 * NOT a real Panchangam calculation — no ephemeris, no lunisolar maths.
 * Festival dates are the exception: those come from a real almanac (see
 * [FestivalData]).
 * ---------------------------------------------------------------------
 */
class MockPanchangRepository : PanchangRepository {

    override fun dayDetail(date: LocalDate): PanchangDay = generate(date)

    override fun range(start: LocalDate, end: LocalDate): Map<LocalDate, PanchangDay> {
        val out = LinkedHashMap<LocalDate, PanchangDay>()
        var cursor = start
        while (!cursor.isAfter(end)) {
            out[cursor] = generate(cursor)
            cursor = cursor.plusDays(1)
        }
        return out
    }

    private fun generate(date: LocalDate): PanchangDay {
        val daysSinceAnchor = ChronoUnit.DAYS.between(FestivalData.ugadiStart, date).toInt()
        val cycleDay = Math.floorMod(daysSinceAnchor, 30)
        val paksha = if (cycleDay < 15) Paksha.SHUKLA else Paksha.KRISHNA
        val tithiIndex = cycleDay % 15
        val tithi = if (paksha == Paksha.SHUKLA) {
            ReferenceTables.shuklaTithis[tithiIndex]
        } else {
            ReferenceTables.krishnaTithis[tithiIndex]
        }

        val nakshatra = ReferenceTables.nakshatras[abs(daysSinceAnchor) % 27]
        val pada = (abs(daysSinceAnchor) % 4) + 1
        val masa = Masa.entries[(abs(daysSinceAnchor) / 30) % Masa.entries.size]
        val vara = Vara.forDate(date)
        val yoga = ReferenceTables.yogas[(abs(daysSinceAnchor) + 5) % ReferenceTables.yogas.size]
        val karana = ReferenceTables.karanas[abs(daysSinceAnchor) % ReferenceTables.karanas.size]

        // Shaka Samvat rolls over at Ugadi rather than 1 January.
        val onOrAfterUgadi = date.monthValue > 3 || (date.monthValue == 3 && date.dayOfMonth >= 19)
        val shakaYear = date.year - if (onOrAfterUgadi) 78 else 79

        val sunriseMin = 6 * 60 + (date.dayOfMonth % 5)
        val sunsetMin = 18 * 60 + (30 + date.dayOfMonth % 20)

        val festival = FestivalData.festivals.firstOrNull { it.date == date }
        val special = when {
            festival != null -> SpecialDayType.FESTIVAL
            tithi.index == 11 -> SpecialDayType.EKADASHI
            tithi.index == 15 && paksha == Paksha.SHUKLA -> SpecialDayType.PURNIMA
            tithi.index == 15 && paksha == Paksha.KRISHNA -> SpecialDayType.AMAVASYA
            else -> SpecialDayType.NONE
        }

        return PanchangDay(
            date = date,
            vara = vara,
            masa = masa,
            paksha = paksha,
            tithi = tithi,
            nakshatra = nakshatra,
            nakshatraPada = pada,
            yoga = yoga,
            karana = karana,
            shakaSamvatYear = shakaYear,
            sunrise = formatMinutes(sunriseMin),
            sunset = formatMinutes(sunsetMin),
            moonrise = formatMinutes((7 + date.dayOfMonth % 12) * 60 + 15),
            moonset = formatMinutes((18 + date.dayOfMonth % 5) * 60 + 40),
            muhurtas = listOf(
                MuhurtaWindow("Rahu Kalam", "రాహు కాలం", shiftTime(vara.ordinal, 0), shiftTime(vara.ordinal, 90)),
                MuhurtaWindow("Yamagandam", "యమగండం", shiftTime(vara.ordinal, 180), shiftTime(vara.ordinal, 270))
            ),
            choghadiya = choghadiya(vara.ordinal, sunriseMin, sunsetMin),
            specialDayType = special,
            festivalId = festival?.id
        )
    }

    private fun choghadiya(weekdayIndex: Int, sunriseMin: Int, sunsetMin: Int): List<ChoghadiyaPeriod> {
        val names = ReferenceTables.choghadiyaSequence.getValue(weekdayIndex)
        val slot = (sunsetMin - sunriseMin) / 8.0
        return (0 until 8).map { i ->
            val name = names[i]
            ChoghadiyaPeriod(
                name = name,
                telugu = ReferenceTables.choghadiyaTelugu.getValue(name),
                start = formatMinutes((sunriseMin + slot * i).toInt()),
                end = formatMinutes((sunriseMin + slot * (i + 1)).toInt()),
                quality = when (name) {
                    "Labh", "Amrit", "Shubh" -> ChoghadiyaQuality.GOOD
                    "Chal" -> ChoghadiyaQuality.NEUTRAL
                    else -> ChoghadiyaQuality.INAUSPICIOUS
                }
            )
        }
    }

    private fun shiftTime(weekdayIndex: Int, minuteOffset: Int): String {
        val base = 9 * 60 + (weekdayIndex * 17) % 60
        return formatMinutes((base + minuteOffset) % (24 * 60))
    }

    private fun formatMinutes(totalMinutes: Int): String {
        val h24 = (totalMinutes / 60) % 24
        val m = totalMinutes % 60
        val period = if (h24 >= 12) "PM" else "AM"
        val h12 = if (h24 % 12 == 0) 12 else h24 % 12
        return String.format("%02d:%02d %s", h12, m, period)
    }
}

class MockFestivalRepository : FestivalRepository {
    override fun all(): List<Festival> = FestivalData.festivals

    override fun byId(id: String): Festival? = FestivalData.festivals.firstOrNull { it.id == id }

    override fun upcoming(from: LocalDate, limit: Int): List<Festival> =
        FestivalData.festivals.filter { !it.date.isBefore(from) }.take(limit)

    override fun onDate(date: LocalDate): List<Festival> =
        FestivalData.festivals.filter { it.date == date }
}
