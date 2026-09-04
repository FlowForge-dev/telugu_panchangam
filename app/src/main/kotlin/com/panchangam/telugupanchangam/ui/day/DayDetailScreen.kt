package com.panchangam.telugupanchangam.ui.day

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.unit.dp
import com.panchangam.telugupanchangam.domain.ChoghadiyaQuality
import com.panchangam.telugupanchangam.domain.Festival
import com.panchangam.telugupanchangam.domain.FestivalRepository
import com.panchangam.telugupanchangam.domain.PanchangRepository
import com.panchangam.telugupanchangam.ui.components.DetailRow
import com.panchangam.telugupanchangam.ui.components.OutlinedBlock
import com.panchangam.telugupanchangam.ui.components.PreviewDataNote
import com.panchangam.telugupanchangam.ui.components.SectionHeader
import com.panchangam.telugupanchangam.ui.components.ThinDivider
import com.panchangam.telugupanchangam.ui.components.formatLong
import com.panchangam.telugupanchangam.ui.theme.Ink
import java.time.LocalDate

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DayDetailScreen(
    date: LocalDate,
    panchangRepository: PanchangRepository,
    festivalRepository: FestivalRepository,
    onBack: () -> Unit,
    onFestivalSelected: (String) -> Unit
) {
    val day = remember(date) { panchangRepository.dayDetail(date) }
    val festivals = remember(date) { festivalRepository.onDate(date) }

    Scaffold(
        containerColor = Ink.White,
        topBar = {
            TopAppBar(
                title = { Text(date.formatLong(), style = MaterialTheme.typography.titleLarge) },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back", tint = Ink.Black)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = Ink.White)
            )
        }
    ) { padding ->
        LazyColumn(
            modifier = Modifier.fillMaxSize().padding(padding),
            contentPadding = androidx.compose.foundation.layout.PaddingValues(bottom = 32.dp)
        ) {
            item {
                Column(Modifier.padding(horizontal = 16.dp, vertical = 8.dp)) {
                    OutlinedBlock {
                        Text(
                            "${day.masa.telugu} · ${day.paksha.telugu}",
                            style = MaterialTheme.typography.titleSmall
                        )
                        Text(
                            "${day.shakaSamvatYear} శక సంవత్సరం",
                            style = MaterialTheme.typography.bodySmall
                        )
                        Spacer(Modifier.height(12.dp))
                        ThinDivider()
                        DetailRow("వారం", day.vara.telugu, day.vara.transliteration)
                        DetailRow("తిథి", day.tithi.telugu, day.tithi.label)
                        DetailRow(
                            "నక్షత్రం",
                            day.nakshatra.telugu,
                            "${day.nakshatra.name} · Pada ${day.nakshatraPada}"
                        )
                        DetailRow("యోగం", day.yoga.telugu, day.yoga.name)
                        DetailRow("కరణం", day.karana.telugu, day.karana.name)
                    }
                    Spacer(Modifier.height(12.dp))
                    PreviewDataNote()
                }
            }

            if (festivals.isNotEmpty()) {
                item { SectionHeader("నేటి పండుగ", "Festival today") }
                items(festivals) { festival ->
                    FestivalRow(festival) { onFestivalSelected(festival.id) }
                }
            }

            item { SectionHeader("సూర్య చంద్రుడు", "Sun & Moon") }
            item {
                Column(Modifier.padding(horizontal = 16.dp)) {
                    OutlinedBlock {
                        DetailRow("సూర్యోదయం", day.sunrise)
                        DetailRow("సూర్యాస్తమయం", day.sunset)
                        DetailRow("చంద్రోదయం", day.moonrise)
                        DetailRow("చంద్రాస్తమయం", day.moonset)
                    }
                }
            }

            if (day.muhurtas.isNotEmpty()) {
                item { SectionHeader("రాహు కాలం, యమగండం", "Inauspicious windows") }
                item {
                    Column(Modifier.padding(horizontal = 16.dp)) {
                        OutlinedBlock {
                            day.muhurtas.forEachIndexed { i, m ->
                                if (i > 0) ThinDivider()
                                DetailRow(m.teluguLabel, "${m.start} – ${m.end}", m.label)
                            }
                        }
                    }
                }
            }

            if (day.choghadiya.isNotEmpty()) {
                item { SectionHeader("చౌఘడియ", "Choghadiya") }
                item {
                    Column(Modifier.padding(horizontal = 16.dp)) {
                        OutlinedBlock {
                            day.choghadiya.forEachIndexed { i, c ->
                                if (i > 0) ThinDivider()
                                val quality = when (c.quality) {
                                    ChoghadiyaQuality.GOOD -> "శుభం"
                                    ChoghadiyaQuality.NEUTRAL -> "సమం"
                                    ChoghadiyaQuality.INAUSPICIOUS -> "అశుభం"
                                }
                                DetailRow("${c.telugu}  ·  $quality", "${c.start} – ${c.end}", c.name)
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun FestivalRow(festival: Festival, onClick: () -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 4.dp)
            .clip(RoundedCornerShape(12.dp))
            .background(Ink.Wash)
            .clickable(onClick = onClick)
            .padding(14.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Column(Modifier.weight(1f)) {
            Text(festival.teluguName, style = MaterialTheme.typography.titleMedium)
            Text(festival.name, style = MaterialTheme.typography.bodySmall)
        }
        Spacer(Modifier.width(8.dp))
        Icon(Icons.AutoMirrored.Filled.KeyboardArrowRight, contentDescription = null, tint = Ink.Secondary)
    }
}
