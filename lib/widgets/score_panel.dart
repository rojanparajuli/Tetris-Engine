import 'package:flutter/material.dart';
import '../engine/tetris_game.dart';
import '../themes/tetris_theme.dart';
import '../themes/default_theme.dart';

class ScorePanel extends StatelessWidget {
  final TetrisGame game;
  final TetrisTheme? theme;

  const ScorePanel({super.key, required this.game, this.theme});

  @override
  Widget build(BuildContext context) {
    final t = theme ?? defaultTetrisTheme;
    return ListenableBuilder(
      listenable: game,
      builder: (_, _) => _Panel(
        label: 'SCORE',
        value: game.state.scoreState.score.toString(),
        theme: t,
      ),
    );
  }
}

class LevelPanel extends StatelessWidget {
  final TetrisGame game;
  final TetrisTheme? theme;

  const LevelPanel({super.key, required this.game, this.theme});

  @override
  Widget build(BuildContext context) {
    final t = theme ?? defaultTetrisTheme;
    return ListenableBuilder(
      listenable: game,
      builder: (_, _) => _Panel(
        label: 'LEVEL',
        value: game.state.levelState.level.toString(),
        theme: t,
      ),
    );
  }
}

class LinesClearedPanel extends StatelessWidget {
  final TetrisGame game;
  final TetrisTheme? theme;

  const LinesClearedPanel({super.key, required this.game, this.theme});

  @override
  Widget build(BuildContext context) {
    final t = theme ?? defaultTetrisTheme;
    return ListenableBuilder(
      listenable: game,
      builder: (_, _) => _Panel(
        label: 'LINES',
        value: game.state.levelState.linesCleared.toString(),
        theme: t,
      ),
    );
  }
}

/// Internal reusable label+value panel.
class _Panel extends StatelessWidget {
  final String label;
  final String value;
  final TetrisTheme theme;

  const _Panel({required this.label, required this.value, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.panelBackground,
        border: Border.all(color: theme.boardBorderColor.withAlpha(60)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: theme.labelStyle),
          const SizedBox(height: 2),
          Text(value, style: theme.valueStyle),
        ],
      ),
    );
  }
}
