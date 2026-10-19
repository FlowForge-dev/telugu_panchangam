package com.panchangam.telugupanchangam.domain

import java.time.LocalDate

/**
 * Ports the UI depends on. `data/` provides the astronomical
 * implementation; the Compose layer never touches the maths directly.
 */
interface PanchangRepository {
    fun dayDetail(date: LocalDate, city: City): PanchangDay
    fun summaries(start: LocalDate, end: LocalDate, city: City): Map<LocalDate, DaySummary>
}

interface FestivalRepository {
    fun all(): List<Festival>
    fun byId(id: String): Festival?
    fun upcoming(from: LocalDate, limit: Int = 50): List<Festival>
    fun onDate(date: LocalDate): List<Festival>
}
