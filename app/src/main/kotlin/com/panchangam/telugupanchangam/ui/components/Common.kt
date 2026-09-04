package com.panchangam.telugupanchangam.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.unit.dp
import com.panchangam.telugupanchangam.domain.SourceReference
import com.panchangam.telugupanchangam.domain.VerificationStatus
import com.panchangam.telugupanchangam.ui.theme.Ink
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import java.util.Locale

private val shortDate: DateTimeFormatter = DateTimeFormatter.ofPattern("d MMM yyyy", Locale.ENGLISH)
private val longDate: DateTimeFormatter = DateTimeFormatter.ofPattern("EEEE, d MMMM yyyy", Locale.ENGLISH)
private val monthYear: DateTimeFormatter = DateTimeFormatter.ofPattern("MMMM yyyy", Locale.ENGLISH)

fun LocalDate.formatShort(): String = format(shortDate)
fun LocalDate.formatLong(): String = format(longDate)
fun LocalDate.formatMonthYear(): String = format(monthYear)

/** A section title: Telugu leading, English as a small caption beside it. */
@Composable
fun SectionHeader(telugu: String, english: String, modifier: Modifier = Modifier) {
    Row(
        modifier = modifier.padding(start = 16.dp, end = 16.dp, top = 24.dp, bottom = 8.dp),
        verticalAlignment = Alignment.Bottom
    ) {
        Text(telugu, style = MaterialTheme.typography.headlineSmall)
        Text(
            "  $english",
            style = MaterialTheme.typography.bodySmall,
            modifier = Modifier.padding(bottom = 2.dp)
        )
    }
}

/** A hairline-bordered white card — the only container style in the app. */
@Composable
fun OutlinedBlock(
    modifier: Modifier = Modifier,
    content: @Composable () -> Unit
) {
    Column(
        modifier = modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .background(Ink.White)
            .border(1.dp, Ink.Line, RoundedCornerShape(12.dp))
            .padding(16.dp)
    ) { content() }
}

/** One label/value row, used across the day-detail tables. */
@Composable
fun DetailRow(label: String, value: String, sub: String? = null) {
    Row(
        modifier = Modifier.fillMaxWidth().padding(vertical = 7.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.Top
    ) {
        Text(label, style = MaterialTheme.typography.bodyMedium, color = Ink.Secondary)
        Column(horizontalAlignment = Alignment.End) {
            Text(value, style = MaterialTheme.typography.titleMedium)
            if (sub != null) Text(sub, style = MaterialTheme.typography.bodySmall)
        }
    }
}

/**
 * Renders a [SourceReference] with its verification status spelled out.
 * Provenance is a first-class feature, so this appears anywhere a
 * religious/calendrical claim is shown.
 */
@Composable
fun SourceReferenceCard(source: SourceReference, modifier: Modifier = Modifier) {
    val statusLabel = when (source.status) {
        VerificationStatus.VERIFIED -> "Verified"
        VerificationStatus.PENDING_VERIFICATION -> "Pending verification"
        VerificationStatus.VARIES_BY_TRADITION -> "Varies by tradition"
    }
    val pending = source.status == VerificationStatus.PENDING_VERIFICATION

    Column(
        modifier = modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .background(Ink.Wash)
            .padding(14.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.Top
        ) {
            Text(
                source.title,
                style = MaterialTheme.typography.titleSmall,
                color = if (pending) Ink.Secondary else Ink.Black,
                fontStyle = if (pending) FontStyle.Italic else FontStyle.Normal,
                modifier = Modifier.weight(1f)
            )
            Text(
                statusLabel,
                style = MaterialTheme.typography.labelSmall,
                color = if (pending) Ink.Secondary else Ink.Black
            )
        }
        listOfNotNull(source.sectionOrChapter, source.edition, source.language)
            .takeIf { it.isNotEmpty() }
            ?.let {
                Text(
                    it.joinToString(" · "),
                    style = MaterialTheme.typography.bodySmall,
                    modifier = Modifier.padding(top = 6.dp)
                )
            }
        source.notes?.let {
            Text(it, style = MaterialTheme.typography.bodySmall, modifier = Modifier.padding(top = 6.dp))
        }
    }
}

/** A subtle marker for values produced by the development mock layer. */
@Composable
fun PreviewDataNote(text: String = "Preview calculation — not a verified Panchangam engine.") {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(8.dp))
            .background(Ink.Wash)
            .padding(horizontal = 12.dp, vertical = 8.dp)
    ) {
        Text(text, style = MaterialTheme.typography.labelSmall, color = Ink.Secondary)
    }
}

@Composable
fun ThinDivider(modifier: Modifier = Modifier) {
    HorizontalDivider(modifier = modifier, thickness = 1.dp, color = Ink.Line)
}
