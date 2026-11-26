import 'board_state.dart';
import 'tetromino.dart';
import 'score_state.dart';
import 'level_state.dart';
import 'game_mode.dart';

/// Lifecycle of a game.
enum TetrisGameStatus { idle, playing, paused, gameOver }

/// The complete, serializable snapshot of a Tetris game.
class GameState {
  /// Locked cells.
  final BoardState board;

  /// The falling piece, or null between pieces and when not playing.
  final Tetromino? activePiece;

  /// Where [activePiece] would land if hard-dropped.
  final Tetromino? ghostPiece;

  /// The held piece, if any.
  final Tetromino? heldPiece;

  /// False after holding until the next piece spawns.
  final bool canHold;

  /// Upcoming pieces, next first.
  final List<TetrominoType> nextQueue;
  final ScoreState scoreState;
  final LevelState levelState;
  final TetrisGameStatus status;

  /// How the game ended, once [status] is [TetrisGameStatus.gameOver].
  /// Null while the game is running.
  final GameEndReason? endReason;

  const GameState({
    required this.board,
    this.activePiece,
    this.ghostPiece,
    this.heldPiece,
    this.canHold = true,
    required this.nextQueue,
    required this.scoreState,
    required this.levelState,
    this.status = TetrisGameStatus.idle,
    this.endReason,
  });

  GameState copyWith({
    BoardState? board,
    Tetromino? activePiece,
    Tetromino? ghostPiece,
    Tetromino? heldPiece,
    bool? canHold,
    List<TetrominoType>? nextQueue,
    ScoreState? scoreState,
    LevelState? levelState,
    TetrisGameStatus? status,
    GameEndReason? endReason,
    bool clearActive = false,
    bool clearGhost = false,
    bool clearHeld = false,
  }) => GameState(
    board: board ?? this.board,
    activePiece: clearActive ? null : activePiece ?? this.activePiece,
    ghostPiece: clearGhost ? null : ghostPiece ?? this.ghostPiece,
    heldPiece: clearHeld ? null : heldPiece ?? this.heldPiece,
    canHold: canHold ?? this.canHold,
    nextQueue: nextQueue ?? this.nextQueue,
    scoreState: scoreState ?? this.scoreState,
    levelState: levelState ?? this.levelState,
    status: status ?? this.status,
    endReason: endReason ?? this.endReason,
  );

  Map<String, dynamic> toJson() => {
    'board': board.toJson(),
    'activePiece': activePiece?.toJson(),
    'heldPiece': heldPiece?.toJson(),
    'canHold': canHold,
    'nextQueue': nextQueue.map((t) => t.index).toList(),
    'scoreState': scoreState.toJson(),
    'levelState': levelState.toJson(),
    'status': status.index,
    if (endReason != null) 'endReason': endReason!.name,
  };

  factory GameState.fromJson(Map<String, dynamic> json) => GameState(
    board: BoardState.fromJson(json['board'] as Map<String, dynamic>),
    activePiece: json['activePiece'] != null
        ? Tetromino.fromJson(json['activePiece'] as Map<String, dynamic>)
        : null,
    heldPiece: json['heldPiece'] != null
        ? Tetromino.fromJson(json['heldPiece'] as Map<String, dynamic>)
        : null,
    canHold: json['canHold'] as bool,
    nextQueue: (json['nextQueue'] as List)
        .map((i) => TetrominoType.values[i as int])
        .toList(),
    scoreState: ScoreState.fromJson(json['scoreState'] as Map<String, dynamic>),
    levelState: LevelState.fromJson(json['levelState'] as Map<String, dynamic>),
    status: TetrisGameStatus.values[json['status'] as int],
    endReason: switch (json['endReason']) {
      final String name => GameEndReason.values.byName(name),
      _ => null,
    },
  );
}
