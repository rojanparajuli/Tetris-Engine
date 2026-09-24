import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/game_state.dart';
import '../models/board_state.dart';
import '../models/tetris_event.dart';
import '../models/tetromino.dart';
import '../models/position.dart';
import '../models/score_state.dart';
import '../replay/replay_recorder.dart';
import '../statistics/tetris_statistics.dart';
import 'board_manager.dart';
import 'piece_manager.dart';
import 'collision_system.dart';
import 'rotation_system.dart';
import 'scoring_system.dart';
import 'level_system.dart';

/// A complete Tetris game: board, pieces, scoring, levels and timing.
///
/// Listen to it (it is a [ChangeNotifier]) to rebuild UI, or subscribe to
/// [events] for sound effects, haptics and animations.
///
/// ```dart
/// final game = TetrisGame(lockDelay: const Duration(milliseconds: 500));
/// game.start();
/// ```
class TetrisGame extends ChangeNotifier {
  // ── Config ──────────────────────────────────────────────────────────────
  final int boardRows;
  final int boardCols;
  final int nextQueueSize;

  /// Level a new game starts at.
  final int startLevel;

  /// How long a piece may rest on the stack before it locks.
  ///
  /// Moving or rotating a grounded piece restarts the delay, up to
  /// [maxLockResets] times per piece. Use [Duration.zero] for the classic
  /// behaviour where a grounded piece locks on the next gravity step.
  final Duration lockDelay;

  /// Maximum number of lock-delay resets before a grounded piece locks
  /// immediately. Prevents stalling forever by spinning a piece in place.
  final int maxLockResets;

  /// Optional custom gravity: the delay between automatic drops at a given
  /// level. Defaults to [LevelState.gravityMs].
  final Duration Function(int level)? gravityCurve;

  /// Seed passed to the constructor; when null a fresh random seed is picked
  /// for every game.
  final int? _fixedSeed;

  // ── Sub-systems ─────────────────────────────────────────────────────────
  late final CollisionSystem _collision;
  late final RotationSystem _rotation;
  late final BoardManager _boardManager;
  late PieceManager _pieceManager;
  late final ScoringSystem _scoring;
  final LevelSystem _levelSystem;

  // ── State ────────────────────────────────────────────────────────────────
  late GameState _state;
  GameState get state => _state;

  late int _seed;

  /// Seed of the piece randomizer for the current game. Starting a game with
  /// the same seed produces the same piece sequence.
  int get seed => _seed;

  Timer? _gravityTimer;
  Timer? _lockTimer;
  final Stopwatch _playClock = Stopwatch();

  /// Whether the active piece is resting on the stack with a lock pending.
  bool _lockPending = false;
  int _lockResets = 0;
  int _lowestRow = 0;
  bool _lastMoveWasRotation = false;
  int _lastKickIndex = 0;

  bool _useInternalClock = true;

  final StreamController<TetrisEvent> _events =
      StreamController<TetrisEvent>.broadcast();

  /// Stream of everything that happens in the game. See [TetrisEvent].
  Stream<TetrisEvent> get events => _events.stream;

  /// Statistics accumulated across games. Pass the same instance to several
  /// games (or restore it with [TetrisStatistics.loadFromJson]) to keep
  /// lifetime stats.
  final TetrisStatistics statistics;

  /// When set, every action (including gravity steps and lock-delay expiry)
  /// is recorded, and recording restarts on every [start]. Playing the result
  /// back with [ReplayPlayer.play] and its seed reproduces the game exactly.
  ReplayRecorder? recorder;

  /// Called after every lock with the current score.
  void Function(int score)? onScoreChanged;

  /// Called once when the game ends.
  void Function()? onGameOver;

  /// Called with the new level after a level up.
  void Function(int level)? onLevelUp;

  /// Called with the number of lines cleared (1–4).
  void Function(int lines)? onLinesCleared;

