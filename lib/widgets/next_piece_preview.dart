import 'package:flutter/material.dart';
import '../engine/tetris_game.dart';
import '../themes/tetris_theme.dart';
import '../themes/default_theme.dart';
import 'piece_preview.dart';

/// Shows the next [count] pieces in the queue.
class NextPiecePreview extends StatelessWidget {
  final TetrisGame game;
  final TetrisTheme? theme;
  final int count;

  const NextPiecePreview({
    super.key,
    required this.game,
    this.theme,
    this.count = 3,
  });

  @override
  Widget build(BuildContext context) {
    final t = theme ?? defaultTetrisTheme;
    return ListenableBuilder(
      listenable: game,
      builder: (_, _) {
        final queue = game.state.nextQueue.take(count).toList();
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('NEXT', style: t.labelStyle),
            const SizedBox(height: 4),
            ...queue.map((type) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: TetrisPiecePreview(type: type, theme: t, size: 52),
            )),
          ],
        );
      },
    );
  }
}
