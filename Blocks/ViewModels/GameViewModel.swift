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

    // MARK: - Init

    init() {
        gameState.highScore = UserDefaults.standard.integer(forKey: "highScore")
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
            return false
        }

        // Place the piece and score its cells.
        board.place(piece, at: origin)
        gameState.score += piece.cells.count

        // Clear completed lines and apply combo-multiplied bonus.
        let linesCleared = board.clearFullLines()
        if linesCleared > 0 {
            let baseBonus = scoreForLines(linesCleared)
            let comboMultiplier = comboMultiplier(forComboCount: gameState.comboCount)
            let totalBonus = Int(Double(baseBonus) * comboMultiplier)
            gameState.score += totalBonus
            gameState.comboCount += 1
        } else {
            // No lines cleared this round — reset the combo streak.
            gameState.comboCount = 0
        }

        // Mark piece as used; replenish when the whole set is gone.
        pieceSet.markPlaced(pieceWithID: piece.id)
        if pieceSet.isEmpty {
            pieceSet.replenish()
            // Combo resets between sets (each set is its own round).
            gameState.comboCount = 0
        }

        // Check whether the game should end.
        let anyPieceFits = pieceSet.availablePieces.contains { board.hasValidPlacement(for: $0) }
        if !anyPieceFits {
            gameState.isGameOver = true
        }

        // Persist high score.
        if gameState.score > gameState.highScore {
            gameState.highScore = gameState.score
            UserDefaults.standard.set(gameState.highScore, forKey: "highScore")
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
        gameState.highScore = UserDefaults.standard.integer(forKey: "highScore")
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

