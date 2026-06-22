import 'package:flutter_test/flutter_test.dart';
import 'package:tetris_engine/engine/scoring_system.dart';
import 'package:tetris_engine/models/score_state.dart';

void main() {
  const scoring = ScoringSystem();

  group('ScoringSystem', () {
    test('single clears 100 × level', () {
      const state = ScoreState();
      final result = scoring.onLinesCleared(state, 1, 1);
      expect(result.score, 100);
    });

    test('tetris (4 lines) scores 800 × level', () {
      const state = ScoreState();
      final result = scoring.onLinesCleared(state, 4, 1);
      expect(result.score, 800);
    });

    test('back-to-back tetris multiplies by 1.5', () {
      const state = ScoreState(backToBack: true);
      final result = scoring.onLinesCleared(state, 4, 1);
      expect(result.score, (800 * 1.5).toInt());
    });

    test('combo bonus accumulates', () {
      var state = const ScoreState();
      state = scoring.onLinesCleared(state, 1, 1); // combo 0→1
      final scoreAfterFirst = state.score;
      state = scoring.onLinesCleared(state, 1, 1); // combo 1→2, bonus = 50*1*1 = 50
      expect(state.score, greaterThan(scoreAfterFirst + 100));
    });

    test('zero lines clears resets combo', () {
      const state = ScoreState(combo: 3);
      final result = scoring.onLinesCleared(state, 0, 1);
      expect(result.combo, 0);
    });

    test('hard drop adds 2× cells', () {
      const state = ScoreState();
      final result = scoring.onHardDrop(state, 10);
      expect(result.score, 20);
    });

    test('soft drop adds 1 per cell', () {
      const state = ScoreState();
      final result = scoring.onSoftDrop(state, 5);
      expect(result.score, 5);
    });
  });
}
