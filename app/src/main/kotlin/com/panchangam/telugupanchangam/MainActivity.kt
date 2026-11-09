package com.panchangam.telugupanchangam

import android.content.Context
import android.content.Intent
import android.graphics.Color as AndroidColor
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.SystemBarStyle
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import com.panchangam.telugupanchangam.ui.AppSettings
import com.panchangam.telugupanchangam.ui.theme.ThemeMode

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)
        val store = PrefsSettingsStore(this)
        val versionName = runCatching { packageManager.getPackageInfo(packageName, 0).versionName }.getOrNull() ?: ""
        setContent {
            PanchangamRoot(
                store = store,
                onShare = ::shareText,
                versionName = versionName,
                onDarkThemeChange = { dark ->
                    val bars = if (dark) SystemBarStyle.dark(AndroidColor.TRANSPARENT)
                    else SystemBarStyle.light(AndroidColor.TRANSPARENT, AndroidColor.TRANSPARENT)
                    enableEdgeToEdge(statusBarStyle = bars, navigationBarStyle = bars)
                }
            )
        }
    }

    private fun shareText(text: String) {
        val send = Intent(Intent.ACTION_SEND).apply {
            type = "text/plain"
            putExtra(Intent.EXTRA_TEXT, text)
        }
        startActivity(Intent.createChooser(send, null))
    }
}

/** Preferences in a private SharedPreferences file. */
private class PrefsSettingsStore(context: Context) : SettingsStore {
    private val prefs = context.getSharedPreferences("settings", Context.MODE_PRIVATE)

    override fun load() = AppSettings(
        cityId = prefs.getString("city", null) ?: AppSettings().cityId,
        theme = runCatching { ThemeMode.valueOf(prefs.getString("theme", null) ?: "") }.getOrDefault(ThemeMode.SYSTEM),
        use24Hour = prefs.getBoolean("use24h", false)
    )

    override fun save(settings: AppSettings) {
        prefs.edit()
            .putString("city", settings.cityId)
            .putString("theme", settings.theme.name)
            .putBoolean("use24h", settings.use24Hour)
            .apply()
    }
}
