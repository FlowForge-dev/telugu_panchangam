package com.panchangam.telugupanchangam

import android.content.Context
import android.content.Intent
import android.graphics.Color as AndroidColor
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.SystemBarStyle
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CalendarMonth
import androidx.compose.material.icons.filled.Celebration
import androidx.compose.material.icons.filled.MoreHoriz
import androidx.compose.material.icons.filled.WbSunny
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.NavigationBarItemDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.dp
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.panchangam.telugupanchangam.data.AstronomicalPanchangRepository
import com.panchangam.telugupanchangam.data.StaticFestivalRepository
import com.panchangam.telugupanchangam.ui.AppSettings
import com.panchangam.telugupanchangam.ui.LocalAppSettings
import com.panchangam.telugupanchangam.ui.calendar.CalendarScreen
import com.panchangam.telugupanchangam.ui.day.DayDetailScreen
import com.panchangam.telugupanchangam.ui.festivals.FestivalDetailScreen
import com.panchangam.telugupanchangam.ui.festivals.FestivalsScreen
import com.panchangam.telugupanchangam.ui.more.CityPickerScreen
import com.panchangam.telugupanchangam.ui.more.MoreScreen
import com.panchangam.telugupanchangam.ui.theme.Ink
import com.panchangam.telugupanchangam.ui.theme.TeluguPanchangamTheme
import com.panchangam.telugupanchangam.ui.theme.ThemeMode
import com.panchangam.telugupanchangam.ui.today.TodayScreen
import java.time.LocalDate

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)
        val store = SettingsStore(this)
        setContent {
            var settings by remember { mutableStateOf(store.load()) }
            TeluguPanchangamTheme(mode = settings.theme) {
                val dark = Ink.current.isDark
                LaunchedEffect(dark) {
                    enableEdgeToEdge(
                        statusBarStyle = if (dark) SystemBarStyle.dark(AndroidColor.TRANSPARENT)
                        else SystemBarStyle.light(AndroidColor.TRANSPARENT, AndroidColor.TRANSPARENT),
                        navigationBarStyle = if (dark) SystemBarStyle.dark(AndroidColor.TRANSPARENT)
                        else SystemBarStyle.light(AndroidColor.TRANSPARENT, AndroidColor.TRANSPARENT)
                    )
                }
                CompositionLocalProvider(LocalAppSettings provides settings) {
                    PanchangamApp(
                        settings = settings,
                        onSettingsChange = {
                            settings = it
                            store.save(it)
                        },
                        onShare = ::shareText,
                        versionName = BuildConfigVersion.name(this)
                    )
                }
            }
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
private class SettingsStore(context: Context) {
    private val prefs = context.getSharedPreferences("settings", Context.MODE_PRIVATE)

    fun load() = AppSettings(
        cityId = prefs.getString("city", null) ?: AppSettings().cityId,
        theme = runCatching { ThemeMode.valueOf(prefs.getString("theme", null) ?: "") }.getOrDefault(ThemeMode.SYSTEM),
        use24Hour = prefs.getBoolean("use24h", false)
    )

    fun save(s: AppSettings) {
        prefs.edit()
            .putString("city", s.cityId)
            .putString("theme", s.theme.name)
            .putBoolean("use24h", s.use24Hour)
            .apply()
    }
}

private object BuildConfigVersion {
    fun name(context: Context): String = runCatching {
        context.packageManager.getPackageInfo(context.packageName, 0).versionName
    }.getOrNull() ?: ""
}

private data class Destination(
    val route: String,
    val telugu: String,
    val icon: ImageVector,
    val contentDescription: String
)

private val destinations = listOf(
    Destination("today", "నేడు", Icons.Filled.WbSunny, "Today"),
    Destination("calendar", "క్యాలెండర్", Icons.Filled.CalendarMonth, "Calendar"),
    Destination("festivals", "పండుగలు", Icons.Filled.Celebration, "Festivals"),
    Destination("more", "మరిన్ని", Icons.Filled.MoreHoriz, "More")
)

@Composable
fun PanchangamApp(
    settings: AppSettings,
    onSettingsChange: (AppSettings) -> Unit,
    onShare: (String) -> Unit,
    versionName: String
) {
    val navController = rememberNavController()
    val panchangRepository = remember { AstronomicalPanchangRepository() }
    val festivalRepository = remember { StaticFestivalRepository() }
    val ink = Ink.current

    val backStackEntry by navController.currentBackStackEntryAsState()
    val currentRoute = backStackEntry?.destination?.route
    val showBottomBar = currentRoute in destinations.map { it.route }

    Scaffold(
        containerColor = ink.page,
        // Each screen handles the status bar itself (top-level screens pad
        // for it, detail screens have a TopAppBar), so only the bottom bar
        // contributes padding here.
        contentWindowInsets = WindowInsets(0, 0, 0, 0),
        bottomBar = {
            if (showBottomBar) {
                NavigationBar(containerColor = ink.page, tonalElevation = 0.dp) {
                    destinations.forEach { destination ->
                        NavigationBarItem(
                            selected = currentRoute == destination.route,
                            onClick = {
                                navController.navigate(destination.route) {
                                    popUpTo(navController.graph.findStartDestination().id) { saveState = true }
                                    launchSingleTop = true
                                    restoreState = true
                                }
                            },
                            icon = { Icon(destination.icon, contentDescription = destination.contentDescription) },
                            label = { Text(destination.telugu, style = MaterialTheme.typography.labelSmall) },
                            colors = NavigationBarItemDefaults.colors(
                                selectedIconColor = ink.page,
                                selectedTextColor = ink.strong,
                                indicatorColor = ink.strong,
                                unselectedIconColor = ink.secondary,
                                unselectedTextColor = ink.secondary
                            )
                        )
                    }
                }
            }
        }
    ) { padding ->
        NavHost(
            navController = navController,
            startDestination = "today",
            modifier = Modifier
                .fillMaxSize()
                .background(ink.page)
                .padding(padding)
        ) {
            composable("today") {
                TodayScreen(
                    panchangRepository = panchangRepository,
                    festivalRepository = festivalRepository,
                    onPickCity = { navController.navigate("cities") },
                    onFestivalSelected = { id -> navController.navigate("festival/$id") },
                    onShare = onShare
                )
            }
            composable("calendar") {
                CalendarScreen(
                    panchangRepository = panchangRepository,
                    festivalRepository = festivalRepository,
                    onDaySelected = { date -> navController.navigate("day/$date") },
                    onFestivalSelected = { id -> navController.navigate("festival/$id") }
                )
            }
            composable("festivals") {
                FestivalsScreen(
                    festivalRepository = festivalRepository,
                    onFestivalSelected = { id -> navController.navigate("festival/$id") }
                )
            }
            composable("more") {
                MoreScreen(
                    settings = settings,
                    onSettingsChange = onSettingsChange,
                    onPickCity = { navController.navigate("cities") },
                    versionName = versionName
                )
            }
            composable("cities") {
                CityPickerScreen(
                    selectedId = settings.cityId,
                    onSelect = { city ->
                        onSettingsChange(settings.copy(cityId = city.id))
                        navController.popBackStack()
                    },
                    onBack = { navController.popBackStack() }
                )
            }
            composable("day/{date}") { entry ->
                val date = entry.arguments?.getString("date")
                    ?.let { runCatching { LocalDate.parse(it) }.getOrNull() }
                    ?: LocalDate.now(settings.city.zone)
                DayDetailScreen(
                    date = date,
                    panchangRepository = panchangRepository,
                    festivalRepository = festivalRepository,
                    onBack = { navController.popBackStack() },
                    onFestivalSelected = { id -> navController.navigate("festival/$id") },
                    onShare = onShare
                )
            }
            composable("festival/{id}") { entry ->
                FestivalDetailScreen(
                    festivalId = entry.arguments?.getString("id").orEmpty(),
                    festivalRepository = festivalRepository,
                    onBack = { navController.popBackStack() },
                    onOpenDay = { date -> navController.navigate("day/$date") }
                )
            }
        }
    }
}
