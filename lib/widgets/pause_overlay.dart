import 'package:flutter/material.dart';
import '../themes/tetris_theme.dart';
import '../themes/default_theme.dart';

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
                color: Colors.white,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onResume,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Text(
                  'RESUME',
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
