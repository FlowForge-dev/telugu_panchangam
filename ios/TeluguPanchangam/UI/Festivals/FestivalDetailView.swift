import SwiftUI

/// One festival: its date and how sure we are of it, significance, and sources.
struct FestivalDetailView: View {
    @Environment(\.ink) private var ink
    @EnvironmentObject private var settings: AppSettings
    let festivalId: String

    var body: some View {
        Group {
            if let festival = FestivalRepository.shared.byId(festivalId) {
                ScrollView {
                    FestivalDetailContent(festival: festival, today: CivilDate.today(in: settings.city.zone))
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                }
            } else {
                Text("Festival not found")
                    .font(AppFont.bodyMedium)
                    .foregroundColor(ink.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(ink.page.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(ink.page, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .tint(ink.strong)
    }
}

private struct FestivalDetailContent: View {
    @Environment(\.ink) private var ink
    let festival: Festival
    let today: CivilDate

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(festival.teluguName).font(AppFont.displaySmall).foregroundColor(ink.strong)
            Text(festival.name).font(AppFont.bodyLarge).foregroundColor(ink.secondary)
            Text(festival.shortSignificance)
                .font(AppFont.bodyMedium)
                .foregroundColor(ink.body)
                .padding(.top, 10)
                .padding(.bottom, 20)

            DateCard(festival: festival, today: today)

            DetailSection(telugu: "ప్రాముఖ్యత", english: "Significance", text: festival.significance)
            if let observance = festival.observance {
                DetailSection(telugu: "ఆచరణ", english: "Observance", text: observance)
            }
            if let preparation = festival.preparation {
                DetailSection(telugu: "సన్నాహం", english: "Preparation", text: preparation)
            }

            Text("మంత్రాలు, పూజా విధానం ఇక్కడ ఇవ్వలేదు — మీ పురోహితులను లేదా కుటుంబ పంచాంగాన్ని సంప్రదించండి. " +
                 "Mantras and step-by-step ritual are deliberately not included without a cited traditional source.")
                .font(AppFont.bodySmall)
                .foregroundColor(ink.secondary)
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(ink.wash))
                .padding(.top, 20)

            Text("ఆధారాలు").font(AppFont.titleLarge).foregroundColor(ink.strong).padding(.top, 28)
            Text("SOURCES").font(AppFont.labelSmall).foregroundColor(ink.faint).padding(.bottom, 10)
            ForEach(Array(festival.sources.enumerated()), id: \.offset) { _, source in
                SourceReferenceCard(source: source).padding(.bottom, 8)
            }

            Text("Festival list covers \(FestivalData.ugadiStart.formatLong) – \(FestivalData.nextUgadi.formatLong).")
                .font(AppFont.labelSmall)
                .foregroundColor(ink.faint)
                .padding(.top, 12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct DateCard: View {
    @Environment(\.ink) private var ink
    let festival: Festival
    let today: CivilDate

    var body: some View {
        OutlinedBlock {
            HStack(alignment: .center, spacing: 8) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("\(festival.date.teluguDayMonth) \(String(festival.date.year))")
                        .font(AppFont.titleLarge)
                        .foregroundColor(ink.strong)
                    Text(festival.date.formatLong).font(AppFont.bodySmall).foregroundColor(ink.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Pill(text: countdownLabel(today, festival.date), filled: festival.date >= today)
            }
            ThinDivider().padding(.top, 14).padding(.bottom, 12)
            HStack(spacing: 8) {
                Dot(size: 8, fill: festival.dateStatus == .verified ? ink.strong : ink.page, rim: ink.strong)
                Text("\(festival.dateStatus.teluguLabel) · \(festival.dateStatus.englishLabel)")
                    .font(AppFont.labelLarge)
                    .foregroundColor(ink.strong)
            }
            if let note = festival.dateNote {
                Text(note).font(AppFont.bodySmall).foregroundColor(ink.secondary).padding(.top, 8)
            }
            NavigationLink(value: Route.day(festival.date)) {
                HStack(spacing: 4) {
                    Text("ఆ రోజు పంచాంగం · View the day").font(AppFont.labelLarge)
                    Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(ink.strong)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(ink.line, lineWidth: 1))
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.top, 12)
        }
    }
}

private struct DetailSection: View {
    @Environment(\.ink) private var ink
    let telugu: String
    let english: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(telugu).font(AppFont.titleLarge).foregroundColor(ink.strong)
            Text(english.uppercased()).font(AppFont.labelSmall).foregroundColor(ink.faint)
            Text(text).font(AppFont.bodyLarge).foregroundColor(ink.body).padding(.top, 8)
        }
        .padding(.top, 28)
    }
}
