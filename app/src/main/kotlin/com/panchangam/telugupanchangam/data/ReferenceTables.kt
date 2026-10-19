package com.panchangam.telugupanchangam.data

import com.panchangam.telugupanchangam.domain.Karana
import com.panchangam.telugupanchangam.domain.Nakshatra
import com.panchangam.telugupanchangam.domain.PanchangYoga
import com.panchangam.telugupanchangam.domain.Rashi
import com.panchangam.telugupanchangam.domain.Samvatsara
import com.panchangam.telugupanchangam.domain.Tithi

/**
 * Fixed reference tables — the standard names and ordering of Tithis,
 * Nakshatras, Yogas, Karanas, Rashis and the sixty Samvatsaras. These
 * are stable, well-documented lists, not calculated values.
 */
object ReferenceTables {

    private val tithiNames = listOf(
        "Padyami" to "పాడ్యమి", "Vidiya" to "విదియ", "Tadiya" to "తదియ", "Chavithi" to "చవితి",
        "Panchami" to "పంచమి", "Shashti" to "షష్ఠి", "Saptami" to "సప్తమి", "Ashtami" to "అష్టమి",
        "Navami" to "నవమి", "Dashami" to "దశమి", "Ekadashi" to "ఏకాదశి", "Dwadashi" to "ద్వాదశి",
        "Trayodashi" to "త్రయోదశి", "Chaturdashi" to "చతుర్దశి"
    )

    /** All thirty tithis, numbered 1..30 (Shukla Padyami .. Amavasya). */
    val tithis: List<Tithi> = (1..30).map { n ->
        when (n) {
            15 -> Tithi(15, "Purnima", "పౌర్ణమి")
            30 -> Tithi(30, "Amavasya", "అమావాస్య")
            else -> tithiNames[(n - 1) % 15].let { Tithi(n, it.first, it.second) }
        }
    }

    val nakshatras = listOf(
        Nakshatra(1, "Ashwini", "అశ్విని"), Nakshatra(2, "Bharani", "భరణి"),
        Nakshatra(3, "Krittika", "కృత్తిక"), Nakshatra(4, "Rohini", "రోహిణి"),
        Nakshatra(5, "Mrigashira", "మృగశిర"), Nakshatra(6, "Ardra", "ఆరుద్ర"),
        Nakshatra(7, "Punarvasu", "పునర్వసు"), Nakshatra(8, "Pushyami", "పుష్యమి"),
        Nakshatra(9, "Ashlesha", "ఆశ్లేష"), Nakshatra(10, "Magha", "మఖ"),
        Nakshatra(11, "Pubba", "పుబ్బ"), Nakshatra(12, "Uttara", "ఉత్తర"),
        Nakshatra(13, "Hasta", "హస్త"), Nakshatra(14, "Chitta", "చిత్త"),
        Nakshatra(15, "Swati", "స్వాతి"), Nakshatra(16, "Vishakha", "విశాఖ"),
        Nakshatra(17, "Anuradha", "అనూరాధ"), Nakshatra(18, "Jyeshta", "జ్యేష్ఠ"),
        Nakshatra(19, "Moola", "మూల"), Nakshatra(20, "Purvashadha", "పూర్వాషాఢ"),
        Nakshatra(21, "Uttarashadha", "ఉత్తరాషాఢ"), Nakshatra(22, "Shravanam", "శ్రవణం"),
        Nakshatra(23, "Dhanishta", "ధనిష్ఠ"), Nakshatra(24, "Shatabhisham", "శతభిషం"),
        Nakshatra(25, "Purvabhadra", "పూర్వాభాద్ర"), Nakshatra(26, "Uttarabhadra", "ఉత్తరాభాద్ర"),
        Nakshatra(27, "Revati", "రేవతి")
    )

