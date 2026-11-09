package com.panchangam.telugupanchangam.astro

import kotlin.math.PI
import kotlin.math.abs
import kotlin.math.asin
import kotlin.math.atan2
import kotlin.math.cos
import kotlin.math.floor
import kotlin.math.sin

/**
 * Positional astronomy for the Panchangam, after Jean Meeus,
 * *Astronomical Algorithms* (2nd ed.):
 *
 *  - Sun: chapter 25 (low-accuracy theory, ~0.01°).
 *  - Moon: chapter 47 (ELP-2000/82 truncated, ~10″ in longitude).
 *  - Lahiri (Chitrapaksha) ayanamsa: the mean value as used by the
 *    Swiss Ephemeris `SIDM_LAHIRI` mode, 23.857092° at J2000 plus
 *    general precession in longitude.
 *
 * Sidereal longitudes are mean-equinox longitudes minus the mean
 * ayanamsa, which is exactly what Swiss Ephemeris returns for
 * `FLG_SIDEREAL` (nutation cancels).
 *
 * Every function takes a Julian Day in Universal Time; the TT
 * correction (ΔT) is applied internally.
 */
object Astronomy {

    private const val DEG = PI / 180.0
    const val J2000 = 2451545.0

    fun norm360(x: Double): Double {
        val r = x % 360.0
        return if (r < 0) r + 360.0 else r
    }

    /** Signed difference a − b folded into (−180, 180]. */
    fun angleDiff(a: Double, b: Double): Double {
        var d = norm360(a - b)
        if (d > 180.0) d -= 360.0
        return d
    }

    /**
     * ΔT = TT − UT in seconds. Observed values from IERS for the recent
     * past; a gentle extrapolation beyond. Errors of a few seconds move
     * the Moon by ~1″ and are immaterial for Panchangam purposes.
     */
    fun deltaTSeconds(jdUt: Double): Double {
        val year = 2000.0 + (jdUt - J2000) / 365.25
        return when {
            year < 1986 -> 45.45 + 1.067 * (year - 1975) - (year - 1975) * (year - 1975) / 260.0
            year < 2005 -> 63.86 + 0.3345 * (year - 2000) - 0.060374 * (year - 2000) * (year - 2000)
            year < 2025 -> 64.69 + 0.2 * (year - 2005)
            else -> 69.0 + 0.1 * (year - 2025)
        }
    }

    private fun centuriesTT(jdUt: Double): Double =
        (jdUt + deltaTSeconds(jdUt) / 86400.0 - J2000) / 36525.0

    // ------------------------------------------------------------------
    // Sun
    // ------------------------------------------------------------------

    /** Geometric mean-equinox longitude of the Sun, with aberration. */
    private fun sunMeanEquinoxLongitude(t: Double): Double {
        val l0 = 280.46646 + 36000.76983 * t + 0.0003032 * t * t
        val m = (357.52911 + 35999.05029 * t - 0.0001537 * t * t) * DEG
        val c = (1.914602 - 0.004817 * t - 0.000014 * t * t) * sin(m) +
            (0.019993 - 0.000101 * t) * sin(2 * m) +
            0.000289 * sin(3 * m)
        // Perturbations by Venus, Jupiter and the Moon, plus a long-period
        // term (Meeus, *Astronomical Formulae for Calculators*, ch. 18;
        // arguments counted from 1900.0, hence t + 1).
        val t1 = t + 1.0
        val p = 0.00134 * cos((153.23 + 22518.7541 * t1) * DEG) +
            0.00154 * cos((216.57 + 45037.5082 * t1) * DEG) +
            0.00200 * cos((312.69 + 32964.3577 * t1) * DEG) +
            0.00179 * sin((350.74 + 445267.1142 * t1) * DEG) +
            0.00178 * sin((231.19 + 20.20 * t1) * DEG)
        return norm360(l0 + c + p - 0.00569)
    }

    // ------------------------------------------------------------------
    // Moon
    // ------------------------------------------------------------------

    // Meeus table 47.A: D, M, M', F, Σl (1e-6°). Distance terms omitted.
    private val moonLon = intArrayOf(
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
        1, 1, -1, 0, 299, 2, 0, 3, 0, 294
    )

