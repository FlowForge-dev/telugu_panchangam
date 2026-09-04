package com.panchangam.telugupanchangam.data

import com.panchangam.telugupanchangam.domain.Festival
import com.panchangam.telugupanchangam.domain.FestivalImportance
import com.panchangam.telugupanchangam.domain.SourceReference
import com.panchangam.telugupanchangam.domain.VerificationStatus
import java.time.LocalDate

/**
 * Festival calendar for the Ugadi -> Ugadi year.
 *
 * Dates from 19 Mar 2026 through 24 Dec 2026 are taken from the
 * "2026 Drik Panchang Hindu Calendar" (Amanta system, Hyderabad,
 * v1.0.4) supplied by the user — a real published almanac. Only the
 * date and name of each occasion come from that source; interpretive
 * significance is summarised prose and mantra text stays withheld.
 *
 * The Jan–Apr 2027 entries fall outside that document's coverage and
 * remain unverified estimates (isMockCalculated = true).
 */
object FestivalData {

    val pendingAlmanac = SourceReference(
        title = "[AUTHORITATIVE SOURCE REQUIRED]",
        notes = "Detailed significance and exact observance rules are pending review by a qualified Panchangam authority.",
        status = VerificationStatus.PENDING_VERIFICATION
    )

    val pendingMantra = SourceReference(
        title = "[AUTHORITATIVE SOURCE REQUIRED]",
        language = "Sanskrit / Telugu",
        notes = "Mantra text withheld pending citation from a verified traditional source.",
        status = VerificationStatus.PENDING_VERIFICATION
    )

    val drikPanchang2026 = SourceReference(
        title = "2026 Drik Panchang Hindu Calendar",
        edition = "v1.0.4, Hyderabad, Telangana (Amanta system)",
        language = "English",
        notes = "Confirms the date and name of each occasion. Deeper significance, observance rules and mantra " +
            "text still require separate citation from a qualified source.",
        status = VerificationStatus.VERIFIED
    )

    /** First day of the Panchangam year covered by this build. */
    val ugadiStart: LocalDate = LocalDate.of(2026, 3, 19)
    val nextUgadi: LocalDate = LocalDate.of(2027, 4, 7)

    private const val PENDING = "[VERIFIED CONTENT REQUIRED]"

    private fun verified(
        id: String, name: String, telugu: String, date: LocalDate,
        importance: FestivalImportance, short: String, significance: String,
        observance: String = PENDING, preparation: String = PENDING
    ) = Festival(
        id = id, name = name, teluguName = telugu, date = date, importance = importance,
        shortSignificance = short, significance = significance,
        observance = observance, preparation = preparation,
        mantraSources = listOf(pendingMantra), sources = listOf(drikPanchang2026),
        isMockCalculated = false
    )

    private fun estimated(
        id: String, name: String, telugu: String, date: LocalDate,
        importance: FestivalImportance, short: String, significance: String,
        observance: String = PENDING, preparation: String = PENDING
    ) = Festival(
        id = id, name = name, teluguName = telugu, date = date, importance = importance,
        shortSignificance = short, significance = significance,
        observance = observance, preparation = preparation,
        mantraSources = listOf(pendingMantra), sources = listOf(pendingAlmanac),
        isMockCalculated = true
    )

