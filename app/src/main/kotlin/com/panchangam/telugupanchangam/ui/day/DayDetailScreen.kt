package com.panchangam.telugupanchangam.ui.day

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowLeft
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowRight
import androidx.compose.material.icons.filled.Share
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.panchangam.telugupanchangam.domain.FestivalRepository
import com.panchangam.telugupanchangam.domain.PanchangRepository
import com.panchangam.telugupanchangam.ui.LocalAppSettings
import com.panchangam.telugupanchangam.ui.components.formatLong
import com.panchangam.telugupanchangam.ui.components.teluguDayMonth
import com.panchangam.telugupanchangam.ui.theme.Ink
import kotlinx.coroutines.launch
import java.time.LocalDate
import java.time.LocalDateTime

private const val DAY_PAGES = 365 * 30
private const val DAY_CENTRE = DAY_PAGES / 2

/** One day's full Panchangam; swipe sideways for the previous or next day. */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DayDetailScreen(
    date: LocalDate,
    panchangRepository: PanchangRepository,
    festivalRepository: FestivalRepository,
    onBack: () -> Unit,
    onFestivalSelected: (String) -> Unit,
    onShare: (String) -> Unit
) {
    val settings = LocalAppSettings.current
    val city = settings.city
    val pager = rememberPagerState(initialPage = DAY_CENTRE) { DAY_PAGES }
    val scope = rememberCoroutineScope()
    val shown = date.plusDays((pager.currentPage - DAY_CENTRE).toLong())
    val ink = Ink.current

    Scaffold(
        containerColor = ink.page,
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text(shown.teluguDayMonth() + " ${shown.year}", style = MaterialTheme.typography.titleLarge, color = ink.strong)
                        Text(shown.formatLong(), style = MaterialTheme.typography.bodySmall, color = ink.secondary)
                    }
                },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back", tint = ink.strong)
                    }
                },
                actions = {
                    IconButton(onClick = { scope.launch { pager.animateScrollToPage(pager.currentPage - 1) } }) {
                        Icon(Icons.AutoMirrored.Filled.KeyboardArrowLeft, contentDescription = "Previous day", tint = ink.strong)
                    }
                    IconButton(onClick = { scope.launch { pager.animateScrollToPage(pager.currentPage + 1) } }) {
                        Icon(Icons.AutoMirrored.Filled.KeyboardArrowRight, contentDescription = "Next day", tint = ink.strong)
                    }
                    IconButton(onClick = {
                        val day = panchangRepository.dayDetail(shown, city)
                        onShare(shareText(day, festivalRepository.onDate(shown), settings.use24Hour))
                    }) {
                        Icon(Icons.Filled.Share, contentDescription = "Share", tint = ink.strong)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = ink.page)
            )
        }
    ) { padding ->
        HorizontalPager(
            state = pager,
            modifier = Modifier.fillMaxSize().padding(padding),
            beyondViewportPageCount = 0
        ) { page ->
            val pageDate = date.plusDays((page - DAY_CENTRE).toLong())
            val day = remember(pageDate, city.id) { panchangRepository.dayDetail(pageDate, city) }
            val festivals = remember(pageDate) { festivalRepository.onDate(pageDate) }
            val now = LocalDateTime.now(city.zone)
            LazyColumn(
                modifier = Modifier.fillMaxSize(),
                contentPadding = PaddingValues(bottom = 32.dp)
            ) {
                panchangDayItems(day, festivals, now, onFestivalSelected)
            }
        }
    }
}
