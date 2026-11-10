import SwiftUI

@main
struct TeluguPanchangamApp: App {
    @StateObject private var settings = AppSettings()

    var body: some Scene {
        WindowGroup {
            InkProvider { RootView() }
                .environmentObject(settings)
                .preferredColorScheme(settings.theme.colorScheme)
        }
    }
}

/// Screens that are pushed on top of a tab.
enum Route: Hashable {
    case cities
    case festival(String)
    case day(CivilDate)
}

/// The four top-level tabs, each with its own navigation stack.
struct RootView: View {
    @Environment(\.ink) private var ink

    var body: some View {
        TabView {
            TabStack { TodayView() }
                .tabItem { Label("నేడు", systemImage: "sun.max.fill") }
            TabStack { CalendarView() }
                .tabItem { Label("క్యాలెండర్", systemImage: "calendar") }
            TabStack { FestivalsView() }
                .tabItem { Label("పండుగలు", systemImage: "sparkles") }
            TabStack { MoreView() }
                .tabItem { Label("మరిన్ని", systemImage: "ellipsis") }
        }
        .tint(ink.strong)
    }
}

private struct TabStack<Root: View>: View {
    @Environment(\.ink) private var ink
    @ViewBuilder let root: () -> Root

    var body: some View {
        NavigationStack {
            root()
                .toolbarBackground(ink.page, for: .tabBar)
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .cities:
                        CityPickerView()
                    case .festival(let id):
                        FestivalDetailView(festivalId: id)
                    case .day(let date):
                        DayDetailView(date: date)
                    }
                }
        }
    }
}
