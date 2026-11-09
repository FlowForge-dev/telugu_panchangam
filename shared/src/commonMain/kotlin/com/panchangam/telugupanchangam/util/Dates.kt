package com.panchangam.telugupanchangam.util

import kotlinx.datetime.DateTimeUnit
import kotlinx.datetime.DayOfWeek
import kotlinx.datetime.LocalDate
import kotlinx.datetime.LocalDateTime
import kotlinx.datetime.Month
import kotlinx.datetime.TimeZone
import kotlinx.datetime.YearMonth
import kotlinx.datetime.isoDayNumber
import kotlinx.datetime.minus
import kotlinx.datetime.number
import kotlinx.datetime.plus
import kotlinx.datetime.toInstant
import kotlinx.datetime.toLocalDateTime
import kotlinx.datetime.todayIn
import kotlinx.datetime.yearMonth
import kotlin.time.Clock
import kotlin.time.Duration

/*
 * Small helpers over kotlinx-datetime so the shared (Android + iOS) code
 * reads the same as the original java.time version.
 */

typealias ZoneId = TimeZone

fun LocalDate.Companion.of(year: Int, month: Int, day: Int): LocalDate = LocalDate(year, month, day)
fun LocalDate.Companion.now(zone: TimeZone): LocalDate = Clock.System.todayIn(zone)
fun LocalDateTime.Companion.now(zone: TimeZone): LocalDateTime = Clock.System.now().toLocalDateTime(zone)

val LocalDate.monthValue: Int get() = month.number
fun LocalDate.toEpochDay(): Long = toEpochDays()
fun LocalDate.plusDays(days: Long): LocalDate = plus(days, DateTimeUnit.DAY)
fun LocalDate.plusDays(days: Int): LocalDate = plus(days, DateTimeUnit.DAY)
fun LocalDate.minusDays(days: Long): LocalDate = minus(days, DateTimeUnit.DAY)
fun LocalDate.minusDays(days: Int): LocalDate = minus(days, DateTimeUnit.DAY)
fun LocalDate.isAfter(other: LocalDate): Boolean = this > other
fun LocalDate.isBefore(other: LocalDate): Boolean = this < other
fun LocalDate.atStartOfDay(): LocalDateTime = LocalDateTime(this, kotlinx.datetime.LocalTime(0, 0))

fun LocalDateTime.toLocalDate(): LocalDate = date
fun LocalDateTime.isAfter(other: LocalDateTime): Boolean = this > other
fun LocalDateTime.isBefore(other: LocalDateTime): Boolean = this < other
operator fun LocalDateTime.plus(d: Duration): LocalDateTime =
    (toInstant(TimeZone.UTC) + d).toLocalDateTime(TimeZone.UTC)

/** Wall-clock difference between two local times (both in the same zone). */
fun durationBetween(from: LocalDateTime, to: LocalDateTime): Duration =
    to.toInstant(TimeZone.UTC) - from.toInstant(TimeZone.UTC)

val DayOfWeek.value: Int get() = isoDayNumber

fun YearMonth.Companion.of(year: Int, month: Int): YearMonth = YearMonth(year, month)
fun YearMonth.Companion.from(date: LocalDate): YearMonth = date.yearMonth
val YearMonth.monthValue: Int get() = month.number
fun YearMonth.atDay(day: Int): LocalDate = LocalDate(year, month, day)
fun YearMonth.atEndOfMonth(): LocalDate = lastDay
fun YearMonth.lengthOfMonth(): Int = numberOfDays
fun YearMonth.plusMonths(months: Long): YearMonth = plus(months, DateTimeUnit.MONTH)

private val monthNames = listOf(
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
)
private val weekdayNames = listOf("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")

val Month.englishName: String get() = monthNames[number - 1]
val Month.englishShort: String get() = englishName.take(3)
val DayOfWeek.englishName: String get() = weekdayNames[isoDayNumber - 1]
val DayOfWeek.englishShort: String get() = englishName.take(3)

private fun Int.pad2() = toString().padStart(2, '0')

/** "h:mm AM" or "HH:mm". */
fun LocalDateTime.formatClock(use24Hour: Boolean): String =
    if (use24Hour) "${hour.pad2()}:${minute.pad2()}"
    else {
        val h = if (hour % 12 == 0) 12 else hour % 12
        "$h:${minute.pad2()} ${if (hour < 12) "AM" else "PM"}"
    }

/** [value] rounded to [decimals] places, e.g. 17.39. */
fun Double.fixed(decimals: Int): String {
    var factor = 1L
    repeat(decimals) { factor *= 10 }
    val scaled = kotlin.math.round(kotlin.math.abs(this) * factor).toLong()
    val sign = if (this < 0 && scaled != 0L) "-" else ""
    val whole = scaled / factor
    val frac = (scaled % factor).toString().padStart(decimals, '0')
    return if (decimals == 0) "$sign$whole" else "$sign$whole.$frac"
}
