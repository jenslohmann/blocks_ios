/// All mutable game state: score, combo tracking, and game-over flag.
/// The all-time high score list is managed separately by ScoreRepository.
struct GameState {
    var score: Int = 0
    /// The highest score in the persisted top-10 list, refreshed at init and after each game.
    var highScore: Int = 0
    var comboCount: Int = 0      // number of consecutive rounds where at least one line was cleared
    var isGameOver: Bool = false
    /// True when the final score made it into the top-10 list.
    var isNewHighScore: Bool = false
}
