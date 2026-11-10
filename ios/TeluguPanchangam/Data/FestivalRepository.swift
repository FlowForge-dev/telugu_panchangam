import Foundation

/// Serves the curated, source-cited festival list in `FestivalData`.
final class FestivalRepository: @unchecked Sendable {

    static let shared = FestivalRepository()

    private let byDate: [CivilDate: [Festival]] = Dictionary(grouping: FestivalData.festivals, by: { $0.date })

    func all() -> [Festival] { FestivalData.festivals }

    func byId(_ id: String) -> Festival? { FestivalData.festivals.first { $0.id == id } }

    func upcoming(from: CivilDate, limit: Int = 50) -> [Festival] {
        Array(FestivalData.festivals.filter { $0.date >= from }.prefix(limit))
    }

    func onDate(_ date: CivilDate) -> [Festival] { byDate[date] ?? [] }
}
