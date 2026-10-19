package com.panchangam.telugupanchangam.ui.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.OpenInNew
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.platform.LocalUriHandler
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.panchangam.telugupanchangam.domain.SourceReference
import com.panchangam.telugupanchangam.domain.VerificationStatus
import com.panchangam.telugupanchangam.ui.LocalAppSettings
import com.panchangam.telugupanchangam.ui.theme.Ink
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import java.util.Locale
import kotlin.math.abs
import kotlin.math.cos

// ---------------------------------------------------------------------
// Formatting
// ---------------------------------------------------------------------

private val shortDate: DateTimeFormatter = DateTimeFormatter.ofPattern("d MMM yyyy", Locale.ENGLISH)
private val longDate: DateTimeFormatter = DateTimeFormatter.ofPattern("EEEE, d MMMM yyyy", Locale.ENGLISH)
private val dayMonth: DateTimeFormatter = DateTimeFormatter.ofPattern("d MMM", Locale.ENGLISH)
private val weekdayShort: DateTimeFormatter = DateTimeFormatter.ofPattern("EEE", Locale.ENGLISH)
private val time12: DateTimeFormatter = DateTimeFormatter.ofPattern("h:mm a", Locale.ENGLISH)
private val time24: DateTimeFormatter = DateTimeFormatter.ofPattern("HH:mm", Locale.ENGLISH)

val teluguMonths = listOf(
    "జనవరి", "ఫిబ్రవరి", "మార్చి", "ఏప్రిల్", "మే", "జూన్",
    "జూలై", "ఆగస్టు", "సెప్టెంబరు", "అక్టోబరు", "నవంబరు", "డిసెంబరు"
)

fun LocalDate.formatShort(): String = format(shortDate)
fun LocalDate.formatLong(): String = format(longDate)
fun LocalDate.formatDayMonth(): String = format(dayMonth)
fun LocalDate.formatWeekdayShort(): String = format(weekdayShort)
fun LocalDate.teluguMonthYear(): String = "${teluguMonths[monthValue - 1]} $year"
fun LocalDate.teluguDayMonth(): String = "$dayOfMonth ${teluguMonths[monthValue - 1]}"

fun LocalDateTime.formatTime(use24Hour: Boolean): String = format(if (use24Hour) time24 else time12)

/**
 * A clock time relative to the civil day [day]: times on the next or
 * previous day get a small marker so a sunrise-to-sunrise span reads
 * correctly.
 */
@Composable
fun timeLabel(time: LocalDateTime, day: LocalDate): String {
    val base = time.formatTime(LocalAppSettings.current.use24Hour)
    return when (time.toLocalDate().toEpochDay() - day.toEpochDay()) {
        0L -> base
        1L -> "$base (+1)"
        -1L -> "$base (−1)"
        else -> "$base · ${time.toLocalDate().formatDayMonth()}"
    }
}

/** "in 3 days" style countdown, Telugu first. */
fun countdownLabel(today: LocalDate, date: LocalDate): String {
    val days = date.toEpochDay() - today.toEpochDay()
    return when {
        days == 0L -> "ఈరోజు"
        days == 1L -> "రేపు"
        days > 1L -> "$days రోజుల్లో"
        days == -1L -> "నిన్న"
        else -> "${-days} రోజుల క్రితం"
    }
}

// ---------------------------------------------------------------------
// Containers
// ---------------------------------------------------------------------

/** A section title: Telugu leading, English as a small caption beside it. */
@Composable
fun SectionHeader(
    telugu: String,
    english: String,
    modifier: Modifier = Modifier,
    trailing: (@Composable () -> Unit)? = null
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .padding(start = 20.dp, end = 20.dp, top = 28.dp, bottom = 10.dp),
        verticalAlignment = Alignment.Bottom
    ) {
        Text(telugu, style = MaterialTheme.typography.titleLarge, color = Ink.current.strong)
        Text(
            "  ${english.uppercase()}",
            style = MaterialTheme.typography.labelSmall,
            color = Ink.current.faint,
            modifier = Modifier.padding(bottom = 3.dp).weight(1f)
        )
        trailing?.invoke()
    }
}

