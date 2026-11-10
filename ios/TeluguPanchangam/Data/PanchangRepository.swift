import Foundation

/// Computes the Panchangam from first principles for any date and city:
/// Sun and Moon positions from `Astronomy`, Lahiri ayanamsa, amanta
/// lunar months with adhika-masa detection, and the sunrise-based
/// conventions used by Telugu Panchangams.
///
/// Accuracy, checked against the Swiss Ephemeris (see README): tithi,
/// nakshatra, yoga and karana transition times within about a minute;
/// sunrise and sunset within about a minute.
///
/// A port of the Android app's `AstronomicalPanchangRepository.kt`.
/// Thread-safe: the calendar computes month summaries off the main thread.
final class PanchangRepository: @unchecked Sendable {

    static let shared = PanchangRepository()

    private struct Key: Hashable {
        let date: CivilDate
        let cityId: String
    }

    private let lock = NSLock()
    private var dayCache: [Key: PanchangDay] = [:]
    private var dayOrder: [Key] = []
    private var summaryCache: [Key: DaySummary] = [:]
    private var summaryOrder: [Key] = []

    func dayDetail(_ date: CivilDate, _ city: City) -> PanchangDay {
        let key = Key(date: date, cityId: city.id)
        lock.lock()
        if let hit = dayCache[key] {
            lock.unlock()
            return hit
        }
        lock.unlock()

        let day = compute(date, city)

        lock.lock()
        if dayCache[key] == nil {
            dayCache[key] = day
            dayOrder.append(key)
            if dayOrder.count > 120 { dayCache[dayOrder.removeFirst()] = nil }
        }
        lock.unlock()
        return day
    }

    func summaries(_ start: CivilDate, _ end: CivilDate, _ city: City) -> [CivilDate: DaySummary] {
        var out: [CivilDate: DaySummary] = [:]
        var d = start
        while d <= end {
            let key = Key(date: d, cityId: city.id)
            lock.lock()
            let hit = summaryCache[key]
            lock.unlock()
            if let hit = hit {
                out[d] = hit
            } else {
                let s = summarise(d, city)
                lock.lock()
                if summaryCache[key] == nil {
                    summaryCache[key] = s
                    summaryOrder.append(key)
                    if summaryOrder.count > 1200 { summaryCache[summaryOrder.removeFirst()] = nil }
                }
                lock.unlock()
                out[d] = s
            }
            d = d.plusDays(1)
        }
        return out
    }

    // MARK: -

    private func summarise(_ date: CivilDate, _ city: City) -> DaySummary {
        let midnight = Self.jdAtStartOf(date, city.zone)
        let sunrise = self.sunrise(midnight, city)
        let elong = Astronomy.elongation(sunrise)
        let tithi = ReferenceTables.tithis[tithiIndex(elong)]
        return DaySummary(
            date: date,
            tithi: tithi,
            lunarMonth: lunarMonth(sunrise),
            nakshatra: ReferenceTables.nakshatras[nakshatraIndex(Astronomy.moonSidereal(sunrise))],
            elongation: elong,
            specialDayType: specialDay(tithi.number)
        )
    }

