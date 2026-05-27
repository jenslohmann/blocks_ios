import Foundation

/// A single recorded game score together with the date it was achieved.
/// Stored as JSON in UserDefaults and kept in a top-10 list.
struct ScoreEntry: Codable, Identifiable, Equatable {
    let id: UUID
    let score: Int
    let date: Date

    init(score: Int, date: Date = .now) {
        self.id    = UUID()
        self.score = score
        self.date  = date
    }
}

