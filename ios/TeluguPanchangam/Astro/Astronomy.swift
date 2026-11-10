import Foundation

/// Positional astronomy for the Panchangam, after Jean Meeus,
/// *Astronomical Algorithms* (2nd ed.):
///
///  - Sun: chapter 25 (low-accuracy theory, ~0.01°) plus the classical
///    Venus, Jupiter and lunar perturbation terms.
///  - Moon: chapter 47 (ELP-2000/82 truncated, ~10″ in longitude).
///  - Lahiri (Chitrapaksha) ayanamsa: the mean value as used by the
///    Swiss Ephemeris `SIDM_LAHIRI` mode, 23.857092° at J2000 plus
///    general precession in longitude.
///
/// Sidereal longitudes are mean-equinox longitudes minus the mean
/// ayanamsa, which is exactly what Swiss Ephemeris returns for
/// `FLG_SIDEREAL` (nutation cancels).
///
/// Every function takes a Julian Day in Universal Time; the TT
/// correction (ΔT) is applied internally.
///
/// This is a line-for-line port of the Android app's `Astronomy.kt`.
enum Astronomy {

    private static let deg = Double.pi / 180.0
    static let j2000 = 2451545.0

    static func norm360(_ x: Double) -> Double {
        let r = x.truncatingRemainder(dividingBy: 360.0)
        return r < 0 ? r + 360.0 : r
    }

    /// Signed difference a − b folded into (−180, 180].
    static func angleDiff(_ a: Double, _ b: Double) -> Double {
        var d = norm360(a - b)
        if d > 180.0 { d -= 360.0 }
        return d
    }

    /// ΔT = TT − UT in seconds. Observed values for the recent past; a
    /// gentle extrapolation beyond. Errors of a few seconds move the Moon
    /// by ~1″ and are immaterial for Panchangam purposes.
    static func deltaTSeconds(_ jdUt: Double) -> Double {
        let year = 2000.0 + (jdUt - j2000) / 365.25
        if year < 1986 {
            let y = year - 1975
            return 45.45 + 1.067 * y - y * y / 260.0
        } else if year < 2005 {
            let y = year - 2000
            return 63.86 + 0.3345 * y - 0.060374 * y * y
        } else if year < 2025 {
            return 64.69 + 0.2 * (year - 2005)
        } else {
            return 69.0 + 0.1 * (year - 2025)
        }
    }

    private static func centuriesTT(_ jdUt: Double) -> Double {
        (jdUt + deltaTSeconds(jdUt) / 86400.0 - j2000) / 36525.0
    }

    // MARK: - Sun

    /// Geometric mean-equinox longitude of the Sun, with aberration.
    private static func sunMeanEquinoxLongitude(_ t: Double) -> Double {
        let l0 = 280.46646 + 36000.76983 * t + 0.0003032 * t * t
        let m = (357.52911 + 35999.05029 * t - 0.0001537 * t * t) * deg
        let c1 = (1.914602 - 0.004817 * t - 0.000014 * t * t) * sin(m)
        let c2 = (0.019993 - 0.000101 * t) * sin(2 * m)
        let c3 = 0.000289 * sin(3 * m)
        let c = c1 + c2 + c3
        // Perturbations by Venus, Jupiter and the Moon, plus a long-period
        // term (Meeus, *Astronomical Formulae for Calculators*, ch. 18;
        // arguments counted from 1900.0, hence t + 1).
        let t1 = t + 1.0
        let p1 = 0.00134 * cos((153.23 + 22518.7541 * t1) * deg)
        let p2 = 0.00154 * cos((216.57 + 45037.5082 * t1) * deg)
        let p3 = 0.00200 * cos((312.69 + 32964.3577 * t1) * deg)
        let p4 = 0.00179 * sin((350.74 + 445267.1142 * t1) * deg)
        let p5 = 0.00178 * sin((231.19 + 20.20 * t1) * deg)
        let p = p1 + p2 + p3 + p4 + p5
        return norm360(l0 + c + p - 0.00569)
    }

    // MARK: - Moon

