import SwiftUI

/// One day's full Panchangam; swipe sideways for the previous or next day.
struct DayDetailView: View {
    @Environment(\.ink) private var ink
    @EnvironmentObject private var settings: AppSettings
    let date: CivilDate

    @State private var offset = 0
    @State private var forward = true

    private var shown: CivilDate { date.plusDays(offset) }

    var body: some View {
        let city = settings.city
        let day = PanchangRepository.shared.dayDetail(shown, city)
        let festivals = FestivalRepository.shared.onDate(shown)

        ScrollView {
            PanchangDayContent(day: day, festivals: festivals, now: Date())
                .padding(.bottom, 32)
                .id(shown)
                .transition(pageTransition(forward: forward))
        }
        .horizontalSwipe(step)
        .background(ink.page.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                TitleStack(title: "\(shown.teluguDayMonth) \(shown.year)", caption: shown.formatLong)
            }
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button { step(-1) } label: { Image(systemName: "chevron.left") }
                    .accessibilityLabel("Previous day")
                Button { step(1) } label: { Image(systemName: "chevron.right") }
                    .accessibilityLabel("Next day")
                ShareLink(item: shareText(day, festivals: festivals, use24Hour: settings.use24Hour)) {
                    Image(systemName: "square.and.arrow.up")
                }
                .accessibilityLabel("Share")
            }
        }
        .toolbarBackground(ink.page, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .tint(ink.strong)
    }

    private func step(_ by: Int) {
        forward = by > 0
        withAnimation(.easeInOut(duration: 0.25)) { offset += by }
    }
}
