import Foundation

private let englishMonths = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December",
]
private let englishWeekdays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

let teluguMonths = [
    "జనవరి", "ఫిబ్రవరి", "మార్చి", "ఏప్రిల్", "మే", "జూన్",
    "జూలై", "ఆగస్టు", "సెప్టెంబరు", "అక్టోబరు", "నవంబరు", "డిసెంబరు",
]

extension CivilDate {
    /// 19 Mar 2026
    var formatShort: String { "\(day) \(englishMonths[month - 1].prefix(3)) \(year)" }
    /// Thursday, 19 March 2026
    var formatLong: String { "\(englishWeekdays[weekdayIndex]), \(day) \(englishMonths[month - 1]) \(year)" }
    /// 19 Mar
    var formatDayMonth: String { "\(day) \(englishMonths[month - 1].prefix(3))" }
    /// Thu
    var formatWeekdayShort: String { String(englishWeekdays[weekdayIndex].prefix(3)) }
    /// March 2026
    var englishMonthYear: String { "\(englishMonths[month - 1]) \(year)" }
    /// మార్చి 2026
    var teluguMonthYear: String { "\(teluguMonths[month - 1]) \(year)" }
    /// 19 మార్చి
    var teluguDayMonth: String { "\(day) \(teluguMonths[month - 1])" }
}

/// Formats instants as clock times in a city's zone.
struct Clock {
    let use24Hour: Bool
    let zone: TimeZone

    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    func time(_ t: Date) -> String {
        let f = Clock.formatter
        f.timeZone = zone
        f.dateFormat = use24Hour ? "HH:mm" : "h:mm a"
        return f.string(from: t)
    }

    /// A clock time relative to the civil day `day`: times on the next or
    /// previous day get a small marker so a sunrise-to-sunrise span reads
    /// correctly.
    func label(_ t: Date, day: CivilDate) -> String {
        let base = time(t)
        let local = CivilDate(t, in: zone)
        switch local.epochDay - day.epochDay {
        case 0: return base
        case 1: return "\(base) (+1)"
        case -1: return "\(base) (−1)"
        default: return "\(base) · \(local.formatDayMonth)"
        }
    }
}

/// "in 3 days" style countdown, Telugu first.
func countdownLabel(_ today: CivilDate, _ date: CivilDate) -> String {
    let days = date.epochDay - today.epochDay
    if days == 0 { return "ఈరోజు" }
    if days == 1 { return "రేపు" }
    if days > 1 { return "\(days) రోజుల్లో" }
    if days == -1 { return "నిన్న" }
    return "\(-days) రోజుల క్రితం"
}
