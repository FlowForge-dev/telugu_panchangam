import XCTest
@testable import TeluguPanchangam

/// Pins the engine to independently computed reference values. Every
/// expected value below was produced with the Swiss Ephemeris 2.10
/// (pyswisseph, Moshier ephemeris, SIDM_LAHIRI, upper-limb sunrise with
/// standard refraction) — not with this code. Same table as the Android
/// app's `AstronomicalPanchangRepositoryTest`.
final class PanchangEngineTests: XCTestCase {

    private struct Ref {
        let city: String
        let date: String
        let sunrise: String
        let tithi: Int
        let tithiEnds: String
        let nakshatra: Int
    }

    private let refs: [Ref] = [
        Ref(city: "hyderabad", date: "2026-03-19", sunrise: "2026-03-19T06:21", tithi: 30, tithiEnds: "2026-03-19T06:53", nakshatra: 26),
        Ref(city: "hyderabad", date: "2026-03-27", sunrise: "2026-03-27T06:14", tithi: 9, tithiEnds: "2026-03-27T10:07", nakshatra: 7),
        Ref(city: "hyderabad", date: "2026-04-21", sunrise: "2026-04-21T05:56", tithi: 5, tithiEnds: "2026-04-22T01:20", nakshatra: 5),
        Ref(city: "hyderabad", date: "2026-08-21", sunrise: "2026-08-21T06:00", tithi: 9, tithiEnds: "2026-08-21T23:36", nakshatra: 17),
        Ref(city: "hyderabad", date: "2026-09-14", sunrise: "2026-09-14T06:03", tithi: 3, tithiEnds: "2026-09-14T07:07", nakshatra: 14),
        Ref(city: "hyderabad", date: "2026-10-20", sunrise: "2026-10-20T06:10", tithi: 9, tithiEnds: "2026-10-20T12:50", nakshatra: 22),
        Ref(city: "hyderabad", date: "2026-11-08", sunrise: "2026-11-08T06:17", tithi: 29, tithiEnds: "2026-11-08T11:28", nakshatra: 15),
        Ref(city: "hyderabad", date: "2026-12-20", sunrise: "2026-12-20T06:40", tithi: 11, tithiEnds: "2026-12-20T20:15", nakshatra: 1),
        Ref(city: "hyderabad", date: "2027-01-15", sunrise: "2027-01-15T06:49", tithi: 7, tithiEnds: "2027-01-15T14:13", nakshatra: 27),
        Ref(city: "hyderabad", date: "2027-03-06", sunrise: "2027-03-06T06:31", tithi: 28, tithiEnds: "2027-03-06T12:04", nakshatra: 23),
        Ref(city: "hyderabad", date: "2027-04-07", sunrise: "2027-04-07T06:06", tithi: 1, tithiEnds: "2027-04-08T04:29", nakshatra: 27),
        Ref(city: "sringeri", date: "2026-10-21", sunrise: "2026-10-21T06:20", tithi: 10, tithiEnds: "2026-10-21T14:12", nakshatra: 23),
        Ref(city: "sringeri", date: "2026-07-29", sunrise: "2026-07-29T06:13", tithi: 15, tithiEnds: "2026-07-29T20:05", nakshatra: 21),
    ]

    private let repo = PanchangRepository()
    private let hyd = City.hyderabad

    private func civil(_ iso: String) -> CivilDate {
        let p = iso.split(separator: "-").map { Int($0)! }
        return CivilDate(p[0], p[1], p[2])
    }

    /// "2026-03-19T06:21" in `zone` as an instant.
    private func local(_ iso: String, _ zone: TimeZone) -> Date {
        let parts = iso.split(separator: "T")
        let hm = parts[1].split(separator: ":").map { Int($0)! }
        return civil(String(parts[0])).startOfDay(in: zone).addingTimeInterval(Double(hm[0] * 3600 + hm[1] * 60))
    }

    private func assertClose(_ expected: String, _ actual: Date, _ zone: TimeZone, _ label: String,
                             file: StaticString = #filePath, line: UInt = #line) {
        let minutes = actual.timeIntervalSince(local(expected, zone)) / 60
        XCTAssertLessThanOrEqual(abs(minutes), 2, "\(label): expected ~\(expected), off by \(minutes) min", file: file, line: line)
    }

    func testMatchesSwissEphemerisReference() {
        for r in refs {
            let city = City.byId(r.city)
            let day = repo.dayDetail(civil(r.date), city)
            let at = "\(r.city) \(r.date)"
            assertClose(r.sunrise, day.sunrise, city.zone, "\(at) sunrise")
            XCTAssertEqual(r.tithi, day.tithi.number, "\(at) tithi")
            assertClose(r.tithiEnds, day.tithis[0].end, city.zone, "\(at) tithi end")
            XCTAssertEqual(r.nakshatra, day.nakshatra.index, "\(at) nakshatra")
        }
    }

