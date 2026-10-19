package com.panchangam.telugupanchangam.ui

import androidx.compose.runtime.compositionLocalOf
import com.panchangam.telugupanchangam.domain.City
import com.panchangam.telugupanchangam.ui.theme.ThemeMode

/** User preferences. Persisted by the host activity. */
data class AppSettings(
    val cityId: String = City.HYDERABAD.id,
    val theme: ThemeMode = ThemeMode.SYSTEM,
    val use24Hour: Boolean = false
) {
    val city: City get() = City.byId(cityId)
}

val LocalAppSettings = compositionLocalOf { AppSettings() }
