import SwiftUI

/// The full Panchangam for one day. `now` highlights whichever windows
/// are running, when the day being shown is today.
struct PanchangDayContent: View {
    @Environment(\.ink) private var ink
    @EnvironmentObject private var settings: AppSettings
    let day: PanchangDay
    let festivals: [Festival]
    let now: Date?

    private var live: Date? {
        guard let now = now, now >= day.sunrise, now < day.nextSunrise else { return nil }
        return now
    }

    private var clock: Clock { Clock(use24Hour: settings.use24Hour, zone: day.city.zone) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HeroCard(day: day, clock: clock)
                .padding(.horizontal, 16)
                .padding(.top, 8)

            if !festivals.isEmpty {
                SectionHeader("నేటి పర్వదినం", "Today's occasion")
                ForEach(festivals) { festival in
                    NavigationLink(value: Route.festival(festival.id)) {
                        FestivalRow(festival: festival)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
                }
            }

            if let live = live {
                NowCard(day: day, now: live, clock: clock)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
            }

            SectionHeader("పంచాంగం", "Five limbs")
            OutlinedBlock {
                LimbRow(telugu: "వారం", english: "Vara", value: day.vara.telugu, sub: day.vara.transliteration)
                ThinDivider()
                SpanRows(telugu: "తిథి", english: "Tithi", rows: day.tithis.map {
                    SpanRowData(te: "\($0.item.paksha.teluguShort) \($0.item.telugu)", en: $0.item.label, end: $0.end)
                }, day: day.date, clock: clock)
                ThinDivider()
                SpanRows(telugu: "నక్షత్రం", english: "Nakshatra", rows: day.nakshatras.map {
                    SpanRowData(te: $0.item.telugu, en: $0.item.name, end: $0.end)
                }, day: day.date, clock: clock)
                ThinDivider()
                SpanRows(telugu: "యోగం", english: "Yoga", rows: day.yogas.map {
                    SpanRowData(te: $0.item.telugu, en: $0.item.name, end: $0.end)
                }, day: day.date, clock: clock)
                ThinDivider()
                SpanRows(telugu: "కరణం", english: "Karana", rows: day.karanas.map {
                    SpanRowData(te: $0.item.telugu, en: $0.item.name, end: $0.end)
                }, day: day.date, clock: clock)
            }
            .padding(.horizontal, 16)

            SectionHeader("సూర్య చంద్రులు", "Sun & Moon")
            SunMoonCard(day: day, clock: clock).padding(.horizontal, 16)

            SectionHeader("ముహూర్తాలు", "Timings")
            OutlinedBlock {
                Text("శుభ సమయం · AUSPICIOUS").font(AppFont.labelSmall).foregroundColor(ink.faint)
                ForEach(day.auspicious, id: \.label) { WindowRow(window: $0, day: day.date, now: live, clock: clock) }
                ThinDivider().padding(.vertical, 10)
                Text("వర్జ్య సమయం · AVOID").font(AppFont.labelSmall).foregroundColor(ink.faint)
                ForEach(day.inauspicious, id: \.label) { WindowRow(window: $0, day: day.date, now: live, clock: clock) }
            }
            .padding(.horizontal, 16)

            SectionHeader("రాశులు", "Sidereal signs at sunrise")
            OutlinedBlock {
                HStack(alignment: .top, spacing: 0) {
                    Stat(telugu: "సూర్య రాశి", value: day.sunRashi.telugu, sub: day.sunRashi.name)
                    Stat(telugu: "చంద్ర రాశి", value: day.moonRashi.telugu, sub: day.moonRashi.name)
                }
            }
            .padding(.horizontal, 16)

            SectionHeader("చౌఘడియ", "Choghadiya")
            ChoghadiyaCard(day: day, now: live, clock: clock)
                .id(day.date)
                .padding(.horizontal, 16)

            Text(methodNote)
                .font(AppFont.bodySmall)
                .foregroundColor(ink.faint)
                .padding(.horizontal, 20)
                .padding(.top, 24)
        }
    }

    private var methodNote: String {
        let city = day.city
        let coords = String(format: "%.2f°, %.2f°", city.latitude, city.longitude)
        return "\(city.telugu) · \(city.name) (\(coords)) కోసం గణించబడింది. Computed for this location with the " +
            "Lahiri ayanamsa; the day runs sunrise to sunrise. Times are local (\(city.zoneId))."
    }
}

