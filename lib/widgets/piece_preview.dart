import 'package:flutter/material.dart';
import '../models/tetromino.dart';
import '../themes/tetris_theme.dart';
import '../themes/default_theme.dart';

/// Renders a single tetromino piece centered in a small preview box.
class TetrisPiecePreview extends StatelessWidget {
  final TetrominoType? type;
  final TetrisTheme? theme;
  final double size;
  final String? label;

  const TetrisPiecePreview({
    super.key,
    required this.type,
    this.theme,
    this.size = 64,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final t = theme ?? defaultTetrisTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(label!, style: t.labelStyle),
          ),
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: t.panelBackground,
            border: Border.all(color: t.boardBorderColor, width: 1),
          ),
          child: type == null
              ? const SizedBox()
              : CustomPaint(painter: _PiecePainter(type: type!, theme: t)),
        ),
      ],
    );
  }
}

class _PiecePainter extends CustomPainter {
  final TetrominoType type;
  final TetrisTheme theme;

  const _PiecePainter({required this.type, required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final piece = Tetromino.spawn(type);
    final cells = piece.cells;

    // Find bounding box of piece
    int minR = cells.map((p) => p.row).reduce((a, b) => a < b ? a : b);
    int maxR = cells.map((p) => p.row).reduce((a, b) => a > b ? a : b);
    int minC = cells.map((p) => p.col).reduce((a, b) => a < b ? a : b);
    int maxC = cells.map((p) => p.col).reduce((a, b) => a > b ? a : b);

    final pieceW = (maxC - minC + 1).toDouble();
    final pieceH = (maxR - minR + 1).toDouble();

    final cellSize = (size.width / (pieceW + 1)).clamp(0.0, size.width / 2);
    final offsetX = (size.width - pieceW * cellSize) / 2;
    final offsetY = (size.height - pieceH * cellSize) / 2;

    final fill = Paint()..color = theme.tetrominoColors.fillFor(type);
    final border = Paint()
      ..color = theme.tetrominoColors.borderFor(type)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (final p in cells) {
      final rect = Rect.fromLTWH(
        offsetX + (p.col - minC) * cellSize + 1,
        offsetY + (p.row - minR) * cellSize + 1,
        cellSize - 2,
        cellSize - 2,
      );
      final rr = RRect.fromRectAndRadius(rect, Radius.circular(theme.cellBorderRadius));
      canvas.drawRRect(rr, fill);
      canvas.drawRRect(rr, border);
    }
  }

  @override
  bool shouldRepaint(_PiecePainter old) => old.type != type;
}