    private func compute(_ date: CivilDate, _ city: City) -> PanchangDay {
        let zone = city.zone
        let lat = city.latitude
        let lon = city.longitude
        let midnight = Self.jdAtStartOf(date, zone)
        let sunrise = self.sunrise(midnight, city)
        let sunset = Astronomy.findCrossing(sunrise, midnight + 1.0, h0: Astronomy.sunRiseAltitude, rising: false) {
            Astronomy.sunAltitude($0, latDeg: lat, lonDeg: lon)
        } ?? (sunrise + 0.5)
        let nextSunrise = self.sunrise(midnight + 1.0, city)

        let moonAlt: (Double) -> Double = { Astronomy.moonAltitude($0, latDeg: lat, lonDeg: lon) }
        let moonrise = Astronomy.findCrossing(midnight, midnight + 1.0, h0: Astronomy.moonRiseAltitude, rising: true, moonAlt)
        let moonset = Astronomy.findCrossing(midnight, midnight + 1.0, h0: Astronomy.moonRiseAltitude, rising: false, moonAlt)

        func t(_ jd: Double) -> Date { Self.toDate(jd) }

        let tithis = spans(sunrise, nextSunrise, size: 12.0, rate: Astronomy.moonSunRate,
                           angle: Astronomy.elongation) { ReferenceTables.tithis[$0 % 30] }
        let nakshatras = spans(sunrise, nextSunrise, size: 360.0 / 27, rate: Astronomy.moonRate,
                               angle: Astronomy.moonSidereal) { ReferenceTables.nakshatras[$0 % 27] }
        let yogas = spans(sunrise, nextSunrise, size: 360.0 / 27, rate: Astronomy.yogaRate,
                          angle: Astronomy.yogaArgument) { ReferenceTables.yogas[$0 % 27] }
        let karanas = spans(sunrise, nextSunrise, size: 6.0, rate: Astronomy.moonSunRate,
                            angle: Astronomy.elongation) { ReferenceTables.karana($0 % 60) }

        let month = lunarMonth(sunrise)
        let shaka = shakaYear(date, month.masa)
        let sunLon = Astronomy.sunSidereal(sunrise)
        let vara = Vara.forDate(date)
        let w = vara.rawValue

        // ---- Kalams: the day split into eight equal parts ------------
        let dayLength = sunset - sunrise
        let part = dayLength / 8.0
        func kalam(_ n: Int) -> (Date, Date) {
            (t(sunrise + part * Double(n - 1)), t(sunrise + part * Double(n)))
        }
        let rahu = kalam([8, 2, 7, 5, 6, 4, 3][w])
        let yama = kalam([5, 4, 3, 2, 1, 7, 6][w])
        let gulika = kalam([7, 6, 5, 4, 3, 2, 1][w])

        // ---- Muhurtas: day and night each split into fifteen ---------
        let dayMuhurta = dayLength / 15.0
        let nightMuhurta = (nextSunrise - sunset) / 15.0

        let inauspicious = [
            TimeWindow(label: "Rahu Kalam", teluguLabel: "రాహు కాలం", start: rahu.0, end: rahu.1, auspicious: false),
            TimeWindow(label: "Yamagandam", teluguLabel: "యమగండం", start: yama.0, end: yama.1, auspicious: false),
            TimeWindow(label: "Gulika Kalam", teluguLabel: "గుళిక కాలం", start: gulika.0, end: gulika.1, auspicious: false),
        ]
        let auspicious = [
            TimeWindow(label: "Brahma Muhurtam", teluguLabel: "బ్రాహ్మీ ముహూర్తం",
                       start: t(sunrise - 2 * nightMuhurta), end: t(sunrise - nightMuhurta), auspicious: true),
            TimeWindow(label: "Abhijit Muhurtam", teluguLabel: "అభిజిత్ ముహూర్తం",
                       start: t(sunrise + 7 * dayMuhurta), end: t(sunrise + 8 * dayMuhurta), auspicious: true),
        ]

        let dayChoghadiya = choghadiya(ReferenceTables.dayChoghadiya(w), sunrise, sunset, night: false)
        let nightChoghadiya = choghadiya(ReferenceTables.nightChoghadiya(w), sunset, nextSunrise, night: true)

        let elong = Astronomy.elongation(sunrise)
        return PanchangDay(
            date: date,
            city: city,
            vara: vara,
            samvatsara: ReferenceTables.samvatsara(shaka),
            shakaYear: shaka,
            ayana: (sunLon >= 270.0 || sunLon < 90.0) ? .uttarayana : .dakshinayana,
            ritu: Ritu.forMasa(month.masa),
            lunarMonth: month,
            paksha: tithis[0].item.paksha,
            tithis: tithis,
            nakshatras: nakshatras,
            yogas: yogas,
            karanas: karanas,
            sunRashi: ReferenceTables.rashis[Int(sunLon / 30.0) % 12],
            moonRashi: ReferenceTables.rashis[Int(Astronomy.moonSidereal(sunrise) / 30.0) % 12],
            sunrise: t(sunrise),
            sunset: t(sunset),
            nextSunrise: t(nextSunrise),
            moonrise: moonrise.map(t),
            moonset: moonset.map(t),
            inauspicious: inauspicious,
            auspicious: auspicious,
            dayChoghadiya: dayChoghadiya,
            nightChoghadiya: nightChoghadiya,
            elongation: elong,
            specialDayType: specialDay(tithis[0].item.number)
        )
    }

    // MARK: -

