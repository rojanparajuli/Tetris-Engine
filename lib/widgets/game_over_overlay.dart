import 'package:flutter/widgets.dart';
import '../themes/tetris_theme.dart';
import '../themes/default_theme.dart';
import '../models/game_mode.dart';

/// Default overlay shown by `TetrisBoard` when the game ends. Replace it
/// with `TetrisBoard.gameOverOverlayBuilder`.
///
/// The title follows [endReason]: GAME OVER, COMPLETE or TIME UP. When
/// [time] is given (a finished line-goal mode such as Sprint) it is shown
/// under the score.
class TetrisGameOverOverlay extends StatelessWidget {
  final int score;
  final VoidCallback onRestart;
  final TetrisTheme? theme;

  /// How the game ended. Null shows GAME OVER.
  final GameEndReason? endReason;

  /// Final time to show, e.g. for a completed Sprint.
  final Duration? time;

  const TetrisGameOverOverlay({
    super.key,
    required this.score,
    required this.onRestart,
    this.theme,
    this.endReason,
    this.time,
  });

  /// Formats [d] as `m:ss.cc`.
  static String formatTime(Duration d) {
    final m = d.inMinutes;
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    final cs = ((d.inMilliseconds % 1000) ~/ 10).toString().padLeft(2, '0');
    return '$m:$s.$cs';
  }

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
              switch (endReason) {
                GameEndReason.goalReached => 'COMPLETE',
                GameEndReason.timeUp => 'TIME UP',
                GameEndReason.toppedOut || null => 'GAME OVER',
              },
              style: t.valueStyle.copyWith(
                fontSize: 28,
                color: const Color(0xFFFFFFFF),
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'SCORE: $score',
              style: t.labelStyle.copyWith(
                color: const Color(0xB3FFFFFF),
                fontSize: 14,
              ),
            ),
            if (time != null) ...[
              const SizedBox(height: 4),
              Text(
                'TIME: ${formatTime(time!)}',
                style: t.labelStyle.copyWith(
                  color: const Color(0xB3FFFFFF),
                  fontSize: 14,
                ),
              ),
            ],
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onRestart,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFFFFFFF),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  'RESTART',
                  style: t.labelStyle.copyWith(
                    color: const Color(0xFFFFFFFF),
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