// MARK: - Hero

private struct HeroCard: View {
    @Environment(\.ink) private var ink
    let day: PanchangDay
    let clock: Clock

    var body: some View {
        InvertedBlock {
            Text("శ్రీ \(day.samvatsara.telugu) నామ సంవత్సరం")
                .font(AppFont.titleMedium)
                .foregroundColor(ink.onCard)
            Text("\(day.samvatsara.name) · Shaka \(String(day.shakaYear)) · \(day.ayana.telugu) · \(day.ritu.telugu)")
                .font(AppFont.bodySmall)
                .foregroundColor(ink.onCardSoft)

            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("\(day.lunarMonth.telugu) · \(day.paksha.telugu)")
                        .font(AppFont.labelLarge)
                        .foregroundColor(ink.onCardSoft)
                    Text(day.tithi.telugu)
                        .font(AppFont.displayMedium)
                        .foregroundColor(ink.onCard)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                    Text(tithiLine)
                        .font(AppFont.bodySmall)
                        .foregroundColor(ink.onCardSoft)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                MoonPhaseView(
                    elongation: day.elongation,
                    size: 64,
                    lit: ink.onCard,
                    dark: ink.cardFill,
                    rim: ink.onCardSoft
                )
            }
            .padding(.top, 20)

            HStack(spacing: 8) {
                HeroChip(text: "\(day.nakshatra.telugu) నక్షత్రం")
                HeroChip(text: day.vara.telugu)
            }
            .padding(.top, 18)
        }
    }

    private var tithiLine: String {
        var s = "\(clock.label(day.tithis[0].end, day: day.date)) వరకు"
        if day.tithis.count > 1 { s += " · తర్వాత \(day.tithis[1].item.telugu)" }
        return s
    }
}

private struct HeroChip: View {
    @Environment(\.ink) private var ink
    let text: String

    var body: some View {
        Text(text)
            .font(AppFont.labelMedium)
            .foregroundColor(ink.onCard)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .overlay(Capsule().stroke(ink.onCardSoft, lineWidth: 1))
    }
}

private struct FestivalRow: View {
    @Environment(\.ink) private var ink
    let festival: Festival

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text(festival.teluguName).font(AppFont.titleMedium).foregroundColor(ink.strong)
                Text(festival.name).font(AppFont.bodySmall).foregroundColor(ink.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Image(systemName: "chevron.right").foregroundColor(ink.secondary)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(ink.wash))
        .contentShape(Rectangle())
    }
}

// MARK: - Now

private struct NowCard: View {
    @Environment(\.ink) private var ink
    let day: PanchangDay
    let now: Date
    let clock: Clock

    var body: some View {
        let chog = (day.dayChoghadiya + day.nightChoghadiya).first { $0.contains(now) }
        let activeWindow = (day.inauspicious + day.auspicious).first { $0.contains(now) }
        let tithi = day.tithis.first { $0.contains(now) }
        let total = day.nextSunrise.timeIntervalSince(day.sunrise)
        let progress = min(max(now.timeIntervalSince(day.sunrise) / total, 0), 1)

        return OutlinedBlock {
            HStack(spacing: 0) {
                Circle().fill(ink.strong).frame(width: 8, height: 8)
                Text("ఇప్పుడు").font(AppFont.titleMedium).foregroundColor(ink.strong).padding(.leading, 8)
                Text("  NOW").font(AppFont.labelSmall).foregroundColor(ink.faint)
            }

            // Sunrise-to-sunrise progress.
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(ink.lineFaint)
                    Rectangle().fill(ink.strong).frame(width: geo.size.width * CGFloat(progress))
                }
                .clipShape(Capsule())
            }
            .frame(height: 6)
            .padding(.top, 12)

            HStack {
                Text(clock.label(day.sunrise, day: day.date))
                Spacer(minLength: 4)
                Text("అస్తమయం \(clock.label(day.sunset, day: day.date))")
                Spacer(minLength: 4)
                Text(clock.label(day.nextSunrise, day: day.date))
            }
            .font(AppFont.labelSmall)
            .foregroundColor(ink.faint)
            .padding(.top, 4)
            .padding(.bottom, 8)

