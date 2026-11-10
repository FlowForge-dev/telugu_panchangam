import SwiftUI

private let firstMonth = CivilDate(2000, 1, 1)
private let monthPages = 12 * 51 // Jan 2000 – Dec 2050

/// Month grid in the style of a general-purpose calendar app: a clean
/// page, hairline cells, today marked by a filled disc, the tithi under
/// each date, moon glyphs on Purnima and Amavasya, and festival tags.
/// Swipe sideways to change month.
struct CalendarView: View {
    @Environment(\.ink) private var ink
    @EnvironmentObject private var settings: AppSettings

    @State private var page: Int?
    @State private var forward = true

    private var today: CivilDate { CivilDate.today(in: settings.city.zone) }

    private var todayPage: Int {
        let t = today
        return min(max((t.year - firstMonth.year) * 12 + t.month - 1, 0), monthPages - 1)
    }

    private var currentPage: Int { page ?? todayPage }
    private var shownMonth: CivilDate { firstMonth.plusMonths(currentPage) }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(shownMonth.teluguMonthYear)
                        .font(AppFont.headlineMedium)
                        .foregroundColor(ink.strong)
                        .lineLimit(1)
                    Text(shownMonth.englishMonthYear).font(AppFont.bodySmall).foregroundColor(ink.secondary)
                }
                Spacer(minLength: 8)
                if currentPage != todayPage {
                    Button("ఈరోజు") { go(to: todayPage) }
                        .font(AppFont.labelLarge)
                        .foregroundColor(ink.strong)
                        .padding(.horizontal, 8)
                }
                Button { go(to: currentPage - 1) } label: {
                    Image(systemName: "chevron.left").frame(width: 40, height: 40)
                }
                .accessibilityLabel("Previous month")
                Button { go(to: currentPage + 1) } label: {
                    Image(systemName: "chevron.right").frame(width: 40, height: 40)
                }
                .accessibilityLabel("Next month")
            }
            .foregroundColor(ink.strong)
            .padding(.leading, 20)
            .padding(.trailing, 4)
            .padding(.top, 12)
            .padding(.bottom, 4)

            ScrollView {
                MonthPage(month: shownMonth, city: settings.city, today: today)
                    .id(currentPage)
                    .transition(pageTransition(forward: forward))
            }
            .horizontalSwipe { go(to: currentPage + $0) }
        }
        .background(ink.page.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    private func go(to target: Int) {
        let clamped = min(max(target, 0), monthPages - 1)
        guard clamped != currentPage else { return }
        forward = clamped > currentPage
        withAnimation(.easeInOut(duration: 0.25)) { page = clamped }
    }
}

private struct MonthPage: View {
    @Environment(\.ink) private var ink
    let month: CivilDate
    let city: City
    let today: CivilDate

    @State private var summaries: [CivilDate: DaySummary] = [:]

