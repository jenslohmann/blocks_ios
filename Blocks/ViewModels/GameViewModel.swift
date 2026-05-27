import Foundation
import Observation
import SwiftUI

/// Coordinates all game logic: piece placement, line clearing, scoring, and game-over detection.
/// Views observe this object and re-render whenever its published state changes.
/// Marked @MainActor so all state mutations happen on the main thread, which SwiftUI requires.
@MainActor
@Observable
final class GameViewModel {

    // MARK: - State

    private(set) var board = Board()
    var pieceSet = PieceSet()
    var gameState = GameState()

    /// The piece currently being dragged, together with the board cell it is hovering over.
    private(set) var draggedPiece: Piece? = nil
    private(set) var ghostOrigin: Coordinate? = nil

    // MARK: - Animation triggers
    // Each property is toggled so views can drive .onChange animations.

    /// Toggled every time a piece is placed successfully.
    private(set) var placementEventID: UUID = UUID()
    /// Set of coordinates that were just cleared — drives the flash-and-shrink animation.
    private(set) var recentlyClearedCells: Set<Coordinate> = []
    /// Toggled when a combo is scored.
    private(set) var comboEventID: UUID = UUID()
    /// Toggled when the game ends.
    private(set) var gameOverEventID: UUID = UUID()
    /// Toggled when an invalid drop is attempted.
    private(set) var invalidDropEventID: UUID = UUID()

    // MARK: - Init

    init() {
        gameState.highScore = ScoreRepository.loadTopScores().first?.score ?? 0
    }

    // MARK: - Drag interaction

    /// Called continuously while the player drags a piece over the board.
    /// Updates the ghost overlay so the player can preview the placement.
    func updateDrag(piece: Piece, hoveredCell: Coordinate?) {
        draggedPiece = piece
        if let cell = hoveredCell, board.canPlace(piece, at: cell) {
            ghostOrigin = cell
        } else {
            ghostOrigin = nil
        }
    }

    /// Called when the player releases a piece.
    /// Returns true if the piece was successfully placed; false if the drop was invalid.
    @discardableResult
    func commitDrop(piece: Piece, at origin: Coordinate?) -> Bool {
        draggedPiece = nil
        ghostOrigin = nil

        guard let origin = origin, board.canPlace(piece, at: origin) else {
            // Invalid drop — haptic + animation trigger.
            invalidDropEventID = UUID()
            HapticManager.invalidDrop()
            return false
        }

        // Place the piece and score its cells.
        board.place(piece, at: origin)
        gameState.score += piece.cells.count
        placementEventID = UUID()
        HapticManager.piecePlaced()
        SoundManager.shared.play(.place)

        // Capture which cells are about to be cleared so the UI can animate them.
        let cellsToAnimate = board.fullLineCells()
        recentlyClearedCells = cellsToAnimate

        // Clear completed lines and apply combo-multiplied bonus.
        let linesCleared = board.clearFullLines()
        if linesCleared > 0 {
            let baseBonus = scoreForLines(linesCleared)
            let comboMultiplier = comboMultiplier(forComboCount: gameState.comboCount)
            let totalBonus = Int(Double(baseBonus) * comboMultiplier)
            gameState.score += totalBonus

            if gameState.comboCount > 0 {
                // This is a consecutive clear — fire the combo event.
                comboEventID = UUID()
                HapticManager.combo()
                SoundManager.shared.play(.combo)
            } else {
                HapticManager.lineCleared()
                SoundManager.shared.play(.clear)
            }
            gameState.comboCount += 1

            // Reset the clearing set after the animation has had time to finish.
            // The shrink-to-zero animation takes ~300 ms; waiting 400 ms is safe.
            Task {
                try? await Task.sleep(for: .milliseconds(400))
                recentlyClearedCells = []
            }
        } else {
            recentlyClearedCells = []
            gameState.comboCount = 0
        }

        // Mark piece as used; replenish when the whole set is gone.
        pieceSet.markPlaced(pieceWithID: piece.id)
        if pieceSet.isEmpty {
            pieceSet.replenish()
            gameState.comboCount = 0
        }

        // Check whether the game should end.
        let anyPieceFits = pieceSet.availablePieces.contains { board.hasValidPlacement(for: $0) }
        if !anyPieceFits {
            gameState.isGameOver = true
            gameOverEventID = UUID()
            HapticManager.gameOver()
            SoundManager.shared.play(.gameOver)

            // Only record the final score once the game is truly over.
            let result = ScoreRepository.record(score: gameState.score)
            gameState.isNewHighScore = result.isTopTen
            gameState.highScore = result.entries.first?.score ?? gameState.score
        }

        return true
    }

    /// Cancels an in-progress drag without placing anything.
    func cancelDrag() {
        draggedPiece = nil
        ghostOrigin = nil
    }

    // MARK: - Game lifecycle

    /// Resets all state to start a fresh game.
    func newGame() {
        board = Board()
        pieceSet = PieceSet()
        gameState = GameState()
        gameState.highScore = ScoreRepository.loadTopScores().first?.score ?? 0
    }

    // MARK: - Private helpers

    /// Maps a number of simultaneously cleared lines to a base point bonus.
    private func scoreForLines(_ count: Int) -> Int {
        switch count {
        case 1:  return 10
        case 2:  return 30
        case 3:  return 60
        default: return count >= 4 ? 100 : 0
        }
    }

    /// Returns the combo multiplier for the given consecutive-clear count.
    /// The first clear in a streak has no multiplier (×1.0).
    /// Each subsequent consecutive clear round adds ×0.5.
    private func comboMultiplier(forComboCount count: Int) -> Double {
        if count <= 0 { return 1.0 }
        return 1.0 + Double(count) * 0.5
    }
}

