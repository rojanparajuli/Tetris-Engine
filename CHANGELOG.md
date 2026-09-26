## 1.3.0

### New features
- **Level colors**: `LevelThemes` and `LevelPalette` change piece and board
  colors every level, with ten built-in palettes that cycle like classic
  Tetris. `LevelThemeBuilder` rebuilds a layout with the current level's
  theme. The example app now uses them during play.

## 1.2.0

### New features
- **Lock delay** (`TetrisGame.lockDelay`, default 500 ms) with Guideline move
  reset, capped by `maxLockResets` (default 15). Use `Duration.zero` for the
  previous behaviour.
- **T-Spin detection** (3-corner rule, full and mini) with Guideline scoring.
- **Perfect clear** bonus.
- **`TetrisGame.events`**: a stream of `TetrisEvent`s (moves, rotations, drops,
  holds, locks, line clears with T-Spin/back-to-back/combo info, level ups,
  game over) for sound effects, haptics and animations.
- **`TetrisControlPad`** and `TetrisPadButton`: on-screen touch controls with
  auto-repeat (configurable DAS/ARR) and optional haptics.
- **Seeded games**: `TetrisGame(seed: …)` or `start(seed: …)`; `game.seed`
  exposes the current seed.
- **Exact replays**: attach a recorder with `TetrisGame(recorder: …)` to
  capture every action, gravity step and lock together with the seed, then
  replay with `ReplayPlayer.play(frames, seed: recorder.seed)`.
- New `TetrisGame` options: `startLevel`, `linesPerLevel`, `gravityCurve`,
  `statistics` (share lifetime stats between games).
- Manual stepping: `useInternalClock`, `applyGravity()` and
  `lockActivePiece()` for custom game loops, AI and tests.
- `TetrisBoard`: `keyMap` for custom key bindings and `pauseOnBackground`
  (on by default) to pause when the app is hidden.
- `TetrisKeyboardHandler.defaultKeyMap` is now public; X rotates clockwise and
  Left Shift holds, as in the Guideline.
- `TetrisGame.togglePause()`, `playTime`, `gravityInterval`.
- Custom board widths spawn pieces centered (`Tetromino.spawn(type, boardCols: …)`).
- `Tetromino` now has value equality; `BoardState.isEmpty`.

### Bug fixes
- Gravity no longer awards soft-drop points.
- Back-to-back was reset by every piece that cleared no lines, so it almost
  never triggered. It is now only broken by an ordinary line clear.
- Lines cleared past a level threshold were added to, instead of subtracted
  from, the lines needed for the next level.
- Holding the first piece did not update the next-piece preview, and a held
  piece that could not spawn did not end the game.
- `loadFromJson` left the game frozen (no gravity), lost the ghost piece and
  did not restore the upcoming pieces. Restored games now come back paused,
  with the correct queue, and a mismatched board size throws `ArgumentError`.
- `TetrisBoard` kept listening to the old game when given a new one, called
  `onGameOver` on every notification after game over, and called
  `onScoreChanged` on every move instead of only when the score changed.
- Piece previews did not repaint when the theme changed.
- The package bundled its README screenshot as a Flutter asset, adding about
  200 KB to every app that depends on it.

### Other
- Minimum SDK lowered from Dart 3.12.2 to Dart 3.8 / Flutter 3.32.
- `TetrisAnimationController` is deprecated; it was never connected to the
  engine. Use `TetrisGame.events`.
- Added game, replay and widget tests (70 tests in total), CI on the oldest
  supported and latest Flutter versions, and issue templates.
- The example app keeps statistics across games, shows T-Spin, combo and
  perfect-clear banners, and uses `TetrisControlPad`.

## 1.1.0

* Updated the example application to improve clarity and demonstrate package usage more effectively.

## 1.0.0

* Initial release.
* Pure Dart Tetris engine with no backend or cloud dependencies.
* 7-bag randomizer with deterministic seeding.
* Super Rotation System (SRS) with full wall-kick tables for all pieces.
* Guideline scoring — back-to-back Tetris bonus, combo multiplier, hard/soft drop points.
* Level progression with gravity curve (1000 ms → 50 ms floor).
* Ghost piece, hold piece, configurable next-piece queue.
* `TetrisBoard` CustomPainter renderer with shine highlight and grid overlay.
* `NextPiecePreview`, `HoldPiecePreview`, `ScorePanel`, `LevelPanel`, `LinesClearedPanel`.
* `GameOverOverlay` and `PauseOverlay` with customizable builder callbacks.
* Three built-in themes: light, dark, colorblind-safe (Wong palette).
* Full theme customization via `TetrisTheme.copyWith()`.
* Keyboard handler with remappable key map (desktop/web).
* Swipe gesture handler with hard-drop velocity detection (mobile).
* `ReplayRecorder` / `ReplayPlayer` — record inputs as JSON, replay deterministically.
* `TetrisStatistics` — tracks games, scores, lines, levels, play time, piece usage.
* Fully serializable `GameState` — save/restore via any storage backend.
* Supports Android, iOS, Web, Windows, Linux, and macOS.
* Unit tests for collision, rotation, scoring, levels, board clearing, and piece bag.