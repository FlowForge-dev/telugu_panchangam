package com.panchangam.telugupanchangam.data

import com.panchangam.telugupanchangam.domain.Festival
import com.panchangam.telugupanchangam.domain.FestivalImportance
import com.panchangam.telugupanchangam.domain.FestivalImportance.MAJOR
import com.panchangam.telugupanchangam.domain.FestivalImportance.MODERATE
import com.panchangam.telugupanchangam.domain.FestivalImportance.OBSERVANCE
import com.panchangam.telugupanchangam.domain.SourceReference
import com.panchangam.telugupanchangam.domain.VerificationStatus
import com.panchangam.telugupanchangam.domain.VerificationStatus.COMPUTED
import com.panchangam.telugupanchangam.domain.VerificationStatus.PENDING_VERIFICATION
import com.panchangam.telugupanchangam.domain.VerificationStatus.VARIES_BY_TRADITION
import com.panchangam.telugupanchangam.domain.VerificationStatus.VERIFIED
import java.time.LocalDate

/**
 * Festival calendar for Parabhava Samvatsara (Ugadi 2026 → Ugadi 2027).
 *
 * Source priority, as reviewed in October 2026:
 *  1. Sri Sringeri Sharada Peetham — its own event pages and
 *     announcements on sringeri.net for the Parabhava year.
 *  2. The Governments of Andhra Pradesh and Telangana — the 2026
 *     general/optional holiday G.O.s, which fix the dates observed in
 *     the Telugu states.
 *  3. The 2026 Drik Panchang Hindu Calendar (Hyderabad, Amanta), the
 *     almanac the first version of this list was built from.
 *
 * Every date was also checked against the tithi at the relevant time
 * of day (sunrise, midday, afternoon, pradosha or midnight) for
 * Hyderabad, computed with this app's engine and the Swiss Ephemeris.
 * Tithi times quoted in notes are for Hyderabad, IST.
 *
 * Only date and name come from the sources. Significance is short
 * descriptive prose; mantra text and exact ritual rules are withheld.
 */
object FestivalData {

    // ---- Sources ------------------------------------------------------

    private fun sringeri(page: String, url: String) = SourceReference(
        title = page,
        publisher = "Sri Sringeri Sharada Peetham",
        url = url,
        status = VERIFIED
    )

    val sringeriEvents = SourceReference(
        title = "Event and announcement pages, Parabhava Samvatsara",
        publisher = "Sri Sringeri Sharada Peetham",
        url = "https://www.sringeri.net/events/past-events",
        notes = "Dates of observances held at Sringeri in 2026, as published by the Peetham.",
        status = VERIFIED
    )

    val apHolidays2026 = SourceReference(
        title = "General and optional holidays for 2026 — G.O.Rt.No.2276 (4 Dec 2025)",
        publisher = "Government of Andhra Pradesh, GA Department",
        notes = "Read from published copies of the G.O. and press reports of it; the official portal was not reachable for this review.",
        status = VERIFIED
    )

    val tsHolidays2026 = SourceReference(
        title = "General and optional holidays for 2026 — G.O.Rt.No.1715 (6 Dec 2025)",
        publisher = "Government of Telangana, GA Department",
        notes = "Read from press reports of the G.O. (Sakshi Education, The Hans India); the G.O. itself was not opened.",
        status = VERIFIED
    )

    val drikPanchang2026 = SourceReference(
        title = "2026 Drik Panchang Hindu Calendar",
        publisher = "Drik Panchang",
        edition = "v1.0.4, Hyderabad, Telangana (Amanta)",
        notes = "Confirms date and name only.",
        status = VERIFIED
    )

    val ttdHanuman = SourceReference(
        title = "TTD silk vastrams to Sri Japali Hanuman for Hanuman Jayanti, 12 May 2026",
        publisher = "Tirumala Tirupati Devasthanams (as reported by HinduPad)",
        notes = "Secondary report of the TTD observance; the TTD notice itself was not opened.",
        status = VARIES_BY_TRADITION
    )

    val ttdVaikunta = SourceReference(
        title = "Vaikunta Ekadasi at Tirumala on 20 Dec 2026; Vaikunta Dwaram open to 29 Dec",
        publisher = "Tirumala Tirupati Devasthanams (as reported by Tirupati Tirumala Info)",
        status = VERIFIED
    )

