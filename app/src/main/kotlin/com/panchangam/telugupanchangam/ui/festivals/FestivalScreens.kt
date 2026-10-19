package com.panchangam.telugupanchangam.ui.festivals

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
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
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.unit.dp
import com.panchangam.telugupanchangam.data.FestivalData
import com.panchangam.telugupanchangam.domain.Festival
import com.panchangam.telugupanchangam.domain.FestivalImportance
import com.panchangam.telugupanchangam.domain.FestivalRepository
import com.panchangam.telugupanchangam.domain.VerificationStatus
import com.panchangam.telugupanchangam.ui.LocalAppSettings
import com.panchangam.telugupanchangam.ui.components.InvertedBlock
import com.panchangam.telugupanchangam.ui.components.OutlinedBlock
import com.panchangam.telugupanchangam.ui.components.Pill
import com.panchangam.telugupanchangam.ui.components.SourceReferenceCard
import com.panchangam.telugupanchangam.ui.components.StatusBadge
import com.panchangam.telugupanchangam.ui.components.ThinDivider
import com.panchangam.telugupanchangam.ui.components.countdownLabel
import com.panchangam.telugupanchangam.ui.components.englishLabel
import com.panchangam.telugupanchangam.ui.components.formatLong
import com.panchangam.telugupanchangam.ui.components.formatWeekdayShort
import com.panchangam.telugupanchangam.ui.components.teluguDayMonth
import com.panchangam.telugupanchangam.ui.components.teluguLabel
import com.panchangam.telugupanchangam.ui.components.teluguMonthYear
import com.panchangam.telugupanchangam.ui.theme.Ink
import java.time.LocalDate
import java.time.YearMonth

private enum class FestivalFilter(val telugu: String, val english: String) {
    UPCOMING("రాబోయేవి", "Upcoming"),
    MAJOR("ముఖ్యమైనవి", "Major"),
    ALL("అన్నీ", "All")
}

