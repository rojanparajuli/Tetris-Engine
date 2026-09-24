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
      expect(state.level, 2);
      expect(state.linesCleared, 16);
      // 6 lines carried over past level 2, so 4 more are needed.
      expect(state.linesUntilNextLevel, 4);
    });

    test('overshooting a level carries lines over', () {
      var state = const LevelState(linesUntilNextLevel: 2);
      state = levelSystem.onLinesCleared(state, 4);
      expect(state.level, 2);
      expect(state.linesUntilNextLevel, 8);
    });

    test('custom linesPerLevel and multiple levels at once', () {
      const system = LevelSystem(linesPerLevel: 2);
      var state = system.initialState(startLevel: 3);
      expect(state.level, 3);
      state = system.onLinesCleared(state, 4);
      expect(state.level, 5);
      expect(state.linesUntilNextLevel, 2);
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