    // Meeus table 47.B: D, M, M', F, Σb (1e-6°).
    private val moonLat = intArrayOf(
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
        1, 0, -1, -1, -119, 4, -1, 0, -1, 115, 2, -2, 0, 1, 107
    )

    private class MoonEcliptic(val longitude: Double, val latitude: Double)

    private fun moonMeanEquinox(t: Double): MoonEcliptic {
        val t2 = t * t
        val t3 = t2 * t
        val t4 = t3 * t
        val lp = norm360(218.3164477 + 481267.88123421 * t - 0.0015786 * t2 + t3 / 538841.0 - t4 / 65194000.0)
        val d = norm360(297.8501921 + 445267.1114034 * t - 0.0018819 * t2 + t3 / 545868.0 - t4 / 113065000.0)
        val m = norm360(357.5291092 + 35999.0502909 * t - 0.0001536 * t2 + t3 / 24490000.0)
        val mp = norm360(134.9633964 + 477198.8675055 * t + 0.0087414 * t2 + t3 / 69699.0 - t4 / 14712000.0)
        val f = norm360(93.2720950 + 483202.0175233 * t - 0.0036539 * t2 - t3 / 3526000.0 + t4 / 863310000.0)
        val a1 = norm360(119.75 + 131.849 * t)
        val a2 = norm360(53.09 + 479264.290 * t)
        val a3 = norm360(313.45 + 481266.484 * t)
        val e = 1.0 - 0.002516 * t - 0.0000074 * t2

        fun series(table: IntArray): Double {
            var sum = 0.0
            var i = 0
            while (i < table.size) {
                val cm = table[i + 1]
                val arg = (table[i] * d + cm * m + table[i + 2] * mp + table[i + 3] * f) * DEG
                val ecc = when (abs(cm)) { 1 -> e; 2 -> e * e; else -> 1.0 }
                sum += table[i + 4] * ecc * sin(arg)
                i += 5
            }
            return sum
        }

        val sl = series(moonLon) +
            3958 * sin(a1 * DEG) + 1962 * sin((lp - f) * DEG) + 318 * sin(a2 * DEG)
        val sb = series(moonLat) -
            2235 * sin(lp * DEG) + 382 * sin(a3 * DEG) + 175 * sin((a1 - f) * DEG) +
            175 * sin((a1 + f) * DEG) + 127 * sin((lp - mp) * DEG) - 115 * sin((lp + mp) * DEG)

        return MoonEcliptic(norm360(lp + sl / 1e6), sb / 1e6)
    }

    // ------------------------------------------------------------------
    // Sidereal (nirayana) longitudes
    // ------------------------------------------------------------------

    /** Mean Lahiri ayanamsa in degrees. */
    fun lahiriAyanamsa(jdUt: Double): Double {
        val t = centuriesTT(jdUt)
        return 23.857092 + (5028.796195 * t + 1.1054348 * t * t) / 3600.0
    }

    fun sunSidereal(jdUt: Double): Double =
        norm360(sunMeanEquinoxLongitude(centuriesTT(jdUt)) - lahiriAyanamsa(jdUt))

    fun moonSidereal(jdUt: Double): Double =
        norm360(moonMeanEquinox(centuriesTT(jdUt)).longitude - lahiriAyanamsa(jdUt))

    /** Moon − Sun, 0..360. Independent of the ayanamsa. */
    fun elongation(jdUt: Double): Double {
        val t = centuriesTT(jdUt)
        return norm360(moonMeanEquinox(t).longitude - sunMeanEquinoxLongitude(t))
    }

    /** Sun + Moon (sidereal), 0..360 — the argument of the Yoga. */
    fun yogaArgument(jdUt: Double): Double = norm360(sunSidereal(jdUt) + moonSidereal(jdUt))

    // ------------------------------------------------------------------
    // Rising and setting
    // ------------------------------------------------------------------

    private fun obliquity(t: Double): Double = 23.439291 - 0.0130042 * t

    /** Greenwich mean sidereal time in degrees. */
    private fun gmst(jdUt: Double): Double {
        val t = (jdUt - J2000) / 36525.0
        return norm360(280.46061837 + 360.98564736629 * (jdUt - J2000) + 0.000387933 * t * t - t * t * t / 38710000.0)
    }

