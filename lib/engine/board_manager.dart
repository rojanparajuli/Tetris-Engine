import '../models/board_state.dart';
import '../models/tetromino.dart';
import 'collision_system.dart';

/// Manages board mutations (locking pieces, clearing lines).
class BoardManager {
  final CollisionSystem _collision;

  BoardManager(this._collision);

  /// Locks [piece] onto [board] and clears completed lines.
  /// Returns (newBoard, linesCleared).
  (BoardState, int) lockAndClear(BoardState board, Tetromino piece) {
    final locked = board.withPieceLocked(piece);
    return locked.clearLines();
  }

  /// Returns true if spawning [piece] on [board] immediately collides
  /// (block-out game over condition).
  bool isBlockOut(BoardState board, Tetromino piece) =>
      _collision.hasCollision(piece, board);
}
