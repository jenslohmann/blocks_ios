import XCTest
@testable import Blocks

final class BoardTests: XCTestCase {

    // MARK: - canPlace

    func test_canPlace_returnsTrueForValidEmptyPosition() {
        let board = Board()
        let piece = Piece(cells: [Coordinate(row: 0, col: 0)], colorName: "red")
        XCTAssertTrue(board.canPlace(piece, at: Coordinate(row: 0, col: 0)))
    }

    func test_canPlace_returnsFalseWhenCellIsAlreadyOccupied() {
        let board = Board()
        let piece = Piece(cells: [Coordinate(row: 0, col: 0)], colorName: "red")
        let origin = Coordinate(row: 3, col: 3)
        board.place(piece, at: origin)
        XCTAssertFalse(board.canPlace(piece, at: origin))
    }

    func test_canPlace_returnsFalseWhenPieceExceedsRightBound() {
        let board = Board()
        let piece = Piece(cells: [Coordinate(row: 0, col: 0), Coordinate(row: 0, col: 1)], colorName: "red")
        XCTAssertFalse(board.canPlace(piece, at: Coordinate(row: 0, col: Board.size - 1)))
    }

    func test_canPlace_returnsFalseWhenPieceExceedsBottomBound() {
        let board = Board()
        let piece = Piece(cells: [Coordinate(row: 0, col: 0), Coordinate(row: 1, col: 0)], colorName: "blue")
        XCTAssertFalse(board.canPlace(piece, at: Coordinate(row: Board.size - 1, col: 0)))
    }

    func test_canPlace_returnsFalseForNegativeOrigin() {
        let board = Board()
        let piece = Piece(cells: [Coordinate(row: 0, col: 0)], colorName: "red")
        XCTAssertFalse(board.canPlace(piece, at: Coordinate(row: -1, col: 0)))
    }

    // MARK: - place

    func test_place_fillsCorrectCells() {
        let board = Board()
        let piece = Piece(cells: [Coordinate(row: 0, col: 0), Coordinate(row: 0, col: 1)], colorName: "green")
        board.place(piece, at: Coordinate(row: 2, col: 3))
        XCTAssertEqual(board.grid[2][3], "green")
        XCTAssertEqual(board.grid[2][4], "green")
        XCTAssertNil(board.grid[2][5])
    }

    // MARK: - clearFullLines

    func test_clearFullLines_clearsACompleteRow() {
        let board = Board()
        for col in 0 ..< Board.size { board.grid[0][col] = "red" }
        XCTAssertEqual(board.clearFullLines(), 1)
        for col in 0 ..< Board.size { XCTAssertNil(board.grid[0][col]) }
    }

    func test_clearFullLines_doesNotClearIncompleteRow() {
        let board = Board()
        for col in 0 ..< Board.size - 1 { board.grid[0][col] = "red" }
        XCTAssertEqual(board.clearFullLines(), 0)
    }

    func test_clearFullLines_clearsACompleteColumn() {
        let board = Board()
        for row in 0 ..< Board.size { board.grid[row][0] = "red" }
        XCTAssertEqual(board.clearFullLines(), 1)
        for row in 0 ..< Board.size { XCTAssertNil(board.grid[row][0]) }
    }

    func test_clearFullLines_clearsRowAndColumnSimultaneously() {
        let board = Board()
        for col in 0 ..< Board.size { board.grid[2][col] = "red" }
        for row in 0 ..< Board.size { board.grid[row][5] = "red" }
        XCTAssertEqual(board.clearFullLines(), 2)
    }

    func test_clearFullLines_clearsMultipleRows() {
        let board = Board()
        for col in 0 ..< Board.size { board.grid[0][col] = "red" }
        for col in 0 ..< Board.size { board.grid[7][col] = "red" }
        XCTAssertEqual(board.clearFullLines(), 2)
    }

    // MARK: - hasValidPlacement

    func test_hasValidPlacement_returnsTrueOnEmptyBoard() {
        let board = Board()
        let piece = Piece(cells: [Coordinate(row: 0, col: 0)], colorName: "red")
        XCTAssertTrue(board.hasValidPlacement(for: piece))
    }

    func test_hasValidPlacement_returnsFalseWhenBoardIsFullyOccupied() {
        let board = Board()
        for row in 0 ..< Board.size { for col in 0 ..< Board.size { board.grid[row][col] = "red" } }
        let piece = Piece(cells: [Coordinate(row: 0, col: 0)], colorName: "red")
        XCTAssertFalse(board.hasValidPlacement(for: piece))
    }
}
