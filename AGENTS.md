# AGENTS.md — Blocks iOS/iPadOS Game

## Project Overview

**Blocks** is a universal puzzle game for iPhone and **native iPad**, inspired by *Block Blast*. The player drags Tetromino-style pieces onto a grid. When a full row or column is completed, it clears and scores points. The game ends when no piece can be placed on the board.

---

## Game Mechanics

### Grid
- 8×8 board (64 cells)
- Each cell is either empty or filled with a colored block

### Pieces
- Up to **3 pieces** are shown at the bottom of the screen at all times
- Pieces are Tetromino/Pentomino-shaped (1–5 cells in various configurations)
- When all 3 pieces have been placed, a new set of 3 is generated
- Pieces **cannot be rotated** (as in Block Blast)

### Placement
- Player drags a piece from the tray onto the grid
- A ghost/preview shows where the piece will land
- A piece can only be placed if all its cells fit on the board and land on empty cells
- If a piece cannot be placed anywhere on the board, the game is over

### Line Clearing
- When one or more **rows** or **columns** are completely filled, they clear simultaneously
- Clearing multiple lines at once gives a combo bonus
- Cleared cells animate off the screen

### Scoring
| Action | Points |
|--------|--------|
| Place a piece (per cell) | 1 pt per cell |
| Clear 1 line | 10 pts |
| Clear 2 lines simultaneously | 30 pts |
| Clear 3 lines simultaneously | 60 pts |
| Clear 4+ lines simultaneously | 100 pts (+ combo multiplier) |
| Combo (consecutive clears) | ×1.5 per consecutive clear round |

### Game Over
- The game ends when **none** of the 3 current pieces can be legally placed on the board
- Final score is shown with a "Play Again" option
- High score is persisted locally

---

## Technical Architecture

### Platform & Language
- **iOS 17+ / iPadOS 17+**, **Swift 5.9+**, **SwiftUI** for UI
- Deployment target: **iPhone + iPad** (Universal app — `UIUserInterfaceIdiom` agnostic)
- **SpriteKit** (optional) for animations, or pure SwiftUI with animation modifiers
- **Combine** or `@Observable` for state management

### Adaptive Layout

The UI must feel **native and purposeful** on every screen size — not just a scaled-up iPhone layout.

| Device class | Layout strategy |
|---|---|
| **iPhone** (portrait) | Board centred, piece tray below board |
| **iPhone** (landscape) | Board left/centre, piece tray to the right, HUD top |
| **iPad** (portrait) | Board centred with generous padding, tray below, HUD above |
| **iPad** (landscape) | Board centred, tray below, HUD flanking both sides |
| **iPad Split View / Slide Over** | Compact-width: revert to iPhone portrait layout |

Implementation rules:
- Use `GeometryReader` + `horizontalSizeClass` / `verticalSizeClass` environment values to switch layouts
- **Cell size is computed dynamically**: `cellSize = min(availableWidth, availableHeight) / 8` so the board always fills the available square without overflow
- Piece tray items scale proportionally with cell size
- Minimum touch target for any draggable piece: **44 × 44 pt** (HIG requirement)
- No hard-coded widths or heights anywhere in Views
- On iPad, drag coordinate translation must account for the board's position within the larger canvas (use `GeometryReader` anchored to the `BoardView`)

### Project Structure
```
Blocks/
├── App/
│   └── BlocksApp.swift          # App entry point
├── Models/
│   ├── Block.swift              # Single cell model
│   ├── Piece.swift              # Piece shape definition
│   ├── PieceSet.swift           # Manages the tray of 3 pieces
│   ├── Board.swift              # 8×8 grid state & logic
│   └── GameState.swift          # Score, combo, game-over state
├── ViewModels/
│   └── GameViewModel.swift      # Bridges models ↔ views
├── Views/
│   ├── GameView.swift           # Root game screen; chooses iPhone vs iPad layout
│   ├── BoardView.swift          # Renders the 8×8 grid (size-class agnostic)
│   ├── CellView.swift           # Single grid cell
│   ├── PieceTrayView.swift      # Piece tray (horizontal on iPhone, flexible on iPad)
│   ├── PieceView.swift          # Draggable piece widget
│   └── HUDView.swift            # Score, high score display
├── Resources/
│   ├── Assets.xcassets          # Colors, icons, images (including iPad app icon)
│   ├── Localisation/
│   │   ├── Localizable.xcstrings    # String catalogue (da, fr, en, ja)
│   │   └── InfoPlist.xcstrings      # Localised app name etc.
│   └── Sounds/                  # SFX (place, clear, game over)
└── Utilities/
    ├── PieceLibrary.swift       # All piece shape definitions
    └── HapticManager.swift      # Haptic feedback helpers
```

### Key Data Structures

```swift
// A cell coordinate on the board
struct Coordinate: Hashable { var row: Int; var col: Int }

// A piece is an array of relative coordinates
struct Piece: Identifiable {
    let id: UUID
    let cells: [Coordinate]   // relative to origin (0,0)
    let color: Color
}

// Board holds an 8×8 matrix
class Board: ObservableObject {
    var grid: [[Color?]]      // nil = empty
    func canPlace(_ piece: Piece, at origin: Coordinate) -> Bool
    func place(_ piece: Piece, at origin: Coordinate)
    func clearFullLines() -> Int   // returns number of lines cleared
}
```