    val yogas = listOf(
        PanchangYoga(1, "Vishkambha", "విష్కంభ"), PanchangYoga(2, "Priti", "ప్రీతి"),
        PanchangYoga(3, "Ayushman", "ఆయుష్మాన్"), PanchangYoga(4, "Saubhagya", "సౌభాగ్య"),
        PanchangYoga(5, "Shobhana", "శోభన"), PanchangYoga(6, "Atiganda", "అతిగండ"),
        PanchangYoga(7, "Sukarma", "సుకర్మ"), PanchangYoga(8, "Dhriti", "ధృతి"),
        PanchangYoga(9, "Shoola", "శూల"), PanchangYoga(10, "Ganda", "గండ"),
        PanchangYoga(11, "Vriddhi", "వృద్ధి"), PanchangYoga(12, "Dhruva", "ధ్రువ"),
        PanchangYoga(13, "Vyaghata", "వ్యాఘాత"), PanchangYoga(14, "Harshana", "హర్షణ"),
        PanchangYoga(15, "Vajra", "వజ్ర"), PanchangYoga(16, "Siddhi", "సిద్ధి"),
        PanchangYoga(17, "Vyatipata", "వ్యతీపాత"), PanchangYoga(18, "Variyan", "వరీయాన్"),
        PanchangYoga(19, "Parigha", "పరిఘ"), PanchangYoga(20, "Shiva", "శివ"),
        PanchangYoga(21, "Siddha", "సిద్ధ"), PanchangYoga(22, "Sadhya", "సాధ్య"),
        PanchangYoga(23, "Shubha", "శుభ"), PanchangYoga(24, "Shukla", "శుక్ల"),
        PanchangYoga(25, "Brahma", "బ్రహ్మ"), PanchangYoga(26, "Indra", "ఐంద్ర"),
        PanchangYoga(27, "Vaidhriti", "వైధృతి")
    )

    private val kimstughna = Karana("Kimstughna", "కింస్తుఘ్న")
    private val movableKaranas = listOf(
        Karana("Bava", "బవ"), Karana("Balava", "బాలవ"), Karana("Kaulava", "కౌలవ"),
        Karana("Taitila", "తైతుల"), Karana("Garaja", "గరజి"), Karana("Vanija", "వణిజ"),
        Karana("Vishti (Bhadra)", "విష్టి (భద్ర)")
    )
    private val shakuni = Karana("Shakuni", "శకుని")
    private val chatushpada = Karana("Chatushpada", "చతుష్పాత్")
    private val naga = Karana("Naga", "నాగవ")

    /**
     * Karana for half-tithi [k] (0..59, counted from the new moon): the
     * first half of Shukla Padyami is Kimstughna, then the seven movable
     * karanas repeat eight times, and the last three halves are Shakuni,
     * Chatushpada and Naga.
     */
    fun karana(k: Int): Karana = when (k) {
        0 -> kimstughna
        57 -> shakuni
        58 -> chatushpada
        59 -> naga
        else -> movableKaranas[(k - 1) % 7]
    }

    val rashis = listOf(
        Rashi(1, "Mesha", "మేషం"), Rashi(2, "Vrishabha", "వృషభం"), Rashi(3, "Mithuna", "మిథునం"),
        Rashi(4, "Karkataka", "కర్కాటకం"), Rashi(5, "Simha", "సింహం"), Rashi(6, "Kanya", "కన్య"),
        Rashi(7, "Tula", "తుల"), Rashi(8, "Vrishchika", "వృశ్చికం"), Rashi(9, "Dhanus", "ధనుస్సు"),
        Rashi(10, "Makara", "మకరం"), Rashi(11, "Kumbha", "కుంభం"), Rashi(12, "Meena", "మీనం")
    )

