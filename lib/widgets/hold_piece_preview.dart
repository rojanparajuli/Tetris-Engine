import 'package:flutter/material.dart';
import '../engine/tetris_game.dart';
import '../themes/tetris_theme.dart';
import '../themes/default_theme.dart';
import 'piece_preview.dart';

/// Displays the currently held piece.
class HoldPiecePreview extends StatelessWidget {
  final TetrisGame game;
  final TetrisTheme? theme;

  const HoldPiecePreview({super.key, required this.game, this.theme});

  @override
  Widget build(BuildContext context) {
    final t = theme ?? defaultTetrisTheme;
    return ListenableBuilder(
      listenable: game,
      builder: (_, _) {
        final held = game.state.heldPiece;
        final canHold = game.state.canHold;
        return Opacity(
          opacity: canHold ? 1.0 : 0.4,
          child: TetrisPiecePreview(
            type: held?.type,
            theme: t,
            size: 64,
            label: 'HOLD',
          ),
        );
      },
    );
  }
}
