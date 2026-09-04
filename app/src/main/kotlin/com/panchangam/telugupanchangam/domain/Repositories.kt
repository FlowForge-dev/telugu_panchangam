package com.panchangam.telugupanchangam.domain

import java.time.LocalDate

/**
 * Ports the UI depends on. `data/` provides today's mock implementation;
 * a real deterministic Panchangam backend can replace it without any
 * change to the Compose layer.
 */
interface PanchangRepository {
    fun dayDetail(date: LocalDate): PanchangDay
    fun range(start: LocalDate, end: LocalDate): Map<LocalDate, PanchangDay>
}

interface FestivalRepository {
    fun all(): List<Festival>
    fun byId(id: String): Festival?
    fun upcoming(from: LocalDate = LocalDate.now(), limit: Int = 50): List<Festival>
    fun onDate(date: LocalDate): List<Festival>
}
