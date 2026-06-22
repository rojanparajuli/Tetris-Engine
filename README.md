# tetris engine

A complete, reusable Tetris Engine package — pure Dart, no backend, no cloud dependencies.
Works on Android, iOS, Web, Windows, Linux, and macOS.

## Features

- **Full Tetris Guideline engine** — 7-bag randomizer, SRS rotation, ghost piece, hold, next queue
- **Scoring** — line clear points, back-to-back Tetris bonus, combo multiplier, hard/soft drop
- **Level & gravity** — automatic speed progression
- **Theme system** — light, dark, and colorblind-safe themes; fully customizable
- **Input** — keyboard (desktop/web), swipe gestures (mobile), on-screen buttons
- **Replay system** — record inputs as JSON, play back deterministically
- **Statistics** — tracks scores, levels, play time, piece usage across sessions
- **Serializable state** — save/restore via SharedPreferences, Hive, or any storage

## Installation

```yaml
dependencies:
  tetris_engine: ^1.0.0
```

## Quick Start

```dart
final game = TetrisGame();
game.start();

// In your widget tree:
TetrisBoard(
  game: game,
  theme: darkTetrisTheme,
  onGameOver: () => print('Game over! Score: ${game.state.scoreState.score}'),
  onScoreChanged: (score) => print('Score: $score'),
)
```

## Layout Example

```dart
Row(
  children: [
    Column(
      children: [
        HoldPiecePreview(game: game),
        ScorePanel(game: game),
        LevelPanel(game: game),
        LinesClearedPanel(game: game),
      ],
    ),
    SizedBox(width: 200, child: TetrisBoard(game: game)),
    NextPiecePreview(game: game, count: 4),
  ],
)
```

## Theme Customization

```dart
// Built-in themes
TetrisBoard(game: game, theme: defaultTetrisTheme);  // light
TetrisBoard(game: game, theme: darkTetrisTheme);      // dark
TetrisBoard(game: game, theme: colorblindTetrisTheme); // Wong palette

// Custom theme
final myTheme = darkTetrisTheme.copyWith(
  boardBackground: Colors.black,
  tetrominoColors: TetrominoColors(
    fill: { TetrominoType.I: Colors.cyan, ... },
    border: { TetrominoType.I: Colors.blue, ... },
  ),
);
```


## Replay

```dart
// Record
final recorder = ReplayRecorder();
recorder.startRecording();
// ... play the game ...
recorder.stopRecording();
final json = recorder.exportJson();

// Replay
final player = ReplayPlayer(InputController(game));
recorder.importJson(json);
player.play(recorder.frames);
```

## Saving State

```dart
// Serialize
final json = game.toJson();
prefs.setString('tetris_save', jsonEncode(json));

// Restore
game.loadFromJson(jsonDecode(prefs.getString('tetris_save')!));
```

## Custom Board Size

```dart
TetrisGame(boardRows: 24, boardCols: 10, nextQueueSize: 6)
```

## Keyboard Controls (Desktop / Web)

| Key | Action |
|-----|--------|
| ← / A | Move left |
| → / D | Move right |
| ↓ / S | Soft drop |
| ↑ / W | Rotate CW |
| Z | Rotate CCW |
| Space | Hard drop |
| C | Hold |
| P / Esc | Pause |

## Mobile Controls

- **Tap** → Rotate CW
- **Swipe left/right** → Move
- **Swipe down** → Soft drop
- **Fast swipe down** → Hard drop
- **Long press** → Hold

## Architecture

```
TetrisGame (ChangeNotifier)
├── CollisionSystem    — pure collision / ghost piece
├── RotationSystem     — SRS wall kicks
├── BoardManager       — lock + line clear
├── PieceManager       — 7-bag randomizer
├── ScoringSystem      — guideline scoring
└── LevelSystem        — progression & gravity

Widgets
├── TetrisBoard        — CustomPainter renderer
├── NextPiecePreview   — upcoming pieces
├── HoldPiecePreview   — held piece
├── ScorePanel / LevelPanel / LinesClearedPanel
├── GameOverOverlay / PauseOverlay
└── StatisticsPanel
```

## License

MIT