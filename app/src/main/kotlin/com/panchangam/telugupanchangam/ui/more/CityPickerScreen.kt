package com.panchangam.telugupanchangam.ui.more

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.panchangam.telugupanchangam.domain.City
import com.panchangam.telugupanchangam.ui.components.ThinDivider
import com.panchangam.telugupanchangam.ui.theme.Ink

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CityPickerScreen(
    selectedId: String,
    onSelect: (City) -> Unit,
    onBack: () -> Unit
) {
    val ink = Ink.current
    var query by rememberSaveable { mutableStateOf("") }
    val matches = remember(query) {
        val q = query.trim().lowercase()
        City.ALL.filter {
            q.isEmpty() || it.name.lowercase().contains(q) || it.telugu.contains(q) || it.region.lowercase().contains(q)
        }
    }
    val grouped = remember(matches) { matches.groupBy { it.region } }

    Scaffold(
        containerColor = ink.page,
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text("ప్రదేశం ఎంచుకోండి", style = MaterialTheme.typography.titleLarge, color = ink.strong)
                        Text("Choose a city", style = MaterialTheme.typography.bodySmall, color = ink.secondary)
                    }
                },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back", tint = ink.strong)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = ink.page)
            )
        }
    ) { padding ->
        LazyColumn(
            modifier = Modifier.fillMaxSize().padding(padding),
            contentPadding = PaddingValues(bottom = 32.dp)
        ) {
            item {
                OutlinedTextField(
                    value = query,
                    onValueChange = { query = it },
                    singleLine = true,
                    placeholder = { Text("వెతకండి · Search", color = ink.faint) },
                    leadingIcon = { Icon(Icons.Filled.Search, contentDescription = null, tint = ink.secondary) },
                    shape = RoundedCornerShape(14.dp),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = ink.strong,
                        unfocusedBorderColor = ink.line,
                        cursorColor = ink.strong,
                        focusedTextColor = ink.strong,
                        unfocusedTextColor = ink.strong
                    ),
                    modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp, vertical = 8.dp)
                )
            }
            grouped.forEach { (region, cities) ->
                item(key = "r-$region") {
                    Text(
                        region.uppercase(),
                        style = MaterialTheme.typography.labelSmall,
                        color = ink.faint,
                        modifier = Modifier.padding(start = 20.dp, top = 18.dp, bottom = 4.dp)
                    )
                }
                cities.forEachIndexed { i, city ->
                    item(key = city.id) {
                        if (i > 0) ThinDivider(Modifier.padding(start = 20.dp))
                        Row(
                            Modifier
                                .fillMaxWidth()
                                .clickable { onSelect(city) }
                                .padding(horizontal = 20.dp, vertical = 14.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Column(Modifier.weight(1f)) {
                                Text(city.telugu, style = MaterialTheme.typography.titleMedium, color = ink.strong)
                                Text(city.name, style = MaterialTheme.typography.bodySmall, color = ink.secondary)
                            }
                            if (city.id == selectedId) {
                                Icon(Icons.Filled.Check, contentDescription = "Selected", tint = ink.strong)
                            }
                        }
                    }
                }
            }
        }
    }
}
