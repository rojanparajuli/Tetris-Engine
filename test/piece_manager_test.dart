import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tetris_engine/engine/piece_manager.dart';
import 'package:tetris_engine/models/tetromino.dart';

void main() {
  group('PieceManager (7-bag)', () {
    test('peek returns correct count', () {
      final pm = PieceManager();
      expect(pm.peek(5).length, 5);
    });

    test('every bag contains all 7 types', () {
      final pm = PieceManager();
      final types = <TetrominoType>{};
      for (int i = 0; i < 7; i++) {
        types.add(pm.next());
      }
      expect(types.length, TetrominoType.values.length);
    });

    test('two consecutive bags each contain all 7 types', () {
      final pm = PieceManager();
      final bag1 = {for (int i = 0; i < 7; i++) pm.next()};
      final bag2 = {for (int i = 0; i < 7; i++) pm.next()};
      expect(bag1.length, 7);
      expect(bag2.length, 7);
    });

    test('seed produces deterministic output', () {
      final pm = PieceManager();
      pm.seed([TetrominoType.I, TetrominoType.O, TetrominoType.T]);
      expect(pm.next(), TetrominoType.I);
      expect(pm.next(), TetrominoType.O);
      expect(pm.next(), TetrominoType.T);
    });

    test('same Random seed gives the same sequence', () {
      final a = PieceManager(random: Random(99));
      final b = PieceManager(random: Random(99));
      expect(
        List.generate(21, (_) => a.next()),
        List.generate(21, (_) => b.next()),
      );
    });
  });

  group('Tetromino.spawn', () {
    test('matches Guideline columns on a 10-wide board', () {
      expect(Tetromino.spawn(TetrominoType.I).position.col, 3);
      expect(Tetromino.spawn(TetrominoType.O).position.col, 4);
      expect(Tetromino.spawn(TetrominoType.T).position.col, 3);
    });

    test('is centered on other board widths', () {
      for (final type in TetrominoType.values) {
        final cols = Tetromino.spawn(
          type,
          boardCols: 6,
        ).cells.map((c) => c.col);
        expect(cols.every((c) => c >= 1 && c <= 4), isTrue, reason: '$type');
      }
    });
  });
}
