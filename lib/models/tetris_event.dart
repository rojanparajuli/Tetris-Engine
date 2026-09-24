import 'tetromino.dart';

/// The kind of [TetrisEvent] emitted by a game.
enum TetrisEventType {
  started,
  paused,
  resumed,
  moved,
  rotated,
  softDropped,
  hardDropped,
  held,

  /// A piece locked onto the board (always emitted, even with no line clear).
  locked,

  /// One or more lines were cleared. See [TetrisEvent.lines],
  /// [TetrisEvent.tSpin], [TetrisEvent.perfectClear] and
  /// [TetrisEvent.backToBack].
  linesCleared,

  /// A T-Spin was performed without clearing any lines.
  tSpin,
  levelUp,
  gameOver,
}

/// Something that happened in a game, delivered on `TetrisGame.events`.
///
/// Use it to drive sound effects, haptics, animations or analytics:
///
/// ```dart
/// game.events.listen((e) {
///   if (e.type == TetrisEventType.linesCleared && e.lines == 4) {
///     playSound('tetris.wav');
///   }
/// });
/// ```
class TetrisEvent {
  final TetrisEventType type;

  /// The piece involved (moved, rotated, dropped, held or locked), if any.
  final TetrominoType? piece;

  /// Number of lines cleared, for [TetrisEventType.linesCleared].
  final int lines;

  /// Cells travelled, for [TetrisEventType.softDropped] and
  /// [TetrisEventType.hardDropped].
  final int cells;

  /// The new level, for [TetrisEventType.levelUp].
  final int level;

  final TSpinType tSpin;
  final bool perfectClear;

  /// Whether this clear continued a back-to-back chain.
  final bool backToBack;

  /// Current combo count after this event.
  final int combo;

  const TetrisEvent(
    this.type, {
    this.piece,
    this.lines = 0,
    this.cells = 0,
    this.level = 0,
    this.tSpin = TSpinType.none,
    this.perfectClear = false,
    this.backToBack = false,
    this.combo = 0,
  });

  @override
  String toString() =>
      'TetrisEvent(${type.name}'
      '${piece != null ? ', piece: ${piece!.name}' : ''}'
      '${lines > 0 ? ', lines: $lines' : ''}'
      '${cells > 0 ? ', cells: $cells' : ''}'
      '${level > 0 ? ', level: $level' : ''}'
      '${tSpin != TSpinType.none ? ', tSpin: ${tSpin.name}' : ''}'
      '${perfectClear ? ', perfectClear' : ''}'
      '${backToBack ? ', backToBack' : ''})';
}