  TetrisGame({
    this.boardRows = 20,
    this.boardCols = 10,
    this.nextQueueSize = 5,
    this.startLevel = 1,
    int linesPerLevel = 10,
    this.lockDelay = const Duration(milliseconds: 500),
    this.maxLockResets = 15,
    this.gravityCurve,
    int? seed,
    TetrisStatistics? statistics,
    this.recorder,
    this.onScoreChanged,
    this.onGameOver,
    this.onLevelUp,
    this.onLinesCleared,
  }) : assert(boardRows >= 4 && boardCols >= 4, 'Board must be at least 4×4'),
       assert(startLevel >= 1, 'startLevel must be at least 1'),
       _fixedSeed = seed,
       _levelSystem = LevelSystem(linesPerLevel: linesPerLevel),
       statistics = statistics ?? TetrisStatistics() {
    _collision = const CollisionSystem();
    _rotation = RotationSystem(_collision);
    _boardManager = BoardManager(_collision);
    _scoring = const ScoringSystem();
    _resetRandomizer(null);
    _initState();
  }

  void _resetRandomizer(int? seed) {
    _seed = seed ?? _fixedSeed ?? Random().nextInt(0x7fffffff);
    _pieceManager = PieceManager(random: Random(_seed));
  }

  void _initState() {
    _state = GameState(
      board: BoardState(rows: boardRows, cols: boardCols),
      nextQueue: _pieceManager.peek(nextQueueSize),
      scoreState: const ScoreState(),
      levelState: _levelSystem.initialState(startLevel: startLevel),
      status: TetrisGameStatus.idle,
    );
  }

  /// Whether gravity and lock delay are driven by the game's own timers.
  ///
  /// Set to false to drive the game yourself with [applyGravity] and
  /// [lockActivePiece] (for example from a fixed-step game loop, an AI, or a
  /// replay).
  bool get useInternalClock => _useInternalClock;
  set useInternalClock(bool value) {
    if (value == _useInternalClock) return;
    _useInternalClock = value;
    if (!value) {
      _gravityTimer?.cancel();
      _lockTimer?.cancel();
    } else if (_state.status == TetrisGameStatus.playing) {
      _startGravity();
      if (_lockPending) _startLockTimer();
    }
  }

  /// Current delay between automatic drops.
  Duration get gravityInterval =>
      gravityCurve?.call(_state.levelState.level) ??
      Duration(milliseconds: _state.levelState.gravityMs);

  /// Time spent playing the current game, excluding pauses.
  Duration get playTime => _playClock.elapsed;

  // ── Public API ───────────────────────────────────────────────────────────

  /// Starts a new game. Pass [seed] to get a reproducible piece sequence.
  void start({int? seed}) {
    _cancelTimers();
    _resetRandomizer(seed);
    _initState();
    _state = _state.copyWith(status: TetrisGameStatus.playing);
    recorder?.startRecording(seed: _seed);
    _playClock
      ..reset()
      ..start();
    _emit(const TetrisEvent(TetrisEventType.started));
    _spawnPiece();
    _startGravity();
    notifyListeners();
  }

  /// Pauses gravity, lock delay and the play clock.
  void pause() {
    if (_state.status != TetrisGameStatus.playing) return;
    _record('pause');
    _gravityTimer?.cancel();
    _lockTimer?.cancel();
    _playClock.stop();
    _state = _state.copyWith(status: TetrisGameStatus.paused);
    _emit(const TetrisEvent(TetrisEventType.paused));
    notifyListeners();
  }

  /// Resumes a paused game.
  void resume() {
    if (_state.status != TetrisGameStatus.paused) return;
    _record('resume');
    _state = _state.copyWith(status: TetrisGameStatus.playing);
    _startGravity();
    if (_lockPending) _startLockTimer();
    _playClock.start();
    _emit(const TetrisEvent(TetrisEventType.resumed));
    notifyListeners();
  }

  /// Toggles between playing and paused.
  void togglePause() {
    if (_state.status == TetrisGameStatus.playing) {
      pause();
    } else if (_state.status == TetrisGameStatus.paused) {
      resume();
    }
  }

