import SwiftUI

/// User preferences, persisted in `UserDefaults` on this device only.
final class AppSettings: ObservableObject {
    private let defaults: UserDefaults

    @Published var cityId: String {
        didSet { defaults.set(cityId, forKey: "city") }
    }
    @Published var theme: ThemeMode {
        didSet { defaults.set(theme.rawValue, forKey: "theme") }
    }
    @Published var use24Hour: Bool {
        didSet { defaults.set(use24Hour, forKey: "use24h") }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        cityId = defaults.string(forKey: "city") ?? City.hyderabad.id
        theme = ThemeMode(rawValue: defaults.string(forKey: "theme") ?? "") ?? .system
        use24Hour = defaults.bool(forKey: "use24h")
    }

    var city: City { City.byId(cityId) }

    /// Clock-time formatting for the chosen city and 12/24-hour setting.
    var clock: Clock { Clock(use24Hour: use24Hour, zone: city.zone) }
}
