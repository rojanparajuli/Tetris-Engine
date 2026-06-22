import '../models/board_state.dart';
import '../models/position.dart';
import '../models/tetromino.dart';

/// Pure collision detection logic. No Flutter dependencies.
class CollisionSystem {
  const CollisionSystem();

  /// Returns true if [piece] overlaps any filled cell or is out of bounds.
  bool hasCollision(Tetromino piece, BoardState board) {
    for (final pos in piece.cells) {
      if (_outOfBounds(pos, board)) return true;
      if (board.cellAt(pos.row, pos.col).filled) return true;
    }
    return false;
  }

  bool _outOfBounds(Position pos, BoardState board) =>
      pos.row < 0 || pos.row >= board.rows || pos.col < 0 || pos.col >= board.cols;

  /// Returns the lowest valid Y the piece can drop to (for ghost piece).
  Tetromino ghostPiece(Tetromino piece, BoardState board) {
    var ghost = piece;
    while (true) {
      final dropped = ghost.copyWith(
        position: Position(ghost.position.row + 1, ghost.position.col),
      );
      if (hasCollision(dropped, board)) return ghost;
      ghost = dropped;
    }
  }

  /// True if the piece can move one cell in the given direction.
  bool canMove(Tetromino piece, BoardState board, int dRow, int dCol) {
    final moved = piece.copyWith(
      position: Position(piece.position.row + dRow, piece.position.col + dCol),
    );
    return !hasCollision(moved, board);
  }

  /// True if [piece] is entirely above row 0 (lock-out / game-over condition).
  bool isLockOut(Tetromino piece) => piece.cells.every((p) => p.row < 0);
}
