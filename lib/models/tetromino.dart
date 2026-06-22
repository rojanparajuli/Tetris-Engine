import 'position.dart';

/// The 7 standard Tetromino types.
enum TetrominoType { I, O, T, S, Z, J, L }

/// Immutable representation of a Tetromino piece at a given rotation.
class Tetromino {
  final TetrominoType type;
  final int rotation; // 0–3
  final Position position; // top-left anchor

  const Tetromino({
    required this.type,
    this.rotation = 0,
    required this.position,
  });

  Tetromino copyWith({TetrominoType? type, int? rotation, Position? position}) =>
      Tetromino(
        type: type ?? this.type,
        rotation: rotation ?? this.rotation,
        position: position ?? this.position,
      );

  /// Returns all 4 occupied cells for this piece in its current rotation.
  List<Position> get cells {
    final shape = _shapes[type]![rotation % _shapes[type]!.length];
    return shape
        .map((p) => Position(position.row + p.row, position.col + p.col))
        .toList();
  }

  Tetromino rotatedCW() => copyWith(rotation: (rotation + 1) % 4);
  Tetromino rotatedCCW() => copyWith(rotation: (rotation + 3) % 4);

  Map<String, dynamic> toJson() => {
    'type': type.index,
    'rotation': rotation,
    'position': position.toJson(),
  };

  factory Tetromino.fromJson(Map<String, dynamic> json) => Tetromino(
    type: TetrominoType.values[json['type'] as int],
    rotation: json['rotation'] as int,
    position: Position.fromJson(json['position'] as Map<String, dynamic>),
  );

  /// Spawn position for each type on a standard 10-wide board.
  factory Tetromino.spawn(TetrominoType type) {
    final col = type == TetrominoType.O ? 4 : 3;
    return Tetromino(type: type, rotation: 0, position: Position(0, col));
  }

  // ── Shape definitions ───────────────────────────────────────────────────
  // Each list has 4 rotations; each rotation is a list of 4 cell offsets.
  static final Map<TetrominoType, List<List<Position>>> _shapes = {
    TetrominoType.I: [
      [Position(1,0), Position(1,1), Position(1,2), Position(1,3)],
      [Position(0,2), Position(1,2), Position(2,2), Position(3,2)],
      [Position(2,0), Position(2,1), Position(2,2), Position(2,3)],
      [Position(0,1), Position(1,1), Position(2,1), Position(3,1)],
    ],
    TetrominoType.O: [
      [Position(0,0), Position(0,1), Position(1,0), Position(1,1)],
      [Position(0,0), Position(0,1), Position(1,0), Position(1,1)],
      [Position(0,0), Position(0,1), Position(1,0), Position(1,1)],
      [Position(0,0), Position(0,1), Position(1,0), Position(1,1)],
    ],
    TetrominoType.T: [
      [Position(0,1), Position(1,0), Position(1,1), Position(1,2)],
      [Position(0,1), Position(1,1), Position(1,2), Position(2,1)],
      [Position(1,0), Position(1,1), Position(1,2), Position(2,1)],
      [Position(0,1), Position(1,0), Position(1,1), Position(2,1)],
    ],
    TetrominoType.S: [
      [Position(0,1), Position(0,2), Position(1,0), Position(1,1)],
      [Position(0,1), Position(1,1), Position(1,2), Position(2,2)],
      [Position(1,1), Position(1,2), Position(2,0), Position(2,1)],
      [Position(0,0), Position(1,0), Position(1,1), Position(2,1)],
    ],
    TetrominoType.Z: [
      [Position(0,0), Position(0,1), Position(1,1), Position(1,2)],
      [Position(0,2), Position(1,1), Position(1,2), Position(2,1)],
      [Position(1,0), Position(1,1), Position(2,1), Position(2,2)],
      [Position(0,1), Position(1,0), Position(1,1), Position(2,0)],
    ],
    TetrominoType.J: [
      [Position(0,0), Position(1,0), Position(1,1), Position(1,2)],
      [Position(0,1), Position(0,2), Position(1,1), Position(2,1)],
      [Position(1,0), Position(1,1), Position(1,2), Position(2,2)],
      [Position(0,1), Position(1,1), Position(2,0), Position(2,1)],
    ],
    TetrominoType.L: [
      [Position(0,2), Position(1,0), Position(1,1), Position(1,2)],
      [Position(0,1), Position(1,1), Position(2,1), Position(2,2)],
      [Position(1,0), Position(1,1), Position(1,2), Position(2,0)],
      [Position(0,0), Position(0,1), Position(1,1), Position(2,1)],
    ],
  };
}