    val festivals: List<Festival> = listOf(
        verified(
            "ugadi", "Ugadi", "ఉగాది", LocalDate.of(2026, 3, 19), FestivalImportance.MAJOR,
            "Telugu New Year — start of the calendrical cycle.",
            "Ugadi marks the traditional start of the new year in the Telugu lunisolar calendar. It is widely " +
                "observed with the preparation of Ugadi pachadi, a dish combining several tastes said to " +
                "represent the varied experiences of the year ahead.\n\nDetailed significance: $PENDING",
            observance = "Households commonly clean and decorate the home, wear new clothing, and prepare Ugadi " +
                "pachadi. Exact ritual sequence and timing: $PENDING",
            preparation = "Home cleaning, mango-leaf toranam at the entrance, and gathering pachadi ingredients " +
                "(neem, jaggery, tamarind, raw mango, chilli, salt) the evening before."
        ),
        verified(
            "sri-rama-navami", "Sri Rama Navami", "శ్రీరామ నవమి", LocalDate.of(2026, 3, 26),
            FestivalImportance.MAJOR, "Commemorates the birth of Sri Rama.",
            "Observed as the birth anniversary of Sri Rama. Many temples hold Kalyanam (ceremonial wedding) " +
                "observances on this day.\n\nDetailed significance: $PENDING"
        ),
        verified(
            "hanuman-jayanti", "Hanuman Jayanti", "హనుమాన్ జయంతి", LocalDate.of(2026, 4, 2),
            FestivalImportance.MODERATE, "Birth anniversary of Sri Hanuman.",
            "Observed by many as the birth anniversary of Hanuman, on Chaitra Purnima. Regional dates and " +
                "traditions vary.\n\nDetailed significance: $PENDING"
        ),
        verified(
            "akshaya-tritiya", "Akshaya Tritiya", "అక్షయ తృతీయ", LocalDate.of(2026, 4, 19),
            FestivalImportance.MODERATE, "Considered an auspicious day for new beginnings.",
            "Widely regarded as an auspicious day for new ventures, purchases and charitable giving.\n\n" +
                "Detailed significance: $PENDING"
        ),
        verified(
            "narasimha-jayanti", "Narasimha Jayanti", "నృసింహ జయంతి", LocalDate.of(2026, 4, 30),
            FestivalImportance.MODERATE, "Commemorates the Narasimha avatar of Vishnu.",
            "Observed as the appearance day of Sri Narasimha.\n\nDetailed significance: $PENDING"
        ),
        verified(
            "buddha-purnima", "Buddha Purnima", "బుద్ధ పౌర్ణమి", LocalDate.of(2026, 5, 1),
            FestivalImportance.MODERATE, "Vaishakha Purnima; also observed as Buddha Purnima.",
            "The full-moon day of Vaishakha masam.\n\nDetailed significance: $PENDING"
        ),
        verified(
            "nirjala-ekadashi", "Nirjala Ekadashi", "నిర్జల ఏకాదశి", LocalDate.of(2026, 6, 25),
            FestivalImportance.OBSERVANCE, "The most rigorous of the year's Ekadashi observances.",
            "Observed with a waterless fast; widely considered the most demanding Ekadashi of the year.\n\n" +
                "Detailed significance: $PENDING",
            preparation = "Fasting practices vary by tradition. $PENDING"
        ),
        verified(
            "jagannath-rathayatra", "Jagannath Rathayatra", "జగన్నాథ రథయాత్ర", LocalDate.of(2026, 7, 16),
            FestivalImportance.MODERATE, "Chariot festival of Lord Jagannath.",
            "A chariot procession observance associated with Lord Jagannath.\n\nDetailed significance: $PENDING"
        ),
        verified(
            "devshayani-ekadashi", "Devshayani Ekadashi", "దేవశయని ఏకాదశి", LocalDate.of(2026, 7, 25),
            FestivalImportance.OBSERVANCE, "Marks the start of the Chaturmasya period.",
            "Traditionally marks the beginning of Chaturmasya, a four-month observance period.\n\n" +
                "Detailed significance: $PENDING"
        ),
        verified(
            "guru-purnima", "Guru Purnima", "గురు పౌర్ణమి", LocalDate.of(2026, 7, 29),
            FestivalImportance.MODERATE, "Ashadha Purnima; a day of reverence for one's teachers.",
            "Observed as Vyasa Puja and a day of reverence for one's teachers/guru.\n\n" +
                "Detailed significance: $PENDING"
        ),
        verified(
            "varalakshmi-vratam", "Varalakshmi Vratam", "వరలక్ష్మి వ్రతం", LocalDate.of(2026, 8, 28),
            FestivalImportance.MAJOR, "Vratam dedicated to Goddess Varalakshmi.",
            "A widely observed vratam dedicated to Goddess Varalakshmi, performed by many households on a Friday " +
                "of Shravana masam. Some traditions observe it on a different Friday than the general " +
                "Amanta-calendar date used here.\n\nDetailed significance: $PENDING"
        ),
        verified(
            "raksha-bandhan", "Raksha Bandhan", "రాఖీ పౌర్ణమి", LocalDate.of(2026, 8, 28),
            FestivalImportance.MODERATE, "Shravana Purnima; siblings tie the rakhi thread.",
            "Observed on Shravana Purnima, this occasion coincides with Varalakshmi Vratam this year.\n\n" +
                "Detailed significance: $PENDING"
        ),
        verified(
            "krishna-janmashtami", "Krishna Janmashtami", "శ్రీకృష్ణాష్టమి", LocalDate.of(2026, 9, 4),
            FestivalImportance.MAJOR, "Celebrates the birth of Sri Krishna.",
            "Observed as the birth anniversary of Sri Krishna, typically marked with fasting until midnight and " +
                "devotional singing.\n\nDetailed significance: $PENDING"
        ),
        verified(
            "vinayaka-chavithi", "Vinayaka Chavithi", "వినాయక చవితి", LocalDate.of(2026, 9, 14),
            FestivalImportance.MAJOR, "Ganesh Chaturthi — worship of Lord Ganesha.",
            "A major household and community festival honouring Lord Ganesha, typically involving a clay idol " +
                "installed at home or in a pandal for a set number of days.\n\nDetailed significance: $PENDING",
            preparation = "Idol/pandal arrangements, modakam or kudumu preparation traditions vary by family."
        ),
        verified(
            "ganesh-visarjan", "Ganesh Visarjan", "గణేశ నిమజ్జనం", LocalDate.of(2026, 9, 25),
            FestivalImportance.MODERATE, "Anant Chaturdashi — immersion of the Ganesha idol.",
            "Marks the conclusion of the Vinayaka Chavithi observance with idol immersion.\n\n" +
                "Detailed significance: $PENDING"
        ),
        verified(
            "sarannavaratri", "Sharan Navaratri", "శరన్నవరాత్రులు", LocalDate.of(2026, 10, 11),
            FestivalImportance.MAJOR, "Nine nights honouring the Goddess.",
            "A nine-night observance honouring the Goddess in her various forms, culminating in Vijayadashami." +
                "\n\nDetailed significance: $PENDING"
        ),
        verified(
            "vijayadashami", "Vijayadashami", "విజయదశమి", LocalDate.of(2026, 10, 20),
            FestivalImportance.MAJOR, "Dasara — marks the victory of good over evil.",
            "Marks the culmination of Navaratri and is widely associated with the victory of good over evil.\n\n" +
                "Detailed significance: $PENDING"
        ),
        verified(
            "sharad-purnima", "Sharad Purnima", "శరత్ పౌర్ణమి", LocalDate.of(2026, 10, 25),
            FestivalImportance.MODERATE, "Kojagara Puja; full moon of Ashwina masam.",
            "The full-moon day of Ashwina masam, observed as Kojagara Puja in several traditions.\n\n" +
                "Detailed significance: $PENDING"
        ),
        verified(
            "dhanteras", "Dhanteras", "ధనత్రయోదశి", LocalDate.of(2026, 11, 6),
            FestivalImportance.MODERATE, "Opens the Deepavali festival period.",
            "Traditionally regarded as an auspicious day for purchases, opening the Deepavali period.\n\n" +
                "Detailed significance: $PENDING"
        ),
        verified(
            "deepavali", "Deepavali", "దీపావళి", LocalDate.of(2026, 11, 8),
            FestivalImportance.MAJOR, "Festival of lights.",
            "Widely observed festival of lights, marked with the lighting of diyas, sharing of sweets and family " +
                "gatherings.\n\nDetailed significance: $PENDING",
            observance = "Naraka Chaturdashi and Lakshmi Puja timing details: $PENDING",
            preparation = "Home cleaning and decoration with diyas/rangoli."
        ),
        verified(
            "govardhan-puja", "Govardhan Puja", "బలిపాడ్యమి", LocalDate.of(2026, 11, 10),
            FestivalImportance.MODERATE, "Bali Padyami — the day after the main Deepavali observance.",
            "Observed the day after the main Deepavali night.\n\nDetailed significance: $PENDING"
        ),
        verified(
            "devutthana-ekadashi", "Devutthana Ekadashi", "దేవోత్థాన ఏకాదశి", LocalDate.of(2026, 11, 20),
            FestivalImportance.OBSERVANCE, "Traditionally marks the end of the Chaturmasya period.",
            "Traditionally regarded as the close of Chaturmasya.\n\nDetailed significance: $PENDING"
        ),
        verified(
            "tulasi-vivah", "Tulasi Vivah", "తులసి వివాహం", LocalDate.of(2026, 11, 21),
            FestivalImportance.MODERATE, "Ceremonial wedding of the Tulasi plant.",
            "A household observance marking the ceremonial wedding of the Tulasi plant.\n\n" +
                "Detailed significance: $PENDING"
        ),
        verified(
            "karthika-pournami", "Karthika Pournami", "కార్తీక పౌర్ణమి", LocalDate.of(2026, 11, 24),
            FestivalImportance.MODERATE, "Full moon of Karthika masam; also observed as Dev Diwali.",
            "The full-moon day of Karthika masam, traditionally associated with lighting lamps at home and in " +
                "temples.\n\nDetailed significance: $PENDING"
        ),
        verified(
            "vivah-panchami", "Vivah Panchami", "వివాహ పంచమి", LocalDate.of(2026, 12, 14),
            FestivalImportance.OBSERVANCE, "Commemorates the wedding of Sri Rama and Sita.",
            "Observed in commemoration of the wedding of Sri Rama and Sita.\n\nDetailed significance: $PENDING"
        ),
        verified(
            "subrahmanya-shashti", "Subrahmanya Shashti", "సుబ్రహ్మణ్య షష్ఠి", LocalDate.of(2026, 12, 15),
            FestivalImportance.MODERATE, "Also observed as Champa Shashthi.",
            "A day dedicated to Lord Subrahmanya (Skanda/Kartikeya).\n\nDetailed significance: $PENDING"
        ),
        verified(
            "dhanurmasam-begins", "Dhanurmasam Begins", "ధనుర్మాసం ప్రారంభం", LocalDate.of(2026, 12, 16),
            FestivalImportance.OBSERVANCE, "Sun's transit into Dhanu Rashi.",
            "Marks the Sun's transit into Dhanu Rashi, beginning a month widely observed with daily dawn temple " +
                "visits.\n\nDetailed significance: $PENDING"
        ),
        verified(
            "mukkoti-ekadashi", "Mukkoti Ekadashi", "ముక్కోటి ఏకాదశి", LocalDate.of(2026, 12, 20),
            FestivalImportance.OBSERVANCE, "Vaikunta Ekadashi observance; also Gita Jayanti.",
            "Also known as Vaikunta Ekadashi, observed with visits to Vishnu temples through the \"Uttara " +
                "Dwaram\" (northern gateway) at many shrines. Coincides with Gita Jayanti this year.\n\n" +
                "Detailed significance: $PENDING",
            preparation = "Ekadashi fasting practices vary by tradition. $PENDING"
        ),
        verified(
            "dattatreya-jayanti", "Dattatreya Jayanti", "దత్తాత్రేయ జయంతి", LocalDate.of(2026, 12, 23),
            FestivalImportance.MODERATE, "Commemorates the appearance of Lord Dattatreya.",
            "Observed as the appearance day of Lord Dattatreya.\n\nDetailed significance: $PENDING"
        ),
        verified(
            "margashirsha-purnima", "Margashirsha Purnima", "మార్గశిర పౌర్ణమి", LocalDate.of(2026, 12, 24),
            FestivalImportance.MODERATE, "Full moon of Margashira masam.",
            "The full-moon day of Margashira masam.\n\nDetailed significance: $PENDING"
        ),
        estimated(
            "sankranthi", "Makara Sankranthi", "మకర సంక్రాంతి", LocalDate.of(2027, 1, 14),
            FestivalImportance.MAJOR, "Harvest festival marking the Sun's transit into Makara.",
            "A major harvest festival marking the Sun's transit into Makara Rashi, celebrated over multiple days " +
                "including Bhogi and Kanuma. This date falls outside the range covered by the Drik Panchang " +
                "document provided and is an estimate pending confirmation.\n\nDetailed significance: $PENDING",
            preparation = "Home cleaning, rangoli (muggu), and harvest-related preparations."
        ),
        estimated(
            "maha-shivaratri", "Maha Shivaratri", "మహా శివరాత్రి", LocalDate.of(2027, 2, 15),
            FestivalImportance.MAJOR, "Night dedicated to Lord Shiva.",
            "A major observance dedicated to Lord Shiva, widely marked with night-long vigil and worship. This " +
                "date falls outside the range covered by the Drik Panchang document provided and is an estimate " +
                "pending confirmation.\n\nDetailed significance: $PENDING"
        ),
        estimated(
            "ugadi-next", "Ugadi", "ఉగాది", LocalDate.of(2027, 4, 7),
            FestivalImportance.MAJOR, "Telugu New Year — start of the next calendrical cycle.",
            "Marks the start of the next Panchangam year. This date falls outside the range covered by the Drik " +
                "Panchang document provided and is an estimate pending confirmation.\n\n" +
                "Detailed significance: $PENDING"
        )
    ).sortedBy { it.date }
}
