import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../engine/tetris_game.dart';
import '../models/game_state.dart';
import '../models/tetromino.dart';
import '../themes/tetris_theme.dart';
import '../themes/default_theme.dart';
import '../controllers/input_controller.dart';
import '../input/tetris_keyboard_handler.dart';
import '../input/tetris_gesture_handler.dart';
import 'game_over_overlay.dart';
import 'pause_overlay.dart';

/// The main Tetris board rendering widget.
///
/// ```dart
/// TetrisBoard(
///   game: myGame,
///   theme: darkTetrisTheme,
///   onGameOver: () => setState(() {}),
/// )
/// ```
class TetrisBoard extends StatefulWidget {
  final TetrisGame game;

  /// Visual theme. Defaults to [defaultTetrisTheme].
  final TetrisTheme? theme;

  /// Called once when the game ends.
  final void Function()? onGameOver;

  /// Called whenever the score changes.
  final void Function(int score)? onScoreChanged;

  /// Builds a custom pause overlay in place of [TetrisPauseOverlay].
  final Widget Function(BuildContext, VoidCallback resume)? pauseOverlayBuilder;

  /// Builds a custom game-over overlay in place of [TetrisGameOverOverlay].
  final Widget Function(BuildContext, VoidCallback restart)?
  gameOverOverlayBuilder;

  /// Whether to draw the ghost piece showing where the piece will land.
  final bool showGhostPiece;

  /// Handle keyboard input (see [TetrisKeyboardHandler.defaultKeyMap]).
  final bool enableKeyboard;

  /// Handle swipe and tap gestures on the board.
  final bool enableGestures;

  /// Custom keyboard mapping from key to [InputController] action name.
  /// Defaults to [TetrisKeyboardHandler.defaultKeyMap].
  final Map<LogicalKeyboardKey, String>? keyMap;

  /// Pause automatically when the app is hidden or sent to the background.
  final bool pauseOnBackground;

  const TetrisBoard({
    super.key,
    required this.game,
    this.theme,
    this.onGameOver,
    this.onScoreChanged,
    this.pauseOverlayBuilder,
    this.gameOverOverlayBuilder,
    this.showGhostPiece = true,
    this.enableKeyboard = true,
    this.enableGestures = true,
    this.keyMap,
    this.pauseOnBackground = true,
  });

  @override
  State<TetrisBoard> createState() => _TetrisBoardState();
}

class _TetrisBoardState extends State<TetrisBoard> {
  late InputController _input;
  late TetrisKeyboardHandler _keyboard;
  final FocusNode _focusNode = FocusNode();
  AppLifecycleListener? _lifecycle;
  late TetrisGameStatus _lastStatus;
  late int _lastScore;

  @override
  void initState() {
    super.initState();
    _attach(widget.game);
    _lifecycle = AppLifecycleListener(onStateChange: _onLifecycleChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void didUpdateWidget(TetrisBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.game != widget.game) {
      oldWidget.game.removeListener(_onGameChanged);
      _attach(widget.game);
    } else if (oldWidget.keyMap != widget.keyMap) {
      _keyboard = TetrisKeyboardHandler(_input, keyMap: widget.keyMap);
    }
  }

  void _attach(TetrisGame game) {
    _input = InputController(game);
    _keyboard = TetrisKeyboardHandler(_input, keyMap: widget.keyMap);
    _lastStatus = game.state.status;
    _lastScore = game.state.scoreState.score;
    game.addListener(_onGameChanged);
  }

  void _onGameChanged() {
    if (!mounted) return;
    final state = widget.game.state;
    if (state.status == TetrisGameStatus.gameOver &&
        _lastStatus != TetrisGameStatus.gameOver) {
      widget.onGameOver?.call();
    }
    if (state.scoreState.score != _lastScore) {
      widget.onScoreChanged?.call(state.scoreState.score);
    }
    _lastStatus = state.status;
    _lastScore = state.scoreState.score;
  }

  void _onLifecycleChanged(AppLifecycleState state) {
    if (!widget.pauseOnBackground) return;
    if (state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused) {
      widget.game.pause();
    }
  }

  @override
  void dispose() {
    widget.game.removeListener(_onGameChanged);
    _lifecycle?.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme ?? defaultTetrisTheme;
    return ListenableBuilder(
      listenable: widget.game,
      builder: (context, _) {
        final state = widget.game.state;
        Widget board = _buildBoard(state, theme);

        if (widget.enableGestures) {
          board = TetrisGestureHandler(input: _input, child: board);
        }

        if (widget.enableKeyboard) {
          board = Focus(
            focusNode: _focusNode,
            autofocus: true,
            onKeyEvent: (_, event) => _keyboard.handleKeyEvent(event)
                ? KeyEventResult.handled
                : KeyEventResult.ignored,
            child: board,
          );
        }

        return Stack(
          children: [
            board,
            if (state.status == TetrisGameStatus.paused)
              widget.pauseOverlayBuilder?.call(context, widget.game.resume) ??
                  TetrisPauseOverlay(onResume: widget.game.resume),
            if (state.status == TetrisGameStatus.gameOver)
              widget.gameOverOverlayBuilder?.call(
                    context,
                    widget.game.restart,
                  ) ??
                  TetrisGameOverOverlay(
                    score: state.scoreState.score,
                    onRestart: widget.game.restart,
                  ),
          ],
        );
      },
    );
  }

  Widget _buildBoard(GameState state, TetrisTheme theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellSize = constraints.maxWidth / widget.game.boardCols;
        final boardHeight = cellSize * widget.game.boardRows;

        return Container(
          width: constraints.maxWidth,
          height: boardHeight,
          decoration: BoxDecoration(
            color: theme.boardBackground,
            border: Border.all(
              color: theme.boardBorderColor,
              width: theme.boardBorderWidth,
            ),
          ),
          child: CustomPaint(
            painter: _BoardPainter(
              state: state,
              theme: theme,
              cellSize: cellSize,
              showGhost: widget.showGhostPiece,
              boardRows: widget.game.boardRows,
              boardCols: widget.game.boardCols,
            ),
          ),
        );
      },
    );
  }
}

