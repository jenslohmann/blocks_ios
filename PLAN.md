# PLAN.md — Blocks iOS/iPadOS Development Plan

> Derived from `AGENTS.md`. This document breaks each milestone into concrete tasks with clear acceptance criteria.

---

## Milestone 1 — Project Setup & Board Model

**Goal:** A working Xcode project targeting iPhone + iPad, with the board model fully implemented and a basic grid rendered on screen.

### Tasks

#### 1.1 Xcode Project
- [ ] Create a new Xcode project: product name `Blocks`, organisation identifier of your choice
- [ ] Set deployment target to **iOS 17.0** (covers both iPhone and iPad)
- [ ] Set supported destinations to **iPhone + iPad** (Universal)
- [ ] Enable portrait + landscape orientations for both device families
- [ ] Delete the default `ContentView.swift`; set up the folder structure from `AGENTS.md`

#### 1.2 Models (no UIKit/SwiftUI imports)
- [ ] `Coordinate.swift` — `struct Coordinate: Hashable { var row: Int; var col: Int }`
- [ ] `Block.swift` — `struct Block` representing a single filled cell (coordinate + color name string)
- [ ] `Piece.swift` — `struct Piece: Identifiable` with `id: UUID`, `cells: [Coordinate]`, `colorName: String`
- [ ] `Board.swift` — 8×8 grid logic:
  - `var grid: [[String?]]` (color name strings; `nil` = empty)
  - `func canPlace(_ piece: Piece, at origin: Coordinate) -> Bool`
  - `func place(_ piece: Piece, at origin: Coordinate)`
  - `func clearFullLines() -> Int` (clears complete rows and columns, returns count)
- [ ] `GameState.swift` — `struct GameState` with `score`, `highScore`, `comboCount`, `isGameOver`

#### 1.3 Basic SwiftUI Grid
- [ ] `BlocksApp.swift` — app entry point
- [ ] `GameView.swift` — root view; for now just embeds `BoardView`
- [ ] `BoardView.swift` — renders the 8×8 grid using `GeometryReader`; cell size computed as `min(width, height) / 8`
- [ ] `CellView.swift` — renders a single cell (filled or empty)

#### 1.4 Unit Tests
- [ ] `BoardTests.swift` — test suite covering:
  - `canPlace` returns `true` for a valid empty position
  - `canPlace` returns `false` when cells are already occupied
  - `canPlace` returns `false` when piece would exceed grid bounds
  - `place` correctly fills the grid
  - `clearFullLines` clears a completed row and returns 1
  - `clearFullLines` clears a completed column and returns 1
  - `clearFullLines` clears multiple lines simultaneously and returns the correct count

#### 1.5 Git Commit
- [ ] Commit with message: `[M1] Setup board model and basic grid rendering`

---

## Milestone 2 — Piece Library, Tray & Drag-and-Drop

**Goal:** All pieces defined, a tray showing 3 pieces at the bottom, and working drag-to-place interaction.

### Tasks

#### 2.1 Piece Library
- [ ] `PieceLibrary.swift` — defines all 16 piece shapes as static constants (see `AGENTS.md` for shapes)
- [ ] `PieceSet.swift` — manages a tray of up to 3 pieces; generates a new random set when all 3 are placed

#### 2.2 ViewModel
- [ ] `GameViewModel.swift` — `@Observable` class that owns:
  - `board: Board`
  - `gameState: GameState`
  - `currentPieceSet: PieceSet`
  - `func tryPlace(piece:at:)` — places a piece, triggers line clearing, updates score, checks game over
  - `func newGame()` — resets all state

#### 2.3 Tray View
- [ ] `PieceTrayView.swift` — horizontal row of 3 `PieceView` instances; scales with `cellSize`
- [ ] `PieceView.swift` — renders a piece as a mini grid of coloured cells; minimum 44×44 pt touch target

#### 2.4 Drag-and-Drop
- [ ] Attach `DragGesture` to each `PieceView`
- [ ] During drag: translate finger position → board cell coordinate; show ghost overlay on `BoardView`
- [ ] On drag end: call `GameViewModel.tryPlace`; if invalid, animate piece back to tray with a wiggle
- [ ] On iPad: use `GeometryReader` anchored to `BoardView` to correctly translate coordinates

