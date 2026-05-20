/// All mutable game state: score, high score, combo tracking, and game-over flag.
struct GameState {
    var score: Int = 0
    var highScore: Int = 0
    var comboCount: Int = 0      // number of consecutive rounds where at least one line was cleared
    var isGameOver: Bool = false
    var isNewHighScore: Bool = false
}
