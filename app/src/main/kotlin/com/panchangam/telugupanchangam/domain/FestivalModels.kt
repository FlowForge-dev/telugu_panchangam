package com.panchangam.telugupanchangam.domain

import java.time.LocalDate

enum class VerificationStatus {
    /** Date confirmed by a named, authoritative published source. */
    VERIFIED,
    /** Authoritative sources disagree by tradition or region; see the note. */
    VARIES_BY_TRADITION,
    /** Derived astronomically by this app; no published source was checked. */
    COMPUTED,
    /** Not yet confirmed by an authoritative source. */
    PENDING_VERIFICATION
}

/**
 * Provenance for any religious/calendrical claim shown in the app.
 * Treated as a first-class feature, not an afterthought.
 */
data class SourceReference(
    val title: String,
    val publisher: String? = null,
    val edition: String? = null,
    val url: String? = null,
    val notes: String? = null,
    val status: VerificationStatus = VerificationStatus.PENDING_VERIFICATION
)

enum class FestivalImportance { MAJOR, MODERATE, OBSERVANCE }

data class Festival(
    val id: String,
    val name: String,
    val teluguName: String,
    val date: LocalDate,
    val importance: FestivalImportance,
    val shortSignificance: String,
    val significance: String,
    /** How sure we are of the date, and why. */
    val dateStatus: VerificationStatus,
    /** Tithi timing or tradition note explaining the date, if any. */
    val dateNote: String? = null,
    val observance: String? = null,
    val preparation: String? = null,
    val sources: List<SourceReference> = emptyList()
)