    private val samvatsaraNames = listOf(
        "Prabhava" to "ప్రభవ", "Vibhava" to "విభవ", "Shukla" to "శుక్ల", "Pramoduta" to "ప్రమోదూత",
        "Prajotpatti" to "ప్రజోత్పత్తి", "Angirasa" to "ఆంగీరస", "Shrimukha" to "శ్రీముఖ", "Bhava" to "భావ",
        "Yuva" to "యువ", "Dhatu" to "ధాత", "Ishvara" to "ఈశ్వర", "Bahudhanya" to "బహుధాన్య",
        "Pramadi" to "ప్రమాది", "Vikrama" to "విక్రమ", "Vrisha" to "వృష", "Chitrabhanu" to "చిత్రభాను",
        "Svabhanu" to "స్వభాను", "Tarana" to "తారణ", "Parthiva" to "పార్థివ", "Vyaya" to "వ్యయ",
        "Sarvajit" to "సర్వజిత్", "Sarvadhari" to "సర్వధారి", "Virodhi" to "విరోధి", "Vikruti" to "వికృతి",
        "Khara" to "ఖర", "Nandana" to "నందన", "Vijaya" to "విజయ", "Jaya" to "జయ",
        "Manmatha" to "మన్మథ", "Durmukhi" to "దుర్ముఖి", "Hevilambi" to "హేవిళంబి", "Vilambi" to "విళంబి",
        "Vikari" to "వికారి", "Sharvari" to "శార్వరి", "Plava" to "ప్లవ", "Shubhakrit" to "శుభకృత్",
        "Shobhakrit" to "శోభకృత్", "Krodhi" to "క్రోధి", "Vishvavasu" to "విశ్వావసు", "Parabhava" to "పరాభవ",
        "Plavanga" to "ప్లవంగ", "Kilaka" to "కీలక", "Saumya" to "సౌమ్య", "Sadharana" to "సాధారణ",
        "Virodhikrit" to "విరోధికృత్", "Paridhavi" to "పరీధావి", "Pramadicha" to "ప్రమాదీచ", "Ananda" to "ఆనంద",
        "Rakshasa" to "రాక్షస", "Nala" to "నల", "Pingala" to "పింగళ", "Kalayukti" to "కాళయుక్తి",
        "Siddharthi" to "సిద్ధార్థి", "Raudri" to "రౌద్రి", "Durmati" to "దుర్మతి", "Dundubhi" to "దుందుభి",
        "Rudhirodgari" to "రుధిరోద్గారి", "Raktakshi" to "రక్తాక్షి", "Krodhana" to "క్రోధన", "Akshaya" to "అక్షయ"
    )

    /**
     * Samvatsara of a Shaka year as used in the Telugu (southern, lunar)
     * reckoning: Shaka 1948 (Ugadi 2026 – Ugadi 2027) is Parabhava, the
     * 40th — matching the year name in Sringeri Sharada Peetham's own
     * 2026 announcements.
     */
    fun samvatsara(shakaYear: Int): Samvatsara {
        val i = Math.floorMod(shakaYear + 11, 60)
        val (name, telugu) = samvatsaraNames[i]
        return Samvatsara(i + 1, name, telugu)
    }

    /** Standard day-Choghadiya starting name per weekday (Sunday = 0). */
    private val dayCycle = listOf("Udveg", "Chal", "Labh", "Amrit", "Kaal", "Shubh", "Rog")
    private val dayStart = listOf(0, 3, 6, 2, 5, 1, 4)

    /** The eight day-Choghadiya names for a weekday (Sunday = 0). */
    fun dayChoghadiya(weekday: Int): List<String> =
        (0 until 8).map { dayCycle[(dayStart[weekday] + it) % 7] }

    /**
     * Night Choghadiyas run through the cycle in steps of −2 (mod 7),
     * starting from the name that opens the day four weekdays later.
     */
    fun nightChoghadiya(weekday: Int): List<String> {
        val first = dayStart[(weekday + 4) % 7]
        return (0 until 8).map { dayCycle[Math.floorMod(first - 2 * it, 7)] }
    }

    val choghadiyaTelugu = mapOf(
        "Udveg" to "ఉద్వేగ", "Chal" to "చర", "Labh" to "లాభ", "Amrit" to "అమృత",
        "Kaal" to "కాల", "Shubh" to "శుభ", "Rog" to "రోగ"
    )
}