  /// Starts a new game with the same settings.
  void restart() => start();

  // ── Moves ────────────────────────────────────────────────────────────────

  /// Moves the active piece one column left, if possible.
  void moveLeft() => _tryMove(-1, 'moveLeft');

  /// Moves the active piece one column right, if possible.
  void moveRight() => _tryMove(1, 'moveRight');

  /// Moves the piece down one row for 1 point. If the piece is already
  /// resting on the stack it locks immediately.
  void softDrop() {
    final piece = _activePiece;
    if (piece == null) return;
    _record('softDrop');
    if (_collision.canMove(piece, _state.board, 1, 0)) {
      _state = _state.copyWith(
        activePiece: _shifted(piece, 1, 0),
        scoreState: _scoring.onSoftDrop(_state.scoreState, 1),
      );
      _lastMoveWasRotation = false;
      _emit(
        TetrisEvent(TetrisEventType.softDropped, piece: piece.type, cells: 1),
      );
      _onPieceMoved();
      notifyListeners();
    } else {
      _lockPiece();
    }
  }

  /// Drops the piece straight down and locks it, for 2 points per cell.
  void hardDrop() {
    final piece = _activePiece;
    if (piece == null) return;
    _record('hardDrop');
    final ghost = _collision.ghostPiece(piece, _state.board);
    final dropped = ghost.position.row - piece.position.row;
    if (dropped > 0) _lastMoveWasRotation = false;
    _state = _state.copyWith(
      activePiece: ghost,
      scoreState: _scoring.onHardDrop(_state.scoreState, dropped),
    );
    _emit(
      TetrisEvent(
        TetrisEventType.hardDropped,
        piece: piece.type,
        cells: dropped,
      ),
    );
    _lockPiece();
  }

  /// Rotates clockwise using SRS wall kicks.
  void rotateCW() => _rotate(clockwise: true);

  /// Rotates counter-clockwise using SRS wall kicks.
  void rotateCCW() => _rotate(clockwise: false);

  /// Swaps the active piece with the held piece (once per piece).
  void holdPiece() {
    final piece = _activePiece;
    if (piece == null || !_state.canHold) return;
    _record('hold');
    _cancelLockTimer();

    final incomingType = _state.heldPiece?.type ?? _pieceManager.next();
    final incoming = Tetromino.spawn(incomingType, boardCols: boardCols);

    _state = _state.copyWith(
      heldPiece: Tetromino.spawn(piece.type, boardCols: boardCols),
      activePiece: incoming,
      ghostPiece: _collision.ghostPiece(incoming, _state.board),
      nextQueue: _pieceManager.peek(nextQueueSize),
      canHold: false,
    );
    _emit(TetrisEvent(TetrisEventType.held, piece: piece.type));

    if (_boardManager.isBlockOut(_state.board, incoming)) {
      _gameOver();
      return;
    }
    _resetPieceTracking(incoming);
    notifyListeners();
  }

  /// Performs one gravity step: moves the piece down a row, or starts the
  /// lock delay if it is resting on the stack.
  ///
  /// Called automatically by the internal clock; call it yourself when
  /// [useInternalClock] is false.
  void applyGravity() {
    final piece = _activePiece;
    if (piece == null) return;
    _record('gravity');
    if (_collision.canMove(piece, _state.board, 1, 0)) {
      _state = _state.copyWith(activePiece: _shifted(piece, 1, 0));
      _lastMoveWasRotation = false;
      _onPieceMoved();
      notifyListeners();
    } else if (lockDelay == Duration.zero) {
      _lockPiece();
    } else if (!_lockPending) {
      _startLockTimer();
    }
  }

  /// Locks the active piece if it is resting on the stack or floor.
  ///
  /// Called automatically when the lock delay expires; call it yourself when
  /// [useInternalClock] is false.
  void lockActivePiece() {
    final piece = _activePiece;
    if (piece == null) return;
    if (_collision.canMove(piece, _state.board, 1, 0)) return;
    _record('lock');
    _lockPiece();
  }

