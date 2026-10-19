package com.panchangam.telugupanchangam.ui.day

import com.panchangam.telugupanchangam.domain.Festival
import com.panchangam.telugupanchangam.domain.PanchangDay
import com.panchangam.telugupanchangam.ui.components.formatLong
import com.panchangam.telugupanchangam.ui.components.formatTime
import com.panchangam.telugupanchangam.ui.components.teluguDayMonth

/** A plain-text day summary for the system share sheet. */
fun shareText(day: PanchangDay, festivals: List<Festival>, use24Hour: Boolean): String {
    fun t(x: java.time.LocalDateTime) = x.formatTime(use24Hour) + if (x.toLocalDate() != day.date) " (+1)" else ""
    val rahu = day.inauspicious.first()
    val yama = day.inauspicious[1]
    return buildString {
        appendLine("🗓 ${day.date.teluguDayMonth()} ${day.date.year}, ${day.vara.telugu} — ${day.date.formatLong()}")
        appendLine("శ్రీ ${day.samvatsara.telugu} నామ సంవత్సరం, ${day.ayana.telugu}, ${day.ritu.telugu}")
        appendLine("${day.lunarMonth.telugu}, ${day.paksha.telugu}")
        appendLine("తిథి: ${day.tithi.telugu} ${t(day.tithis.first().end)} వరకు")
        appendLine("నక్షత్రం: ${day.nakshatra.telugu} ${t(day.nakshatras.first().end)} వరకు")
        appendLine("యోగం: ${day.yoga.telugu} · కరణం: ${day.karana.telugu}")
        appendLine("సూర్యోదయం ${t(day.sunrise)} · సూర్యాస్తమయం ${t(day.sunset)}")
        appendLine("రాహు కాలం ${t(rahu.start)}–${t(rahu.end)} · యమగండం ${t(yama.start)}–${t(yama.end)}")
        festivals.forEach { appendLine("🪔 ${it.teluguName} (${it.name})") }
        append("— ${day.city.name}, Telugu Panchangam")
    }
}