    val engine = SourceReference(
        title = "Astronomical computation (this app)",
        publisher = "Meeus algorithms, Lahiri ayanamsa — cross-checked with the Swiss Ephemeris",
        notes = "Tithi and solar-ingress times agree with the Swiss Ephemeris to about a minute. The traditional " +
            "rule applied is named in the date note. No published almanac was checked for this date.",
        status = COMPUTED
    )

    val secondary2027 = SourceReference(
        title = "Published 2027 calendars (Drik Panchang, Telugu Panchangam Daily and others)",
        notes = "Agree with this app's computation. The 2027 AP/Telangana holiday G.O.s and the Sringeri " +
            "Plavanga Panchanga were not available at the time of review.",
        status = PENDING_VERIFICATION
    )

    /** Every source that appears in the list, for the About screen. */
    val allSources: List<SourceReference>
        get() = listOf(sringeriEvents, apHolidays2026, tsHolidays2026, drikPanchang2026, ttdVaikunta, ttdHanuman, engine, secondary2027)

    /** First and last days of the Panchangam year this list covers. */
    val ugadiStart: LocalDate = LocalDate.of(2026, 3, 19)
    val nextUgadi: LocalDate = LocalDate.of(2027, 4, 7)

    private fun f(
        id: String, name: String, telugu: String, date: LocalDate, importance: FestivalImportance,
        short: String, significance: String, status: VerificationStatus, vararg sources: SourceReference,
        note: String? = null, observance: String? = null, preparation: String? = null
    ) = Festival(
        id = id, name = name, teluguName = telugu, date = date, importance = importance,
        shortSignificance = short, significance = significance, dateStatus = status, dateNote = note,
        observance = observance, preparation = preparation, sources = sources.toList()
    )

    private fun d(y: Int, m: Int, day: Int) = LocalDate.of(y, m, day)