    // Meeus table 47.A: D, M, M', F, Σl (1e-6°). Distance terms omitted.
    private static let moonLon: [Int] = [
        0, 0, 1, 0, 6288774, 2, 0, -1, 0, 1274027, 2, 0, 0, 0, 658314,
        0, 0, 2, 0, 213618, 0, 1, 0, 0, -185116, 0, 0, 0, 2, -114332,
        2, 0, -2, 0, 58793, 2, -1, -1, 0, 57066, 2, 0, 1, 0, 53322,
        2, -1, 0, 0, 45758, 0, 1, -1, 0, -40923, 1, 0, 0, 0, -34720,
        0, 1, 1, 0, -30383, 2, 0, 0, -2, 15327, 0, 0, 1, 2, -12528,
        0, 0, 1, -2, 10980, 4, 0, -1, 0, 10675, 0, 0, 3, 0, 10034,
        4, 0, -2, 0, 8548, 2, 1, -1, 0, -7888, 2, 1, 0, 0, -6766,
        1, 0, -1, 0, -5163, 1, 1, 0, 0, 4987, 2, -1, 1, 0, 4036,
        2, 0, 2, 0, 3994, 4, 0, 0, 0, 3861, 2, 0, -3, 0, 3665,
        0, 1, -2, 0, -2689, 2, 0, -1, 2, -2602, 2, -1, -2, 0, 2390,
        1, 0, 1, 0, -2348, 2, -2, 0, 0, 2236, 0, 1, 2, 0, -2120,
        0, 2, 0, 0, -2069, 2, -2, -1, 0, 2048, 2, 0, 1, -2, -1773,
        2, 0, 0, 2, -1595, 4, -1, -1, 0, 1215, 0, 0, 2, 2, -1110,
        3, 0, -1, 0, -892, 2, 1, 1, 0, -810, 4, -1, -2, 0, 759,
        0, 2, -1, 0, -713, 2, 2, -1, 0, -700, 2, 1, -2, 0, 691,
        2, -1, 0, -2, 596, 4, 0, 1, 0, 549, 0, 0, 4, 0, 537,
        4, -1, 0, 0, 520, 1, 0, -2, 0, -487, 2, 1, 0, -2, -399,
        0, 0, 2, -2, -381, 1, 1, 1, 0, 351, 3, 0, -2, 0, -340,
        4, 0, -3, 0, 330, 2, -1, 2, 0, 327, 0, 2, 1, 0, -323,
        1, 1, -1, 0, 299, 2, 0, 3, 0, 294,
    ]

    // Meeus table 47.B: D, M, M', F, Σb (1e-6°).
    private static let moonLat: [Int] = [
        0, 0, 0, 1, 5128122, 0, 0, 1, 1, 280602, 0, 0, 1, -1, 277693,
        2, 0, 0, -1, 173237, 2, 0, -1, 1, 55413, 2, 0, -1, -1, 46271,
        2, 0, 0, 1, 32573, 0, 0, 2, 1, 17198, 2, 0, 1, -1, 9266,
        0, 0, 2, -1, 8822, 2, -1, 0, -1, 8216, 2, 0, -2, -1, 4324,
        2, 0, 1, 1, 4200, 2, 1, 0, -1, -3359, 2, -1, -1, 1, 2463,
        2, -1, 0, 1, 2211, 2, -1, -1, -1, 2065, 0, 1, -1, -1, -1870,
        4, 0, -1, -1, 1828, 0, 1, 0, 1, -1794, 0, 0, 0, 3, -1749,
        0, 1, -1, 1, -1565, 1, 0, 0, 1, -1491, 0, 1, 1, 1, -1475,
        0, 1, 1, -1, -1410, 0, 1, 0, -1, -1344, 1, 0, 0, -1, -1335,
        0, 0, 3, 1, 1107, 4, 0, 0, -1, 1021, 4, 0, -1, 1, 833,
        0, 0, 1, -3, 777, 4, 0, -2, 1, 671, 2, 0, 0, -3, 607,
        2, 0, 2, -1, 596, 2, -1, 1, -1, 491, 2, 0, -2, 1, -451,
        0, 0, 3, -1, 439, 2, 0, 2, 1, 422, 2, 0, -3, -1, 421,
        2, 1, -1, 1, -366, 2, 1, 0, 1, -351, 4, 0, 0, 1, 331,
        2, -1, 1, 1, 315, 2, -2, 0, -1, 302, 0, 0, 1, 3, -283,
        2, 1, 1, -1, -229, 1, 1, 0, -1, 223, 1, 1, 0, 1, 223,
        0, 1, -2, -1, -220, 2, 1, -1, -1, -220, 1, 0, 1, 1, -185,
        2, -1, -2, -1, 181, 0, 1, 2, 1, -177, 4, 0, -2, -1, 176,
        4, -1, -1, -1, 166, 1, 0, 1, -1, -164, 4, 0, 1, -1, 132,
        1, 0, -1, -1, -119, 4, -1, 0, -1, 115, 2, -2, 0, 1, 107,
    ]