@Composable
fun FestivalsScreen(
    festivalRepository: FestivalRepository,
    onFestivalSelected: (String) -> Unit
) {
    val ink = Ink.current
    val city = LocalAppSettings.current.city
    val today = remember(city.id) { LocalDate.now(city.zone) }
    val all = remember { festivalRepository.all() }
    var filter by rememberSaveable { mutableStateOf(FestivalFilter.UPCOMING) }

    val shown = remember(filter, today) {
        when (filter) {
            FestivalFilter.UPCOMING -> all.filter { !it.date.isBefore(today) }
            FestivalFilter.MAJOR -> all.filter { it.importance == FestivalImportance.MAJOR }
            FestivalFilter.ALL -> all
        }
    }
    val next = remember(today) { all.firstOrNull { !it.date.isBefore(today) } }
    val grouped = remember(shown) { shown.groupBy { YearMonth.from(it.date) } }

    LazyColumn(
        modifier = Modifier.fillMaxSize().background(ink.page).statusBarsPadding(),
        contentPadding = PaddingValues(bottom = 32.dp)
    ) {
        item(key = "title") {
            Column(Modifier.padding(start = 20.dp, end = 20.dp, top = 16.dp, bottom = 12.dp)) {
                Text("పండుగలు", style = MaterialTheme.typography.headlineMedium, color = ink.strong)
                Text(
                    "శ్రీ పరాభవ నామ సంవత్సరం · Festivals & observances, Ugadi 2026 – Ugadi 2027",
                    style = MaterialTheme.typography.bodySmall,
                    color = ink.secondary
                )
            }
        }

        if (next != null) {
            item(key = "next") {
                InvertedBlock(
                    Modifier
                        .padding(horizontal = 16.dp)
                        .clip(RoundedCornerShape(24.dp))
                        .clickable { onFestivalSelected(next.id) }
                ) {
                    val onCard = if (ink.isDark) ink.strong else ink.page
                    val soft = if (ink.isDark) ink.secondary else ink.disabled
                    Text("తదుపరి పండుగ · NEXT", style = MaterialTheme.typography.labelSmall, color = soft)
                    Spacer(Modifier.height(10.dp))
                    Text(next.teluguName, style = MaterialTheme.typography.displaySmall, color = onCard)
                    Text(next.name, style = MaterialTheme.typography.bodyMedium, color = soft)
                    Spacer(Modifier.height(14.dp))
                    Row(verticalAlignment = Alignment.Bottom) {
                        Text(countdownLabel(today, next.date), style = MaterialTheme.typography.headlineSmall, color = onCard)
                        Spacer(Modifier.weight(1f))
                        Text(
                            "${next.date.teluguDayMonth()} · ${next.date.formatWeekdayShort()}",
                            style = MaterialTheme.typography.labelLarge,
                            color = soft
                        )
                    }
                }
            }
        }

        item(key = "filters") {
            Row(
                Modifier
                    .fillMaxWidth()
                    .horizontalScroll(rememberScrollState())
                    .padding(horizontal = 16.dp, vertical = 16.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                FestivalFilter.entries.forEach { f ->
                    FilterTab("${f.telugu} · ${f.english}", selected = filter == f) { filter = f }
                }
            }
        }

        if (shown.isEmpty()) {
            item(key = "empty") {
                Text(
                    "ఈ సంవత్సరపు జాబితాలో మరిన్ని పండుగలు లేవు. The verified list ends at Ugadi 2027.",
                    style = MaterialTheme.typography.bodyMedium,
                    color = ink.secondary,
                    modifier = Modifier.padding(20.dp)
                )
            }
        }

        grouped.forEach { (month, items) ->
            item(key = "m-$month") {
                Text(
                    month.atDay(1).teluguMonthYear(),
                    style = MaterialTheme.typography.labelLarge,
                    color = ink.faint,
                    modifier = Modifier.padding(start = 20.dp, top = 16.dp, bottom = 4.dp)
                )
            }
            items.forEachIndexed { i, festival ->
                item(key = festival.id) {
                    if (i > 0) ThinDivider(Modifier.padding(start = 80.dp, end = 20.dp))
                    FestivalListItem(festival, today) { onFestivalSelected(festival.id) }
                }
            }
        }
    }
}

@Composable
private fun FilterTab(text: String, selected: Boolean, onClick: () -> Unit) {
    val ink = Ink.current
    Box(
        Modifier
            .clip(RoundedCornerShape(50))
            .background(if (selected) ink.strong else ink.page)
            .border(1.dp, if (selected) ink.strong else ink.line, RoundedCornerShape(50))
            .clickable(onClick = onClick)
            .padding(horizontal = 14.dp, vertical = 8.dp)
    ) {
        Text(text, style = MaterialTheme.typography.labelLarge, color = if (selected) ink.page else ink.secondary)
    }
}

@Composable
private fun FestivalListItem(festival: Festival, today: LocalDate, onClick: () -> Unit) {
    val ink = Ink.current
    val past = festival.date.isBefore(today)
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
            .padding(horizontal = 20.dp, vertical = 12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Column(
            Modifier
                .width(46.dp)
                .clip(RoundedCornerShape(12.dp))
                .background(if (festival.importance == FestivalImportance.MAJOR && !past) ink.strong else ink.page)
                .border(1.dp, if (festival.importance == FestivalImportance.MAJOR && !past) ink.strong else ink.line, RoundedCornerShape(12.dp))
                .padding(vertical = 6.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            val fg = if (festival.importance == FestivalImportance.MAJOR && !past) ink.page else if (past) ink.faint else ink.strong
            Text(festival.date.dayOfMonth.toString(), style = MaterialTheme.typography.titleMedium, color = fg)
            Text(festival.date.formatWeekdayShort().uppercase(), style = MaterialTheme.typography.labelSmall, color = fg.copy(alpha = 0.7f))
        }
        Spacer(Modifier.width(14.dp))
        Column(Modifier.weight(1f)) {
            Text(festival.teluguName, style = MaterialTheme.typography.titleMedium, color = if (past) ink.secondary else ink.strong)
            Text(festival.name, style = MaterialTheme.typography.bodySmall, color = ink.secondary)
            Text(
                festival.shortSignificance,
                style = MaterialTheme.typography.bodySmall,
                color = ink.faint,
                maxLines = 1,
                modifier = Modifier.padding(top = 2.dp)
            )
            if (festival.dateStatus != VerificationStatus.VERIFIED) {
                Row(Modifier.padding(top = 6.dp)) { StatusBadge(festival.dateStatus) }
            }
        }
        Spacer(Modifier.width(8.dp))
        Text(
            countdownLabel(today, festival.date),
            style = MaterialTheme.typography.labelMedium,
            color = if (past) ink.faint else ink.secondary
        )
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FestivalDetailScreen(
    festivalId: String,
    festivalRepository: FestivalRepository,
    onBack: () -> Unit,
    onOpenDay: (LocalDate) -> Unit
) {
    val ink = Ink.current
    val city = LocalAppSettings.current.city
    val today = remember(city.id) { LocalDate.now(city.zone) }
    val festival = remember(festivalId) { festivalRepository.byId(festivalId) }

    Scaffold(
        containerColor = ink.page,
        topBar = {
            TopAppBar(
                title = {},
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back", tint = ink.strong)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = ink.page)
            )
        }
    ) { padding ->
        if (festival == null) {
            Box(Modifier.fillMaxSize().padding(padding), contentAlignment = Alignment.Center) {
                Text("Festival not found", style = MaterialTheme.typography.bodyMedium, color = ink.secondary)
            }
            return@Scaffold
        }

        LazyColumn(
            modifier = Modifier.fillMaxSize().padding(padding),
            contentPadding = PaddingValues(start = 20.dp, end = 20.dp, bottom = 40.dp)
        ) {
            item {
                Text(festival.teluguName, style = MaterialTheme.typography.displaySmall, color = ink.strong)
                Text(festival.name, style = MaterialTheme.typography.bodyLarge, color = ink.secondary)
                Spacer(Modifier.height(10.dp))
                Text(festival.shortSignificance, style = MaterialTheme.typography.bodyMedium, color = ink.body)
                Spacer(Modifier.height(20.dp))

                OutlinedBlock {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Column(Modifier.weight(1f)) {
                            Text(festival.date.teluguDayMonth() + " ${festival.date.year}", style = MaterialTheme.typography.titleLarge, color = ink.strong)
                            Text(festival.date.formatLong(), style = MaterialTheme.typography.bodySmall, color = ink.secondary)
                        }
                        Pill(countdownLabel(today, festival.date), filled = !festival.date.isBefore(today))
                    }
                    Spacer(Modifier.height(14.dp))
                    ThinDivider()
                    Spacer(Modifier.height(12.dp))
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Box(
                            Modifier
                                .size(8.dp)
                                .clip(CircleShape)
                                .background(if (festival.dateStatus == VerificationStatus.VERIFIED) ink.strong else ink.page)
                                .border(1.dp, ink.strong, CircleShape)
                        )
                        Spacer(Modifier.width(8.dp))
                        Text(
                            "${festival.dateStatus.teluguLabel()} · ${festival.dateStatus.englishLabel()}",
                            style = MaterialTheme.typography.labelLarge,
                            color = ink.strong
                        )
                    }
                    festival.dateNote?.let {
                        Text(it, style = MaterialTheme.typography.bodySmall, color = ink.secondary, modifier = Modifier.padding(top = 8.dp))
                    }
                    Spacer(Modifier.height(12.dp))
                    OutlinedButton(onClick = { onOpenDay(festival.date) }, shape = RoundedCornerShape(12.dp)) {
                        Text("ఆ రోజు పంచాంగం · View the day", style = MaterialTheme.typography.labelLarge, color = ink.strong)
                        Spacer(Modifier.width(4.dp))
                        Icon(Icons.AutoMirrored.Filled.KeyboardArrowRight, contentDescription = null, tint = ink.strong, modifier = Modifier.size(18.dp))
                    }
                }
            }

            section("ప్రాముఖ్యత", "Significance", festival.significance)
            festival.observance?.let { section("ఆచరణ", "Observance", it) }
            festival.preparation?.let { section("సన్నాహం", "Preparation", it) }

            item {
                Spacer(Modifier.height(20.dp))
                Box(
                    Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(14.dp))
                        .background(ink.wash)
                        .padding(14.dp)
                ) {
                    Text(
                        "మంత్రాలు, పూజా విధానం ఇక్కడ ఇవ్వలేదు — మీ పురోహితులను లేదా కుటుంబ పంచాంగాన్ని సంప్రదించండి. " +
                            "Mantras and step-by-step ritual are deliberately not included without a cited traditional source.",
                        style = MaterialTheme.typography.bodySmall,
                        color = ink.secondary
                    )
                }
            }

            item {
                Spacer(Modifier.height(28.dp))
                Text("ఆధారాలు", style = MaterialTheme.typography.titleLarge, color = ink.strong)
                Text("SOURCES", style = MaterialTheme.typography.labelSmall, color = ink.faint)
                Spacer(Modifier.height(10.dp))
            }
            festival.sources.forEach { source ->
                item { SourceReferenceCard(source, Modifier.padding(bottom = 8.dp)) }
            }
            item {
                Text(
                    "Festival list covers ${FestivalData.ugadiStart.formatLong()} – ${FestivalData.nextUgadi.formatLong()}.",
                    style = MaterialTheme.typography.labelSmall,
                    color = ink.faint,
                    modifier = Modifier.padding(top = 12.dp)
                )
            }
        }
    }
}

private fun androidx.compose.foundation.lazy.LazyListScope.section(
    telugu: String,
    english: String,
    body: String
) = item {
    Spacer(Modifier.height(28.dp))
    Text(telugu, style = MaterialTheme.typography.titleLarge, color = Ink.current.strong)
    Text(english.uppercase(), style = MaterialTheme.typography.labelSmall, color = Ink.current.faint)
    Spacer(Modifier.height(8.dp))
    Text(body, style = MaterialTheme.typography.bodyLarge, color = Ink.current.body)
}
