import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/game_state.dart';
import '../models/board_state.dart';
import '../models/tetromino.dart';
import '../models/position.dart';
import '../models/score_state.dart';
import '../models/level_state.dart';
import '../statistics/tetris_statistics.dart';
import 'board_manager.dart';
import 'piece_manager.dart';
import 'collision_system.dart';
import 'rotation_system.dart';
import 'scoring_system.dart';
import 'level_system.dart';

class TetrisGame extends ChangeNotifier {
  // ── Config ──────────────────────────────────────────────────────────────
  final int boardRows;
  final int boardCols;
  final int nextQueueSize;
  // TetrisAudioHooks? audioHooks;

  // ── Sub-systems ─────────────────────────────────────────────────────────
  late final CollisionSystem _collision;
  late final RotationSystem _rotation;
  late final BoardManager _boardManager;
  late final PieceManager _pieceManager;
  late final ScoringSystem _scoring;
  late final LevelSystem _levelSystem;

  // ── State ────────────────────────────────────────────────────────────────
  late GameState _state;
  GameState get state => _state;

  Timer? _gravityTimer;
  final Stopwatch _playClock = Stopwatch();

  // Statistics
  final TetrisStatistics statistics = TetrisStatistics();

  // Callbacks
  void Function(int score)? onScoreChanged;
  void Function()? onGameOver;
  void Function(int level)? onLevelUp;
  void Function(int lines)? onLinesCleared;

  TetrisGame({
    this.boardRows = 20,
    this.boardCols = 10,
    this.nextQueueSize = 5,
    // this.audioHooks,
    this.onScoreChanged,
    this.onGameOver,
    this.onLevelUp,
    this.onLinesCleared,
  }) {
    _collision = const CollisionSystem();
    _rotation = RotationSystem(_collision);
    _boardManager = BoardManager(_collision);
    _pieceManager = PieceManager();
    _scoring = const ScoringSystem();
    _levelSystem = const LevelSystem();
    _initState();
  }

  void _initState() {
    _state = GameState(
      board: BoardState(rows: boardRows, cols: boardCols),
      nextQueue: _pieceManager.peek(nextQueueSize),
      scoreState: const ScoreState(),
      levelState: const LevelState(),
      status: TetrisGameStatus.idle,
    );
  }

  // ── Public API ───────────────────────────────────────────────────────────

  void start() {
    _initState();
    _state = _state.copyWith(status: TetrisGameStatus.playing);
    _spawnPiece();
    _startGravity();
    _playClock
      ..reset()
      ..start();
    notifyListeners();
  }

  void pause() {
    if (_state.status != TetrisGameStatus.playing) return;
    _gravityTimer?.cancel();
    _playClock.stop();
    _state = _state.copyWith(status: TetrisGameStatus.paused);
    notifyListeners();
  }

  void resume() {
    if (_state.status != TetrisGameStatus.paused) return;
    _state = _state.copyWith(status: TetrisGameStatus.playing);
    _startGravity();
    _playClock.start();
    notifyListeners();
  }

  void restart() {
    _gravityTimer?.cancel();
    _playClock
      ..reset()
      ..start();
    start();
  }

  // ── Moves ────────────────────────────────────────────────────────────────

  void moveLeft() => _tryMove(0, -1);
  void moveRight() => _tryMove(0, 1);

  void softDrop() {
    if (_state.status != TetrisGameStatus.playing) return;
    final piece = _state.activePiece;
    if (piece == null) return;
    if (_collision.canMove(piece, _state.board, 1, 0)) {
      _state = _state.copyWith(
        activePiece: piece.copyWith(
          position: Position(piece.position.row + 1, piece.position.col),
        ),
        scoreState: _scoring.onSoftDrop(_state.scoreState, 1),
      );
      notifyListeners();
    } else {
      _lockPiece();
    }
  }

  void hardDrop() {
    if (_state.status != TetrisGameStatus.playing) return;
    final piece = _state.activePiece;
    if (piece == null) return;
    final ghost = _collision.ghostPiece(piece, _state.board);
    final dropped = ghost.position.row - piece.position.row;
    _state = _state.copyWith(
      activePiece: ghost,
      scoreState: _scoring.onHardDrop(_state.scoreState, dropped),
    );
    // audioHooks?.onHardDrop?.call();
    _lockPiece();
  }

  void rotateCW() {
    if (_state.status != TetrisGameStatus.playing) return;
    final piece = _state.activePiece;
    if (piece == null) return;
    final rotated = _rotation.rotateCW(piece, _state.board);
    if (rotated != null) {
      _state = _state.copyWith(
        activePiece: rotated,
        ghostPiece: _collision.ghostPiece(rotated, _state.board),
      );
      // audioHooks?.onRotate?.call();
      notifyListeners();
    }
  }

