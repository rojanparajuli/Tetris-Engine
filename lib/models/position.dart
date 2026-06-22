/// A 2D integer coordinate on the Tetris board.
class Position {
  final int row;
  final int col;

  const Position(this.row, this.col);

  Position operator +(Position other) => Position(row + other.row, col + other.col);
  Position operator -(Position other) => Position(row - other.row, col - other.col);

  Position copyWith({int? row, int? col}) => Position(row ?? this.row, col ?? this.col);

  @override
  bool operator ==(Object other) =>
      other is Position && other.row == row && other.col == col;

  @override
  int get hashCode => Object.hash(row, col);

  @override
  String toString() => 'Position($row, $col)';

  Map<String, dynamic> toJson() => {'row': row, 'col': col};

  factory Position.fromJson(Map<String, dynamic> json) =>
      Position(json['row'] as int, json['col'] as int);
}
