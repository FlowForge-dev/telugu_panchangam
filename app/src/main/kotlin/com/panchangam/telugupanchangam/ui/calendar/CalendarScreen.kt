package com.panchangam.telugupanchangam.ui.calendar

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowLeft
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.panchangam.telugupanchangam.data.FestivalData
import com.panchangam.telugupanchangam.domain.PanchangDay
import com.panchangam.telugupanchangam.domain.PanchangRepository
import com.panchangam.telugupanchangam.domain.SpecialDayType
import com.panchangam.telugupanchangam.domain.Vara
import com.panchangam.telugupanchangam.ui.components.formatMonthYear
import com.panchangam.telugupanchangam.ui.theme.Ink
import java.time.LocalDate

/**
 * Month grid in the style of a general-purpose calendar app: a white
 * page, hairline cell borders, today marked by a filled black disc, and
 * a compact festival chip where one falls.
 */
@Composable
fun CalendarScreen(
    panchangRepository: PanchangRepository,
    onDaySelected: (LocalDate) -> Unit
) {
    val today = remember { LocalDate.now() }
    val rangeStart = remember { FestivalData.ugadiStart.withDayOfMonth(1) }
    val rangeEnd = remember { FestivalData.nextUgadi.withDayOfMonth(1) }

    var month by remember {
        val current = today.withDayOfMonth(1)
        mutableStateOf(
            when {
                current.isBefore(rangeStart) -> rangeStart
                current.isAfter(rangeEnd) -> rangeEnd
                else -> current
            }
        )
    }

    val gridStart = remember(month) {
        val firstOfMonth = month.withDayOfMonth(1)
        firstOfMonth.minusDays((firstOfMonth.dayOfWeek.value % 7).toLong())
    }
    val days = remember(month) {
        panchangRepository.range(gridStart, gridStart.plusDays(41))
    }

    val canGoPrev = !month.minusMonths(1).isBefore(rangeStart)
    val canGoNext = !month.plusMonths(1).isAfter(rangeEnd)

    Column(modifier = Modifier.fillMaxSize().background(Ink.White)) {

        // ---- Month header -------------------------------------------
        Row(
            modifier = Modifier.fillMaxWidth().padding(start = 16.dp, end = 8.dp, top = 12.dp, bottom = 8.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    month.formatMonthYear(),
                    style = MaterialTheme.typography.headlineMedium,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
                days[month.withDayOfMonth(1)]?.let {
                    Text(it.masa.telugu, style = MaterialTheme.typography.bodySmall)
                }
            }
            OutlinedButton(
                onClick = {
                    val current = today.withDayOfMonth(1)
                    if (!current.isBefore(rangeStart) && !current.isAfter(rangeEnd)) month = current
                },
                shape = RoundedCornerShape(8.dp)
            ) { Text("ఈరోజు", style = MaterialTheme.typography.labelLarge) }

            IconButton(onClick = { if (canGoPrev) month = month.minusMonths(1) }, enabled = canGoPrev) {
                Icon(Icons.AutoMirrored.Filled.KeyboardArrowLeft, contentDescription = "Previous month", tint = Ink.Black)
            }
            IconButton(onClick = { if (canGoNext) month = month.plusMonths(1) }, enabled = canGoNext) {
                Icon(Icons.AutoMirrored.Filled.KeyboardArrowRight, contentDescription = "Next month", tint = Ink.Black)
            }
        }

        // ---- Weekday strip -------------------------------------------
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .background(Ink.White)
                .padding(vertical = 8.dp)
        ) {
            Vara.entries.forEach { vara ->
                Box(modifier = Modifier.weight(1f), contentAlignment = Alignment.Center) {
                    Text(
                        vara.short,
                        style = MaterialTheme.typography.labelSmall,
                        color = Ink.Secondary
                    )
                }
            }
        }

        // ---- Day grid -------------------------------------------------
        Column(modifier = Modifier.fillMaxSize()) {
            repeat(6) { row ->
                Row(modifier = Modifier.weight(1f).fillMaxWidth()) {
                    repeat(7) { col ->
                        val date = gridStart.plusDays((row * 7 + col).toLong())
                        DayCell(
                            date = date,
                            day = days[date],
                            inCurrentMonth = date.monthValue == month.monthValue,
                            isToday = date == today,
                            modifier = Modifier.weight(1f).fillMaxSize(),
                            onClick = { onDaySelected(date) }
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun DayCell(
    date: LocalDate,
    day: PanchangDay?,
    inCurrentMonth: Boolean,
    isToday: Boolean,
    modifier: Modifier = Modifier,
    onClick: () -> Unit
) {
    val numberColor = when {
        isToday -> Ink.White
        !inCurrentMonth -> Ink.Disabled
        else -> Ink.Body
    }

    Column(
        modifier = modifier
            .border(0.5.dp, Ink.Line)
            .clickable(enabled = inCurrentMonth, onClick = onClick)
            .padding(horizontal = 3.dp, vertical = 4.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Top
    ) {
        Box(
            modifier = Modifier
                .size(24.dp)
                .clip(CircleShape)
                .background(if (isToday) Ink.Black else Ink.White),
            contentAlignment = Alignment.Center
        ) {
            Text(
                date.dayOfMonth.toString(),
                color = numberColor,
                fontSize = 13.sp,
                fontWeight = if (isToday) FontWeight.Bold else FontWeight.Normal
            )
        }

        if (day != null && inCurrentMonth) {
            Text(
                "తి.${day.tithi.index}",
                fontSize = 9.sp,
                color = Ink.Faint,
                maxLines = 1,
                modifier = Modifier.padding(top = 1.dp)
            )

            when {
                day.festivalId != null -> Box(
                    modifier = Modifier
                        .padding(top = 2.dp)
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(3.dp))
                        .background(Ink.Black)
                        .padding(horizontal = 2.dp, vertical = 1.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text("పండుగ", color = Ink.White, fontSize = 8.sp, maxLines = 1, overflow = TextOverflow.Clip)
                }

                day.specialDayType != SpecialDayType.NONE -> Box(
                    modifier = Modifier
                        .padding(top = 4.dp)
                        .size(5.dp)
                        .clip(CircleShape)
                        .background(Ink.Secondary)
                )
            }
        }
    }
}