// ── CustomPainter ──────────────────────────────────────────────────────────

class _BoardPainter extends CustomPainter {
  final GameState state;
  final TetrisTheme theme;
  final double cellSize;
  final bool showGhost;
  final int boardRows;
  final int boardCols;

  _BoardPainter({
    required this.state,
    required this.theme,
    required this.cellSize,
    required this.showGhost,
    required this.boardRows,
    required this.boardCols,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);
    _drawBoard(canvas);
    if (showGhost && state.ghostPiece != null) {
      _drawPiece(canvas, state.ghostPiece!, ghost: true);
    }
    if (state.activePiece != null) {
      _drawPiece(canvas, state.activePiece!, ghost: false);
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    if (!theme.showGridLines) return;
    final paint = Paint()
      ..color = theme.gridLineColor
      ..strokeWidth = 0.5;
    for (int r = 0; r <= boardRows; r++) {
      canvas.drawLine(
        Offset(0, r * cellSize),
        Offset(size.width, r * cellSize),
        paint,
      );
    }
    for (int c = 0; c <= boardCols; c++) {
      canvas.drawLine(
        Offset(c * cellSize, 0),
        Offset(c * cellSize, size.height),
        paint,
      );
    }
  }

  void _drawBoard(Canvas canvas) {
    for (int r = 0; r < boardRows; r++) {
      for (int c = 0; c < boardCols; c++) {
        final cell = state.board.cellAt(r, c);
        if (cell.filled && cell.type != null) {
          _drawCell(canvas, r, c, cell.type!, ghost: false);
        }
      }
    }
  }

  void _drawPiece(Canvas canvas, Tetromino piece, {required bool ghost}) {
    for (final pos in piece.cells) {
      if (pos.row >= 0 &&
          pos.row < boardRows &&
          pos.col >= 0 &&
          pos.col < boardCols) {
        _drawCell(canvas, pos.row, pos.col, piece.type, ghost: ghost);
      }
    }
  }

  void _drawCell(
    Canvas canvas,
    int row,
    int col,
    TetrominoType type, {
    required bool ghost,
  }) {
    final rect = Rect.fromLTWH(
      col * cellSize + 1,
      row * cellSize + 1,
      cellSize - 2,
      cellSize - 2,
    );
    final rRect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(theme.cellBorderRadius),
    );

    if (ghost) {
      canvas.drawRRect(rRect, Paint()..color = theme.ghostCellColor);
    } else {
      canvas.drawRRect(
        rRect,
        Paint()..color = theme.tetrominoColors.fillFor(type),
      );
      canvas.drawRRect(
        rRect,
        Paint()
          ..color = theme.tetrominoColors.borderFor(type)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
      // Highlight shine
      final shinePaint = Paint()
        ..color = Colors.white.withAlpha(60)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            rect.left + 2,
            rect.top + 2,
            rect.width * 0.4,
            rect.height * 0.25,
          ),
          const Radius.circular(1),
        ),
        shinePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_BoardPainter old) =>
      old.state != state || old.theme != theme || old.cellSize != cellSize;
}
