package com.panchangam.telugupanchangam.ui.more

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.RadioButton
import androidx.compose.material3.RadioButtonDefaults
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.unit.dp
import com.panchangam.telugupanchangam.data.FestivalData
import com.panchangam.telugupanchangam.ui.AppSettings
import com.panchangam.telugupanchangam.ui.components.OutlinedBlock
import com.panchangam.telugupanchangam.ui.components.SectionHeader
import com.panchangam.telugupanchangam.ui.components.SourceReferenceCard
import com.panchangam.telugupanchangam.ui.components.ThinDivider
import com.panchangam.telugupanchangam.ui.theme.Ink
import com.panchangam.telugupanchangam.ui.theme.ThemeMode

/** Settings, methodology, sources and privacy. */
@Composable
fun MoreScreen(
    settings: AppSettings,
    onSettingsChange: (AppSettings) -> Unit,
    onPickCity: () -> Unit,
    versionName: String
) {
    val ink = Ink.current
    LazyColumn(
        modifier = Modifier.fillMaxSize().background(ink.page).statusBarsPadding(),
        contentPadding = PaddingValues(bottom = 40.dp)
    ) {
        item {
            Column(Modifier.padding(start = 20.dp, end = 20.dp, top = 16.dp)) {
                Text("మరిన్ని", style = MaterialTheme.typography.headlineMedium, color = ink.strong)
                Text("Settings, method & sources", style = MaterialTheme.typography.bodySmall, color = ink.secondary)
            }
        }

        item { SectionHeader("ప్రదేశం", "Location") }
        item {
            OutlinedBlock(Modifier.padding(horizontal = 16.dp), onClick = onPickCity) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Column(Modifier.weight(1f)) {
                        Text(settings.city.telugu, style = MaterialTheme.typography.titleMedium, color = ink.strong)
                        Text(
                            "${settings.city.name}, ${settings.city.region} · ${settings.city.zoneId}",
                            style = MaterialTheme.typography.bodySmall,
                            color = ink.secondary
                        )
                    }
                    Icon(Icons.AutoMirrored.Filled.KeyboardArrowRight, contentDescription = "Change city", tint = ink.secondary)
                }
            }
        }

        item { SectionHeader("రూపం", "Appearance") }
        item {
            OutlinedBlock(Modifier.padding(horizontal = 16.dp), padding = 6.dp) {
                listOf(
                    ThemeMode.SYSTEM to ("సిస్టమ్ ప్రకారం" to "Follow system"),
                    ThemeMode.LIGHT to ("తెలుపు" to "Light"),
                    ThemeMode.DARK to ("నలుపు" to "Dark")
                ).forEach { (mode, labels) ->
                    Row(
                        Modifier
                            .fillMaxWidth()
                            .clip(RoundedCornerShape(12.dp))
                            .clickable { onSettingsChange(settings.copy(theme = mode)) }
                            .padding(horizontal = 6.dp, vertical = 2.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        RadioButton(
                            selected = settings.theme == mode,
                            onClick = { onSettingsChange(settings.copy(theme = mode)) },
                            colors = RadioButtonDefaults.colors(selectedColor = ink.strong, unselectedColor = ink.faint)
                        )
                        Text(labels.first, style = MaterialTheme.typography.bodyLarge, color = ink.strong)
                        Text("  ${labels.second}", style = MaterialTheme.typography.bodySmall, color = ink.secondary)
                    }
                }
                ThinDivider(Modifier.padding(vertical = 4.dp))
                Row(
                    Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(12.dp))
                        .clickable { onSettingsChange(settings.copy(use24Hour = !settings.use24Hour)) }
                        .padding(horizontal = 14.dp, vertical = 8.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column(Modifier.weight(1f)) {
                        Text("24 గంటల సమయం", style = MaterialTheme.typography.bodyLarge, color = ink.strong)
                        Text("24-hour clock", style = MaterialTheme.typography.bodySmall, color = ink.secondary)
                    }
                    Switch(
                        checked = settings.use24Hour,
                        onCheckedChange = { onSettingsChange(settings.copy(use24Hour = it)) },
                        colors = SwitchDefaults.colors(
                            checkedThumbColor = ink.page,
                            checkedTrackColor = ink.strong,
                            uncheckedThumbColor = ink.faint,
                            uncheckedTrackColor = ink.wash,
                            uncheckedBorderColor = ink.line
                        )
                    )
                }
            }
        }

        item { SectionHeader("గణన విధానం", "How it is calculated") }
        item {
            InfoCard(
                "Computed on your phone, for your city",
                "Tithi, nakshatra, yoga, karana, the lunar month, sunrise, sunset, moonrise and moonset are computed " +
                    "astronomically for the chosen city, for any date: Sun and Moon positions from Jean Meeus's " +
                    "Astronomical Algorithms, the Lahiri (Chitrapaksha) ayanamsa used by Indian national Panchangams, " +
                    "and amanta months with adhika-masa detection. Results were checked against the Swiss Ephemeris " +
                    "for every day of 2026–27: all transition times agree to about a minute."
            )
        }
        item {
            InfoCard(
                "Conventions",
                "The day runs from sunrise to sunrise and is named by the tithi at sunrise. Sunrise is the upper " +
                    "limb on the horizon with standard refraction. Rahu Kalam, Yamagandam and Gulika divide daylight " +
                    "into eight parts by weekday; Abhijit is the 8th of 15 day muhurtas; Brahma Muhurtam is the 14th " +
                    "of 15 night muhurtas; Choghadiya divides day and night into eight each. Local almanacs may differ " +
                    "by a minute or two through their choice of sunrise definition."
            )
        }
        item {
            InfoCard(
                "Not included",
                "Varjyam, Amrita Kalam and Durmuhurtam are not shown: their tables vary between almanacs and were not " +
                    "verified for this release. Mantra text and step-by-step ritual are withheld without a cited " +
                    "traditional source."
            )
        }

        item { SectionHeader("పండుగ తేదీలు", "Festival dates") }
        item {
            InfoCard(
                "Where festival dates come from",
                "Festival dates for Parabhava Samvatsara (${FestivalData.ugadiStart} – ${FestivalData.nextUgadi}) are " +
                    "taken first from Sri Sringeri Sharada Peetham's own announcements, then from the Andhra Pradesh " +
                    "and Telangana government holiday orders, then from the Drik Panchang 2026 calendar — and each was " +
                    "re-checked against the computed tithi. Each festival shows its sources and a status: Verified, " +
                    "Varies by tradition, Computed, or Pending verification. Festival dates follow the Telugu-state " +
                    "observance; outside India, local temples may observe some festivals a day earlier or later."
            )
        }
        FestivalData.allSources.forEach { source ->
            item { SourceReferenceCard(source, Modifier.padding(start = 16.dp, end = 16.dp, bottom = 8.dp)) }
        }

        item { SectionHeader("గోప్యత", "Privacy") }
        item {
            InfoCard(
                "Nothing leaves your phone",
                "No account, no analytics, no network requests. Your city and display preferences are stored only on " +
                    "this device."
            )
        }
        item {
            Text(
                "Telugu Panchangam $versionName · ఈ యాప్ సమాచారం కోసం మాత్రమే — ముఖ్యమైన కార్యాలకు మీ పురోహితులను సంప్రదించండి.",
                style = MaterialTheme.typography.labelSmall,
                color = ink.faint,
                modifier = Modifier.padding(start = 20.dp, end = 20.dp, top = 20.dp)
            )
        }
    }
}

@Composable
private fun InfoCard(title: String, body: String) {
    Column(Modifier.padding(start = 16.dp, end = 16.dp, bottom = 10.dp)) {
        OutlinedBlock {
            Text(title, style = MaterialTheme.typography.titleMedium, color = Ink.current.strong)
            Spacer(Modifier.height(6.dp))
            Text(body, style = MaterialTheme.typography.bodyMedium, color = Ink.current.body)
        }
    }
}
