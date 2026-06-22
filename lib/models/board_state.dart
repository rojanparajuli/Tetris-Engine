import 'cell.dart';
import 'tetromino.dart';

/// The immutable state of the Tetris board grid.
class BoardState {
  final int rows;
  final int cols;

  /// Row-major grid. [0][0] is top-left.
  final List<List<Cell>> grid;

  BoardState({required this.rows, required this.cols, List<List<Cell>>? grid})
      : grid = grid ??
            List.generate(rows, (_) => List.generate(cols, (_) => const Cell.empty()));

  BoardState copyWith({List<List<Cell>>? grid}) =>
      BoardState(rows: rows, cols: cols, grid: grid ?? _deepCopy());

  /// Returns a new board with the given tetromino locked in.
  BoardState withPieceLocked(Tetromino piece) {
    final newGrid = _deepCopy();
    for (final pos in piece.cells) {
      if (pos.row >= 0 && pos.row < rows && pos.col >= 0 && pos.col < cols) {
        newGrid[pos.row][pos.col] = Cell(filled: true, type: piece.type);
      }
    }
    return BoardState(rows: rows, cols: cols, grid: newGrid);
  }

  /// Returns a new board with completed rows cleared, and the count cleared.
  (BoardState, int) clearLines() {
    final remaining = grid.where((row) => row.any((c) => !c.filled)).toList();
    final cleared = rows - remaining.length;
    final newRows = List.generate(
      cleared,
      (_) => List.generate(cols, (_) => const Cell.empty()),
    );
    final newGrid = [...newRows, ...remaining];
    return (BoardState(rows: rows, cols: cols, grid: newGrid), cleared);
  }

  Cell cellAt(int row, int col) => grid[row][col];

  bool isRowFull(int row) => grid[row].every((c) => c.filled);

  List<List<Cell>> _deepCopy() =>
      grid.map((row) => List<Cell>.from(row)).toList();

  Map<String, dynamic> toJson() => {
    'rows': rows,
    'cols': cols,
    'grid': grid
        .map((row) => row.map((c) => c.toJson()).toList())
        .toList(),
  };

  factory BoardState.fromJson(Map<String, dynamic> json) {
    final rows = json['rows'] as int;
    final cols = json['cols'] as int;
    final rawGrid = json['grid'] as List;
    final grid = rawGrid
        .map((row) => (row as List).map((c) => Cell.fromJson(c as Map<String, dynamic>)).toList())
        .toList();
    return BoardState(rows: rows, cols: cols, grid: grid);
  }
}
