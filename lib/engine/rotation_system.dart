import '../models/board_state.dart';
import '../models/position.dart';
import '../models/tetromino.dart';
import 'collision_system.dart';

/// Implements the Tetris Guideline Super Rotation System (SRS).
class RotationSystem {
  final CollisionSystem _collision;

  const RotationSystem(this._collision);

  /// Attempts clockwise rotation with SRS wall-kick tests.
  /// Returns the rotated piece or null if no valid kick found.
  Tetromino? rotateCW(Tetromino piece, BoardState board) =>
      tryRotate(piece, board, clockwise: true)?.piece;

  /// Attempts counter-clockwise rotation with SRS wall-kick tests.
  Tetromino? rotateCCW(Tetromino piece, BoardState board) =>
      tryRotate(piece, board, clockwise: false)?.piece;

  /// Attempts a rotation and also reports which SRS kick test succeeded
  /// (0 = no kick, 4 = the fifth and final test).
  ///
  /// Returns null when every kick test collides.
  ({Tetromino piece, int kickIndex})? tryRotate(
    Tetromino piece,
    BoardState board, {
    required bool clockwise,
  }) {
    final rotated = clockwise ? piece.rotatedCW() : piece.rotatedCCW();
    final kicks = _getKicks(piece.type, piece.rotation, clockwise);
    for (var i = 0; i < kicks.length; i++) {
      final kicked = rotated.copyWith(
        position: Position(
          rotated.position.row + kicks[i].row,
          rotated.position.col + kicks[i].col,
        ),
      );
      if (!_collision.hasCollision(kicked, board)) {
        return (piece: kicked, kickIndex: i);
      }
    }
    return null;
  }

  /// Classifies a T piece that has just been rotated into place using the
  /// Guideline 3-corner rule.
  ///
  /// [kickIndex] is the kick test used by the last rotation; a T-Spin that
  /// needed the final kick (e.g. a T-Spin Triple setup) always counts as full.
  /// Walls and floor count as occupied corners.
  TSpinType detectTSpin(
    Tetromino piece,
    BoardState board, {
    int kickIndex = 0,
  }) {
    if (piece.type != TetrominoType.T) return TSpinType.none;

    bool occupied(int dr, int dc) {
      final r = piece.position.row + dr;
      final c = piece.position.col + dc;
      if (r < 0 || r >= board.rows || c < 0 || c >= board.cols) return true;
      return board.cellAt(r, c).filled;
    }

    // Corners around the T's center cell at offset (1, 1).
    final topLeft = occupied(0, 0);
    final topRight = occupied(0, 2);
    final bottomLeft = occupied(2, 0);
    final bottomRight = occupied(2, 2);

    final count = [
      topLeft,
      topRight,
      bottomLeft,
      bottomRight,
    ].where((c) => c).length;
    if (count < 3) return TSpinType.none;

    // The two corners on the side the T is pointing towards.
    final (frontA, frontB) = switch (piece.rotation % 4) {
      0 => (topLeft, topRight),
      1 => (topRight, bottomRight),
      2 => (bottomLeft, bottomRight),
      _ => (topLeft, bottomLeft),
    };
    if ((frontA && frontB) || kickIndex == 4) return TSpinType.full;
    return TSpinType.mini;
  }

  List<Position> _getKicks(TetrominoType type, int fromRotation, bool cw) {
    if (type == TetrominoType.I) return _iKicks(fromRotation, cw);
    if (type == TetrominoType.O) return [Position(0, 0)];
    return _jlstzKicks(fromRotation, cw);
  }

  // SRS kick data for J, L, S, T, Z
  List<Position> _jlstzKicks(int from, bool cw) {
    const data = {
      // from→to : [offset list]
      '0→1': [
        Position(0, 0),
        Position(0, -1),
        Position(1, -1),
        Position(-2, 0),
        Position(-2, -1),
      ],
      '1→0': [
        Position(0, 0),
        Position(0, 1),
        Position(-1, 1),
        Position(2, 0),
        Position(2, 1),
      ],
      '1→2': [
        Position(0, 0),
        Position(0, 1),
        Position(-1, 1),
        Position(2, 0),
        Position(2, 1),
      ],
      '2→1': [
        Position(0, 0),
        Position(0, -1),
        Position(1, -1),
        Position(-2, 0),
        Position(-2, -1),
      ],
      '2→3': [
        Position(0, 0),
        Position(0, 1),
        Position(1, 1),
        Position(-2, 0),
        Position(-2, 1),
      ],
      '3→2': [
        Position(0, 0),
        Position(0, -1),
        Position(-1, -1),
        Position(2, 0),
        Position(2, -1),
      ],
      '3→0': [
        Position(0, 0),
        Position(0, -1),
        Position(-1, -1),
        Position(2, 0),
        Position(2, -1),
      ],
      '0→3': [
        Position(0, 0),
        Position(0, 1),
        Position(1, 1),
        Position(-2, 0),
        Position(-2, 1),
      ],
    };
    final to = cw ? (from + 1) % 4 : (from + 3) % 4;
    return data['$from→$to'] ?? [Position(0, 0)];
  }

  // SRS kick data for I
  List<Position> _iKicks(int from, bool cw) {
    const data = {
      '0→1': [
        Position(0, 0),
        Position(0, -2),
        Position(0, 1),
        Position(1, -2),
        Position(-2, 1),
      ],
      '1→0': [
        Position(0, 0),
        Position(0, 2),
        Position(0, -1),
        Position(-1, 2),
        Position(2, -1),
      ],
      '1→2': [
        Position(0, 0),
        Position(0, -1),
        Position(0, 2),
        Position(-2, -1),
        Position(1, 2),
      ],
      '2→1': [
        Position(0, 0),
        Position(0, 1),
        Position(0, -2),
        Position(2, 1),
        Position(-1, -2),
      ],
      '2→3': [
        Position(0, 0),
        Position(0, 2),
        Position(0, -1),
        Position(-1, 2),
        Position(2, -1),
      ],
      '3→2': [
        Position(0, 0),
        Position(0, -2),
        Position(0, 1),
        Position(1, -2),
        Position(-2, 1),
      ],
      '3→0': [
        Position(0, 0),
        Position(0, 1),
        Position(0, -2),
        Position(2, 1),
        Position(-1, -2),
      ],
      '0→3': [
        Position(0, 0),
        Position(0, -1),
        Position(0, 2),
        Position(-2, -1),
        Position(1, 2),
      ],
    };
    final to = cw ? (from + 1) % 4 : (from + 3) % 4;
    return data['$from→$to'] ?? [Position(0, 0)];
  }
}