    func testDetectsAdhikaJyeshtha2026() {
        let adhika = repo.dayDetail(CivilDate(2026, 5, 25), hyd).lunarMonth
        XCTAssertEqual(adhika.masa, .jyeshtha)
        XCTAssertTrue(adhika.isAdhika)
        let nija = repo.dayDetail(CivilDate(2026, 6, 25), hyd).lunarMonth
        XCTAssertEqual(nija.masa, .jyeshtha)
        XCTAssertTrue(nija.isNija)
    }

    func testSamvatsaraTurnsAtUgadi() {
        XCTAssertEqual("Vishvavasu", repo.dayDetail(CivilDate(2026, 3, 1), hyd).samvatsara.name)
        XCTAssertEqual("Parabhava", repo.dayDetail(CivilDate(2026, 3, 20), hyd).samvatsara.name)
        XCTAssertEqual("Parabhava", repo.dayDetail(CivilDate(2027, 2, 1), hyd).samvatsara.name)
        XCTAssertEqual("Plavanga", repo.dayDetail(CivilDate(2027, 4, 7), hyd).samvatsara.name)
    }

    func testSpansCoverSunriseToSunrise() {
        let day = repo.dayDetail(CivilDate(2026, 10, 19), hyd)
        let all: [[(Date, Date)]] = [
            day.tithis.map { ($0.start, $0.end) },
            day.nakshatras.map { ($0.start, $0.end) },
            day.yogas.map { ($0.start, $0.end) },
            day.karanas.map { ($0.start, $0.end) },
        ]
        for spans in all {
            XCTAssertLessThanOrEqual(spans.first!.0, day.sunrise)
            XCTAssertGreaterThanOrEqual(spans.last!.1, day.nextSunrise)
            for i in 1..<spans.count { XCTAssertEqual(spans[i - 1].1, spans[i].0) }
        }
    }

    func testRahuKalamFollowsWeekdayRule() {
        // Monday: the 2nd of eight parts of the day.
        let day = repo.dayDetail(CivilDate(2026, 10, 19), hyd)
        XCTAssertEqual(day.vara, .monday)
        let part = day.sunset.timeIntervalSince(day.sunrise) / 8
        let rahu = day.inauspicious.first { $0.label == "Rahu Kalam" }!
        XCTAssertLessThanOrEqual(abs(rahu.start.timeIntervalSince(day.sunrise.addingTimeInterval(part))), 1)
    }

    func testCivilDateRoundTrips() {
        for d in [CivilDate(2000, 1, 1), CivilDate(2024, 2, 29), CivilDate(2026, 11, 8), CivilDate(2050, 12, 31)] {
            XCTAssertEqual(CivilDate(epochDay: d.epochDay), d)
        }
        XCTAssertEqual(CivilDate(1970, 1, 1).epochDay, 0)
        XCTAssertEqual(CivilDate(2026, 11, 8).weekdayIndex, 0) // a Sunday
        XCTAssertEqual(CivilDate(2026, 1, 31).plusMonths(1), CivilDate(2026, 2, 28))
        XCTAssertEqual(CivilDate(2026, 1, 15).plusMonths(-1), CivilDate(2025, 12, 15))
    }
}

final class FestivalDataTests: XCTestCase {

    private let festivals = FestivalData.festivals
    private let engine = PanchangRepository()

    func testIdsAreUniqueAndListIsSorted() {
        XCTAssertEqual(festivals.count, Set(festivals.map { $0.id }).count)
        XCTAssertEqual(festivals.map { $0.date }, festivals.map { $0.date }.sorted())
    }

    func testEveryFestivalIsInRangeAndCited() {
        for f in festivals {
            XCTAssertTrue(f.date >= FestivalData.ugadiStart && f.date <= FestivalData.nextUgadi, f.id)
            XCTAssertFalse(f.sources.isEmpty, "\(f.id) has no source")
        }
    }

    /// Spot-checks that corrected dates agree with the computed tithi.
    func testCorrectedDatesMatchTheirTithiRule() {
        let hyd = City.hyderabad
        func tithiAtSunrise(_ d: CivilDate) -> Int { engine.dayDetail(d, hyd).tithi.number }

        // Sri Rama Navami: Chaitra Shukla Navami (9) at sunrise.
        XCTAssertEqual(9, tithiAtSunrise(CivilDate(2026, 3, 27)))
        // Maha Shivaratri: Krishna Chaturdashi (29) holds at local midnight of 6 Mar 2027.
        let shivaratri = engine.dayDetail(CivilDate(2027, 3, 6), hyd)
        let midnight = CivilDate(2027, 3, 7).startOfDay(in: hyd.zone)
        XCTAssertTrue(shivaratri.tithis.contains { $0.item.number == 29 && $0.contains(midnight) })
        // Makara Sankranti 2027: Uttarayana begins with the sunrise of 15 Jan.
        XCTAssertEqual(.dakshinayana, engine.dayDetail(CivilDate(2027, 1, 14), hyd).ayana)
        XCTAssertEqual(.uttarayana, engine.dayDetail(CivilDate(2027, 1, 15), hyd).ayana)
        // Ugadi 2027: Chaitra Shukla Padyami at sunrise.
        XCTAssertEqual(1, tithiAtSunrise(CivilDate(2027, 4, 7)))
    }
}
