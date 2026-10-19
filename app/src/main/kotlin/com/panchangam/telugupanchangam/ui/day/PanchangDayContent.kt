package com.panchangam.telugupanchangam.ui.day

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyListScope
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.filled.ModeNight
import androidx.compose.material.icons.filled.NightsStay
import androidx.compose.material.icons.filled.WbSunny
import androidx.compose.material.icons.filled.WbTwilight
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.panchangam.telugupanchangam.domain.ChoghadiyaPeriod
import com.panchangam.telugupanchangam.domain.ChoghadiyaQuality
import com.panchangam.telugupanchangam.domain.Festival
import com.panchangam.telugupanchangam.domain.PanchangDay
import com.panchangam.telugupanchangam.domain.Span
import com.panchangam.telugupanchangam.domain.TimeWindow
import com.panchangam.telugupanchangam.ui.components.InvertedBlock
import com.panchangam.telugupanchangam.ui.components.MoonPhase
import com.panchangam.telugupanchangam.ui.components.OutlinedBlock
import com.panchangam.telugupanchangam.ui.components.Pill
import com.panchangam.telugupanchangam.ui.components.SectionHeader
import com.panchangam.telugupanchangam.ui.components.ThinDivider
import com.panchangam.telugupanchangam.ui.components.timeLabel
import com.panchangam.telugupanchangam.ui.theme.Ink
import java.time.Duration
import java.time.LocalDateTime

private val gutter = Modifier.padding(horizontal = 16.dp)

/**
 * The full Panchangam for one day as lazy-list items. [now] highlights
 * whichever windows are running, when the day being shown is today.
 */
fun LazyListScope.panchangDayItems(
    day: PanchangDay,
    festivals: List<Festival>,
    now: LocalDateTime?,
    onFestivalSelected: (String) -> Unit
) {
    val live = now?.takeIf { !it.isBefore(day.sunrise) && it.isBefore(day.nextSunrise) }

    item(key = "hero") { HeroCard(day, Modifier.padding(start = 16.dp, end = 16.dp, top = 8.dp)) }

    if (festivals.isNotEmpty()) {
        item(key = "fest-header") { SectionHeader("నేటి పర్వదినం", "Today's occasion") }
        festivals.forEach { festival ->
            item(key = "fest-${festival.id}") {
                FestivalRow(festival, Modifier.padding(horizontal = 16.dp, vertical = 4.dp)) {
                    onFestivalSelected(festival.id)
                }
            }
        }
    }

    if (live != null) {
        item(key = "now") { NowCard(day, live, Modifier.padding(start = 16.dp, end = 16.dp, top = 16.dp)) }
    }

    item(key = "anga-header") { SectionHeader("పంచాంగం", "Five limbs") }
    item(key = "angas") {
        OutlinedBlock(gutter) {
            LimbRow("వారం", "Vara", day.vara.telugu, day.vara.transliteration)
            ThinDivider()
            SpanRows("తిథి", "Tithi", day.tithis, day) { "${it.paksha.telugu.substringBefore(" ")} ${it.telugu}" to it.label }
            ThinDivider()
            SpanRows("నక్షత్రం", "Nakshatra", day.nakshatras, day) { it.telugu to it.name }
            ThinDivider()
            SpanRows("యోగం", "Yoga", day.yogas, day) { it.telugu to it.name }
            ThinDivider()
            SpanRows("కరణం", "Karana", day.karanas, day) { it.telugu to it.name }
        }
    }

    item(key = "sun-header") { SectionHeader("సూర్య చంద్రులు", "Sun & Moon") }
    item(key = "sun") { SunMoonCard(day, gutter) }

    item(key = "times-header") { SectionHeader("ముహూర్తాలు", "Timings") }
    item(key = "times") {
        OutlinedBlock(gutter) {
            Text("శుభ సమయం · AUSPICIOUS", style = MaterialTheme.typography.labelSmall, color = Ink.current.faint)
            day.auspicious.forEach { WindowRow(it, day, live) }
            Spacer(Modifier.height(10.dp))
            ThinDivider()
            Spacer(Modifier.height(10.dp))
            Text("వర్జ్య సమయం · AVOID", style = MaterialTheme.typography.labelSmall, color = Ink.current.faint)
            day.inauspicious.forEach { WindowRow(it, day, live) }
        }
    }

    item(key = "rashi-header") { SectionHeader("రాశులు", "Sidereal signs at sunrise") }
    item(key = "rashi") {
        OutlinedBlock(gutter) {
            Row(Modifier.fillMaxWidth()) {
                Stat("సూర్య రాశి", day.sunRashi.telugu, day.sunRashi.name, Modifier.weight(1f))
                Stat("చంద్ర రాశి", day.moonRashi.telugu, day.moonRashi.name, Modifier.weight(1f))
            }
        }
    }

    item(key = "chog-header") { SectionHeader("చౌఘడియ", "Choghadiya") }
    item(key = "chog") { ChoghadiyaCard(day, live, gutter) }

    item(key = "method") {
        val city = day.city
        val coords = "%.2f°, %.2f°".format(city.latitude, city.longitude)
        Text(
            "${city.telugu} · ${city.name} ($coords) కోసం గణించబడింది. Computed for this location with the " +
                "Lahiri ayanamsa; the day runs sunrise to sunrise. Times are local (${city.zoneId}).",
            style = MaterialTheme.typography.bodySmall,
            color = Ink.current.faint,
            modifier = Modifier.padding(start = 20.dp, end = 20.dp, top = 24.dp)
        )
    }
}