            if let tithi = tithi {
                NowLine(label: "తిథి", value: "\(tithi.item.telugu) · \(clock.label(tithi.end, day: day.date)) వరకు")
            }
            if let chog = chog {
                NowLine(label: "చౌఘడియ",
                        value: "\(chog.telugu) (\(chog.quality.telugu)) · \(clock.label(chog.end, day: day.date)) వరకు")
            }
            if let w = activeWindow {
                NowLine(label: w.teluguLabel,
                        value: "\(w.auspicious ? "నడుస్తోంది" : "జాగ్రత్త") · \(clock.label(w.end, day: day.date)) వరకు",
                        strong: true)
            }
        }
    }
}

private struct NowLine: View {
    @Environment(\.ink) private var ink
    let label: String
    let value: String
    var strong: Bool = false

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text(label)
                .font(AppFont.bodyMedium)
                .foregroundColor(ink.secondary)
                .frame(width: 96, alignment: .leading)
            Text(value)
                .font(.system(size: 14, weight: strong ? .bold : .medium))
                .foregroundColor(ink.strong)
            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Limbs

private struct LimbRow: View {
    @Environment(\.ink) private var ink
    let telugu: String
    let english: String
    let value: String
    let sub: String

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            LimbLabel(telugu: telugu, english: english)
            VStack(alignment: .leading, spacing: 0) {
                Text(value).font(AppFont.titleMedium).foregroundColor(ink.strong)
                Text(sub).font(AppFont.bodySmall).foregroundColor(ink.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 10)
    }
}

private struct LimbLabel: View {
    @Environment(\.ink) private var ink
    let telugu: String
    let english: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(telugu).font(AppFont.bodyMedium).foregroundColor(ink.secondary)
            Text(english.uppercased()).font(AppFont.labelSmall).foregroundColor(ink.faint)
        }
        .frame(width: 92, alignment: .leading)
    }
}

private struct SpanRowData {
    let te: String
    let en: String
    let end: Date
}

/// A limb and everything it passes through between sunrise and the next sunrise.
private struct SpanRows: View {
    @Environment(\.ink) private var ink
    let telugu: String
    let english: String
    let rows: [SpanRowData]
    let day: CivilDate
    let clock: Clock

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            LimbLabel(telugu: telugu, english: english)
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(rows.enumerated()), id: \.offset) { i, row in
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(row.te)
                                .font(i == 0 ? AppFont.titleMedium : AppFont.bodyMedium)
                                .foregroundColor(i == 0 ? ink.strong : ink.body)
                            Text(row.en).font(AppFont.bodySmall).foregroundColor(ink.secondary)
                        }
                        Spacer(minLength: 8)
                        Text("\(clock.label(row.end, day: day)) వరకు")
                            .font(AppFont.labelMedium)
                            .foregroundColor(i == 0 ? ink.strong : ink.secondary)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
        }
        .padding(.vertical, 10)
    }
}

// MARK: - Sun & Moon

private struct SunMoonCard: View {
    @Environment(\.ink) private var ink
    let day: PanchangDay
    let clock: Clock

    var body: some View {
        let minutes = Int(day.sunset.timeIntervalSince(day.sunrise) / 60)
        let h = minutes / 60
        let m = minutes % 60
        return OutlinedBlock {
            HStack(spacing: 0) {
                SunMoonCell(icon: "sun.max.fill", telugu: "సూర్యోదయం", english: "Sunrise",
                            value: clock.label(day.sunrise, day: day.date))
                SunMoonCell(icon: "sunset.fill", telugu: "సూర్యాస్తమయం", english: "Sunset",
                            value: clock.label(day.sunset, day: day.date))
            }
            HStack(spacing: 0) {
                SunMoonCell(icon: "moon.stars.fill", telugu: "చంద్రోదయం", english: "Moonrise",
                            value: day.moonrise.map { clock.label($0, day: day.date) } ?? "—")
                SunMoonCell(icon: "moon.fill", telugu: "చంద్రాస్తమయం", english: "Moonset",
                            value: day.moonset.map { clock.label($0, day: day.date) } ?? "—")
            }
            .padding(.top, 14)
            ThinDivider().padding(.top, 14)
            Text("పగటి సమయం \(h) గం. \(m) ని.  ·  Daylight \(h)h \(m)m")
                .font(AppFont.bodySmall)
                .foregroundColor(ink.secondary)
                .padding(.top, 10)
        }
    }
}

