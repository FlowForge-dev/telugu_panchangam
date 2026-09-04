package com.panchangam.telugupanchangam.ui.about

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.panchangam.telugupanchangam.data.FestivalData
import com.panchangam.telugupanchangam.domain.SourceReference
import com.panchangam.telugupanchangam.ui.components.OutlinedBlock
import com.panchangam.telugupanchangam.ui.components.SourceReferenceCard
import com.panchangam.telugupanchangam.ui.theme.Ink

@Composable
fun AboutScreen() {
    val sources: List<SourceReference> = remember {
        listOf(FestivalData.drikPanchang2026, FestivalData.pendingAlmanac, FestivalData.pendingMantra)
    }

    LazyColumn(
        modifier = Modifier.fillMaxSize().background(Ink.White),
        contentPadding = PaddingValues(start = 16.dp, end = 16.dp, top = 16.dp, bottom = 32.dp)
    ) {
        item {
            Text("గురించి", style = MaterialTheme.typography.headlineMedium)
            Text("About & sources", style = MaterialTheme.typography.bodySmall)
            Spacer(Modifier.height(4.dp))
            Text("Version 1.0.0 (development preview)", style = MaterialTheme.typography.bodySmall)
            Spacer(Modifier.height(20.dp))
        }

        item {
            InfoCard(
                "About this build",
                "Festival dates from 19 Mar 2026 through 24 Dec 2026 are taken from a real published almanac " +
                    "(cited below). Daily Tithi, Nakshatra, Yoga, Karana, sunrise/sunset and Choghadiya values " +
                    "are produced by a development placeholder, not a verified astronomical engine — anything " +
                    "labelled \"Preview calculation\" should not be relied on for religious observance."
            )
        }

        item {
            InfoCard(
                "How we handle provenance",
                "Every festival date, rule and mantra in this app is meant to carry a source — title, edition, " +
                    "language and a verification status. Where a qualified citation has not been reviewed, the " +
                    "content is withheld and marked [VERIFIED CONTENT REQUIRED] rather than guessed at."
            )
        }

        item {
            InfoCard(
                "Privacy",
                "This app stores nothing about you and makes no network requests. There is no account, no " +
                    "analytics and no backend."
            )
        }

        item {
            Spacer(Modifier.height(24.dp))
            Text("ఆధారాలు  ·  Sources", style = MaterialTheme.typography.headlineSmall)
            Spacer(Modifier.height(8.dp))
        }
        items(sources) { source ->
            SourceReferenceCard(source, Modifier.padding(bottom = 8.dp))
        }
    }
}

@Composable
private fun InfoCard(title: String, body: String) {
    Column(Modifier.padding(bottom = 12.dp)) {
        OutlinedBlock {
            Text(title, style = MaterialTheme.typography.titleMedium)
            Spacer(Modifier.height(6.dp))
            Text(body, style = MaterialTheme.typography.bodyMedium)
        }
    }
}