// ---------------------------------------------------------------------

@Composable
private fun HeroCard(day: PanchangDay, modifier: Modifier = Modifier) {
    val ink = Ink.current
    // Inverted card: in light mode the "page" colour is the ink on it.
    val onCard = if (ink.isDark) ink.strong else ink.page
    val onCardSoft = if (ink.isDark) ink.secondary else ink.disabled
    InvertedBlock(modifier) {
        Text(
            "శ్రీ ${day.samvatsara.telugu} నామ సంవత్సరం",
            style = MaterialTheme.typography.titleMedium,
            color = onCard
        )
        Text(
            "${day.samvatsara.name} · Shaka ${day.shakaYear} · ${day.ayana.telugu} · ${day.ritu.telugu}",
            style = MaterialTheme.typography.bodySmall,
            color = onCardSoft
        )
        Spacer(Modifier.height(20.dp))
        Row(verticalAlignment = Alignment.CenterVertically) {
            Column(Modifier.weight(1f)) {
                Text(
                    "${day.lunarMonth.telugu} · ${day.paksha.telugu}",
                    style = MaterialTheme.typography.labelLarge,
                    color = onCardSoft
                )
                Text(day.tithi.telugu, style = MaterialTheme.typography.displayMedium, color = onCard)
                val first = day.tithis.first()
                val next = day.tithis.getOrNull(1)
                Text(
                    buildString {
                        append("${timeLabel(first.end, day.date)} వరకు")
                        if (next != null) append(" · తర్వాత ${next.item.telugu}")
                    },
                    style = MaterialTheme.typography.bodySmall,
                    color = onCardSoft
                )
            }
            Spacer(Modifier.width(16.dp))
            MoonPhase(
                elongation = day.elongation,
                size = 64.dp,
                lit = onCard,
                dark = if (ink.isDark) ink.wash else ink.strong,
                rim = onCardSoft
            )
        }
        Spacer(Modifier.height(18.dp))
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            HeroChip("${day.nakshatra.telugu} నక్షత్రం", onCard, onCardSoft)
            HeroChip(day.vara.telugu, onCard, onCardSoft)
        }
    }
}

@Composable
private fun HeroChip(text: String, fg: androidx.compose.ui.graphics.Color, rim: androidx.compose.ui.graphics.Color) {
    Box(
        Modifier
            .clip(RoundedCornerShape(50))
            .border(1.dp, rim, RoundedCornerShape(50))
            .padding(horizontal = 12.dp, vertical = 5.dp)
    ) { Text(text, style = MaterialTheme.typography.labelMedium, color = fg) }
}

@Composable
private fun FestivalRow(festival: Festival, modifier: Modifier = Modifier, onClick: () -> Unit) {
    val ink = Ink.current
    Row(
        modifier = modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(16.dp))
            .background(ink.wash)
            .clickable(onClick = onClick)
            .padding(16.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Column(Modifier.weight(1f)) {
            Text(festival.teluguName, style = MaterialTheme.typography.titleMedium, color = ink.strong)
            Text(festival.name, style = MaterialTheme.typography.bodySmall, color = ink.secondary)
        }
        Icon(Icons.AutoMirrored.Filled.KeyboardArrowRight, contentDescription = null, tint = ink.secondary)
    }
}

