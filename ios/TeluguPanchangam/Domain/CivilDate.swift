import Foundation

/// A calendar date with no time or zone — the Swift counterpart of
/// `java.time.LocalDate` in the Android app. Arithmetic is done on the
/// proleptic Gregorian day number, so it never depends on a time zone.
struct CivilDate: Hashable, Comparable, Codable, CustomStringConvertible {
    let year: Int
    let month: Int  // 1...12
    let day: Int    // 1...31

    init(_ year: Int, _ month: Int, _ day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }

    /// Days since 1970-01-01 (Howard Hinnant's `days_from_civil`).
    var epochDay: Int {
        let y = month <= 2 ? year - 1 : year
        let era = (y >= 0 ? y : y - 399) / 400
        let yoe = y - era * 400
        let mp = (month + 9) % 12
        let doy = (153 * mp + 2) / 5 + day - 1
        let doe = yoe * 365 + yoe / 4 - yoe / 100 + doy
        return era * 146097 + doe - 719468
    }

    init(epochDay z0: Int) {
        let z = z0 + 719468
        let era = (z >= 0 ? z : z - 146096) / 146097
        let doe = z - era * 146097
        let yoe = (doe - doe / 1460 + doe / 36524 - doe / 146096) / 365
        let doy = doe - (365 * yoe + yoe / 4 - yoe / 100)
        let mp = (5 * doy + 2) / 153
        let d = doy - (153 * mp + 2) / 5 + 1
        let m = mp < 10 ? mp + 3 : mp - 9
        self.init(m <= 2 ? yoe + era * 400 + 1 : yoe + era * 400, m, d)
    }

    /// The civil date of an instant as seen in `zone`.
    init(_ instant: Date, in zone: TimeZone) {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = zone
        let c = cal.dateComponents([.year, .month, .day], from: instant)
        self.init(c.year!, c.month!, c.day!)
    }

    static func today(in zone: TimeZone) -> CivilDate { CivilDate(Date(), in: zone) }

    func plusDays(_ n: Int) -> CivilDate { CivilDate(epochDay: epochDay + n) }

    func plusMonths(_ n: Int) -> CivilDate {
        let total = year * 12 + (month - 1) + n
        let y = Int(floor(Double(total) / 12.0))
        let m = total - y * 12 + 1
        return CivilDate(y, m, min(day, CivilDate.lengthOfMonth(y, m)))
    }

    /// Sunday = 0 … Saturday = 6. 1970-01-01 was a Thursday.
    var weekdayIndex: Int { ((epochDay + 4) % 7 + 7) % 7 }

    var firstOfMonth: CivilDate { CivilDate(year, month, 1) }
    var lengthOfMonth: Int { CivilDate.lengthOfMonth(year, month) }

    static func lengthOfMonth(_ year: Int, _ month: Int) -> Int {
        switch month {
        case 2:
            let leap = (year % 4 == 0 && year % 100 != 0) || year % 400 == 0
            return leap ? 29 : 28
        case 4, 6, 9, 11: return 30
        default: return 31
        }
    }

    /// Midnight at the start of this date in `zone`.
    func startOfDay(in zone: TimeZone) -> Date {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = zone
        let comps = DateComponents(year: year, month: month, day: day)
        return cal.date(from: comps)!
    }

    static func < (a: CivilDate, b: CivilDate) -> Bool {
        (a.year, a.month, a.day) < (b.year, b.month, b.day)
    }

    /// ISO form, e.g. 2026-03-19.
    var description: String {
        String(format: "%04d-%02d-%02d", year, month, day)
    }
}
