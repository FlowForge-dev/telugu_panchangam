import SwiftUI

/// Home: today's Panchangam for the chosen city, with live timings.
struct TodayView: View {
    @Environment(\.ink) private var ink
    @EnvironmentObject private var settings: AppSettings

    var body: some View {
        // Ticks every 30 s so "now" highlights and the day rollover stay current.
        TimelineView(.periodic(from: Date(), by: 30)) { context in
            content(now: context.date)
        }
        .background(ink.page.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    private func content(now: Date) -> some View {
        let city = settings.city
        let today = CivilDate(now, in: city.zone)
        let day = PanchangRepository.shared.dayDetail(today, city)
        let festivals = FestivalRepository.shared.onDate(today)
        let upcoming = FestivalRepository.shared.upcoming(from: today.plusDays(1), limit: 4)

        return ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("\(today.teluguDayMonth), \(day.vara.telugu)")
                            .font(AppFont.headlineMedium)
                            .foregroundColor(ink.strong)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        Text(today.formatLong).font(AppFont.bodySmall).foregroundColor(ink.secondary)
                    }
                    Spacer(minLength: 8)
                    ShareLink(item: shareText(day, festivals: festivals, use24Hour: settings.use24Hour)) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(ink.strong)
                            .frame(width: 44, height: 44)
                    }
                    .accessibilityLabel("Share today's Panchangam")
                }
                .padding(.leading, 20)
                .padding(.trailing, 8)
                .padding(.top, 12)
                .padding(.bottom, 8)

                NavigationLink(value: Route.cities) {
                    CityChip(telugu: city.telugu, english: city.name)
                }
                .buttonStyle(.plain)
                .padding(.leading, 20)
                .padding(.bottom, 8)

                PanchangDayContent(day: day, festivals: festivals, now: now)

                if !upcoming.isEmpty {
                    SectionHeader("రాబోయే పండుగలు", "Coming up")
                    OutlinedBlock(padding: 4) {
                        ForEach(Array(upcoming.enumerated()), id: \.element.id) { i, f in
                            if i > 0 { ThinDivider().padding(.horizontal, 12) }
                            NavigationLink(value: Route.festival(f.id)) {
                                UpcomingRow(festival: f, countdown: countdownLabel(today, f.date))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.bottom, 32)
        }
    }
}

private struct CityChip: View {
    @Environment(\.ink) private var ink
    let telugu: String
    let english: String

    var body: some View {
        HStack(spacing: 0) {
            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(ink.strong)
            Text(telugu).font(AppFont.labelLarge).foregroundColor(ink.strong).padding(.leading, 6)
            Text("  \(english)").font(AppFont.labelMedium).foregroundColor(ink.secondary)
        }
        .padding(.leading, 10)
        .padding(.trailing, 14)
        .padding(.vertical, 6)
        .overlay(Capsule().stroke(ink.line, lineWidth: 1))
        .contentShape(Capsule())
    }
}

private struct UpcomingRow: View {
    @Environment(\.ink) private var ink
    let festival: Festival
    let countdown: String

    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 0) {
                Text(festival.teluguName).font(AppFont.titleMedium).foregroundColor(ink.strong)
                Text("\(festival.name) · \(festival.date.formatShort)").font(AppFont.bodySmall).foregroundColor(ink.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Pill(text: countdown)
        }
        .padding(12)
        .contentShape(Rectangle())
    }
}