#### 2.5 Ghost Overlay
- [ ] `BoardView` accepts an optional `ghostPiece: Piece?` and `ghostOrigin: Coordinate?`
- [ ] Render ghost cells as semi-transparent tint of the piece colour

#### 2.6 Git Commit
- [ ] Commit with message: `[M2] Piece library, tray, and drag-and-drop placement`

---

## Milestone 3 — Line Clearing, Scoring & Combo System

**Goal:** Complete game loop — lines clear, score accumulates, combos multiply, game ends correctly.

### Tasks

#### 3.1 Line Clearing
- [ ] `Board.clearFullLines()` — already stubbed in M1; verify it handles simultaneous row + column clears
- [ ] Return the total number of lines cleared in a single call (rows + columns counted together)

#### 3.2 Scoring
- [ ] In `GameViewModel.tryPlace`:
  - Add 1 pt per cell of the placed piece
  - Calculate line-clear bonus: 1 line → 10 pts, 2 → 30 pts, 3 → 60 pts, 4+ → 100 pts
  - Apply combo multiplier (×1.5 per consecutive round with at least one clear)
  - Reset combo counter if no lines cleared in a round
- [ ] Update `highScore` in `GameState` and persist to `UserDefaults`

#### 3.3 HUD
- [ ] `HUDView.swift` — displays current score and high score
- [ ] All strings go through `String(localized:)` with descriptive keys
- [ ] Numbers formatted with `.formatted()` (locale-aware)

#### 3.4 Game Over Detection
- [ ] After each placement, check if any of the 3 remaining pieces can be legally placed anywhere on the board
- [ ] If none can, set `gameState.isGameOver = true`
- [ ] Show a game-over overlay with final score and a "Play Again" button (calls `newGame()`)

#### 3.5 Unit Tests
- [ ] Scoring tests: correct points for each line-clear tier
- [ ] Combo multiplier test: two consecutive clearing rounds produce ×1.5 bonus
- [ ] Game-over detection test: board filled such that no piece fits → `isGameOver` is `true`

#### 3.6 Git Commit
- [ ] Commit with message: `[M3] Line clearing, scoring, combo system, game over`

---

## Milestone 4 — Adaptive Layouts (iPhone & iPad)

**Goal:** The game looks and feels purposefully designed on every device size and orientation.

### Tasks

#### 4.1 Layout Switching
- [ ] `GameView.swift` reads `@Environment(\.horizontalSizeClass)` and `@Environment(\.verticalSizeClass)`
- [ ] Regular-width → iPad layout; compact-width → iPhone layout (also covers Split View / Slide Over)

#### 4.2 iPhone Layouts
- [ ] Portrait: board centred, `PieceTrayView` below, `HUDView` above
- [ ] Landscape: board left/centre, tray to the right, HUD at top

#### 4.3 iPad Layouts
- [ ] Portrait: board centred with generous padding, tray below, HUD above
- [ ] Landscape: board centred, tray below, HUD flanking both sides

#### 4.4 Dynamic Sizing
- [ ] Cell size derived from `GeometryReader`: `cellSize = min(availableWidth, availableHeight) / 8`
- [ ] Tray piece previews scale proportionally
- [ ] No hard-coded point values anywhere in Views
- [ ] All touch targets ≥ 44×44 pt

#### 4.5 iPad Drag Fix
- [ ] Verify ghost overlay and piece placement are pixel-accurate on all iPad sizes and orientations

#### 4.6 Git Commit
- [ ] Commit with message: `[M4] Adaptive layouts for iPhone and iPad`

---

## Milestone 5 — Animations, Haptics & Sound

**Goal:** The game feels alive and responsive with satisfying feedback.

### Tasks

#### 5.1 Animations
- [ ] Piece placed: scale pop `1.0 → 1.1 → 1.0` on affected cells
- [ ] Line cleared: cells flash white then scale to `0` and fade out
- [ ] Combo: score label bounces with a gold glow
- [ ] Game over: board shakes, dim overlay fades in
- [ ] Invalid drop: piece wiggles back to its tray slot

