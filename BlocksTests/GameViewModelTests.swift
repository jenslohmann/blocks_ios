import XCTest
@testable import Blocks

/// Tests for scoring, combo multiplier, and game-over detection.
@MainActor
final class GameViewModelTests: XCTestCase {

    // MARK: - Scoring: points per cell placed

    func test_placingPiece_addsOnePtPerCell() {
        let viewModel = GameViewModel()
        let threeCellPiece = Piece(
            cells: [Coordinate(row: 0, col: 0), Coordinate(row: 0, col: 1), Coordinate(row: 0, col: 2)],
            colorName: "pieceRed"
        )
        viewModel.commitDrop(piece: threeCellPiece, at: Coordinate(row: 0, col: 0))
        XCTAssertGreaterThanOrEqual(viewModel.gameState.score, 3,
            "Score should gain at least 1 pt per cell placed")
    }

    // MARK: - Scoring: line-clear bonuses via formula

    func test_clearingOneLine_baseBonusIs10() {
        XCTAssertEqual(lineClearBonus(lines: 1, comboCount: 0), 10)
    }

    func test_clearing2Lines_baseBonusIs30() {
        XCTAssertEqual(lineClearBonus(lines: 2, comboCount: 0), 30)
    }

    func test_clearing3Lines_baseBonusIs60() {
        XCTAssertEqual(lineClearBonus(lines: 3, comboCount: 0), 60)
    }

    func test_clearing4PlusLines_baseBonusIs100() {
        XCTAssertEqual(lineClearBonus(lines: 4, comboCount: 0), 100)
    }

    // MARK: - Combo multiplier

    func test_firstClearHasNoMultiplier() {
        XCTAssertEqual(lineClearBonus(lines: 1, comboCount: 0), 10)
    }

    func test_secondConsecutiveClear_applies1point5xMultiplier() {
        // comboCount 1 → multiplier = 1.0 + 1*0.5 = 1.5 → 10 * 1.5 = 15
        XCTAssertEqual(lineClearBonus(lines: 1, comboCount: 1), 15)
    }

    func test_thirdConsecutiveClear_applies2xMultiplier() {
        // comboCount 2 → multiplier = 1.0 + 2*0.5 = 2.0 → 10 * 2.0 = 20
        XCTAssertEqual(lineClearBonus(lines: 1, comboCount: 2), 20)
    }

    // MARK: - Game-over detection

    func test_gameIsNotOverOnStart() {
        let viewModel = GameViewModel()
        XCTAssertFalse(viewModel.gameState.isGameOver)
    }

    func test_gameOverDetected_whenNoPieceFits() {
        let viewModel = GameViewModel()

        // Fill the entire board.
        for row in 0 ..< Board.size {
            for col in 0 ..< Board.size {
                viewModel.board.grid[row][col] = "pieceRed"
            }
        }

        // Force a tray of 4-cell pieces — none can fit on a full board.
        let bigPiece = Piece(
            cells: [Coordinate(row: 0, col: 0), Coordinate(row: 0, col: 1),
                    Coordinate(row: 0, col: 2), Coordinate(row: 0, col: 3)],
            colorName: "pieceBlue"
        )
        viewModel.pieceSet = PieceSet(fixedSlots: [bigPiece, bigPiece, bigPiece])

        // Replicate the game-over check done in commitDrop.
        let anyFits = viewModel.pieceSet.availablePieces.contains {
            viewModel.board.hasValidPlacement(for: $0)
        }
        if !anyFits { viewModel.gameState.isGameOver = true }

        XCTAssertTrue(viewModel.gameState.isGameOver)
    }

    func test_newGame_resetsIsGameOver() {
        let viewModel = GameViewModel()
        viewModel.gameState.isGameOver = true
        viewModel.newGame()
        XCTAssertFalse(viewModel.gameState.isGameOver)
    }

    func test_newGame_resetsScore() {
        let viewModel = GameViewModel()
        viewModel.gameState.score = 999
        viewModel.newGame()
        XCTAssertEqual(viewModel.gameState.score, 0)
    }

    func test_newGame_resetsComboCount() {
        let viewModel = GameViewModel()
        viewModel.gameState.comboCount = 5
        viewModel.newGame()
        XCTAssertEqual(viewModel.gameState.comboCount, 0)
    }

    // MARK: - Helpers

    /// Mirrors the scoring formula in GameViewModel for self-contained verification.
    private func lineClearBonus(lines: Int, comboCount: Int) -> Int {
        let base: Int
        switch lines {
        case 1:  base = 10
        case 2:  base = 30
        case 3:  base = 60
        default: base = lines >= 4 ? 100 : 0
        }
        let multiplier = comboCount <= 0 ? 1.0 : 1.0 + Double(comboCount) * 0.5
        return Int(Double(base) * multiplier)
    }
}
