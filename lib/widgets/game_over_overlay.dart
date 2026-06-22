import 'package:flutter/material.dart';
import '../themes/tetris_theme.dart';
import '../themes/default_theme.dart';

class TetrisGameOverOverlay extends StatelessWidget {
  final int score;
  final VoidCallback onRestart;
  final TetrisTheme? theme;

  const TetrisGameOverOverlay({
    super.key,
    required this.score,
    required this.onRestart,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final t = theme ?? defaultTetrisTheme;
    return Container(
      color: t.overlayBackground,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'GAME OVER',
              style: t.valueStyle.copyWith(
                fontSize: 28,
                color: Colors.white,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'SCORE: $score',
              style: t.labelStyle.copyWith(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onRestart,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Text(
                  'RESTART',
                  style: t.labelStyle.copyWith(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