    private struct MoonEcliptic {
        let longitude: Double
        let latitude: Double
    }

    private static func series(_ table: [Int], d: Double, m: Double, mp: Double, f: Double, e: Double) -> Double {
        var sum = 0.0
        var i = 0
        while i < table.count {
            let cm = table[i + 1]
            let arg = (Double(table[i]) * d + Double(cm) * m + Double(table[i + 2]) * mp + Double(table[i + 3]) * f) * deg
            let ecc: Double
            switch abs(cm) {
            case 1: ecc = e
            case 2: ecc = e * e
            default: ecc = 1.0
            }
            sum += Double(table[i + 4]) * ecc * sin(arg)
            i += 5
        }
        return sum
    }

    private static func moonMeanEquinox(_ t: Double) -> MoonEcliptic {
        let t2 = t * t
        let t3 = t2 * t
        let t4 = t3 * t
        let lp = norm360(218.3164477 + 481267.88123421 * t - 0.0015786 * t2 + t3 / 538841.0 - t4 / 65194000.0)
        let d = norm360(297.8501921 + 445267.1114034 * t - 0.0018819 * t2 + t3 / 545868.0 - t4 / 113065000.0)
        let m = norm360(357.5291092 + 35999.0502909 * t - 0.0001536 * t2 + t3 / 24490000.0)
        let mp = norm360(134.9633964 + 477198.8675055 * t + 0.0087414 * t2 + t3 / 69699.0 - t4 / 14712000.0)
        let f = norm360(93.2720950 + 483202.0175233 * t - 0.0036539 * t2 - t3 / 3526000.0 + t4 / 863310000.0)
        let a1 = norm360(119.75 + 131.849 * t)
        let a2 = norm360(53.09 + 479264.290 * t)
        let a3 = norm360(313.45 + 481266.484 * t)
        let e = 1.0 - 0.002516 * t - 0.0000074 * t2

        var sl = series(moonLon, d: d, m: m, mp: mp, f: f, e: e)
        sl += 3958 * sin(a1 * deg)
        sl += 1962 * sin((lp - f) * deg)
        sl += 318 * sin(a2 * deg)

        var sb = series(moonLat, d: d, m: m, mp: mp, f: f, e: e)
        sb -= 2235 * sin(lp * deg)
        sb += 382 * sin(a3 * deg)
        sb += 175 * sin((a1 - f) * deg)
        sb += 175 * sin((a1 + f) * deg)
        sb += 127 * sin((lp - mp) * deg)
        sb -= 115 * sin((lp + mp) * deg)

        return MoonEcliptic(longitude: norm360(lp + sl / 1e6), latitude: sb / 1e6)
    }

    // MARK: - Sidereal (nirayana) longitudes

    /// Mean Lahiri ayanamsa in degrees.
    static func lahiriAyanamsa(_ jdUt: Double) -> Double {
        let t = centuriesTT(jdUt)
        return 23.857092 + (5028.796195 * t + 1.1054348 * t * t) / 3600.0
    }

    static func sunSidereal(_ jdUt: Double) -> Double {
        norm360(sunMeanEquinoxLongitude(centuriesTT(jdUt)) - lahiriAyanamsa(jdUt))
    }

    static func moonSidereal(_ jdUt: Double) -> Double {
        norm360(moonMeanEquinox(centuriesTT(jdUt)).longitude - lahiriAyanamsa(jdUt))
    }

    /// Moon − Sun, 0..360. Independent of the ayanamsa.
    static func elongation(_ jdUt: Double) -> Double {
        let t = centuriesTT(jdUt)
        return norm360(moonMeanEquinox(t).longitude - sunMeanEquinoxLongitude(t))
    }

    /// Sun + Moon (sidereal), 0..360 — the argument of the Yoga.
    static func yogaArgument(_ jdUt: Double) -> Double {
        norm360(sunSidereal(jdUt) + moonSidereal(jdUt))
    }

    // MARK: - Rising and setting

    private static func obliquity(_ t: Double) -> Double { 23.439291 - 0.0130042 * t }

