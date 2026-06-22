import 'board_state.dart';
import 'tetromino.dart';
import 'score_state.dart';
import 'level_state.dart';

enum TetrisGameStatus { idle, playing, paused, gameOver }

/// The complete, serializable snapshot of a Tetris game.
class GameState {
  final BoardState board;
  final Tetromino? activePiece;
  final Tetromino? ghostPiece;
  final Tetromino? heldPiece;
  final bool canHold;
  final List<TetrominoType> nextQueue;
  final ScoreState scoreState;
  final LevelState levelState;
  final TetrisGameStatus status;

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
    bool clearActive = false,
    bool clearGhost = false,
    bool clearHeld = false,
  }) =>
      GameState(
        board: board ?? this.board,
        activePiece: clearActive ? null : activePiece ?? this.activePiece,
        ghostPiece: clearGhost ? null : ghostPiece ?? this.ghostPiece,
        heldPiece: clearHeld ? null : heldPiece ?? this.heldPiece,
        canHold: canHold ?? this.canHold,
        nextQueue: nextQueue ?? this.nextQueue,
        scoreState: scoreState ?? this.scoreState,
        levelState: levelState ?? this.levelState,
        status: status ?? this.status,
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
  );
}
