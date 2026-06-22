import 'package:flutter_test/flutter_test.dart';
import 'package:tetris_engine/engine/level_system.dart';
import 'package:tetris_engine/models/level_state.dart';

void main() {
  const levelSystem = LevelSystem();

  group('LevelSystem', () {
    test('level advances after 10 lines', () {
      var state = const LevelState();
      state = levelSystem.onLinesCleared(state, 10);
      expect(state.level, 2);
    });

    test('partial lines do not advance level', () {
      var state = const LevelState();
      state = levelSystem.onLinesCleared(state, 5);
      expect(state.level, 1);
      expect(state.linesUntilNextLevel, 5);
    });

    test('multiple level-ups from tetris clears', () {
      var state = const LevelState();
      // 4 tetrises = 16 lines → should level up at least once
      for (int i = 0; i < 4; i++) {
        state = levelSystem.onLinesCleared(state, 4);
      }
      expect(state.level, greaterThan(1));
    });

    test('gravity increases with level', () {
      const l1 = LevelState(level: 1);
      const l5 = LevelState(level: 5);
      expect(l5.gravityMs, lessThan(l1.gravityMs));
    });

    test('gravity clamps at minimum 50ms', () {
      const highLevel = LevelState(level: 100);
      expect(highLevel.gravityMs, 50);
    });
  });
}