    private fun altitude(jdUt: Double, latDeg: Double, lonDeg: Double, lambda: Double, beta: Double, t: Double): Double {
        val eps = obliquity(t) * DEG
        val l = lambda * DEG
        val b = beta * DEG
        val ra = atan2(sin(l) * cos(eps) - kotlin.math.tan(b) * sin(eps), cos(l))
        val dec = asin(sin(b) * cos(eps) + cos(b) * sin(eps) * sin(l))
        val h = (gmst(jdUt) + lonDeg) * DEG - ra
        val phi = latDeg * DEG
        return asin(sin(phi) * sin(dec) + cos(phi) * cos(dec) * cos(h)) / DEG
    }

    /** Apparent altitude of the Sun's centre, without refraction. */
    fun sunAltitude(jdUt: Double, latDeg: Double, lonDeg: Double): Double {
        val t = centuriesTT(jdUt)
        return altitude(jdUt, latDeg, lonDeg, sunMeanEquinoxLongitude(t), 0.0, t)
    }

    /** Geocentric altitude of the Moon's centre, without refraction. */
    fun moonAltitude(jdUt: Double, latDeg: Double, lonDeg: Double): Double {
        val t = centuriesTT(jdUt)
        val m = moonMeanEquinox(t)
        return altitude(jdUt, latDeg, lonDeg, m.longitude, m.latitude, t)
    }

    /**
     * Standard altitudes for rise/set: the upper limb touching the
     * horizon with 34′ of refraction, as used by most published
     * Panchangams (Sun −0°50′; Moon +0°08′ geocentric, Meeus ch. 15).
     */
    const val SUN_RISE_ALTITUDE = -0.8333
    const val MOON_RISE_ALTITUDE = 0.125

    /**
     * Finds the first time in [startJd, endJd) when [altitudeFn] crosses
     * [h0] in the requested direction. Scans in 20-minute steps and
     * refines by bisection to well under a second.
     */
    fun findCrossing(startJd: Double, endJd: Double, h0: Double, rising: Boolean, altitudeFn: (Double) -> Double): Double? {
        val step = 20.0 / 1440.0
        var a = startJd
        var fa = altitudeFn(a) - h0
        while (a < endJd) {
            val b = minOf(a + step, endJd)
            val fb = altitudeFn(b) - h0
            val crosses = if (rising) fa < 0 && fb >= 0 else fa > 0 && fb <= 0
            if (crosses) {
                var lo = a
                var hi = b
                var flo = fa
                repeat(30) {
                    val mid = (lo + hi) / 2
                    val fm = altitudeFn(mid) - h0
                    if ((flo < 0) == (fm < 0)) { lo = mid; flo = fm } else hi = mid
                }
                return (lo + hi) / 2
            }
            a = b
            fa = fb
        }
        return null
    }

    // ------------------------------------------------------------------
    // Root finding on longitudes
    // ------------------------------------------------------------------

    /**
     * The next time at or after [fromJd] when the monotonically increasing
     * angle [fn] reaches [target] (degrees). [rate] is its approximate
     * mean motion in degrees/day, used for the initial guess.
     */
    fun nextTimeAngleReaches(fromJd: Double, target: Double, rate: Double, fn: (Double) -> Double): Double {
        var jd = fromJd + norm360(target - fn(fromJd)) / rate
        repeat(12) {
            val err = angleDiff(fn(jd), target)
            jd -= err / rate
            if (abs(err) < 1e-7) return jd
        }
        return jd
    }

    /** The previous time at or before [fromJd] when [fn] equalled [target]. */
    fun previousTimeAngleReached(fromJd: Double, target: Double, rate: Double, fn: (Double) -> Double): Double {
        var jd = fromJd - norm360(fn(fromJd) - target) / rate
        repeat(12) {
            val err = angleDiff(fn(jd), target)
            jd -= err / rate
            if (abs(err) < 1e-7) return jd
        }
        return jd
    }

    const val MOON_SUN_RATE = 12.190749
    const val MOON_RATE = 13.176358
    const val SUN_RATE = 0.985647
    const val YOGA_RATE = MOON_RATE + SUN_RATE

    fun floorDiv(x: Double, size: Double): Int = floor(x / size).toInt()
}