private struct SunMoonCell: View {
    @Environment(\.ink) private var ink
    let icon: String
    let telugu: String
    let english: String
    let value: String

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle().fill(ink.wash)
                Image(systemName: icon).font(.system(size: 15)).foregroundColor(ink.strong)
            }
            .frame(width: 36, height: 36)
            .accessibilityLabel(english)
            VStack(alignment: .leading, spacing: 0) {
                Text(value).font(AppFont.titleMedium).foregroundColor(ink.strong)
                Text(telugu).font(AppFont.labelSmall).foregroundColor(ink.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Timings

private struct WindowRow: View {
    @Environment(\.ink) private var ink
    let window: TimeWindow
    let day: CivilDate
    let now: Date?
    let clock: Clock

    var body: some View {
        let active = now.map { window.contains($0) } ?? false
        return HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text(window.teluguLabel).font(AppFont.bodyMedium).foregroundColor(ink.strong)
                Text(window.label).font(AppFont.labelSmall).foregroundColor(ink.faint)
            }
            Spacer(minLength: 8)
            if active {
                Pill(text: "ఇప్పుడు", filled: true).padding(.trailing, 8)
            }
            Text("\(clock.label(window.start, day: day)) – \(clock.label(window.end, day: day))")
                .font(AppFont.titleSmall)
                .foregroundColor(ink.strong)
        }
        .padding(.horizontal, active ? 10 : 0)
        .padding(.vertical, 6)
        .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(active ? ink.wash : ink.page))
        .padding(.top, 6)
    }
}

private struct Stat: View {
    @Environment(\.ink) private var ink
    let telugu: String
    let value: String
    let sub: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(telugu).font(AppFont.labelMedium).foregroundColor(ink.secondary)
            Text(value).font(AppFont.titleLarge).foregroundColor(ink.strong)
            Text(sub).font(AppFont.bodySmall).foregroundColor(ink.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Choghadiya

private struct ChoghadiyaCard: View {
    @Environment(\.ink) private var ink
    let day: PanchangDay
    let now: Date?
    let clock: Clock
    @State private var night: Bool

    init(day: PanchangDay, now: Date?, clock: Clock) {
        self.day = day
        self.now = now
        self.clock = clock
        _night = State(initialValue: now.map { $0 >= day.sunset } ?? false)
    }

    private func mark(_ q: ChoghadiyaQuality) -> Color {
        switch q {
        case .good: return ink.strong
        case .neutral: return ink.faint
        case .inauspicious: return ink.page
        }
    }

    var body: some View {
        let periods = night ? day.nightChoghadiya : day.dayChoghadiya
        return OutlinedBlock {
            HStack(spacing: 0) {
                segment(isNight: false, label: "పగలు · Day")
                segment(isNight: true, label: "రాత్రి · Night")
            }
            .padding(4)
            .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(ink.wash))
            .padding(.bottom, 8)

            ForEach(Array(periods.enumerated()), id: \.offset) { _, p in
                let active = now.map { p.contains($0) } ?? false
                HStack(spacing: 12) {
                    Dot(size: 10, fill: mark(p.quality), rim: ink.secondary)
                    VStack(alignment: .leading, spacing: 0) {
                        Text("\(p.telugu) · \(p.quality.telugu)").font(AppFont.bodyMedium).foregroundColor(ink.strong)
                        Text(p.name).font(AppFont.labelSmall).foregroundColor(ink.faint)
                    }
                    Spacer(minLength: 4)
                    Text("\(clock.label(p.start, day: day.date)) – \(clock.label(p.end, day: day.date))")
                        .font(AppFont.labelMedium)
                        .foregroundColor(active ? ink.strong : ink.secondary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(active ? ink.wash : ink.page))
                .padding(.top, 4)
            }

            HStack(spacing: 16) {
                ForEach(ChoghadiyaQuality.allCases, id: \.self) { q in
                    HStack(spacing: 0) {
                        Dot(size: 8, fill: mark(q), rim: ink.secondary)
                        Text("  \(q.telugu)").font(AppFont.labelSmall).foregroundColor(ink.faint)
                    }
                }
            }
            .padding(.top, 12)
            .padding(.leading, 10)
        }
    }

    private func segment(isNight: Bool, label: String) -> some View {
        let selected = night == isNight
        return Button {
            night = isNight
        } label: {
            Text(label)
                .font(AppFont.labelLarge)
                .foregroundColor(selected ? ink.strong : ink.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(RoundedRectangle(cornerRadius: 9, style: .continuous).fill(selected ? ink.page : ink.wash))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