  void rotateCCW() {
    if (_state.status != TetrisGameStatus.playing) return;
    final piece = _state.activePiece;
    if (piece == null) return;
    final rotated = _rotation.rotateCCW(piece, _state.board);
    if (rotated != null) {
      _state = _state.copyWith(
        activePiece: rotated,
        ghostPiece: _collision.ghostPiece(rotated, _state.board),
      );
      // audioHooks?.onRotate?.call();
      notifyListeners();
    }
  }

  void holdPiece() {
    if (_state.status != TetrisGameStatus.playing) return;
    if (!_state.canHold) return;
    final piece = _state.activePiece;
    if (piece == null) return;

    final TetrominoType incomingType;
    if (_state.heldPiece != null) {
      incomingType = _state.heldPiece!.type;
    } else {
      incomingType = _pieceManager.next();
    }

    _state = _state.copyWith(
      heldPiece: Tetromino.spawn(piece.type),
      activePiece: Tetromino.spawn(incomingType),
      canHold: false,
    );
    _updateGhost();
    notifyListeners();
  }

  // ── Internal ─────────────────────────────────────────────────────────────

  void _tryMove(int dRow, int dCol) {
    if (_state.status != TetrisGameStatus.playing) return;
    final piece = _state.activePiece;
    if (piece == null) return;
    if (_collision.canMove(piece, _state.board, dRow, dCol)) {
      final moved = piece.copyWith(
        position: Position(
          piece.position.row + dRow,
          piece.position.col + dCol,
        ),
      );
      _state = _state.copyWith(
        activePiece: moved,
        ghostPiece: _collision.ghostPiece(moved, _state.board),
      );
      // audioHooks?.onMove?.call();
      notifyListeners();
    }
  }

  void _spawnPiece() {
    final type = _pieceManager.next();
    final piece = Tetromino.spawn(type);

    if (_boardManager.isBlockOut(_state.board, piece)) {
      _gameOver();
      return;
    }

    final nextQueue = _pieceManager.peek(nextQueueSize);
    _state = _state.copyWith(
      activePiece: piece,
      ghostPiece: _collision.ghostPiece(piece, _state.board),
      nextQueue: nextQueue,
      canHold: true,
    );
    notifyListeners();
  }

  void _lockPiece() {
    final piece = _state.activePiece;
    if (piece == null) return;

    final (newBoard, linesCleared) = _boardManager.lockAndClear(
      _state.board,
      piece,
    );
    // audioHooks?.onLock?.call();

    var scoreState = _scoring.onLinesCleared(
      _state.scoreState,
      linesCleared,
      _state.levelState.level,
    );
    var levelState = _levelSystem.onLinesCleared(
      _state.levelState,
      linesCleared,
    );

    final didLevelUp = levelState.level > _state.levelState.level;

    _state = _state.copyWith(
      board: newBoard,
      scoreState: scoreState,
      levelState: levelState,
      clearActive: true,
      clearGhost: true,
    );

    if (linesCleared > 0) {
      // audioHooks?.onLineClear?.call(linesCleared);
      onLinesCleared?.call(linesCleared);
      statistics.recordLineClear(linesCleared);
    }
    if (didLevelUp) {
      // audioHooks?.onLevelUp?.call(levelState.level);
      onLevelUp?.call(levelState.level);
      _restartGravity();
    }

    onScoreChanged?.call(scoreState.score);
    statistics.recordPieceLocked(piece.type);

    _spawnPiece();
  }

  void _updateGhost() {
    final piece = _state.activePiece;
    if (piece == null) return;
    _state = _state.copyWith(
      ghostPiece: _collision.ghostPiece(piece, _state.board),
    );
  }

  void _gameOver() {
    _gravityTimer?.cancel();
    _playClock.stop();
    _state = _state.copyWith(status: TetrisGameStatus.gameOver);
    statistics.recordGameOver(
      score: _state.scoreState.score,
      level: _state.levelState.level,
      playTimeMs: _playClock.elapsedMilliseconds,
    );
    // audioHooks?.onGameOver?.call();
    onGameOver?.call();
    notifyListeners();
  }

  void _startGravity() {
    _gravityTimer?.cancel();
    _gravityTimer = Timer.periodic(
      Duration(milliseconds: _state.levelState.gravityMs),
      (_) => softDrop(),
    );
  }

  void _restartGravity() {
    _gravityTimer?.cancel();
    _startGravity();
  }

  @override
  void dispose() {
    _gravityTimer?.cancel();
    super.dispose();
  }

  // ── Serialization ─────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => _state.toJson();

  void loadFromJson(Map<String, dynamic> json) {
    _gravityTimer?.cancel();
    _state = GameState.fromJson(json);
    notifyListeners();
  }
}