/** A hairline-bordered card — the main container style in the app. */
@Composable
fun OutlinedBlock(
    modifier: Modifier = Modifier,
    padding: Dp = 16.dp,
    onClick: (() -> Unit)? = null,
    content: @Composable ColumnScope.() -> Unit
) {
    val ink = Ink.current
    Column(
        modifier = modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(18.dp))
            .background(ink.page)
            .border(1.dp, ink.line, RoundedCornerShape(18.dp))
            .then(if (onClick != null) Modifier.clickable(onClick = onClick) else Modifier)
            .padding(padding),
        content = content
    )
}

/** A filled, inverted card for the single most important block on a screen. */
@Composable
fun InvertedBlock(
    modifier: Modifier = Modifier,
    content: @Composable ColumnScope.() -> Unit
) {
    val ink = Ink.current
    Column(
        modifier = modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(24.dp))
            .background(if (ink.isDark) ink.wash else ink.strong)
            .border(1.dp, if (ink.isDark) ink.line else ink.strong, RoundedCornerShape(24.dp))
            .padding(20.dp),
        content = content
    )
}

/** One label/value row, used across the day-detail tables. */
@Composable
fun DetailRow(label: String, value: String, sub: String? = null, labelSub: String? = null, emphasised: Boolean = false) {
    val ink = Ink.current
    Row(
        modifier = Modifier.fillMaxWidth().padding(vertical = 9.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.Top
    ) {
        Column(Modifier.weight(1f)) {
            Text(label, style = MaterialTheme.typography.bodyMedium, color = ink.secondary)
            if (labelSub != null) Text(labelSub, style = MaterialTheme.typography.labelSmall, color = ink.faint)
        }
        Spacer(Modifier.width(12.dp))
        Column(horizontalAlignment = Alignment.End) {
            Text(
                value,
                style = MaterialTheme.typography.titleMedium,
                color = ink.strong,
                fontWeight = if (emphasised) FontWeight.Bold else FontWeight.SemiBold
            )
            if (sub != null) Text(sub, style = MaterialTheme.typography.bodySmall, color = ink.secondary)
        }
    }
}

@Composable
fun ThinDivider(modifier: Modifier = Modifier) {
    HorizontalDivider(modifier = modifier, thickness = 1.dp, color = Ink.current.lineFaint)
}

/** A small rounded tag. [filled] inverts it for emphasis. */
@Composable
fun Pill(text: String, filled: Boolean = false, modifier: Modifier = Modifier) {
    val ink = Ink.current
    Box(
        modifier = modifier
            .clip(RoundedCornerShape(50))
            .background(if (filled) ink.strong else ink.page)
            .border(1.dp, if (filled) ink.strong else ink.line, RoundedCornerShape(50))
            .padding(horizontal = 10.dp, vertical = 3.dp)
    ) {
        Text(
            text,
            style = MaterialTheme.typography.labelSmall,
            color = if (filled) ink.page else ink.secondary,
            maxLines = 1
        )
    }
}

// ---------------------------------------------------------------------
// Provenance
// ---------------------------------------------------------------------

fun VerificationStatus.teluguLabel(): String = when (this) {
    VerificationStatus.VERIFIED -> "ధృవీకరించబడింది"
    VerificationStatus.VARIES_BY_TRADITION -> "సంప్రదాయాన్ని బట్టి మారుతుంది"
    VerificationStatus.COMPUTED -> "గణించబడింది"
    VerificationStatus.PENDING_VERIFICATION -> "ధృవీకరణ పెండింగ్"
}

fun VerificationStatus.englishLabel(): String = when (this) {
    VerificationStatus.VERIFIED -> "Verified"
    VerificationStatus.VARIES_BY_TRADITION -> "Varies by tradition"
    VerificationStatus.COMPUTED -> "Computed"
    VerificationStatus.PENDING_VERIFICATION -> "Pending verification"
}

@Composable
fun StatusBadge(status: VerificationStatus, modifier: Modifier = Modifier) {
    Pill(status.englishLabel(), filled = status == VerificationStatus.VERIFIED, modifier = modifier)
}

/**
 * Renders a [SourceReference] with its verification status spelled out,
 * and a link when the source is online.
 */
@Composable
fun SourceReferenceCard(source: SourceReference, modifier: Modifier = Modifier) {
    val ink = Ink.current
    val uriHandler = LocalUriHandler.current
    Column(
        modifier = modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(14.dp))
            .background(ink.wash)
            .then(
                if (source.url != null) Modifier.clickable { runCatching { uriHandler.openUri(source.url) } }
                else Modifier
            )
            .padding(14.dp)
    ) {
        Row(verticalAlignment = Alignment.Top) {
            Column(Modifier.weight(1f)) {
                source.publisher?.let {
                    Text(it, style = MaterialTheme.typography.labelMedium, color = ink.secondary)
                }
                Text(source.title, style = MaterialTheme.typography.titleSmall, color = ink.strong)
            }
            Spacer(Modifier.width(8.dp))
            StatusBadge(source.status)
        }
        source.edition?.let {
            Text(it, style = MaterialTheme.typography.bodySmall, color = ink.secondary, modifier = Modifier.padding(top = 6.dp))
        }
        source.notes?.let {
            Text(it, style = MaterialTheme.typography.bodySmall, color = ink.secondary, modifier = Modifier.padding(top = 6.dp))
        }
        source.url?.let {
            Row(Modifier.padding(top = 8.dp), verticalAlignment = Alignment.CenterVertically) {
                Icon(Icons.AutoMirrored.Filled.OpenInNew, contentDescription = null, tint = ink.secondary, modifier = Modifier.size(14.dp))
                Spacer(Modifier.width(6.dp))
                Text(
                    it.removePrefix("https://").removePrefix("www."),
                    style = MaterialTheme.typography.labelMedium,
                    color = ink.secondary,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            }
        }
    }
}

// ---------------------------------------------------------------------
// Moon phase
// ---------------------------------------------------------------------

/**
 * The Moon as seen from the northern hemisphere for a Moon−Sun
 * elongation in degrees (0 = new, 180 = full). Drawn in ink only.
 */
@Composable
fun MoonPhase(
    elongation: Double,
    size: Dp,
    modifier: Modifier = Modifier,
    lit: androidx.compose.ui.graphics.Color = Ink.current.strong,
    dark: androidx.compose.ui.graphics.Color = Ink.current.page,
    rim: androidx.compose.ui.graphics.Color = Ink.current.disabled
) {
    Canvas(modifier.size(size)) {
        val r = this.size.minDimension / 2
        val c = Offset(this.size.width / 2, this.size.height / 2)
        val e = ((elongation % 360) + 360) % 360
        val waxing = e < 180
        val terminatorWidth = (r * abs(cos(Math.toRadians(e)))).toFloat()
        val gibbous = e in 90.0..270.0

        drawCircle(dark, r, c)
        drawArc(
            color = lit,
            startAngle = if (waxing) -90f else 90f,
            sweepAngle = 180f,
            useCenter = true,
            topLeft = Offset(c.x - r, c.y - r),
            size = Size(2 * r, 2 * r)
        )
        drawOval(
            color = if (gibbous) lit else dark,
            topLeft = Offset(c.x - terminatorWidth, c.y - r),
            size = Size(2 * terminatorWidth, 2 * r)
        )
        drawCircle(rim, r, c, style = Stroke(width = 1.dp.toPx()))
    }
}
