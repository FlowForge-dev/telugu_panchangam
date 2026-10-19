package com.panchangam.telugupanchangam.domain

import java.time.ZoneId

/** A place the Panchangam can be computed for. */
data class City(
    val id: String,
    val name: String,
    val telugu: String,
    val region: String,
    val latitude: Double,
    val longitude: Double,
    val zoneId: String
) {
    val zone: ZoneId get() = ZoneId.of(zoneId)

    companion object {
        val HYDERABAD = City("hyderabad", "Hyderabad", "హైదరాబాద్", "Telangana", 17.3850, 78.4867, "Asia/Kolkata")

        /** Coordinates are city centres to 0.01°, which moves sunrise by well under a minute. */
        val ALL: List<City> = listOf(
            HYDERABAD,
            City("warangal", "Warangal", "వరంగల్", "Telangana", 17.9689, 79.5941, "Asia/Kolkata"),
            City("karimnagar", "Karimnagar", "కరీంనగర్", "Telangana", 18.4386, 79.1288, "Asia/Kolkata"),
            City("nizamabad", "Nizamabad", "నిజామాబాద్", "Telangana", 18.6725, 78.0941, "Asia/Kolkata"),
            City("khammam", "Khammam", "ఖమ్మం", "Telangana", 17.2473, 80.1514, "Asia/Kolkata"),
            City("bhadrachalam", "Bhadrachalam", "భద్రాచలం", "Telangana", 17.6688, 80.8936, "Asia/Kolkata"),
            City("vijayawada", "Vijayawada", "విజయవాడ", "Andhra Pradesh", 16.5062, 80.6480, "Asia/Kolkata"),
            City("amaravati", "Amaravati", "అమరావతి", "Andhra Pradesh", 16.5131, 80.5165, "Asia/Kolkata"),
            City("visakhapatnam", "Visakhapatnam", "విశాఖపట్నం", "Andhra Pradesh", 17.6868, 83.2185, "Asia/Kolkata"),
            City("tirupati", "Tirupati", "తిరుపతి", "Andhra Pradesh", 13.6288, 79.4192, "Asia/Kolkata"),
            City("guntur", "Guntur", "గుంటూరు", "Andhra Pradesh", 16.3067, 80.4365, "Asia/Kolkata"),
            City("nellore", "Nellore", "నెల్లూరు", "Andhra Pradesh", 14.4426, 79.9865, "Asia/Kolkata"),
            City("kurnool", "Kurnool", "కర్నూలు", "Andhra Pradesh", 15.8281, 78.0373, "Asia/Kolkata"),
            City("rajahmundry", "Rajahmundry", "రాజమండ్రి", "Andhra Pradesh", 17.0005, 81.8040, "Asia/Kolkata"),
            City("kakinada", "Kakinada", "కాకినాడ", "Andhra Pradesh", 16.9891, 82.2475, "Asia/Kolkata"),
            City("anantapur", "Anantapur", "అనంతపురం", "Andhra Pradesh", 14.6819, 77.6006, "Asia/Kolkata"),
            City("srisailam", "Srisailam", "శ్రీశైలం", "Andhra Pradesh", 16.0733, 78.8684, "Asia/Kolkata"),
            City("sringeri", "Sringeri", "శృంగేరి", "Karnataka", 13.4198, 75.2567, "Asia/Kolkata"),
            City("bengaluru", "Bengaluru", "బెంగళూరు", "Karnataka", 12.9716, 77.5946, "Asia/Kolkata"),
            City("chennai", "Chennai", "చెన్నై", "Tamil Nadu", 13.0827, 80.2707, "Asia/Kolkata"),
            City("mumbai", "Mumbai", "ముంబై", "Maharashtra", 19.0760, 72.8777, "Asia/Kolkata"),
            City("delhi", "New Delhi", "న్యూఢిల్లీ", "Delhi", 28.6139, 77.2090, "Asia/Kolkata"),
            City("varanasi", "Varanasi", "వారణాసి", "Uttar Pradesh", 25.3176, 82.9739, "Asia/Kolkata"),
            City("new-york", "New York", "న్యూయార్క్", "USA", 40.7128, -74.0060, "America/New_York"),
            City("new-jersey", "Edison, NJ", "ఎడిసన్", "USA", 40.5187, -74.4121, "America/New_York"),
            City("chicago", "Chicago", "చికాగో", "USA", 41.8781, -87.6298, "America/Chicago"),
            City("dallas", "Dallas", "డల్లాస్", "USA", 32.7767, -96.7970, "America/Chicago"),
            City("houston", "Houston", "హ్యూస్టన్", "USA", 29.7604, -95.3698, "America/Chicago"),
            City("atlanta", "Atlanta", "అట్లాంటా", "USA", 33.7490, -84.3880, "America/New_York"),
            City("bay-area", "San Jose", "శాన్ హోసే", "USA", 37.3382, -121.8863, "America/Los_Angeles"),
            City("seattle", "Seattle", "సియాటిల్", "USA", 47.6062, -122.3321, "America/Los_Angeles"),
            City("toronto", "Toronto", "టొరంటో", "Canada", 43.6532, -79.3832, "America/Toronto"),
            City("london", "London", "లండన్", "UK", 51.5074, -0.1278, "Europe/London"),
            City("dubai", "Dubai", "దుబాయ్", "UAE", 25.2048, 55.2708, "Asia/Dubai"),
            City("singapore", "Singapore", "సింగపూర్", "Singapore", 1.3521, 103.8198, "Asia/Singapore"),
            City("sydney", "Sydney", "సిడ్నీ", "Australia", -33.8688, 151.2093, "Australia/Sydney"),
            City("melbourne", "Melbourne", "మెల్బోర్న్", "Australia", -37.8136, 144.9631, "Australia/Melbourne")
        )

        fun byId(id: String?): City = ALL.firstOrNull { it.id == id } ?: HYDERABAD
    }
}