@Composable
private fun NowCard(day: PanchangDay, now: LocalDateTime, modifier: Modifier = Modifier) {
    val ink = Ink.current
    val chog = (day.dayChoghadiya + day.nightChoghadiya).firstOrNull { !now.isBefore(it.start) && now.isBefore(it.end) }
    val activeWindow = (day.inauspicious + day.auspicious).firstOrNull { !now.isBefore(it.start) && now.isBefore(it.end) }
    val tithi = day.tithis.firstOrNull { !now.isBefore(it.start) && now.isBefore(it.end) }
    val total = Duration.between(day.sunrise, day.nextSunrise).seconds.toFloat()
    val progress = (Duration.between(day.sunrise, now).seconds / total).coerceIn(0f, 1f)

    OutlinedBlock(modifier) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Box(Modifier.size(8.dp).clip(CircleShape).background(ink.strong))
            Spacer(Modifier.width(8.dp))
            Text("ఇప్పుడు", style = MaterialTheme.typography.titleMedium, color = ink.strong)
            Text("  NOW", style = MaterialTheme.typography.labelSmall, color = ink.faint)
        }
        Spacer(Modifier.height(12.dp))
        // Sunrise-to-sunrise progress, with the sunset mark.
        val sunsetAt = (Duration.between(day.sunrise, day.sunset).seconds / total).coerceIn(0f, 1f)
        Box(Modifier.fillMaxWidth().height(6.dp).clip(RoundedCornerShape(3.dp)).background(ink.lineFaint)) {
            Box(Modifier.fillMaxWidth(progress).height(6.dp).background(ink.strong))
        }
        Row(Modifier.fillMaxWidth().padding(top = 4.dp)) {
            Text(timeLabel(day.sunrise, day.date), style = MaterialTheme.typography.labelSmall, color = ink.faint)
            Spacer(Modifier.weight(sunsetAt.coerceAtLeast(0.01f)))
            Text("అస్తమయం ${timeLabel(day.sunset, day.date)}", style = MaterialTheme.typography.labelSmall, color = ink.faint)
            Spacer(Modifier.weight((1f - sunsetAt).coerceAtLeast(0.01f)))
            Text(timeLabel(day.nextSunrise, day.date), style = MaterialTheme.typography.labelSmall, color = ink.faint)
        }
        Spacer(Modifier.height(8.dp))
        tithi?.let { NowLine("తిథి", "${it.item.telugu} · ${timeLabel(it.end, day.date)} వరకు") }
        chog?.let { NowLine("చౌఘడియ", "${it.telugu} (${qualityTelugu(it.quality)}) · ${timeLabel(it.end, day.date)} వరకు") }
        if (activeWindow != null) {
            NowLine(
                activeWindow.teluguLabel,
                "${if (activeWindow.auspicious) "నడుస్తోంది" else "జాగ్రత్త"} · ${timeLabel(activeWindow.end, day.date)} వరకు",
                strong = true
            )
        }
    }
}

@Composable
private fun NowLine(label: String, value: String, strong: Boolean = false) {
    val ink = Ink.current
    Row(Modifier.fillMaxWidth().padding(vertical = 4.dp), verticalAlignment = Alignment.CenterVertically) {
        Text(label, style = MaterialTheme.typography.bodyMedium, color = ink.secondary, modifier = Modifier.width(96.dp))
        Text(
            value,
            style = MaterialTheme.typography.bodyMedium,
            color = ink.strong,
            fontWeight = if (strong) FontWeight.Bold else FontWeight.Medium
        )
    }
}

@Composable
private fun LimbRow(telugu: String, english: String, value: String, sub: String) {
    val ink = Ink.current
    Row(Modifier.fillMaxWidth().padding(vertical = 10.dp), verticalAlignment = Alignment.Top) {
        Column(Modifier.width(92.dp)) {
            Text(telugu, style = MaterialTheme.typography.bodyMedium, color = ink.secondary)
            Text(english.uppercase(), style = MaterialTheme.typography.labelSmall, color = ink.faint)
        }
        Column(Modifier.weight(1f)) {
            Text(value, style = MaterialTheme.typography.titleMedium, color = ink.strong)
            Text(sub, style = MaterialTheme.typography.bodySmall, color = ink.secondary)
        }
    }
}

