import 'tetromino.dart';

/// Represents a single cell on the Tetris board.
class Cell {
  /// Whether this cell is occupied.
  final bool filled;

  /// Which tetromino type filled this cell (null if empty).
  final TetrominoType? type;

  const Cell({this.filled = false, this.type});

  const Cell.empty() : filled = false, type = null;

  Cell copyWith({bool? filled, TetrominoType? type}) =>
      Cell(filled: filled ?? this.filled, type: type ?? this.type);

  @override
  bool operator ==(Object other) =>
      other is Cell && other.filled == filled && other.type == type;

  @override
  int get hashCode => Object.hash(filled, type);

  Map<String, dynamic> toJson() => {
    'filled': filled,
    'type': type?.index,
  };

  factory Cell.fromJson(Map<String, dynamic> json) => Cell(
    filled: json['filled'] as bool,
    type: json['type'] != null
        ? TetrominoType.values[json['type'] as int]
        : null,
  );
}
