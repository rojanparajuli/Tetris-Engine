## 1.1.0
- Updated the example application to improve clarity and demonstrate package usage more effectively.

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