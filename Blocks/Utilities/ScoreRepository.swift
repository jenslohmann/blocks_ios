import Foundation

/// Reads and writes the persistent top-10 high score list.
/// Scores are kept sorted highest-first; only the top 10 are retained.
enum ScoreRepository {

    private static let userDefaultsKey = "topScores"
    static let maxEntries = 10

    /// Loads and returns the current top-10 list, highest score first.
    static func loadTopScores() -> [ScoreEntry] {
        guard
            let data = UserDefaults.standard.data(forKey: userDefaultsKey),
            let entries = try? JSONDecoder().decode([ScoreEntry].self, from: data)
        else {
            return []
        }
        return entries
    }

    /// Inserts a new score, re-sorts, trims to the top 10, and persists the result.
    /// - Returns: The updated list and whether the new entry made it into the top 10.
    @discardableResult
    static func record(score: Int) -> (entries: [ScoreEntry], isTopTen: Bool) {
        var entries = loadTopScores()
        let newEntry = ScoreEntry(score: score)
        entries.append(newEntry)
        entries.sort { $0.score > $1.score }
        if entries.count > maxEntries {
            entries = Array(entries.prefix(maxEntries))
        }
        let isTopTen = entries.contains { $0.id == newEntry.id }
        if isTopTen {
            save(entries)
        }
        return (entries, isTopTen)
    }

    // MARK: - Private

    private static func save(_ entries: [ScoreEntry]) {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        UserDefaults.standard.set(data, forKey: userDefaultsKey)
    }
}