  // ── Internal ─────────────────────────────────────────────────────────────

  /// The active piece, or null when the game is not accepting input.
  Tetromino? get _activePiece =>
      _state.status == TetrisGameStatus.playing ? _state.activePiece : null;

  Tetromino _shifted(Tetromino piece, int dRow, int dCol) => piece.copyWith(
    position: Position(piece.position.row + dRow, piece.position.col + dCol),
  );

  void _tryMove(int dCol, String action) {
    final piece = _activePiece;
    if (piece == null) return;
    _record(action);
    if (!_collision.canMove(piece, _state.board, 0, dCol)) return;
    final moved = _shifted(piece, 0, dCol);
    _state = _state.copyWith(
      activePiece: moved,
      ghostPiece: _collision.ghostPiece(moved, _state.board),
    );
    _lastMoveWasRotation = false;
    _emit(TetrisEvent(TetrisEventType.moved, piece: piece.type));
    _onPieceMoved();
    notifyListeners();
  }

  void _rotate({required bool clockwise}) {
    final piece = _activePiece;
    if (piece == null) return;
    _record(clockwise ? 'rotCW' : 'rotCCW');
    final result = _rotation.tryRotate(
      piece,
      _state.board,
      clockwise: clockwise,
    );
    if (result == null) return;
    _state = _state.copyWith(
      activePiece: result.piece,
      ghostPiece: _collision.ghostPiece(result.piece, _state.board),
    );
    _lastMoveWasRotation = true;
    _lastKickIndex = result.kickIndex;
    _emit(TetrisEvent(TetrisEventType.rotated, piece: piece.type));
    _onPieceMoved();
    notifyListeners();
  }

  /// Updates lock-delay bookkeeping after the active piece moved or rotated.
  void _onPieceMoved() {
    final piece = _state.activePiece;
    if (piece == null) return;

    // Reaching a new lowest row gives the piece a fresh set of resets.
    if (piece.position.row > _lowestRow) {
      _lowestRow = piece.position.row;
      _lockResets = 0;
    }
    if (lockDelay == Duration.zero) return;

    if (_collision.canMove(piece, _state.board, 1, 0)) {
      _cancelLockTimer();
      return;
    }
    if (_lockPending) {
      if (_lockResets >= maxLockResets) {
        _lockPiece();
        return;
      }
      _lockResets++;
    }
    _startLockTimer();
  }

  void _resetPieceTracking(Tetromino piece) {
    _cancelLockTimer();
    _lockResets = 0;
    _lowestRow = piece.position.row;
    _lastMoveWasRotation = false;
    _lastKickIndex = 0;
  }

  void _spawnPiece() {
    final type = _pieceManager.next();
    final piece = Tetromino.spawn(type, boardCols: boardCols);

    if (_boardManager.isBlockOut(_state.board, piece)) {
      _gameOver();
      return;
    }

    _resetPieceTracking(piece);
    _state = _state.copyWith(
      activePiece: piece,
      ghostPiece: _collision.ghostPiece(piece, _state.board),
      nextQueue: _pieceManager.peek(nextQueueSize),
      canHold: true,
    );
    notifyListeners();
  }

