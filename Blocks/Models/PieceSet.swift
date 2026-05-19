import Foundation

/// Manages the tray of up to 3 pieces shown to the player.
/// When all pieces have been placed, a fresh set of 3 is generated automatically.
struct PieceSet {

    /// The three current pieces. A nil entry means that slot has been placed already.
    private(set) var slots: [Piece?]

    init() {
        slots = PieceLibrary.randomSet().map { Optional($0) }
    }

    /// Initialiser for testing: supply fixed slots directly.
    init(fixedSlots: [Piece?]) {
        slots = fixedSlots
    }

    /// The pieces currently available to place (non-nil slots).
    var availablePieces: [Piece] {
        slots.compactMap { $0 }
    }

    /// True when every slot has been placed, meaning a new set should be generated.
    var isEmpty: Bool {
        slots.allSatisfy { $0 == nil }
    }

    /// Marks the piece with the given id as placed (sets its slot to nil).
    mutating func markPlaced(pieceWithID id: UUID) {
        for index in slots.indices {
            if slots[index]?.id == id {
                slots[index] = nil
                return
            }
        }
    }

    /// Replaces all slots with a fresh random set.
    mutating func replenish() {
        slots = PieceLibrary.randomSet().map { Optional($0) }
    }
}

