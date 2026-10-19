package com.panchangam.telugupanchangam.ui.calendar

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowLeft
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.produceState
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.panchangam.telugupanchangam.domain.City
import com.panchangam.telugupanchangam.domain.DaySummary
import com.panchangam.telugupanchangam.domain.Festival
import com.panchangam.telugupanchangam.domain.FestivalImportance
import com.panchangam.telugupanchangam.domain.FestivalRepository
import com.panchangam.telugupanchangam.domain.PanchangRepository
import com.panchangam.telugupanchangam.domain.SpecialDayType
import com.panchangam.telugupanchangam.domain.Vara
import com.panchangam.telugupanchangam.ui.LocalAppSettings
import com.panchangam.telugupanchangam.ui.components.MoonPhase
import com.panchangam.telugupanchangam.ui.components.SectionHeader
import com.panchangam.telugupanchangam.ui.components.ThinDivider
import com.panchangam.telugupanchangam.ui.components.formatWeekdayShort
import com.panchangam.telugupanchangam.ui.components.teluguMonthYear
import com.panchangam.telugupanchangam.ui.theme.Ink
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.time.LocalDate
import java.time.YearMonth
import java.time.format.DateTimeFormatter
import java.util.Locale

private val FIRST_MONTH: YearMonth = YearMonth.of(2000, 1)
private const val MONTH_PAGES = 12 * 51 // Jan 2000 – Dec 2050
private val englishMonthYear = DateTimeFormatter.ofPattern("MMMM yyyy", Locale.ENGLISH)

/**
 * Month grid in the style of a general-purpose calendar app: a clean
 * page, hairline cells, today marked by a filled disc, the tithi under
 * each date, moon glyphs on Purnima and Amavasya, and festival tags.
 * Swipe sideways to change month.
 */
