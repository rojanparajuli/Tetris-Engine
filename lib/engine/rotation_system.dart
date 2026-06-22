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
  Tetromino? rotateCW(Tetromino piece, BoardState board) {
    final rotated = piece.rotatedCW();
    return _tryKicks(piece, rotated, board, clockwise: true);
  }

  /// Attempts counter-clockwise rotation with SRS wall-kick tests.
  Tetromino? rotateCCW(Tetromino piece, BoardState board) {
    final rotated = piece.rotatedCCW();
    return _tryKicks(piece, rotated, board, clockwise: false);
  }

  Tetromino? _tryKicks(
    Tetromino original,
    Tetromino rotated,
    BoardState board, {
    required bool clockwise,
  }) {
    final kicks = _getKicks(original.type, original.rotation, clockwise);
    for (final offset in kicks) {
      final kicked = rotated.copyWith(
        position: Position(
          rotated.position.row + offset.row,
          rotated.position.col + offset.col,
        ),
      );
      if (!_collision.hasCollision(kicked, board)) return kicked;
    }
    return null;
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
      '0→1': [Position(0,0), Position(0,-1), Position(1,-1), Position(-2,0), Position(-2,-1)],
      '1→0': [Position(0,0), Position(0,1), Position(-1,1), Position(2,0), Position(2,1)],
      '1→2': [Position(0,0), Position(0,1), Position(-1,1), Position(2,0), Position(2,1)],
      '2→1': [Position(0,0), Position(0,-1), Position(1,-1), Position(-2,0), Position(-2,-1)],
      '2→3': [Position(0,0), Position(0,1), Position(1,1), Position(-2,0), Position(-2,1)],
      '3→2': [Position(0,0), Position(0,-1), Position(-1,-1), Position(2,0), Position(2,-1)],
      '3→0': [Position(0,0), Position(0,-1), Position(-1,-1), Position(2,0), Position(2,-1)],
      '0→3': [Position(0,0), Position(0,1), Position(1,1), Position(-2,0), Position(-2,1)],
    };
    final to = cw ? (from + 1) % 4 : (from + 3) % 4;
    return data['$from→$to'] ?? [Position(0, 0)];
  }

  // SRS kick data for I
  List<Position> _iKicks(int from, bool cw) {
    const data = {
      '0→1': [Position(0,0), Position(0,-2), Position(0,1), Position(1,-2), Position(-2,1)],
      '1→0': [Position(0,0), Position(0,2), Position(0,-1), Position(-1,2), Position(2,-1)],
      '1→2': [Position(0,0), Position(0,-1), Position(0,2), Position(-2,-1), Position(1,2)],
      '2→1': [Position(0,0), Position(0,1), Position(0,-2), Position(2,1), Position(-1,-2)],
      '2→3': [Position(0,0), Position(0,2), Position(0,-1), Position(-1,2), Position(2,-1)],
      '3→2': [Position(0,0), Position(0,-2), Position(0,1), Position(1,-2), Position(-2,1)],
      '3→0': [Position(0,0), Position(0,1), Position(0,-2), Position(2,1), Position(-1,-2)],
      '0→3': [Position(0,0), Position(0,-1), Position(0,2), Position(-2,-1), Position(1,2)],
    };
    final to = cw ? (from + 1) % 4 : (from + 3) % 4;
    return data['$from→$to'] ?? [Position(0, 0)];
  }
}