  void _lockPiece() {
    final piece = _state.activePiece;
    if (piece == null) return;
    _cancelLockTimer();

    final tSpin = _lastMoveWasRotation
        ? _rotation.detectTSpin(piece, _state.board, kickIndex: _lastKickIndex)
        : TSpinType.none;

    final (newBoard, linesCleared) = _boardManager.lockAndClear(
      _state.board,
      piece,
    );
    final perfectClear = linesCleared > 0 && newBoard.isEmpty;
    final wasBackToBack = _state.scoreState.backToBack;

    final scoreState = _scoring.onLinesCleared(
      _state.scoreState,
      linesCleared,
      _state.levelState.level,
      tSpin: tSpin,
      perfectClear: perfectClear,
    );
    final levelState = _levelSystem.onLinesCleared(
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

    _emit(TetrisEvent(TetrisEventType.locked, piece: piece.type));
    if (linesCleared > 0) {
      _emit(
        TetrisEvent(
          TetrisEventType.linesCleared,
          piece: piece.type,
          lines: linesCleared,
          tSpin: tSpin,
          perfectClear: perfectClear,
          backToBack:
              wasBackToBack && (linesCleared == 4 || tSpin != TSpinType.none),
          combo: scoreState.combo,
        ),
      );
      onLinesCleared?.call(linesCleared);
      statistics.recordLineClear(linesCleared);
    } else if (tSpin != TSpinType.none) {
      _emit(
        TetrisEvent(TetrisEventType.tSpin, piece: piece.type, tSpin: tSpin),
      );
    }
    if (didLevelUp) {
      _emit(TetrisEvent(TetrisEventType.levelUp, level: levelState.level));
      onLevelUp?.call(levelState.level);
      _startGravity();
    }

    onScoreChanged?.call(scoreState.score);
    statistics.recordPieceLocked(piece.type);

    _spawnPiece();
  }

  void _gameOver() {
    _cancelTimers();
    _playClock.stop();
    _state = _state.copyWith(status: TetrisGameStatus.gameOver);
    statistics.recordGameOver(
      score: _state.scoreState.score,
      level: _state.levelState.level,
      playTimeMs: _playClock.elapsedMilliseconds,
    );
    recorder?.stopRecording();
    _emit(const TetrisEvent(TetrisEventType.gameOver));
    onGameOver?.call();
    notifyListeners();
  }

  void _startGravity() {
    _gravityTimer?.cancel();
    if (!_useInternalClock) return;
    _gravityTimer = Timer.periodic(gravityInterval, (_) => applyGravity());
  }

  void _startLockTimer() {
    _lockPending = true;
    _lockTimer?.cancel();
    if (!_useInternalClock) return;
    _lockTimer = Timer(lockDelay, lockActivePiece);
  }

  void _cancelLockTimer() {
    _lockPending = false;
    _lockTimer?.cancel();
    _lockTimer = null;
  }

  void _cancelTimers() {
    _gravityTimer?.cancel();
    _cancelLockTimer();
  }

  void _record(String action) => recorder?.record(action);

  void _emit(TetrisEvent event) {
    if (!_events.isClosed) _events.add(event);
  }

  @override
  void dispose() {
    _cancelTimers();
    _events.close();
    super.dispose();
  }

  // ── Serialization ─────────────────────────────────────────────────────────

  /// Serializes the current game state. Restore it with [loadFromJson].
  Map<String, dynamic> toJson() => _state.toJson();

  /// Restores a game saved with [toJson].
  ///
  /// A game saved while playing is restored as paused; call [resume] to
  /// continue. Throws [ArgumentError] if the saved board size does not match
  /// [boardRows] × [boardCols].
  void loadFromJson(Map<String, dynamic> json) {
    final loaded = GameState.fromJson(json);
    if (loaded.board.rows != boardRows || loaded.board.cols != boardCols) {
      throw ArgumentError(
        'Saved board is ${loaded.board.rows}×${loaded.board.cols}, '
        'but this game is $boardRows×$boardCols.',
      );
    }
    _cancelTimers();
    _playClock
      ..stop()
      ..reset();

    // Put the saved queue back so the upcoming pieces match the preview.
    _pieceManager.seed(loaded.nextQueue);

    final piece = loaded.activePiece;
    if (piece != null) _resetPieceTracking(piece);
    _state = loaded.copyWith(
      ghostPiece: piece == null
          ? null
          : _collision.ghostPiece(piece, loaded.board),
      nextQueue: _pieceManager.peek(nextQueueSize),
      status: loaded.status == TetrisGameStatus.playing
          ? TetrisGameStatus.paused
          : loaded.status,
    );
    notifyListeners();
  }
}
