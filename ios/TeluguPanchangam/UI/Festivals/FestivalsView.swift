import SwiftUI

private enum FestivalFilter: CaseIterable {
    case upcoming, major, all

    var telugu: String {
        switch self {
        case .upcoming: return "రాబోయేవి"
        case .major: return "ముఖ్యమైనవి"
        case .all: return "అన్నీ"
        }
    }

    var english: String {
        switch self {
        case .upcoming: return "Upcoming"
        case .major: return "Major"
        case .all: return "All"
        }
    }
}

private struct FestivalMonth: Identifiable {
    let month: CivilDate
    let items: [Festival]

    var id: CivilDate { month }
}

/// The year's festivals and observances, grouped by month.
struct FestivalsView: View {
    @Environment(\.ink) private var ink
    @EnvironmentObject private var settings: AppSettings

    @State private var filter = FestivalFilter.upcoming

    var body: some View {
        let today = CivilDate.today(in: settings.city.zone)
        let all = FestivalRepository.shared.all()
        let shown = filtered(all, today)
        let next = all.first { $0.date >= today }
        let months = grouped(shown)

        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("పండుగలు").font(AppFont.headlineMedium).foregroundColor(ink.strong)
                    Text("శ్రీ పరాభవ నామ సంవత్సరం · Festivals & observances, Ugadi 2026 – Ugadi 2027")
                        .font(AppFont.bodySmall)
                        .foregroundColor(ink.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)

                if let next = next {
                    NavigationLink(value: Route.festival(next.id)) {
                        NextFestivalCard(festival: next, today: today)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 16)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(FestivalFilter.allCases, id: \.self) { f in
                            FilterTab(text: "\(f.telugu) · \(f.english)", selected: filter == f) {
                                filter = f
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }

                if shown.isEmpty {
                    Text("ఈ సంవత్సరపు జాబితాలో మరిన్ని పండుగలు లేవు. The verified list ends at Ugadi 2027.")
                        .font(AppFont.bodyMedium)
                        .foregroundColor(ink.secondary)
                        .padding(20)
                }

                ForEach(months) { group in
                    Text(group.month.teluguMonthYear)
                        .font(AppFont.labelLarge)
                        .foregroundColor(ink.faint)
                        .padding(.leading, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 4)
                    ForEach(Array(group.items.enumerated()), id: \.element.id) { i, festival in
                        if i > 0 { ThinDivider().padding(.leading, 80).padding(.trailing, 20) }
                        NavigationLink(value: Route.festival(festival.id)) {
                            FestivalListItem(festival: festival, today: today)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.bottom, 32)
        }
        .background(ink.page.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    private func filtered(_ all: [Festival], _ today: CivilDate) -> [Festival] {
        switch filter {
        case .upcoming: return all.filter { $0.date >= today }
        case .major: return all.filter { $0.importance == .major }
        case .all: return all
        }
    }

    /// Consecutive festivals of the same month; the list is already sorted by date.
    private func grouped(_ festivals: [Festival]) -> [FestivalMonth] {
        var out: [FestivalMonth] = []
        var current: [Festival] = []
        for f in festivals {
            if let first = current.first, first.date.firstOfMonth != f.date.firstOfMonth {
                out.append(FestivalMonth(month: first.date.firstOfMonth, items: current))
                current = []
            }
            current.append(f)
        }
        if let first = current.first {
            out.append(FestivalMonth(month: first.date.firstOfMonth, items: current))
        }
        return out
    }
}

private struct NextFestivalCard: View {
    @Environment(\.ink) private var ink
    let festival: Festival
    let today: CivilDate

    var body: some View {
        InvertedBlock {
            Text("తదుపరి పండుగ · NEXT").font(AppFont.labelSmall).foregroundColor(ink.onCardSoft)
            Text(festival.teluguName)
                .font(AppFont.displaySmall)
                .foregroundColor(ink.onCard)
                .multilineTextAlignment(.leading)
                .padding(.top, 10)
            Text(festival.name).font(AppFont.bodyMedium).foregroundColor(ink.onCardSoft)
            HStack(alignment: .bottom, spacing: 8) {
                Text(countdownLabel(today, festival.date))
                    .font(AppFont.headlineSmall)
                    .foregroundColor(ink.onCard)
                Spacer(minLength: 8)
                Text("\(festival.date.teluguDayMonth) · \(festival.date.formatWeekdayShort)")
                    .font(AppFont.labelLarge)
                    .foregroundColor(ink.onCardSoft)
            }
            .padding(.top, 14)
        }
        .contentShape(Rectangle())
    }
}

private struct FilterTab: View {
    @Environment(\.ink) private var ink
    let text: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(AppFont.labelLarge)
                .foregroundColor(selected ? ink.page : ink.secondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Capsule().fill(selected ? ink.strong : ink.page))
                .overlay(Capsule().stroke(selected ? ink.strong : ink.line, lineWidth: 1))
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

private struct FestivalListItem: View {
    @Environment(\.ink) private var ink
    let festival: Festival
    let today: CivilDate

    var body: some View {
        let past = festival.date < today
        let highlighted = festival.importance == .major && !past
        let dateInk: Color = highlighted ? ink.page : (past ? ink.faint : ink.strong)

        HStack(alignment: .center, spacing: 0) {
            VStack(spacing: 0) {
                Text("\(festival.date.day)").font(AppFont.titleMedium).foregroundColor(dateInk)
                Text(festival.date.formatWeekdayShort.uppercased())
                    .font(AppFont.labelSmall)
                    .foregroundColor(dateInk.opacity(0.7))
            }
            .frame(width: 46)
            .padding(.vertical, 6)
            .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(highlighted ? ink.strong : ink.page))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(highlighted ? ink.strong : ink.line, lineWidth: 1)
            )

            VStack(alignment: .leading, spacing: 0) {
                Text(festival.teluguName)
                    .font(AppFont.titleMedium)
                    .foregroundColor(past ? ink.secondary : ink.strong)
                Text(festival.name).font(AppFont.bodySmall).foregroundColor(ink.secondary)
                Text(festival.shortSignificance)
                    .font(AppFont.bodySmall)
                    .foregroundColor(ink.faint)
                    .lineLimit(1)
                    .padding(.top, 2)
                if festival.dateStatus != .verified {
                    StatusBadge(status: festival.dateStatus).padding(.top, 6)
                }
            }
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 14)
            .padding(.trailing, 8)

            Text(countdownLabel(today, festival.date))
                .font(AppFont.labelMedium)
                .foregroundColor(past ? ink.faint : ink.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}
