package com.panchangam.telugupanchangam.data

import com.panchangam.telugupanchangam.domain.Festival
import com.panchangam.telugupanchangam.domain.FestivalRepository
import java.time.LocalDate

/** Serves the curated, source-cited festival list in [FestivalData]. */
class StaticFestivalRepository : FestivalRepository {
    private val byDate: Map<LocalDate, List<Festival>> = FestivalData.festivals.groupBy { it.date }

    override fun all(): List<Festival> = FestivalData.festivals

    override fun byId(id: String): Festival? = FestivalData.festivals.firstOrNull { it.id == id }

    override fun upcoming(from: LocalDate, limit: Int): List<Festival> =
        FestivalData.festivals.filter { !it.date.isBefore(from) }.take(limit)

    override fun onDate(date: LocalDate): List<Festival> = byDate[date].orEmpty()
}
