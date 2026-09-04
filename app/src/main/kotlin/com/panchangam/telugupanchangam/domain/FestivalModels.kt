package com.panchangam.telugupanchangam.domain

import java.time.LocalDate

enum class VerificationStatus { VERIFIED, PENDING_VERIFICATION, VARIES_BY_TRADITION }

/**
 * Provenance for any religious/calendrical claim shown in the app.
 * Treated as a first-class feature, not an afterthought.
 */
data class SourceReference(
    val title: String,
    val sectionOrChapter: String? = null,
    val edition: String? = null,
    val language: String? = null,
    val notes: String? = null,
    val status: VerificationStatus = VerificationStatus.PENDING_VERIFICATION
) {
    companion object {
        val UNVERIFIED = SourceReference(
            title = "[AUTHORITATIVE SOURCE REQUIRED]",
            notes = "This entry is a structural placeholder pending review by a qualified source."
        )
    }
}

enum class FestivalImportance { MAJOR, MODERATE, OBSERVANCE }

data class Festival(
    val id: String,
    val name: String,
    val teluguName: String,
    val date: LocalDate,
    val importance: FestivalImportance,
    val shortSignificance: String,
    val significance: String,
    val observance: String,
    val preparation: String,
    val mantraSources: List<SourceReference> = emptyList(),
    val sources: List<SourceReference> = emptyList(),
    /** True while the date itself is an unverified estimate. */
    val isMockCalculated: Boolean = true
)
