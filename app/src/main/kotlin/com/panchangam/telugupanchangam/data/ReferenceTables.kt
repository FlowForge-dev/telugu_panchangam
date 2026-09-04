package com.panchangam.telugupanchangam.data

import com.panchangam.telugupanchangam.domain.Karana
import com.panchangam.telugupanchangam.domain.Nakshatra
import com.panchangam.telugupanchangam.domain.PanchangYoga
import com.panchangam.telugupanchangam.domain.Tithi

/**
 * Fixed reference tables — the standard names and ordering of Tithis,
 * Nakshatras, Yogas and Karanas. These are stable, well-documented
 * lists, not calculated values.
 */
object ReferenceTables {

    val shuklaTithis = listOf(
        Tithi(1, "Padyami", "పాడ్యమి"), Tithi(2, "Vidiya", "విదియ"),
        Tithi(3, "Tadiya", "తదియ"), Tithi(4, "Chavithi", "చవితి"),
        Tithi(5, "Panchami", "పంచమి"), Tithi(6, "Shashti", "షష్ఠి"),
        Tithi(7, "Saptami", "సప్తమి"), Tithi(8, "Ashtami", "అష్టమి"),
        Tithi(9, "Navami", "నవమి"), Tithi(10, "Dashami", "దశమి"),
        Tithi(11, "Ekadashi", "ఏకాదశి"), Tithi(12, "Dwadashi", "ద్వాదశి"),
        Tithi(13, "Trayodashi", "త్రయోదశి"), Tithi(14, "Chaturdashi", "చతుర్దశి"),
        Tithi(15, "Purnima", "పౌర్ణమి")
    )

    val krishnaTithis = shuklaTithis.dropLast(1) + Tithi(15, "Amavasya", "అమావాస్య")

    val nakshatras = listOf(
        Nakshatra(1, "Ashwini", "అశ్విని"), Nakshatra(2, "Bharani", "భరణి"),
        Nakshatra(3, "Krittika", "కృత్తిక"), Nakshatra(4, "Rohini", "రోహిణి"),
        Nakshatra(5, "Mrigashira", "మృగశిర"), Nakshatra(6, "Ardra", "ఆరుద్ర"),
        Nakshatra(7, "Punarvasu", "పునర్వసు"), Nakshatra(8, "Pushyami", "పుష్యమి"),
        Nakshatra(9, "Ashlesha", "ఆశ్లేష"), Nakshatra(10, "Magha", "మఖ"),
        Nakshatra(11, "Pubba", "పుబ్బ"), Nakshatra(12, "Uttara", "ఉత్తర"),
        Nakshatra(13, "Hastha", "హస్త"), Nakshatra(14, "Chitta", "చిత్త"),
        Nakshatra(15, "Swati", "స్వాతి"), Nakshatra(16, "Vishakha", "విశాఖ"),
        Nakshatra(17, "Anuradha", "అనూరాధ"), Nakshatra(18, "Jyeshta", "జ్యేష్ఠ"),
        Nakshatra(19, "Moola", "మూల"), Nakshatra(20, "Purvashadha", "పూర్వాషాఢ"),
        Nakshatra(21, "Uttarashadha", "ఉత్తరాషాఢ"), Nakshatra(22, "Shravanam", "శ్రవణం"),
        Nakshatra(23, "Dhanishta", "ధనిష్ఠ"), Nakshatra(24, "Shatabhisham", "శతభిషం"),
        Nakshatra(25, "Poorvabhadra", "పూర్వాభాద్ర"), Nakshatra(26, "Uttarabhadra", "ఉత్తరాభాద్ర"),
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
        PanchangYoga(17, "Vyatipata", "వ్యతీపాత"), PanchangYoga(18, "Variyana", "వరీయాన్"),
        PanchangYoga(19, "Parigha", "పరిఘ"), PanchangYoga(20, "Shiva", "శివ"),
        PanchangYoga(21, "Siddha", "సిద్ధ"), PanchangYoga(22, "Sadhya", "సాధ్య"),
        PanchangYoga(23, "Shubha", "శుభ"), PanchangYoga(24, "Shukla", "శుక్ల"),
        PanchangYoga(25, "Brahma", "బ్రహ్మ"), PanchangYoga(26, "Indra", "ఇంద్ర"),
        PanchangYoga(27, "Vaidhriti", "వైధృతి")
    )

    val karanas = listOf(
        Karana("Bava", "బవ"), Karana("Balava", "బాలవ"), Karana("Kaulava", "కౌలవ"),
        Karana("Taitila", "తైతిల"), Karana("Garaja", "గరజ"), Karana("Vanija", "వణిజ"),
        Karana("Vishti", "విష్టి"), Karana("Shakuni", "శకుని"),
        Karana("Chatushpada", "చతుష్పాద"), Karana("Naga", "నాగ"),
        Karana("Kimstughna", "కింస్తుఘ్న")
    )

    /** Standard day-Choghadiya name sequence per weekday (fixed lookup). */
    val choghadiyaSequence: Map<Int, List<String>> = mapOf(
        0 to listOf("Udveg", "Chal", "Labh", "Amrit", "Kaal", "Shubh", "Rog", "Udveg"),
        1 to listOf("Amrit", "Kaal", "Shubh", "Rog", "Udveg", "Chal", "Labh", "Amrit"),
        2 to listOf("Rog", "Udveg", "Chal", "Labh", "Amrit", "Kaal", "Shubh", "Rog"),
        3 to listOf("Labh", "Amrit", "Kaal", "Shubh", "Rog", "Udveg", "Chal", "Labh"),
        4 to listOf("Shubh", "Rog", "Udveg", "Chal", "Labh", "Amrit", "Kaal", "Shubh"),
        5 to listOf("Chal", "Labh", "Amrit", "Kaal", "Shubh", "Rog", "Udveg", "Chal"),
        6 to listOf("Kaal", "Shubh", "Rog", "Udveg", "Chal", "Labh", "Amrit", "Kaal")
    )

    val choghadiyaTelugu = mapOf(
        "Udveg" to "ఉద్వేగ", "Chal" to "చల", "Labh" to "లాభ", "Amrit" to "అమృత",
        "Kaal" to "కాల", "Shubh" to "శుభ", "Rog" to "రోగ"
    )
}