    val festivals: List<Festival> = listOf(
        f(
            "ugadi", "Ugadi", "ఉగాది", d(2026, 3, 19), MAJOR,
            "Telugu New Year — Parabhava Samvatsara begins.",
            "Ugadi marks the start of the new year in the Telugu lunisolar calendar, on Chaitra Shukla Padyami. " +
                "It is widely observed with Ugadi pachadi, a dish of six tastes said to stand for the varied " +
                "experiences of the year ahead, and with the reading of the new year's Panchangam (Panchanga Shravanam).",
            VERIFIED, apHolidays2026, tsHolidays2026, drikPanchang2026,
            note = "Amavasya ended at 06:53, just after sunrise, and Padyami ran to 04:53 on 20 Mar without " +
                "touching a sunrise — so Ugadi is observed on this day.",
            observance = "Households commonly clean and decorate the home, wear new clothes, prepare Ugadi pachadi " +
                "and listen to the Panchanga Shravanam.",
            preparation = "Home cleaning, a mango-leaf toranam at the entrance, and the pachadi ingredients " +
                "(neem flowers, jaggery, tamarind, raw mango, chilli, salt)."
        ),
        f(
            "sri-rama-navami", "Sri Rama Navami", "శ్రీరామ నవమి", d(2026, 3, 27), MAJOR,
            "Birth of Sri Rama; Sitarama Kalyanam at Bhadrachalam.",
            "Observed as the birth anniversary of Sri Rama on Chaitra Shukla Navami. Many temples, most famously " +
                "Bhadrachalam, perform the Sitarama Kalyanam on this day.",
            VERIFIED,
            sringeri("Sri Rama Navami 2026", "https://www.sringeri.net/events/sri-rama-navami-2026"),
            apHolidays2026, tsHolidays2026,
            note = "Navami ran from 11:49 on 26 Mar to 10:07 on 27 Mar. Sringeri Peetham and both state " +
                "governments observe 27 Mar (Navami at sunrise). The Drik calendar lists 26 Mar, following the " +
                "midday-Navami rule — the earlier version of this app used that date."
        ),
        f(
            "hanuman-jayanti-chaitra", "Hanuman Jayanti (Chaitra Purnima)", "హనుమాన్ జయంతి (చైత్ర పౌర్ణమి)",
            d(2026, 4, 2), OBSERVANCE,
            "Hanuman Jayanti as observed in North India.",
            "Many regions observe Hanuman Jayanti on Chaitra Purnima. Telugu tradition and TTD observe it on " +
                "Vaishakha Bahula Dashami instead — see the 12 May entry.",
            VARIES_BY_TRADITION, drikPanchang2026
        ),
        f(
            "akshaya-tritiya", "Akshaya Tritiya", "అక్షయ తృతీయ", d(2026, 4, 19), MODERATE,
            "An auspicious day for new beginnings and giving.",
            "Vaishakha Shukla Tadiya, widely regarded as an auspicious day for new ventures, purchases and charity.",
            VERIFIED, drikPanchang2026,
            note = "Tadiya began at 10:49 and held through the forenoon and midday."
        ),
        f(
            "shankara-jayanti", "Sri Shankara Jayanti", "శ్రీ శంకర జయంతి", d(2026, 4, 21), MAJOR,
            "Birth anniversary of Sri Adi Shankaracharya.",
            "Vaishakha Shukla Panchami, celebrated as the Jayanti of Sri Adi Shankaracharya, founder of the " +
                "Sringeri Sharada Peetham. At Sringeri the Shankara Jayanti Mahotsava ran from 18 to 21 April, " +
                "with Kanakabhisheka to the Acharya's murti on the Jayanti day.",
            VERIFIED,
            sringeri("Sri Shankara Jayanti Mahotsava 2026", "https://www.sringeri.net/events/sri-shankara-jayanti-mahotsava-2026")
        ),
        f(
            "narasimha-jayanti", "Narasimha Jayanti", "నృసింహ జయంతి", d(2026, 4, 30), MODERATE,
            "Appearance of Sri Narasimha.",
            "Vaishakha Shukla Chaturdashi, observed as the appearance day of Sri Narasimha. At Sringeri a " +
                "Lakshmi Narasimha Homa was performed at Narasimhapura.",
            VERIFIED, sringeriEvents, drikPanchang2026,
            note = "Chaturdashi held at sunset (pradosha) on this day."
        ),
        f(
            "buddha-purnima", "Vaishakha Purnima", "వైశాఖ పౌర్ణమి", d(2026, 5, 1), MODERATE,
            "Full moon of Vaishakha; also Buddha Purnima.",
            "The full-moon day of Vaishakha masam, also observed as Buddha Purnima.",
            VERIFIED, drikPanchang2026
        ),
        f(
            "hanuman-jayanti", "Hanuman Jayanti", "హనుమజ్జయంతి", d(2026, 5, 12), MODERATE,
            "Hanuman Jayanti in the Telugu tradition.",
            "Telugu tradition observes Hanuman Jayanti on Vaishakha Bahula Dashami. TTD offers silk vastrams to " +
                "Sri Japali Hanuman at Tirumala on this day.",
            VARIES_BY_TRADITION, ttdHanuman, engine,
            note = "Dashami held at sunrise (Hyderabad). Other regions observe 2 Apr (Chaitra Purnima) or other dates."
        ),
        f(
            "adhika-jyeshtha", "Adhika Jyeshtha Masam begins", "అధిక జ్యేష్ఠ మాసం ప్రారంభం", d(2026, 5, 17), OBSERVANCE,
            "An intercalary month — no solar ingress falls within it.",
            "Parabhava has an extra lunar month. From 17 May to 15 Jun 2026 runs Adhika Jyeshtha; Nija Jyeshtha " +
                "follows from 16 Jun. Auspicious ceremonies are traditionally avoided in an adhika masam.",
            COMPUTED, engine,
            note = "The new moons of 17 May (01:31 IST) and 15 Jun (08:24 IST) both fall with the Sun in " +
                "Vrishabha, so no sankranti occurs between them."
        ),
        f(
            "nirjala-ekadashi", "Nirjala Ekadashi", "నిర్జల ఏకాదశి", d(2026, 6, 25), OBSERVANCE,
            "The most rigorous Ekadashi of the year.",
            "Nija Jyeshtha Shukla Ekadashi, observed by many with a waterless fast.",
            VERIFIED, drikPanchang2026
        ),
        f(
            "jagannath-rathayatra", "Jagannath Rathayatra", "జగన్నాథ రథయాత్ర", d(2026, 7, 16), MODERATE,
            "Chariot festival of Lord Jagannath.",
            "Ashadha Shukla Vidiya, the chariot procession of Lord Jagannath at Puri.",
            VERIFIED, drikPanchang2026
        ),
        f(
            "tholi-ekadashi", "Tholi Ekadashi", "తొలి ఏకాదశి", d(2026, 7, 25), MODERATE,
            "Shayana Ekadashi — the first Ekadashi, opening Chaturmasya.",
            "Ashadha Shukla Ekadashi, called Tholi (first) Ekadashi in the Telugu states and Devashayani Ekadashi " +
                "elsewhere; traditionally the start of the four-month Chaturmasya period.",
            VERIFIED, drikPanchang2026
        ),
        f(
            "guru-purnima", "Guru Purnima (Vyasa Purnima)", "గురు పౌర్ణమి", d(2026, 7, 29), MAJOR,
            "Vyasa Puja; Chaturmasya Vrata begins.",
            "Ashadha Purnima, observed as Vyasa Puja and a day of reverence for one's guru. At Sringeri the " +
                "Jagadguru performed Vyasa Puja and began the Chaturmasya Vrata on this day.",
            VERIFIED,
            sringeri("Vyasa Puja & Chaturmasya Vrata 2026", "https://www.sringeri.net/announcement/vyasa-puja-chaturmasya-vrata-2026"),
            drikPanchang2026
        ),
        f(
            "varalakshmi-vratam", "Varalakshmi Vratam", "వరలక్ష్మీ వ్రతం", d(2026, 8, 21), MAJOR,
            "Vratam to Goddess Varalakshmi on the Friday before Shravana Purnima.",
            "A widely observed vratam to Goddess Varalakshmi, performed on the Friday before Shravana Purnima.",
            VERIFIED, apHolidays2026, tsHolidays2026,
            note = "Both Telugu state governments list 21 Aug. Shravana Purnima itself fell on Friday 28 Aug, and " +
                "some calendars (including Drik) list 28 Aug — the earlier version of this app used that date."
        ),
        f(
            "shravana-purnima", "Shravana Purnima (Rakhi Pournami)", "రాఖీ పౌర్ణమి", d(2026, 8, 28), MODERATE,
            "Raksha Bandhan; also Jandhyala Pournami.",
            "The full-moon day of Shravana masam, observed as Raksha Bandhan, and as Jandhyala Pournami when the " +
                "sacred thread is renewed.",
            VERIFIED, tsHolidays2026, drikPanchang2026,
            note = "Purnima ran from 09:09 on 27 Aug to 09:48 on 28 Aug. Upakarma timing follows separate rules " +
                "and is not listed here."
        ),
        f(
            "krishna-janmashtami", "Sri Krishna Janmashtami", "శ్రీకృష్ణాష్టమి", d(2026, 9, 4), MAJOR,
            "Birth of Sri Krishna.",
            "Shravana Bahula Ashtami, observed as the birth of Sri Krishna, with fasting until midnight and " +
                "devotional singing. Sri Krishna Jayanti was celebrated at Sringeri on this day.",
            VERIFIED, sringeriEvents, drikPanchang2026
        ),
        f(
            "vinayaka-chavithi", "Vinayaka Chavithi", "వినాయక చవితి", d(2026, 9, 14), MAJOR,
            "Worship of Lord Ganesha.",
            "Bhadrapada Shukla Chavithi, a major household and community festival honouring Lord Ganesha. " +
                "Sringeri's Mahaganapati Vakyartha Vidwat Sabha opened on this day.",
            VERIFIED,
            sringeri("Mahaganapati Vakyartha Vidwat Sabha 2026", "https://www.sringeri.net/events/mahaganapati-vakyartha-vidwat-sabha-2026"),
            apHolidays2026, drikPanchang2026,
            note = "Chavithi began at 07:07, shortly after sunrise, and held through midday.",
            preparation = "Clay idol, patri (21 kinds of leaves) and kudumulu/undrallu; customs vary by family."
        ),
        f(
            "ananta-chaturdashi", "Ananta Chaturdashi · Ganesh Nimajjanam", "అనంత చతుర్దశి · గణేశ నిమజ్జనం",
            d(2026, 9, 25), MODERATE,
            "Ananta Padmanabha Vratam; Ganesha immersion.",
            "Bhadrapada Shukla Chaturdashi, when the Ananta Padmanabha Vratam is performed (observed at Sringeri " +
                "on this day) and community Ganesha idols are immersed.",
            VERIFIED, sringeriEvents, drikPanchang2026
        ),
        f(
            "mahalaya-amavasya", "Mahalaya Amavasya", "మహాలయ అమావాస్య", d(2026, 10, 10), MODERATE,
            "Close of Pitru Paksha; Engili Pula Bathukamma.",
            "The new moon closing Pitru Paksha, a day of offerings to ancestors. In Telangana it opens the " +
                "Bathukamma festival.",
            VERIFIED, apHolidays2026
        ),
        f(
            "sharan-navaratri", "Sharan Navaratri begins", "శరన్నవరాత్రులు ప్రారంభం", d(2026, 10, 11), MAJOR,
            "Nine nights honouring the Goddess.",
            "Ashvayuja Shukla Padyami opens Devi Navaratri. At Sringeri the Sri Sharada Sharannavaratri Mahotsava " +
                "ran from 11 to 22 October.",
            VERIFIED,
            sringeri("Sri Sharada Sharannavaratri Mahotsava 2026", "https://www.sringeri.net/announcement/sri-sharada-sharannavaratri-mahotsava-2026"),
            drikPanchang2026
        ),
        f(
            "saddula-bathukamma", "Saddula Bathukamma", "సద్దుల బతుకమ్మ", d(2026, 10, 18), MODERATE,
            "The grand finale of Bathukamma in Telangana.",
            "The last and largest day of Telangana's Bathukamma flower festival.",
            VERIFIED, tsHolidays2026,
            note = "Most reports of the Telangana G.O. give 18 Oct; one (The Hans India) gives 10 Oct."
        ),
        f(
            "mahanavami", "Mahanavami", "మహర్నవమి", d(2026, 10, 19), MODERATE,
            "Ninth day of Navaratri; Ayudha Puja.",
            "The ninth day of Navaratri, with Saraswati and Ayudha Puja in many homes.",
            VERIFIED, tsHolidays2026,
            note = "Navami began at 10:52 and held at midday. Sringeri's Chennai branch lists Mahanavami on 20 Oct."
        ),
        f(
            "vijayadashami", "Vijayadashami (Dasara)", "విజయదశమి", d(2026, 10, 20), MAJOR,
            "Dasara — the victory of good over evil.",
            "The culmination of Navaratri, associated with the victory of good over evil; Shami puja and " +
                "Aksharabhyasam are customary.",
            VARIES_BY_TRADITION, apHolidays2026, tsHolidays2026, drikPanchang2026,
            SourceReference(
                title = "Navaratri 2026 programme — Bharathi Vidyashram, Chennai",
                publisher = "Sri Sringeri Sharada Peetham (branch)",
                url = "https://www.sringeri.net/branches-navaratri-2026/chennai-bharathividyashram",
                status = VARIES_BY_TRADITION
            ),
            note = "Dashami ran from 12:50 on 20 Oct to 14:12 on 21 Oct, so it held in the afternoon on both " +
                "days. Andhra Pradesh and Telangana observe 20 Oct. Sringeri Peetham's Chennai branch lists " +
                "Vijayadashami on 21 Oct; the main Sringeri schedule could not be read for this review."
        ),
        f(
            "sharad-purnima", "Sharad Purnima", "శరత్ పౌర్ణమి", d(2026, 10, 25), MODERATE,
            "Full moon of Ashvayuja; Kojagara.",
            "The full-moon day of Ashvayuja masam, observed as Kojagara Puja in several traditions.",
            VERIFIED, drikPanchang2026,
            note = "Purnima began at 11:56 and held through the night."
        ),
        f(
            "dhanteras", "Dhana Trayodashi", "ధనత్రయోదశి", d(2026, 11, 6), MODERATE,
            "Opens the Deepavali festival days.",
            "Ashvayuja Bahula Trayodashi, regarded as auspicious for purchases and opening the Deepavali days.",
            VERIFIED, drikPanchang2026
        ),
        f(
            "naraka-chaturdashi", "Naraka Chaturdashi", "నరక చతుర్దశి", d(2026, 11, 8), MODERATE,
            "Commemorates the defeat of Narakasura.",
            "Ashvayuja Bahula Chaturdashi, marked with an early-morning oil bath. This year it falls on the same " +
                "day as Deepavali.",
            VERIFIED, tsHolidays2026,
            note = "Chaturdashi held at sunrise and ended at 11:28; Amavasya followed and held at dusk."
        ),
        f(
            "deepavali", "Deepavali", "దీపావళి", d(2026, 11, 8), MAJOR,
            "Festival of lights; Lakshmi Puja.",
            "Widely observed festival of lights, marked with diyas, Lakshmi Puja on the Amavasya evening, " +
                "sweets and family gatherings.",
            VERIFIED, apHolidays2026, tsHolidays2026, drikPanchang2026,
            note = "Karnataka lists its Deepavali holiday on Bali Padyami, 10 Nov.",
            preparation = "Home cleaning and decoration with diyas and muggulu."
        ),
        f(
            "bali-padyami", "Bali Padyami", "బలిపాడ్యమి", d(2026, 11, 10), MODERATE,
            "Karthika Shukla Padyami; Govardhan Puja.",
            "The first day of Karthika masam, observed as Bali Padyami and Govardhan Puja.",
            VERIFIED, drikPanchang2026,
            note = "Amavasya held at sunrise on 9 Nov; Padyami held at sunrise on 10 Nov."
        ),
        f(
            "karthika-masam", "Karthika Masam begins", "కార్తీక మాసం ప్రారంభం", d(2026, 11, 10), OBSERVANCE,
            "The month of lamps, Karthika Somavarams and Shiva worship.",
            "Karthika masam runs from 10 Nov to 8 Dec 2026. Its Mondays (Karthika Somavaram) are widely observed " +
                "with fasting and Shiva worship.",
            COMPUTED, engine
        ),
        f(
            "uttana-ekadashi", "Uttana Ekadashi", "ఉత్థాన ఏకాదశి", d(2026, 11, 20), OBSERVANCE,
            "Prabodhini Ekadashi — close of Chaturmasya.",
            "Karthika Shukla Ekadashi, when Vishnu is said to wake; traditionally the close of Chaturmasya.",
            VARIES_BY_TRADITION, drikPanchang2026,
            note = "Ekadashi began at 07:16 on 20 Nov and ended at 06:31 on 21 Nov, so it held at sunrise only on " +
                "21 Nov, and only for minutes. The Drik calendar lists 20 Nov; the sunrise rule points to 21 Nov. " +
                "Follow your family or temple Panchangam."
        ),
        f(
            "ksheerabdi-dwadashi", "Ksheerabdi Dwadashi", "క్షీరాబ్ది ద్వాదశి", d(2026, 11, 21), MODERATE,
            "Tulasi Vivah — the ceremonial wedding of Tulasi.",
            "Karthika Shukla Dwadashi, observed in Telugu homes with Tulasi puja (Tulasi Vivah) and lamps.",
            VERIFIED, drikPanchang2026
        ),
        f(
            "karthika-pournami", "Karthika Pournami", "కార్తీక పౌర్ణమి", d(2026, 11, 24), MAJOR,
            "Full moon of Karthika; lamps at temples and rivers.",
            "The full-moon day of Karthika masam, traditionally marked by lighting lamps (365 vattulu) at home, " +
                "in temples and on rivers.",
            VERIFIED, tsHolidays2026, drikPanchang2026
        ),
        f(
            "vivah-panchami", "Vivaha Panchami", "వివాహ పంచమి", d(2026, 12, 14), OBSERVANCE,
            "Wedding anniversary of Sri Rama and Sita.",
            "Margashira Shukla Panchami, commemorating the wedding of Sri Rama and Sita.",
            VERIFIED, drikPanchang2026
        ),
        f(
            "subrahmanya-shashti", "Subrahmanya Shashti", "సుబ్రహ్మణ్య షష్ఠి", d(2026, 12, 15), MODERATE,
            "Dedicated to Lord Subrahmanya.",
            "Margashira Shukla Shashti, dedicated to Lord Subrahmanya (Skanda/Kartikeya).",
            VERIFIED, drikPanchang2026
        ),
        f(
            "dhanurmasam", "Dhanurmasam begins", "ధనుర్మాసం ప్రారంభం", d(2026, 12, 16), OBSERVANCE,
            "Sun enters Dhanus — month of Tiruppavai and dawn worship.",
            "The Sun's entry into Dhanu rashi opens Dhanurmasam, observed with dawn temple worship and the " +
                "recitation of Tiruppavai. It ends at Makara Sankranti.",
            VERIFIED, drikPanchang2026, engine,
            note = "Dhanu sankranti at 10:25 IST."
        ),
        f(
            "mukkoti-ekadashi", "Mukkoti Ekadashi (Vaikunta Ekadashi)", "ముక్కోటి ఏకాదశి", d(2026, 12, 20), MAJOR,
            "Vaikunta Dwara darshan; also Gita Jayanti.",
            "Margashira Shukla Ekadashi, observed with darshan through the northern Vaikunta Dwaram at Vishnu " +
                "temples. Gita Jayanti falls on the same day.",
            VERIFIED, ttdVaikunta, drikPanchang2026,
            note = "Ekadashi ran from 22:09 on 19 Dec to 20:15 on 20 Dec."
        ),
        f(
            "dattatreya-jayanti", "Dattatreya Jayanti", "దత్తాత్రేయ జయంతి", d(2026, 12, 23), MODERATE,
            "Appearance of Lord Dattatreya.",
            "Margashira Purnima evening, observed as the appearance day of Lord Dattatreya.",
            VERIFIED, drikPanchang2026,
            note = "Purnima began at 10:47 and held at dusk."
        ),
        f(
            "margashira-purnima", "Margashira Purnima", "మార్గశిర పౌర్ణమి", d(2026, 12, 24), OBSERVANCE,
            "Full moon of Margashira.",
            "The full-moon day of Margashira masam.",
            VERIFIED, drikPanchang2026,
            note = "Purnima ended at 06:58, a few minutes after sunrise; many observe the Purnima vratam on 23 Dec."
        ),
        f(
            "bhogi", "Bhogi", "భోగి", d(2027, 1, 14), MAJOR,
            "First day of Sankranti — Bhogi bonfire.",
            "The day before Makara Sankranti, marked by the early-morning Bhogi bonfire and Bhogi pallu for children.",
            PENDING_VERIFICATION, secondary2027, engine,
            note = "Day before Makara Sankranti (see below)."
        ),
        f(
            "sankranthi", "Makara Sankranti", "మకర సంక్రాంతి", d(2027, 1, 15), MAJOR,
            "Harvest festival — the Sun enters Makara.",
            "The Sun's entry into Makara rashi, beginning Uttarayana; the main day of the three-day harvest festival.",
            PENDING_VERIFICATION, secondary2027, engine,
            note = "Makara sankranti occurs at 21:10 IST on 14 Jan, after sunset, so the punyakalam and festival " +
                "fall on 15 Jan. The earlier version of this app estimated 14 Jan.",
            preparation = "Home cleaning, muggulu with gobbemmalu, and harvest preparations."
        ),
        f(
            "kanuma", "Kanuma", "కనుమ", d(2027, 1, 16), MODERATE,
            "Third day of Sankranti — honouring cattle.",
            "The day after Makara Sankranti, when cattle are decorated and honoured.",
            PENDING_VERIFICATION, engine,
            note = "Day after Makara Sankranti."
        ),
        f(
            "maha-shivaratri", "Maha Shivaratri", "మహా శివరాత్రి", d(2027, 3, 6), MAJOR,
            "Night of Lord Shiva.",
            "Magha Bahula Chaturdashi, marked with fasting, abhishekam and a night-long vigil.",
            PENDING_VERIFICATION, secondary2027, engine,
            note = "Chaturdashi ran from 12:04 on 6 Mar to 13:46 on 7 Mar and held at midnight (nishita) only on " +
                "the night of 6 Mar. The earlier version of this app estimated 15 Feb, which was wrong."
        ),
        f(
            "ugadi-next", "Ugadi", "ఉగాది", d(2027, 4, 7), MAJOR,
            "Telugu New Year — Plavanga Samvatsara begins.",
            "Chaitra Shukla Padyami, the start of Plavanga Samvatsara.",
            PENDING_VERIFICATION, secondary2027, engine,
            note = "Amavasya ended at 05:21, before sunrise, so Padyami holds at sunrise on 7 Apr."
        )
    ).sortedBy { it.date }
}