@Composable
fun CalendarScreen(
    panchangRepository: PanchangRepository,
    festivalRepository: FestivalRepository,
    onDaySelected: (LocalDate) -> Unit,
    onFestivalSelected: (String) -> Unit
) {
    val city = LocalAppSettings.current.city
    val today = remember(city.id) { LocalDate.now(city.zone) }
    val todayPage = remember(today) {
        (YearMonth.from(today).let { (it.year - FIRST_MONTH.year) * 12 + it.monthValue - 1 }).coerceIn(0, MONTH_PAGES - 1)
    }
    val pager = rememberPagerState(initialPage = todayPage) { MONTH_PAGES }
    val scope = rememberCoroutineScope()
    val shownMonth = FIRST_MONTH.plusMonths(pager.currentPage.toLong())
    val ink = Ink.current

    Column(Modifier.fillMaxSize().background(ink.page).statusBarsPadding()) {
        Row(
            modifier = Modifier.fillMaxWidth().padding(start = 20.dp, end = 4.dp, top = 12.dp, bottom = 4.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column(Modifier.weight(1f)) {
                Text(
                    shownMonth.atDay(1).teluguMonthYear(),
                    style = MaterialTheme.typography.headlineMedium,
                    color = ink.strong,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
                Text(shownMonth.format(englishMonthYear), style = MaterialTheme.typography.bodySmall, color = ink.secondary)
            }
            if (pager.currentPage != todayPage) {
                TextButton(onClick = { scope.launch { pager.animateScrollToPage(todayPage) } }) {
                    Text("ఈరోజు", style = MaterialTheme.typography.labelLarge, color = ink.strong)
                }
            }
            IconButton(onClick = { scope.launch { pager.animateScrollToPage((pager.currentPage - 1).coerceAtLeast(0)) } }) {
                Icon(Icons.AutoMirrored.Filled.KeyboardArrowLeft, contentDescription = "Previous month", tint = ink.strong)
            }
            IconButton(onClick = { scope.launch { pager.animateScrollToPage((pager.currentPage + 1).coerceAtMost(MONTH_PAGES - 1)) } }) {
                Icon(Icons.AutoMirrored.Filled.KeyboardArrowRight, contentDescription = "Next month", tint = ink.strong)
            }
        }

        HorizontalPager(state = pager, modifier = Modifier.fillMaxSize(), beyondViewportPageCount = 1) { page ->
            MonthPage(
                month = FIRST_MONTH.plusMonths(page.toLong()),
                city = city,
                today = today,
                panchangRepository = panchangRepository,
                festivalRepository = festivalRepository,
                onDaySelected = onDaySelected,
                onFestivalSelected = onFestivalSelected
            )
        }
    }
}

@Composable
private fun MonthPage(
    month: YearMonth,
    city: City,
    today: LocalDate,
    panchangRepository: PanchangRepository,
    festivalRepository: FestivalRepository,
    onDaySelected: (LocalDate) -> Unit,
    onFestivalSelected: (String) -> Unit
) {
    val ink = Ink.current
    val first = month.atDay(1)
    val gridStart = first.minusDays((first.dayOfWeek.value % 7).toLong())
    val rows = ((first.dayOfWeek.value % 7) + month.lengthOfMonth() + 6) / 7

    // The month's summaries take a few tens of milliseconds; keep them off the UI thread.
    val summaries by produceState<Map<LocalDate, DaySummary>>(emptyMap(), month, city.id) {
        value = withContext(Dispatchers.Default) {
            panchangRepository.summaries(month.atDay(1), month.atEndOfMonth(), city)
        }
    }
    val festivals = remember(month) {
        (1..month.lengthOfMonth()).flatMap { festivalRepository.onDate(month.atDay(it)) }
    }
    val festivalsByDate = remember(festivals) { festivals.groupBy { it.date } }
    val months = remember(summaries) {
        summaries.values.map { it.lunarMonth }.distinct()
    }

    LazyColumn(Modifier.fillMaxSize(), contentPadding = PaddingValues(bottom = 24.dp)) {
        item(key = "masa") {
            Text(
                if (months.isEmpty()) " " else months.joinToString("  –  ") { it.telugu },
                style = MaterialTheme.typography.labelLarge,
                color = ink.secondary,
                modifier = Modifier.padding(start = 20.dp, end = 20.dp, bottom = 10.dp)
            )
        }
        item(key = "weekdays") {
            Row(Modifier.fillMaxWidth().padding(horizontal = 8.dp, vertical = 6.dp)) {
                Vara.entries.forEach { vara ->
                    Text(
                        vara.short,
                        style = MaterialTheme.typography.labelMedium,
                        color = if (vara == Vara.SUNDAY) ink.strong else ink.secondary,
                        textAlign = TextAlign.Center,
                        modifier = Modifier.weight(1f)
                    )
                }
            }
        }
        item(key = "grid") {
            Column(Modifier.padding(horizontal = 8.dp)) {
                repeat(rows) { row ->
                    Row(Modifier.fillMaxWidth()) {
                        repeat(7) { col ->
                            val date = gridStart.plusDays((row * 7 + col).toLong())
                            val inMonth = date.month == month.month
                            DayCell(
                                date = date,
                                summary = if (inMonth) summaries[date] else null,
                                festivals = if (inMonth) festivalsByDate[date].orEmpty() else emptyList(),
                                inMonth = inMonth,
                                isToday = date == today,
                                modifier = Modifier.weight(1f),
                                onClick = { onDaySelected(date) }
                            )
                        }
                    }
                }
            }
        }
        item(key = "legend") { Legend() }

        if (festivals.isNotEmpty()) {
            item(key = "fest-header") { SectionHeader("ఈ నెల పండుగలు", "This month") }
            festivals.forEachIndexed { i, f ->
                item(key = "fest-${f.id}") {
                    if (i > 0) ThinDivider(Modifier.padding(start = 76.dp, end = 20.dp))
                    MonthFestivalRow(f) { onFestivalSelected(f.id) }
                }
            }
        }
    }
}

@Composable
private fun DayCell(
    date: LocalDate,
    summary: DaySummary?,
    festivals: List<Festival>,
    inMonth: Boolean,
    isToday: Boolean,
    modifier: Modifier = Modifier,
    onClick: () -> Unit
) {
    val ink = Ink.current
    Column(
        modifier = modifier
            .height(76.dp)
            .padding(1.5.dp)
            .clip(RoundedCornerShape(10.dp))
            .background(if (inMonth && festivals.any { it.importance == FestivalImportance.MAJOR }) ink.wash else ink.page)
            .clickable(enabled = inMonth, onClick = onClick)
            .padding(vertical = 5.dp, horizontal = 2.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Box(
            modifier = Modifier
                .size(28.dp)
                .clip(CircleShape)
                .background(if (isToday && inMonth) ink.strong else ink.page.copy(alpha = 0f)),
            contentAlignment = Alignment.Center
        ) {
            Text(
                date.dayOfMonth.toString(),
                color = when {
                    !inMonth -> ink.disabled
                    isToday -> ink.page
                    else -> ink.strong
                },
                fontSize = 14.sp,
                fontWeight = if (isToday || date.dayOfWeek.value == 7) FontWeight.Bold else FontWeight.Normal
            )
        }
        if (summary != null) {
            Text(
                summary.tithi.telugu,
                fontSize = 9.sp,
                lineHeight = 11.sp,
                color = ink.secondary,
                maxLines = 1,
                overflow = TextOverflow.Clip,
                modifier = Modifier.padding(top = 2.dp)
            )
            Spacer(Modifier.height(3.dp))
            when {
                festivals.isNotEmpty() -> Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 1.dp)
                        .clip(RoundedCornerShape(4.dp))
                        .background(ink.strong)
                        .padding(horizontal = 2.dp, vertical = 1.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        festivals.first().teluguName.substringBefore(" ("),
                        color = ink.page,
                        fontSize = 8.sp,
                        lineHeight = 10.sp,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                }

                summary.specialDayType == SpecialDayType.PURNIMA ||
                    summary.specialDayType == SpecialDayType.AMAVASYA ->
                    MoonPhase(summary.elongation, 11.dp)

                summary.specialDayType == SpecialDayType.EKADASHI -> Box(
                    Modifier.size(6.dp).clip(CircleShape).background(ink.secondary)
                )
            }
        }
    }
}

@Composable
private fun Legend() {
    val ink = Ink.current
    Row(
        Modifier.fillMaxWidth().padding(horizontal = 20.dp, vertical = 12.dp),
        horizontalArrangement = Arrangement.spacedBy(16.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            MoonPhase(180.0, 11.dp)
            Text("  పౌర్ణమి", style = MaterialTheme.typography.labelSmall, color = ink.secondary)
        }
        Row(verticalAlignment = Alignment.CenterVertically) {
            MoonPhase(0.0, 11.dp)
            Text("  అమావాస్య", style = MaterialTheme.typography.labelSmall, color = ink.secondary)
        }
        Row(verticalAlignment = Alignment.CenterVertically) {
            Box(Modifier.size(6.dp).clip(CircleShape).background(ink.secondary))
            Text("  ఏకాదశి", style = MaterialTheme.typography.labelSmall, color = ink.secondary)
        }
    }
    Text(
        "తిథి సూర్యోదయ సమయానికి · Tithi shown is the one at local sunrise.",
        style = MaterialTheme.typography.labelSmall,
        color = ink.faint,
        modifier = Modifier.padding(horizontal = 20.dp)
    )
}

@Composable
private fun MonthFestivalRow(festival: Festival, onClick: () -> Unit) {
    val ink = Ink.current
    Row(
        Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
            .padding(horizontal = 20.dp, vertical = 12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Column(
            Modifier
                .width(44.dp)
                .clip(RoundedCornerShape(12.dp))
                .border(1.dp, ink.line, RoundedCornerShape(12.dp))
                .padding(vertical = 6.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(festival.date.dayOfMonth.toString(), style = MaterialTheme.typography.titleMedium, color = ink.strong)
            Text(festival.date.formatWeekdayShort().uppercase(), style = MaterialTheme.typography.labelSmall, color = ink.faint)
        }
        Spacer(Modifier.width(12.dp))
        Column(Modifier.weight(1f)) {
            Text(festival.teluguName, style = MaterialTheme.typography.titleMedium, color = ink.strong)
            Text(festival.name, style = MaterialTheme.typography.bodySmall, color = ink.secondary)
        }
        Icon(Icons.AutoMirrored.Filled.KeyboardArrowRight, contentDescription = null, tint = ink.faint)
    }
}