    /// Splits [from, to) into the successive divisions of an angle that
    /// grows at about `rate` °/day, each `size`° wide. The first span
    /// starts before `from`.
    private func spans<T>(
        _ from: Double, _ to: Double, size: Double, rate: Double,
        angle: (Double) -> Double, item: (Int) -> T
    ) -> [Span<T>] {
        var out: [Span<T>] = []
        var index = Int(floor(angle(from) / size))
        var start = Astronomy.previousTimeAngleReached(from, target: Double(index) * size, rate: rate, angle)
        var cursor = from
        while cursor < to && out.count < 4 {
            let end = Astronomy.nextTimeAngleReaches(cursor, target: Astronomy.norm360(Double(index + 1) * size), rate: rate, angle)
            out.append(Span(item: item(index), start: Self.toDate(start), end: Self.toDate(end)))
            start = end
            cursor = end + 1e-6
            index += 1
        }
        return out
    }

    private func choghadiya(_ names: [String], _ from: Double, _ to: Double, night: Bool) -> [ChoghadiyaPeriod] {
        let slot = (to - from) / 8.0
        return names.enumerated().map { i, name in
            let quality: ChoghadiyaQuality
            switch name {
            case "Labh", "Amrit", "Shubh": quality = .good
            case "Chal": quality = .neutral
            default: quality = .inauspicious
            }
            return ChoghadiyaPeriod(
                name: name,
                telugu: ReferenceTables.choghadiyaTelugu[name] ?? name,
                start: Self.toDate(from + slot * Double(i)),
                end: Self.toDate(from + slot * Double(i + 1)),
                quality: quality,
                isNight: night
            )
        }
    }

    /// Amanta month containing `jd`: named after the sidereal sign the Sun
    /// occupies at the opening new moon, plus one (Sun in Meena → Chaitra).
    /// A lunar month with no solar ingress is adhika; the month after an
    /// adhika month of the same name is nija.
    private func lunarMonth(_ jd: Double) -> LunarMonth {
        let nmBefore = Astronomy.previousTimeAngleReached(jd, target: 0.0, rate: Astronomy.moonSunRate, Astronomy.elongation)
        let nmAfter = Astronomy.nextTimeAngleReaches(nmBefore + 20.0, target: 0.0, rate: Astronomy.moonSunRate, Astronomy.elongation)
        let signStart = sign(nmBefore)
        let signEnd = sign(nmAfter)
        let masa = Masa(rawValue: (signStart + 1) % 12)!
        if signStart == signEnd { return LunarMonth(masa: masa, isAdhika: true) }
        let nmPrevious = Astronomy.previousTimeAngleReached(nmBefore - 10.0, target: 0.0, rate: Astronomy.moonSunRate, Astronomy.elongation)
        return LunarMonth(masa: masa, isAdhika: false, isNija: sign(nmPrevious) == signStart)
    }

    private func sign(_ jd: Double) -> Int { Int(Astronomy.sunSidereal(jd) / 30.0) % 12 }

    /// Shaka year, which turns over at Ugadi: months from Margashira to
    /// Phalguna that fall early in the Gregorian year still belong to the
    /// previous Shaka year.
    private func shakaYear(_ date: CivilDate, _ masa: Masa) -> Int {
        (date.month <= 4 && masa.rawValue >= Masa.margashira.rawValue) ? date.year - 79 : date.year - 78
    }

    private func sunrise(_ midnightJd: Double, _ city: City) -> Double {
        let lat = city.latitude
        let lon = city.longitude
        return Astronomy.findCrossing(midnightJd, midnightJd + 1.0, h0: Astronomy.sunRiseAltitude, rising: true) {
            Astronomy.sunAltitude($0, latDeg: lat, lonDeg: lon)
        } ?? (midnightJd + 0.25)
    }

    private func tithiIndex(_ elong: Double) -> Int { min(max(Int(elong / 12.0), 0), 29) }
    private func nakshatraIndex(_ lon: Double) -> Int { min(max(Int(lon / (360.0 / 27)), 0), 26) }

    private func specialDay(_ tithiNumber: Int) -> SpecialDayType {
        switch tithiNumber {
        case 11, 26: return .ekadashi
        case 15: return .purnima
        case 30: return .amavasya
        default: return .none
        }
    }

    // MARK: - Julian Day ⇄ Date

    private static let unixEpochJd = 2440587.5

    static func jdAtStartOf(_ date: CivilDate, _ zone: TimeZone) -> Double {
        date.startOfDay(in: zone).timeIntervalSince1970 / 86400.0 + unixEpochJd
    }

    static func toDate(_ jd: Double) -> Date {
        Date(timeIntervalSince1970: (jd - unixEpochJd) * 86400.0)
    }
}
