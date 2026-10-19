package com.panchangam.telugupanchangam.ui.today

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
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.LocationOn
import androidx.compose.material.icons.filled.Share
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.panchangam.telugupanchangam.domain.Festival
import com.panchangam.telugupanchangam.domain.FestivalRepository
import com.panchangam.telugupanchangam.domain.PanchangRepository
import com.panchangam.telugupanchangam.ui.LocalAppSettings
import com.panchangam.telugupanchangam.ui.components.OutlinedBlock
import com.panchangam.telugupanchangam.ui.components.Pill
import com.panchangam.telugupanchangam.ui.components.SectionHeader
import com.panchangam.telugupanchangam.ui.components.ThinDivider
import com.panchangam.telugupanchangam.ui.components.countdownLabel
import com.panchangam.telugupanchangam.ui.components.formatLong
import com.panchangam.telugupanchangam.ui.components.formatShort
import com.panchangam.telugupanchangam.ui.components.teluguDayMonth
import com.panchangam.telugupanchangam.ui.day.panchangDayItems
import com.panchangam.telugupanchangam.ui.day.shareText
import com.panchangam.telugupanchangam.ui.theme.Ink
import kotlinx.coroutines.delay
import java.time.LocalDateTime

/** Home: today's Panchangam for the chosen city, with live timings. */
@Composable
fun TodayScreen(
    panchangRepository: PanchangRepository,
    festivalRepository: FestivalRepository,
    onPickCity: () -> Unit,
    onFestivalSelected: (String) -> Unit,
    onShare: (String) -> Unit
) {
    val settings = LocalAppSettings.current
    val city = settings.city

    // Ticks every 30 s so "now" highlights and the day rollover stay current.
    var now by remember(city.id) { mutableStateOf(LocalDateTime.now(city.zone)) }
    LaunchedEffect(city.id) {
        while (true) {
            delay(30_000)
            now = LocalDateTime.now(city.zone)
        }
    }
    val today = now.toLocalDate()

    val day = remember(today, city.id) { panchangRepository.dayDetail(today, city) }
    val festivals = remember(today) { festivalRepository.onDate(today) }
    val upcoming = remember(today) { festivalRepository.upcoming(today.plusDays(1), 4) }
    val use24 = settings.use24Hour

    LazyColumn(
        modifier = Modifier.fillMaxSize().background(Ink.current.page).statusBarsPadding(),
        contentPadding = PaddingValues(bottom = 32.dp)
    ) {
        item(key = "header") {
            Row(
                Modifier.fillMaxWidth().padding(start = 20.dp, end = 8.dp, top = 12.dp, bottom = 8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column(Modifier.weight(1f)) {
                    Text(
                        "${today.teluguDayMonth()}, ${day.vara.telugu}",
                        style = MaterialTheme.typography.headlineMedium,
                        color = Ink.current.strong,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                    Text(today.formatLong(), style = MaterialTheme.typography.bodySmall, color = Ink.current.secondary)
                }
                IconButton(onClick = { onShare(shareText(day, festivals, use24)) }) {
                    Icon(Icons.Filled.Share, contentDescription = "Share today's Panchangam", tint = Ink.current.strong)
                }
            }
            CityChip(city.telugu, city.name, onPickCity, Modifier.padding(start = 20.dp, bottom = 8.dp))
        }

        panchangDayItems(day, festivals, now, onFestivalSelected)

        if (upcoming.isNotEmpty()) {
            item(key = "upcoming-header") { SectionHeader("రాబోయే పండుగలు", "Coming up") }
            item(key = "upcoming") {
                OutlinedBlock(Modifier.padding(horizontal = 16.dp), padding = 4.dp) {
                    upcoming.forEachIndexed { i, f ->
                        if (i > 0) ThinDivider(Modifier.padding(horizontal = 12.dp))
                        UpcomingRow(f, countdownLabel(today, f.date)) { onFestivalSelected(f.id) }
                    }
                }
            }
        }
    }
}

@Composable
private fun CityChip(telugu: String, english: String, onClick: () -> Unit, modifier: Modifier = Modifier) {
    val ink = Ink.current
    Row(
        modifier
            .clip(RoundedCornerShape(50))
            .border(1.dp, ink.line, RoundedCornerShape(50))
            .clickable(onClick = onClick)
            .padding(start = 10.dp, end = 14.dp, top = 6.dp, bottom = 6.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(Icons.Filled.LocationOn, contentDescription = null, tint = ink.strong, modifier = Modifier.size(16.dp))
        Spacer(Modifier.width(6.dp))
        Text(telugu, style = MaterialTheme.typography.labelLarge, color = ink.strong)
        Text("  $english", style = MaterialTheme.typography.labelMedium, color = ink.secondary)
    }
}

@Composable
private fun UpcomingRow(festival: Festival, countdown: String, onClick: () -> Unit) {
    val ink = Ink.current
    Row(
        Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(14.dp))
            .clickable(onClick = onClick)
            .padding(horizontal = 12.dp, vertical = 12.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Column(Modifier.weight(1f)) {
            Text(festival.teluguName, style = MaterialTheme.typography.titleMedium, color = ink.strong)
            Text("${festival.name} · ${festival.date.formatShort()}", style = MaterialTheme.typography.bodySmall, color = ink.secondary)
        }
        Spacer(Modifier.width(8.dp))
        Box { Pill(countdown) }
    }
}
