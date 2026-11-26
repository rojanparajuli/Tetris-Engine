import 'package:flutter/widgets.dart';
import '../themes/tetris_theme.dart';
import '../themes/default_theme.dart';

/// Default overlay shown by `TetrisBoard` while paused. Replace it with
/// `TetrisBoard.pauseOverlayBuilder`.
class TetrisPauseOverlay extends StatelessWidget {
  final VoidCallback onResume;
  final TetrisTheme? theme;

  const TetrisPauseOverlay({super.key, required this.onResume, this.theme});

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
              'PAUSED',
              style: t.valueStyle.copyWith(
                fontSize: 28,
                color: const Color(0xFFFFFFFF),
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onResume,
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
                  'RESUME',
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
