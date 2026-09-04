package com.panchangam.telugupanchangam

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CalendarMonth
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.Star
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.NavigationBarItemDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.dp
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.panchangam.telugupanchangam.data.MockFestivalRepository
import com.panchangam.telugupanchangam.data.MockPanchangRepository
import com.panchangam.telugupanchangam.ui.about.AboutScreen
import com.panchangam.telugupanchangam.ui.calendar.CalendarScreen
import com.panchangam.telugupanchangam.ui.day.DayDetailScreen
import com.panchangam.telugupanchangam.ui.festivals.FestivalDetailScreen
import com.panchangam.telugupanchangam.ui.festivals.FestivalsScreen
import com.panchangam.telugupanchangam.ui.theme.Ink
import com.panchangam.telugupanchangam.ui.theme.TeluguPanchangamTheme
import java.time.LocalDate

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            TeluguPanchangamTheme {
                PanchangamApp()
            }
        }
    }
}

private data class Destination(
    val route: String,
    val telugu: String,
    val icon: ImageVector,
    val contentDescription: String
)

private val destinations = listOf(
    Destination("calendar", "క్యాలెండర్", Icons.Default.CalendarMonth, "Calendar"),
    Destination("festivals", "పండుగలు", Icons.Default.Star, "Festivals"),
    Destination("about", "గురించి", Icons.Default.Info, "About")
)

@Composable
fun PanchangamApp() {
    val navController = rememberNavController()
    val panchangRepository = remember { MockPanchangRepository() }
    val festivalRepository = remember { MockFestivalRepository() }

    val backStackEntry by navController.currentBackStackEntryAsState()
    val currentRoute = backStackEntry?.destination?.route
    val showBottomBar = currentRoute in destinations.map { it.route }

    Scaffold(
        containerColor = Ink.White,
        bottomBar = {
            if (showBottomBar) {
                NavigationBar(containerColor = Ink.White, tonalElevation = 0.dp) {
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
                            icon = {
                                Icon(destination.icon, contentDescription = destination.contentDescription)
                            },
                            label = {
                                Text(destination.telugu, style = MaterialTheme.typography.labelSmall)
                            },
                            colors = NavigationBarItemDefaults.colors(
                                selectedIconColor = Ink.White,
                                selectedTextColor = Ink.Black,
                                indicatorColor = Ink.Black,
                                unselectedIconColor = Ink.Secondary,
                                unselectedTextColor = Ink.Secondary
                            )
                        )
                    }
                }
            }
        }
    ) { padding ->
        NavHost(
            navController = navController,
            startDestination = "calendar",
            modifier = Modifier
                .fillMaxSize()
                .background(Color.White)
                .padding(padding)
        ) {
            composable("calendar") {
                CalendarScreen(
                    panchangRepository = panchangRepository,
                    onDaySelected = { date -> navController.navigate("day/$date") }
                )
            }
            composable("festivals") {
                FestivalsScreen(
                    festivalRepository = festivalRepository,
                    onFestivalSelected = { id -> navController.navigate("festival/$id") }
                )
            }
            composable("about") { AboutScreen() }

            composable("day/{date}") { entry ->
                val date = LocalDate.parse(entry.arguments?.getString("date"))
                DayDetailScreen(
                    date = date,
                    panchangRepository = panchangRepository,
                    festivalRepository = festivalRepository,
                    onBack = { navController.popBackStack() },
                    onFestivalSelected = { id -> navController.navigate("festival/$id") }
                )
            }
            composable("festival/{id}") { entry ->
                FestivalDetailScreen(
                    festivalId = entry.arguments?.getString("id").orEmpty(),
                    festivalRepository = festivalRepository,
                    onBack = { navController.popBackStack() }
                )
            }
        }
    }
}
