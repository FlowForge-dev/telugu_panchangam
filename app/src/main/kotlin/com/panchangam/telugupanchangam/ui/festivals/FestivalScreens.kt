package com.panchangam.telugupanchangam.ui.festivals

import androidx.compose.foundation.background
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
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
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
import com.panchangam.telugupanchangam.domain.Festival
import com.panchangam.telugupanchangam.domain.FestivalImportance
import com.panchangam.telugupanchangam.domain.FestivalRepository
import com.panchangam.telugupanchangam.ui.components.OutlinedBlock
import com.panchangam.telugupanchangam.ui.components.SourceReferenceCard
import com.panchangam.telugupanchangam.ui.components.ThinDivider
import com.panchangam.telugupanchangam.ui.components.formatLong
import com.panchangam.telugupanchangam.ui.components.formatShort
import com.panchangam.telugupanchangam.ui.theme.Ink
import java.time.LocalDate
import java.time.temporal.ChronoUnit

@Composable
fun FestivalsScreen(
    festivalRepository: FestivalRepository,
    onFestivalSelected: (String) -> Unit
) {
    val today = remember { LocalDate.now() }
    val festivals = remember { festivalRepository.all() }

    LazyColumn(
        modifier = Modifier.fillMaxSize().background(Ink.White),
        contentPadding = PaddingValues(bottom = 24.dp)
    ) {
        item {
            Column(Modifier.padding(start = 16.dp, end = 16.dp, top = 16.dp, bottom = 8.dp)) {
                Text("పండుగలు", style = MaterialTheme.typography.headlineMedium)
                Text("Festivals & observances", style = MaterialTheme.typography.bodySmall)
            }
        }
        items(festivals) { festival ->
            FestivalListItem(festival = festival, today = today) { onFestivalSelected(festival.id) }
            ThinDivider(Modifier.padding(start = 16.dp))
        }
    }
}

@Composable
private fun FestivalListItem(festival: Festival, today: LocalDate, onClick: () -> Unit) {
    val daysAway = ChronoUnit.DAYS.between(today, festival.date)
    val countdown = when {
        daysAway == 0L -> "ఈరోజు"
        daysAway == 1L -> "రేపు"
        daysAway > 1L -> "$daysAway days"
        else -> "Passed"
    }

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
            .padding(horizontal = 16.dp, vertical = 14.dp),
        verticalAlignment = Alignment.Top
    ) {
        // Importance shown by weight of a small mark, not by hue.
        Box(
            modifier = Modifier
                .padding(top = 6.dp)
                .size(
                    when (festival.importance) {
                        FestivalImportance.MAJOR -> 9.dp
                        FestivalImportance.MODERATE -> 6.dp
                        FestivalImportance.OBSERVANCE -> 4.dp
                    }
                )
                .clip(CircleShape)
                .background(
                    when (festival.importance) {
                        FestivalImportance.MAJOR -> Ink.Black
                        FestivalImportance.MODERATE -> Ink.Secondary
                        FestivalImportance.OBSERVANCE -> Ink.Faint
                    }
                )
        )
        Spacer(Modifier.width(12.dp))
        Column(Modifier.weight(1f)) {
            Text(festival.teluguName, style = MaterialTheme.typography.titleMedium)
            Text(festival.name, style = MaterialTheme.typography.bodySmall)
            Spacer(Modifier.height(4.dp))
            Text(festival.shortSignificance, style = MaterialTheme.typography.bodyMedium, maxLines = 2)
            Spacer(Modifier.height(6.dp))
            Text(festival.date.formatShort(), style = MaterialTheme.typography.labelMedium)
        }
        Spacer(Modifier.width(8.dp))
        Text(countdown, style = MaterialTheme.typography.labelMedium, color = Ink.Secondary)
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FestivalDetailScreen(
    festivalId: String,
    festivalRepository: FestivalRepository,
    onBack: () -> Unit
) {
    val festival = remember(festivalId) { festivalRepository.byId(festivalId) }

    Scaffold(
        containerColor = Ink.White,
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        festival?.teluguName ?: "Not found",
                        style = MaterialTheme.typography.titleLarge
                    )
                },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back", tint = Ink.Black)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = Ink.White)
            )
        }
    ) { padding ->
        if (festival == null) {
            Box(Modifier.fillMaxSize().padding(padding), contentAlignment = Alignment.Center) {
                Text("Festival not found", style = MaterialTheme.typography.bodyMedium)
            }
            return@Scaffold
        }

        LazyColumn(
            modifier = Modifier.fillMaxSize().padding(padding),
            contentPadding = PaddingValues(start = 16.dp, end = 16.dp, bottom = 32.dp)
        ) {
            item {
                Column {
                    Text(festival.name, style = MaterialTheme.typography.bodyMedium)
                    Spacer(Modifier.height(12.dp))
                    OutlinedBlock {
                        Row(
                            Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            Text(festival.date.formatLong(), style = MaterialTheme.typography.titleMedium)
                        }
                        if (festival.isMockCalculated) {
                            Spacer(Modifier.height(6.dp))
                            Text(
                                "Estimated date — outside the range covered by the cited almanac.",
                                style = MaterialTheme.typography.bodySmall
                            )
                        }
                    }
                }
            }

            section("ప్రాముఖ్యత", "Significance", festival.significance)
            section("ఆచరణ", "Observance", festival.observance)
            section("సన్నాహం", "Preparation", festival.preparation)

            item {
                Spacer(Modifier.height(24.dp))
                Text("మంత్రం  ·  Mantra", style = MaterialTheme.typography.headlineSmall)
                Spacer(Modifier.height(8.dp))
                Box(
                    Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(12.dp))
                        .background(Ink.Wash)
                        .padding(14.dp)
                ) {
                    Text(
                        "Mantra text withheld pending citation from a verified traditional source.",
                        style = MaterialTheme.typography.bodyMedium,
                        color = Ink.Secondary
                    )
                }
            }

            item {
                Spacer(Modifier.height(24.dp))
                Text("ఆధారాలు  ·  Sources", style = MaterialTheme.typography.headlineSmall)
                Spacer(Modifier.height(8.dp))
            }
            items(festival.sources + festival.mantraSources) { source ->
                SourceReferenceCard(source, Modifier.padding(bottom = 8.dp))
            }
        }
    }
}

private fun androidx.compose.foundation.lazy.LazyListScope.section(
    telugu: String,
    english: String,
    body: String
) = item {
    Spacer(Modifier.height(24.dp))
    Text("$telugu  ·  $english", style = MaterialTheme.typography.headlineSmall)
    Spacer(Modifier.height(8.dp))
    Text(body, style = MaterialTheme.typography.bodyLarge)
}
