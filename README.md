# tetris_engine

[![pub package](https://img.shields.io/pub/v/tetris_engine.svg)](https://pub.dev/packages/tetris_engine)
[![CI](https://github.com/rojanparajuli/Tetris-Engine/actions/workflows/ci.yml/badge.svg)](https://github.com/rojanparajuli/Tetris-Engine/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A complete, reusable Tetris engine for Flutter. It has no backend and no
dependencies beyond Flutter, and runs on Android, iOS, Web, Windows, Linux and
macOS.

![Screenshot](https://raw.githubusercontent.com/rojanparajuli/Tetris-Engine/master/assets/ss.jpg)

## Features

- **Tetris Guideline rules**: 7-bag randomizer, SRS rotation with wall kicks,
  hold, ghost piece, next queue and lock delay with move reset
- **Scoring**: singles to Tetrises, T-Spins (full and mini), back-to-back,
  combos, perfect clears, soft and hard drop points
- **Levels and gravity**: configurable start level, lines per level and
  gravity curve
- **Widgets**: board renderer, next and hold previews, score, level and lines
  panels, statistics panel, pause and game-over overlays, on-screen control pad
- **Input**: keyboard with remappable keys (desktop/web), swipe gestures and
  auto-repeating touch buttons (mobile)
- **Events stream** for sound effects, haptics and animations
- **Themes**: light, dark and colorblind-safe themes, all customizable
- **Seeded games and exact replays**: record a game as JSON and play it back
  move for move
- **Save and restore**: serialize the full game state to any storage
- **Statistics**: games, scores, lines, levels, play time and piece usage

## Installation

```yaml
dependencies:
  tetris_engine: ^1.2.0
```

## Quick start

```dart
import 'package:tetris_engine/tetris_engine.dart';

final game = TetrisGame()..start();

// In your widget tree:
TetrisBoard(
  game: game,
  theme: darkTetrisTheme,
  onGameOver: () => print('Game over! Score: ${game.state.scoreState.score}'),
)
```

Remember to call `game.dispose()` when you're done with it.

## Layout example

```dart
Column(
  children: [
    Expanded(
      child: Row(
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
      ),
    ),
    TetrisControlPad(game: game), // on-screen buttons for touch devices
  ],
)
```

## Game options

```dart
TetrisGame(
  boardRows: 20,
  boardCols: 10,
  nextQueueSize: 5,
  startLevel: 1,
  linesPerLevel: 10,
  lockDelay: const Duration(milliseconds: 500), // Duration.zero = classic
  maxLockResets: 15,
  gravityCurve: (level) => Duration(milliseconds: 800 ~/ level),
  seed: 42,                // same seed → same pieces (e.g. daily challenge)
  statistics: myStats,     // share lifetime stats between games
)
```

## Sound effects, haptics and animations

Every action is reported on `game.events`:

```dart
game.events.listen((event) {
  switch (event.type) {
    case TetrisEventType.hardDropped:
      HapticFeedback.mediumImpact();
    case TetrisEventType.linesCleared:
      if (event.tSpin != TSpinType.none) playSound('tspin');
      else if (event.lines == 4) playSound('tetris');
      else playSound('clear');
      if (event.perfectClear) showBanner('PERFECT CLEAR');
    case TetrisEventType.levelUp:
      showBanner('Level ${event.level}');
    default:
      break;
  }
});
```

The simple callbacks `onScoreChanged`, `onLevelUp`, `onLinesCleared` and
`onGameOver` are still available.

## Themes

```dart
// Built-in themes
TetrisBoard(game: game, theme: defaultTetrisTheme);    // light
TetrisBoard(game: game, theme: darkTetrisTheme);       // dark
TetrisBoard(game: game, theme: colorblindTetrisTheme); // Wong palette

// Custom theme
final myTheme = darkTetrisTheme.copyWith(
  boardBackground: Colors.black,
  tetrominoColors: TetrominoColors(
    fill: {TetrominoType.I: Colors.cyan, /* ... */},
    border: {TetrominoType.I: Colors.blue, /* ... */},
  ),
);
```

## Replays

Attach a recorder to the game. It captures every input, gravity step and lock
together with the game's seed, so playback reproduces the game exactly.

```dart
// Record
final recorder = ReplayRecorder();
final game = TetrisGame(recorder: recorder)..start();
// ... play ...
final json = recorder.exportJson();

// Replay onto any game
final saved = ReplayRecorder()..importJson(json);
ReplayPlayer(InputController(replayGame)).play(
  saved.frames,
  seed: saved.seed,
  onComplete: () => print('Replay finished'),
);
```

## Saving state

```dart
// Serialize
prefs.setString('tetris_save', jsonEncode(game.toJson()));

// Restore (comes back paused, so call resume() to continue)
game.loadFromJson(jsonDecode(prefs.getString('tetris_save')!));
game.resume();
```

## Controls

### Keyboard (desktop and web)

| Key | Action |
|-----|--------|
| ← / A | Move left |
| → / D | Move right |
| ↓ / S | Soft drop |
| ↑ / W / X | Rotate clockwise |
| Z | Rotate counter-clockwise |
| Space | Hard drop |
| C / Left Shift | Hold |
| P / Esc | Pause |

Remap keys with `keyMap`:

```dart
TetrisBoard(
  game: game,
  keyMap: {
    ...TetrisKeyboardHandler.defaultKeyMap,
    LogicalKeyboardKey.keyK: 'hardDrop',
  },
)
```

### Touch

On `TetrisBoard` itself:

- **Tap**: rotate clockwise
- **Swipe left/right**: move
- **Swipe down**: soft drop
- **Fast swipe down**: hard drop
- **Long press**: hold

`TetrisControlPad` adds on-screen buttons. Holding move or soft drop repeats
the action (tune it with `repeatDelay` and `repeatInterval`).

`TetrisBoard` pauses the game automatically when the app goes to the
background. Set `pauseOnBackground: false` to turn this off.

## Custom game loops

Turn off the internal timers to step the game yourself, for example from a
fixed-step loop, an AI or a test:

```dart
final game = TetrisGame()..useInternalClock = false;
game.start();
game.applyGravity();      // one gravity step
game.lockActivePiece();   // lock if the piece is resting on the stack
```

## Architecture

```
TetrisGame (ChangeNotifier, events stream)
├── CollisionSystem    — collision and ghost piece
├── RotationSystem     — SRS wall kicks, T-Spin detection
├── BoardManager       — lock and line clear
├── PieceManager       — seeded 7-bag randomizer
├── ScoringSystem      — Guideline scoring
└── LevelSystem        — progression

Widgets
├── TetrisBoard        — CustomPainter renderer + keyboard/gesture input
├── TetrisControlPad   — on-screen buttons
├── NextPiecePreview / HoldPiecePreview
├── ScorePanel / LevelPanel / LinesClearedPanel / StatisticsPanel
└── TetrisPauseOverlay / TetrisGameOverOverlay
```

## Contributing

Bug reports and pull requests are welcome. See
[CONTRIBUTING.md](https://github.com/rojanparajuli/Tetris-Engine/blob/master/CONTRIBUTING.md).

## License

MIT
