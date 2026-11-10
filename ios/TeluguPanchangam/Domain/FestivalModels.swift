import Foundation

enum VerificationStatus {
    /// Date confirmed by a named, authoritative published source.
    case verified
    /// Authoritative sources disagree by tradition or region; see the note.
    case variesByTradition
    /// Derived astronomically by this app; no published source was checked.
    case computed
    /// Not yet confirmed by an authoritative source.
    case pendingVerification

    var teluguLabel: String {
        switch self {
        case .verified: return "ధృవీకరించబడింది"
        case .variesByTradition: return "సంప్రదాయాన్ని బట్టి మారుతుంది"
        case .computed: return "గణించబడింది"
        case .pendingVerification: return "ధృవీకరణ పెండింగ్"
        }
    }

    var englishLabel: String {
        switch self {
        case .verified: return "Verified"
        case .variesByTradition: return "Varies by tradition"
        case .computed: return "Computed"
        case .pendingVerification: return "Pending verification"
        }
    }
}

/// Provenance for any religious/calendrical claim shown in the app.
/// Treated as a first-class feature, not an afterthought.
struct SourceReference: Identifiable {
    let title: String
    let publisher: String?
    let edition: String?
    let url: String?
    let notes: String?
    let status: VerificationStatus

    var id: String { title + (publisher ?? "") }

    init(title: String, publisher: String? = nil, edition: String? = nil, url: String? = nil,
         notes: String? = nil, status: VerificationStatus = .pendingVerification) {
        self.title = title
        self.publisher = publisher
        self.edition = edition
        self.url = url
        self.notes = notes
        self.status = status
    }
}

enum FestivalImportance {
    case major, moderate, observance
}

struct Festival: Identifiable {
    let id: String
    let name: String
    let teluguName: String
    let date: CivilDate
    let importance: FestivalImportance
    let shortSignificance: String
    let significance: String
    /// How sure we are of the date, and why.
    let dateStatus: VerificationStatus
    /// Tithi timing or tradition note explaining the date, if any.
    let dateNote: String?
    let observance: String?
    let preparation: String?
    let sources: [SourceReference]
}