### Gesture Handling
- `DragGesture` on each `PieceView`
- During drag: compute target board cell from drag location, show ghost overlay
- On drag end: attempt placement; if invalid, animate piece back to tray
- On iPad, coordinate translation must account for the board's position within the larger canvas (use `GeometryReader` anchored to the `BoardView`)

### Localisation
- The app uses **Apple's Localisation system** (`Localizable.strings` / `String Catalogues`)
- **Launch languages**: Danish (`da`), French (`fr`), English (`en`), Japanese (`ja`)
- All user-facing strings must go through `String(localized:)` — no hard-coded text in views
- Locale-sensitive formatting (numbers, scores) must use `NumberFormatter` / `formatted()`
- Adding a new language later requires only a new `.strings` / `.xcstrings` entry — no code changes
- String keys must be descriptive (e.g., `"game.score.label"`, `"gameOver.title"`), not positional

### Persistence
- `UserDefaults` to store high score
- Optional: `SwiftData` for future features (stats, levels)

---

## Piece Library (Shapes)

All pieces are defined as arrays of `(row, col)` offsets from the top-left anchor:

| Name | Shape |
|------|-------|
| Single | `[(0,0)]` |
| Domino H | `[(0,0),(0,1)]` |
| Domino V | `[(0,0),(1,0)]` |
| L-Piece | `[(0,0),(1,0),(2,0),(2,1)]` |
| J-Piece | `[(0,1),(1,1),(2,0),(2,1)]` |
| T-Piece | `[(0,0),(0,1),(0,2),(1,1)]` |
| S-Piece | `[(0,1),(0,2),(1,0),(1,1)]` |
| Z-Piece | `[(0,0),(0,1),(1,1),(1,2)]` |
| 2×2 Square | `[(0,0),(0,1),(1,0),(1,1)]` |
| 3×3 Square | all cells in a 3×3 grid |
| I-3 H | `[(0,0),(0,1),(0,2)]` |
| I-4 H | `[(0,0),(0,1),(0,2),(0,3)]` |
| I-5 H | `[(0,0)…(0,4)]` |
| I-3 V | `[(0,0),(1,0),(2,0)]` |
| I-4 V | `[(0,0),(1,0),(2,0),(3,0)]` |
| I-5 V | `[(0,0)…(4,0)]` |

---

## Visual Design

- **Background**: deep dark navy (`#0D0D1A`)
- **Grid lines**: subtle dark gray
- **Block colors**: vibrant palette — red, orange, yellow, green, cyan, blue, purple
- **Cleared lines**: flash white → fade out
- **Piece ghost**: semi-transparent tint of piece color
- **Font**: Rounded system font (SF Rounded)
- **App icons**: provide all required sizes for both iPhone and iPad (`Assets.xcassets`)

---

## Animations & Haptics

| Event | Animation | Haptic |
|-------|-----------|--------|
| Piece placed | scale pop (1.0 → 1.1 → 1.0) | light impact |
| Line cleared | cells flash & scale to 0 | medium impact |
| Combo | score label bounces, gold glow | heavy impact |
| Game over | board shakes, dim overlay | error haptic |
| Invalid drop | piece wiggles back to tray | warning haptic |

---

## Sound Effects

- `place.wav` — soft "thud" when a piece is placed
- `clear.wav` — satisfying "whoosh" when a line clears
- `combo.wav` — ascending chime for combos
- `gameover.wav` — descending tone

---

## Development Milestones

| Milestone | Description |
|-----------|-------------|
| **M1** | Project setup (Universal target), board model, basic SwiftUI grid rendering |
| **M2** | Piece library, tray rendering, drag-and-drop placement |
| **M3** | Line-clearing logic, scoring, combo system |
| **M4** | Adaptive layouts for iPhone & iPad (all orientations + Split View) |
| **M5** | Animations, haptics, sound effects |
| **M6** | High score persistence, game-over screen, localisation (da / fr / en / ja), polish |
| **M7** | TestFlight beta, bug fixes |
| **M8** | App Store submission |

---

## Coding Conventions

- **Simplicity and readability over performance** — prefer clear, straightforward code; avoid premature optimisation
- Use **Swift concurrency** (`async/await`) for any async work (e.g., loading sounds)
- Prefer **value types** (`struct`) for models; use `@Observable` classes for view models
- Write **unit tests** for Board logic (placement validation, line clearing)
- Follow **SwiftUI best practices**: small, focused views; avoid large bodies in `body`
- **No hard-coded sizes** — all dimensions derived from `GeometryReader` or environment
- Use `@Environment(\.horizontalSizeClass)` and `@Environment(\.verticalSizeClass)` to drive layout decisions
- Use **Swift Package Manager** for any third-party dependencies
- Favour **descriptive naming** over brevity — variable and function names should read like plain English
- Avoid clever one-liners; prefer explicit, step-by-step logic that is easy to follow at a glance

---

## Agent Instructions

When implementing features for this project:

1. **Always** read `AGENTS.md` first to understand the architecture.
2. **Follow the project structure** defined above — place new files in the correct folder.
3. **Models must be pure** — no UIKit/SwiftUI imports in `Models/`.
4. **ViewModels** own all game logic coordination; Views are dumb renderers.
5. **Test board logic** — every public method on `Board` must have a unit test.
6. **Never hard-code sizes** — all layout must be adaptive and work on all iPhone and iPad screen sizes and orientations, including Split View and Slide Over.
7. **Ask before deviating** from the architecture described here.
8. For each milestone, create a git commit with the milestone tag (e.g., `[M1] Setup board model`).
