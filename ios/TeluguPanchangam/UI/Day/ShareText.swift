import Foundation

/// A plain-text day summary for the system share sheet.
func shareText(_ day: PanchangDay, festivals: [Festival], use24Hour: Bool) -> String {
    let clock = Clock(use24Hour: use24Hour, zone: day.city.zone)
    func t(_ x: Date) -> String {
        clock.time(x) + (CivilDate(x, in: day.city.zone) != day.date ? " (+1)" : "")
    }
    let rahu = day.inauspicious[0]
    let yama = day.inauspicious[1]
    var lines: [String] = [
        "🗓 \(day.date.teluguDayMonth) \(day.date.year), \(day.vara.telugu) — \(day.date.formatLong)",
        "శ్రీ \(day.samvatsara.telugu) నామ సంవత్సరం, \(day.ayana.telugu), \(day.ritu.telugu)",
        "\(day.lunarMonth.telugu), \(day.paksha.telugu)",
        "తిథి: \(day.tithi.telugu) \(t(day.tithis[0].end)) వరకు",
        "నక్షత్రం: \(day.nakshatra.telugu) \(t(day.nakshatras[0].end)) వరకు",
        "యోగం: \(day.yoga.telugu) · కరణం: \(day.karana.telugu)",
        "సూర్యోదయం \(t(day.sunrise)) · సూర్యాస్తమయం \(t(day.sunset))",
        "రాహు కాలం \(t(rahu.start))–\(t(rahu.end)) · యమగండం \(t(yama.start))–\(t(yama.end))",
    ]
    for f in festivals { lines.append("🪔 \(f.teluguName) (\(f.name))") }
    lines.append("— \(day.city.name), Telugu Panchangam")
    return lines.joined(separator: "\n")
}