/** A limb and everything it passes through between sunrise and the next sunrise. */
@Composable
private fun <T> SpanRows(
    telugu: String,
    english: String,
    spans: List<Span<T>>,
    day: PanchangDay,
    names: (T) -> Pair<String, String>
) {
    val ink = Ink.current
    Row(Modifier.fillMaxWidth().padding(vertical = 10.dp), verticalAlignment = Alignment.Top) {
        Column(Modifier.width(92.dp)) {
            Text(telugu, style = MaterialTheme.typography.bodyMedium, color = ink.secondary)
            Text(english.uppercase(), style = MaterialTheme.typography.labelSmall, color = ink.faint)
        }
        Column(Modifier.weight(1f)) {
            spans.forEachIndexed { i, span ->
                val (te, en) = names(span.item)
                Row(
                    Modifier.fillMaxWidth().padding(top = if (i == 0) 0.dp else 8.dp),
                    verticalAlignment = Alignment.Top
                ) {
                    Column(Modifier.weight(1f)) {
                        Text(
                            te,
                            style = if (i == 0) MaterialTheme.typography.titleMedium else MaterialTheme.typography.bodyMedium,
                            color = if (i == 0) ink.strong else ink.body
                        )
                        Text(en, style = MaterialTheme.typography.bodySmall, color = ink.secondary)
                    }
                    Text(
                        "${timeLabel(span.end, day.date)} వరకు",
                        style = MaterialTheme.typography.labelMedium,
                        color = if (i == 0) ink.strong else ink.secondary
                    )
                }
            }
        }
    }
}

@Composable
private fun SunMoonCard(day: PanchangDay, modifier: Modifier = Modifier) {
    val daylight = Duration.between(day.sunrise, day.sunset)
    OutlinedBlock(modifier) {
        Row(Modifier.fillMaxWidth()) {
            SunMoonCell(Icons.Filled.WbSunny, "సూర్యోదయం", "Sunrise", timeLabel(day.sunrise, day.date), Modifier.weight(1f))
            SunMoonCell(Icons.Filled.WbTwilight, "సూర్యాస్తమయం", "Sunset", timeLabel(day.sunset, day.date), Modifier.weight(1f))
        }
        Spacer(Modifier.height(14.dp))
        Row(Modifier.fillMaxWidth()) {
            SunMoonCell(
                Icons.Filled.NightsStay, "చంద్రోదయం", "Moonrise",
                day.moonrise?.let { timeLabel(it, day.date) } ?: "—", Modifier.weight(1f)
            )
            SunMoonCell(
                Icons.Filled.ModeNight, "చంద్రాస్తమయం", "Moonset",
                day.moonset?.let { timeLabel(it, day.date) } ?: "—", Modifier.weight(1f)
            )
        }
        Spacer(Modifier.height(14.dp))
        ThinDivider()
        Text(
            "పగటి సమయం ${daylight.toHours()} గం. ${daylight.toMinutesPart()} ని.  ·  Daylight ${daylight.toHours()}h ${daylight.toMinutesPart()}m",
            style = MaterialTheme.typography.bodySmall,
            color = Ink.current.secondary,
            modifier = Modifier.padding(top = 10.dp)
        )
    }
}

@Composable
private fun SunMoonCell(icon: ImageVector, telugu: String, english: String, value: String, modifier: Modifier) {
    val ink = Ink.current
    Row(modifier, verticalAlignment = Alignment.CenterVertically) {
        Box(
            Modifier.size(36.dp).clip(CircleShape).background(ink.wash),
            contentAlignment = Alignment.Center
        ) { Icon(icon, contentDescription = english, tint = ink.strong, modifier = Modifier.size(18.dp)) }
        Spacer(Modifier.width(10.dp))
        Column {
            Text(value, style = MaterialTheme.typography.titleMedium, color = ink.strong)
            Text(telugu, style = MaterialTheme.typography.labelSmall, color = ink.secondary)
        }
    }
}