    var body: some View {
        let first = month.firstOfMonth
        let lead = first.weekdayIndex
        let gridStart = first.plusDays(-lead)
        let rows = (lead + month.lengthOfMonth + 6) / 7
        let festivals = (1...month.lengthOfMonth).flatMap {
            FestivalRepository.shared.onDate(CivilDate(month.year, month.month, $0))
        }
        let festivalsByDate = Dictionary(grouping: festivals, by: { $0.date })
        let lunarMonths = distinctMonths()

        VStack(alignment: .leading, spacing: 0) {
            Text(lunarMonths.isEmpty ? " " : lunarMonths.map { $0.telugu }.joined(separator: "  –  "))
                .font(AppFont.labelLarge)
                .foregroundColor(ink.secondary)
                .padding(.horizontal, 20)
                .padding(.bottom, 10)

            HStack(spacing: 0) {
                ForEach(Vara.allCases, id: \.self) { vara in
                    Text(vara.short)
                        .font(AppFont.labelMedium)
                        .foregroundColor(vara == .sunday ? ink.strong : ink.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)

            VStack(spacing: 0) {
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<7, id: \.self) { col in
                            let date = gridStart.plusDays(row * 7 + col)
                            let inMonth = date.month == month.month
                            DayCellLink(
                                date: date,
                                summary: inMonth ? summaries[date] : nil,
                                festivals: inMonth ? (festivalsByDate[date] ?? []) : [],
                                inMonth: inMonth,
                                isToday: date == today
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, 8)

            Legend()

            if !festivals.isEmpty {
                SectionHeader("ఈ నెల పండుగలు", "This month")
                ForEach(Array(festivals.enumerated()), id: \.element.id) { i, f in
                    if i > 0 { ThinDivider().padding(.leading, 76).padding(.trailing, 20) }
                    NavigationLink(value: Route.festival(f.id)) {
                        MonthFestivalRow(festival: f)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.bottom, 24)
        // The month's summaries take a few tens of milliseconds; keep them off the main thread.
        .task(id: "\(month.year)-\(month.month)-\(city.id)") {
            let m = month
            let c = city
            let result = await Task.detached(priority: .userInitiated) {
                PanchangRepository.shared.summaries(m.firstOfMonth, CivilDate(m.year, m.month, m.lengthOfMonth), c)
            }.value
            summaries = result
        }
    }

    private func distinctMonths() -> [LunarMonth] {
        var out: [LunarMonth] = []
        for d in 1...month.lengthOfMonth {
            if let s = summaries[CivilDate(month.year, month.month, d)], !out.contains(s.lunarMonth) {
                out.append(s.lunarMonth)
            }
        }
        return out
    }
}

private struct DayCellLink: View {
    let date: CivilDate
    let summary: DaySummary?
    let festivals: [Festival]
    let inMonth: Bool
    let isToday: Bool

    var body: some View {
        if inMonth {
            NavigationLink(value: Route.day(date)) { cell }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
        } else {
            cell.frame(maxWidth: .infinity)
        }
    }

    private var cell: some View {
        DayCell(date: date, summary: summary, festivals: festivals, inMonth: inMonth, isToday: isToday)
    }
}

private struct DayCell: View {
    @Environment(\.ink) private var ink
    let date: CivilDate
    let summary: DaySummary?
    let festivals: [Festival]
    let inMonth: Bool
    let isToday: Bool

    var body: some View {
        let major = inMonth && festivals.contains { $0.importance == .major }
        VStack(spacing: 0) {
            ZStack {
                Circle().fill(isToday && inMonth ? ink.strong : Color.clear)
                Text("\(date.day)")
                    .font(.system(size: 14, weight: isToday || date.weekdayIndex == 0 ? .bold : .regular))
                    .foregroundColor(!inMonth ? ink.disabled : (isToday ? ink.page : ink.strong))
            }
            .frame(width: 28, height: 28)

            if let summary = summary {
                Text(summary.tithi.telugu)
                    .font(.system(size: 9))
                    .foregroundColor(ink.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .padding(.top, 2)
                    .padding(.bottom, 3)
                if let first = festivals.first {
                    Text(festivalTag(first))
                        .font(.system(size: 8))
                        .foregroundColor(ink.page)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .padding(.horizontal, 2)
                        .padding(.vertical, 1)
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 4).fill(ink.strong))
                        .padding(.horizontal, 1)
                } else if summary.specialDayType == .purnima || summary.specialDayType == .amavasya {
                    MoonPhaseView(elongation: summary.elongation, size: 11)
                } else if summary.specialDayType == .ekadashi {
                    Circle().fill(ink.secondary).frame(width: 6, height: 6)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 2)
        .frame(maxWidth: .infinity)
        .frame(height: 73)
        .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(major ? ink.wash : ink.page))
        .padding(1.5)
        .contentShape(Rectangle())
    }

    private func festivalTag(_ f: Festival) -> String {
        if let r = f.teluguName.range(of: " (") { return String(f.teluguName[..<r.lowerBound]) }
        return f.teluguName
    }
}

private struct Legend: View {
    @Environment(\.ink) private var ink

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 16) {
                HStack(spacing: 0) {
                    MoonPhaseView(elongation: 180, size: 11)
                    Text("  పౌర్ణమి").font(AppFont.labelSmall).foregroundColor(ink.secondary)
                }
                HStack(spacing: 0) {
                    MoonPhaseView(elongation: 0, size: 11)
                    Text("  అమావాస్య").font(AppFont.labelSmall).foregroundColor(ink.secondary)
                }
                HStack(spacing: 0) {
                    Circle().fill(ink.secondary).frame(width: 6, height: 6)
                    Text("  ఏకాదశి").font(AppFont.labelSmall).foregroundColor(ink.secondary)
                }
            }
            .padding(.vertical, 12)
            Text("తిథి సూర్యోదయ సమయానికి · Tithi shown is the one at local sunrise.")
                .font(AppFont.labelSmall)
                .foregroundColor(ink.faint)
        }
        .padding(.horizontal, 20)
    }
}

private struct MonthFestivalRow: View {
    @Environment(\.ink) private var ink
    let festival: Festival

    var body: some View {
        HStack(spacing: 12) {
            VStack(spacing: 0) {
                Text("\(festival.date.day)").font(AppFont.titleMedium).foregroundColor(ink.strong)
                Text(festival.date.formatWeekdayShort.uppercased()).font(AppFont.labelSmall).foregroundColor(ink.faint)
            }
            .frame(width: 44)
            .padding(.vertical, 6)
            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(ink.line, lineWidth: 1))

            VStack(alignment: .leading, spacing: 0) {
                Text(festival.teluguName).font(AppFont.titleMedium).foregroundColor(ink.strong)
                Text(festival.name).font(AppFont.bodySmall).foregroundColor(ink.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Image(systemName: "chevron.right").foregroundColor(ink.faint)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}