    /// Greenwich mean sidereal time in degrees.
    private static func gmst(_ jdUt: Double) -> Double {
        let t = (jdUt - j2000) / 36525.0
        return norm360(280.46061837 + 360.98564736629 * (jdUt - j2000) + 0.000387933 * t * t - t * t * t / 38710000.0)
    }

    private static func altitude(
        _ jdUt: Double, latDeg: Double, lonDeg: Double, lambda: Double, beta: Double, t: Double
    ) -> Double {
        let eps = obliquity(t) * deg
        let l = lambda * deg
        let b = beta * deg
        let ra = atan2(sin(l) * cos(eps) - tan(b) * sin(eps), cos(l))
        let dec = asin(sin(b) * cos(eps) + cos(b) * sin(eps) * sin(l))
        let h = (gmst(jdUt) + lonDeg) * deg - ra
        let phi = latDeg * deg
        return asin(sin(phi) * sin(dec) + cos(phi) * cos(dec) * cos(h)) / deg
    }

    /// Apparent altitude of the Sun's centre, without refraction.
    static func sunAltitude(_ jdUt: Double, latDeg: Double, lonDeg: Double) -> Double {
        let t = centuriesTT(jdUt)
        return altitude(jdUt, latDeg: latDeg, lonDeg: lonDeg, lambda: sunMeanEquinoxLongitude(t), beta: 0.0, t: t)
    }

    /// Geocentric altitude of the Moon's centre, without refraction.
    static func moonAltitude(_ jdUt: Double, latDeg: Double, lonDeg: Double) -> Double {
        let t = centuriesTT(jdUt)
        let m = moonMeanEquinox(t)
        return altitude(jdUt, latDeg: latDeg, lonDeg: lonDeg, lambda: m.longitude, beta: m.latitude, t: t)
    }

    /// Standard altitudes for rise/set: the upper limb touching the
    /// horizon with 34′ of refraction, as used by most published
    /// Panchangams (Sun −0°50′; Moon +0°08′ geocentric, Meeus ch. 15).
    static let sunRiseAltitude = -0.8333
    static let moonRiseAltitude = 0.125

    /// Finds the first time in [startJd, endJd) when `altitudeFn` crosses
    /// `h0` in the requested direction. Scans in 20-minute steps and
    /// refines by bisection to well under a second.
    static func findCrossing(
        _ startJd: Double, _ endJd: Double, h0: Double, rising: Bool,
        _ altitudeFn: (Double) -> Double
    ) -> Double? {
        let step = 20.0 / 1440.0
        var a = startJd
        var fa = altitudeFn(a) - h0
        while a < endJd {
            let b = min(a + step, endJd)
            let fb = altitudeFn(b) - h0
            let crosses = rising ? (fa < 0 && fb >= 0) : (fa > 0 && fb <= 0)
            if crosses {
                var lo = a
                var hi = b
                var flo = fa
                for _ in 0..<30 {
                    let mid = (lo + hi) / 2
                    let fm = altitudeFn(mid) - h0
                    if (flo < 0) == (fm < 0) {
                        lo = mid
                        flo = fm
                    } else {
                        hi = mid
                    }
                }
                return (lo + hi) / 2
            }
            a = b
            fa = fb
        }
        return nil
    }

    // MARK: - Root finding on longitudes

    /// The next time at or after `fromJd` when the monotonically increasing
    /// angle `fn` reaches `target` (degrees). `rate` is its approximate
    /// mean motion in degrees/day, used for the initial guess.
    static func nextTimeAngleReaches(
        _ fromJd: Double, target: Double, rate: Double, _ fn: (Double) -> Double
    ) -> Double {
        var jd = fromJd + norm360(target - fn(fromJd)) / rate
        for _ in 0..<12 {
            let err = angleDiff(fn(jd), target)
            jd -= err / rate
            if abs(err) < 1e-7 { return jd }
        }
        return jd
    }

    /// The previous time at or before `fromJd` when `fn` equalled `target`.
    static func previousTimeAngleReached(
        _ fromJd: Double, target: Double, rate: Double, _ fn: (Double) -> Double
    ) -> Double {
        var jd = fromJd - norm360(fn(fromJd) - target) / rate
        for _ in 0..<12 {
            let err = angleDiff(fn(jd), target)
            jd -= err / rate
            if abs(err) < 1e-7 { return jd }
        }
        return jd
    }

    static let moonSunRate = 12.190749
    static let moonRate = 13.176358
    static let sunRate = 0.985647
    static let yogaRate = moonRate + sunRate
}