#### 5.2 Haptics
- [ ] `HapticManager.swift` — helpers wrapping `UIImpactFeedbackGenerator` and `UINotificationFeedbackGenerator`
- [ ] Piece placed → light impact
- [ ] Line cleared → medium impact
- [ ] Combo → heavy impact
- [ ] Game over → error notification haptic
- [ ] Invalid drop → warning notification haptic

#### 5.3 Sound Effects
- [ ] Add `place.wav`, `clear.wav`, `combo.wav`, `gameover.wav` to `Resources/Sounds/`
- [ ] Load and play sounds using `AVAudioPlayer` (or `AVAudioEngine`) via `async/await`
- [ ] Sounds play alongside haptics for each event

#### 5.4 Git Commit
- [ ] Commit with message: `[M5] Animations, haptics, and sound effects`

---

## Milestone 6 — Persistence, Game Over Screen, Localisation & Polish

**Goal:** A complete, shippable game experience with proper high-score saving and full localisation.

### Tasks

#### 6.1 High Score Persistence
- [ ] Save `highScore` to `UserDefaults` after every score change
- [ ] Load `highScore` from `UserDefaults` on app launch in `GameViewModel.init()`

#### 6.2 Game Over Screen
- [ ] Full-screen overlay showing: "Game Over" title, final score, high score, "Play Again" button
- [ ] All strings localised
- [ ] Triggered by `gameState.isGameOver`

#### 6.3 Localisation
- [ ] Add `Localizable.xcstrings` with all user-facing string keys in English, Danish, French, and Japanese
- [ ] Add `InfoPlist.xcstrings` for localised app name (`"Blocks"` in all languages, or translated where appropriate)
- [ ] Key inventory (minimum):
  - `"game.score.label"` — "Score"
  - `"game.highScore.label"` — "Best"
  - `"gameOver.title"` — "Game Over"
  - `"gameOver.finalScore.label"` — "Final Score"
  - `"gameOver.playAgain.button"` — "Play Again"
- [ ] All numbers formatted with `.formatted()` / `NumberFormatter`

#### 6.4 Polish
- [ ] App icon provided in all required sizes for iPhone and iPad in `Assets.xcassets`
- [ ] Launch screen / splash consistent with dark navy background
- [ ] Review all animations for smoothness on older devices (iPhone SE 2nd gen minimum)

#### 6.5 Git Commit
- [ ] Commit with message: `[M6] Persistence, game-over screen, localisation, polish`

---

## Milestone 7 — TestFlight Beta & Bug Fixes

**Goal:** Real-device testing, crash-free beta, ready for review.

### Tasks

- [ ] Archive and upload to App Store Connect
- [ ] Distribute to internal TestFlight testers
- [ ] Test on physical iPhone (portrait + landscape) and iPad (portrait + landscape + Split View)
- [ ] Fix any crashes, layout regressions, or localisation issues found
- [ ] Validate high score persists across app kills and reboots
- [ ] Run all unit tests; ensure 100 % pass rate
- [ ] Commit with message: `[M7] TestFlight fixes`

---

## Milestone 8 — App Store Submission

**Goal:** The app is submitted and passes App Review.

### Tasks

- [ ] Complete App Store Connect metadata: app name, subtitle, description, keywords (in en / da / fr / ja)
- [ ] Prepare screenshots for iPhone and iPad (all required sizes)
- [ ] Set age rating (4+, no objectionable content)
- [ ] Privacy manifest — confirm no data is collected (`UserDefaults` only, no analytics)
- [ ] Submit for App Review
- [ ] Commit with message: `[M8] App Store submission`

---

## Key Decisions & Constraints (Summary)

| Topic | Decision |
|---|---|
| Platform | iOS 17+ / iPadOS 17+, Universal |
| Language | Swift 5.9+, SwiftUI |
| State management | `@Observable` |
| Animations | Pure SwiftUI (SpriteKit optional) |
| Persistence | `UserDefaults` (high score only) |
| Networking | None — fully offline |
| Localisation | da, fr, en, ja at launch; extensible via `.xcstrings` |
| Grid size | 8×8 |
| Piece rotation | Not supported |
| Code style | Simplicity and readability over performance |

