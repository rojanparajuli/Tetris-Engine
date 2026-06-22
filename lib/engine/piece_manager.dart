import 'dart:math';
import '../models/tetromino.dart';

/// Manages the piece queue using the Tetris Guideline 7-bag randomizer.
class PieceManager {
  final Random _rng;
  final List<TetrominoType> _bag = [];

  PieceManager({Random? random}) : _rng = random ?? Random();

  /// Returns the next piece from the bag.
  TetrominoType next() {
    if (_bag.isEmpty) _refill();
    return _bag.removeAt(0);
  }

  /// Peek at the upcoming [count] pieces without consuming them.
  List<TetrominoType> peek(int count) {
    while (_bag.length < count) {
      _refill();
    }
    return _bag.take(count).toList();
  }

  void _refill() {
    final batch = List<TetrominoType>.from(TetrominoType.values)..shuffle(_rng);
    _bag.addAll(batch);
  }

  /// Seed from a list (e.g. for replay/deterministic testing).
  void seed(List<TetrominoType> types) {
    _bag
      ..clear()
      ..addAll(types);
  }
}