@Composable
private fun WindowRow(window: TimeWindow, day: PanchangDay, now: LocalDateTime?) {
    val ink = Ink.current
    val active = now != null && !now.isBefore(window.start) && now.isBefore(window.end)
    Row(
        Modifier
            .fillMaxWidth()
            .padding(top = 6.dp)
            .clip(RoundedCornerShape(10.dp))
            .background(if (active) ink.wash else ink.page)
            .padding(horizontal = if (active) 10.dp else 0.dp, vertical = 6.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Column(Modifier.weight(1f)) {
            Text(window.teluguLabel, style = MaterialTheme.typography.bodyMedium, color = ink.strong)
            Text(window.label, style = MaterialTheme.typography.labelSmall, color = ink.faint)
        }
        if (active) {
            Pill("ఇప్పుడు", filled = true)
            Spacer(Modifier.width(8.dp))
        }
        Text(
            "${timeLabel(window.start, day.date)} – ${timeLabel(window.end, day.date)}",
            style = MaterialTheme.typography.titleSmall,
            color = ink.strong
        )
    }
}

@Composable
private fun Stat(telugu: String, value: String, sub: String, modifier: Modifier) {
    val ink = Ink.current
    Column(modifier) {
        Text(telugu, style = MaterialTheme.typography.labelMedium, color = ink.secondary)
        Text(value, style = MaterialTheme.typography.titleLarge, color = ink.strong)
        Text(sub, style = MaterialTheme.typography.bodySmall, color = ink.secondary)
    }
}

private fun qualityTelugu(q: ChoghadiyaQuality) = when (q) {
    ChoghadiyaQuality.GOOD -> "శుభం"
    ChoghadiyaQuality.NEUTRAL -> "సమం"
    ChoghadiyaQuality.INAUSPICIOUS -> "అశుభం"
}

@Composable
private fun ChoghadiyaCard(day: PanchangDay, now: LocalDateTime?, modifier: Modifier = Modifier) {
    val ink = Ink.current
    val nightNow = now != null && !now.isBefore(day.sunset)
    var night by rememberSaveable(day.date) { mutableStateOf(nightNow) }
    val periods: List<ChoghadiyaPeriod> = if (night) day.nightChoghadiya else day.dayChoghadiya

    OutlinedBlock(modifier) {
        Row(
            Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(12.dp))
                .background(ink.wash)
                .padding(4.dp)
        ) {
            listOf(false to "పగలు · Day", true to "రాత్రి · Night").forEach { (isNight, label) ->
                val selected = night == isNight
                Box(
                    Modifier
                        .weight(1f)
                        .clip(RoundedCornerShape(9.dp))
                        .background(if (selected) ink.page else ink.wash)
                        .clickable { night = isNight }
                        .padding(vertical = 8.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        label,
                        style = MaterialTheme.typography.labelLarge,
                        color = if (selected) ink.strong else ink.secondary
                    )
                }
            }
        }
        Spacer(Modifier.height(8.dp))
        periods.forEach { p ->
            val active = now != null && !now.isBefore(p.start) && now.isBefore(p.end)
            Row(
                Modifier
                    .fillMaxWidth()
                    .padding(top = 4.dp)
                    .clip(RoundedCornerShape(10.dp))
                    .background(if (active) ink.wash else ink.page)
                    .padding(horizontal = 10.dp, vertical = 8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                val mark = when (p.quality) {
                    ChoghadiyaQuality.GOOD -> ink.strong
                    ChoghadiyaQuality.NEUTRAL -> ink.faint
                    ChoghadiyaQuality.INAUSPICIOUS -> ink.page
                }
                Box(
                    Modifier
                        .size(10.dp)
                        .clip(CircleShape)
                        .background(mark)
                        .border(1.dp, ink.secondary, CircleShape)
                )
                Spacer(Modifier.width(12.dp))
                Column(Modifier.weight(1f)) {
                    Text("${p.telugu} · ${qualityTelugu(p.quality)}", style = MaterialTheme.typography.bodyMedium, color = ink.strong)
                    Text(p.name, style = MaterialTheme.typography.labelSmall, color = ink.faint)
                }
                Text(
                    "${timeLabel(p.start, day.date)} – ${timeLabel(p.end, day.date)}",
                    style = MaterialTheme.typography.labelMedium,
                    color = if (active) ink.strong else ink.secondary
                )
            }
        }
        Row(
            Modifier.padding(top = 12.dp, start = 10.dp),
            horizontalArrangement = Arrangement.spacedBy(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            listOf(
                ChoghadiyaQuality.GOOD to ink.strong,
                ChoghadiyaQuality.NEUTRAL to ink.faint,
                ChoghadiyaQuality.INAUSPICIOUS to ink.page
            ).forEach { (q, fill) ->
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Box(Modifier.size(8.dp).clip(CircleShape).background(fill).border(1.dp, ink.secondary, CircleShape))
                    Text("  ${qualityTelugu(q)}", style = MaterialTheme.typography.labelSmall, color = ink.faint)
                }
            }
        }
    }
}
