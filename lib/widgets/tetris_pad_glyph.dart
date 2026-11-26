import 'dart:math' as math;
import 'package:flutter/widgets.dart';

/// Symbols drawn on [TetrisPadButton]s.
///
/// They are painted with a [CustomPainter], so they need no icon font and
/// render the same whether or not the app enables `uses-material-design`.
enum TetrisPadGlyph {
  moveLeft,
  moveRight,
  rotateCCW,
  rotateCW,
  hold,
  softDrop,
  hardDrop,
  pause,
  play,
}

/// Paints a [TetrisPadGlyph] in a [size]×[size] square.
class TetrisPadGlyphIcon extends StatelessWidget {
  final TetrisPadGlyph glyph;
  final Color color;
  final double size;

  const TetrisPadGlyphIcon(
    this.glyph, {
    super.key,
    this.color = const Color(0xFFFFFFFF),
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(painter: _GlyphPainter(glyph, color)),
  );
}

class _GlyphPainter extends CustomPainter {
  final TetrisPadGlyph glyph;
  final Color color;

  _GlyphPainter(this.glyph, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    Offset p(double x, double y) => Offset(x * s, y * s);

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = color;

    void line(List<Offset> points) =>
        canvas.drawPath(Path()..addPolygon(points, false), stroke);

    void rotateArrow() {
      // Three-quarter circle running clockwise from the right side to the
      // top, with an arrowhead at the top pointing right.
      final c = p(0.5, 0.55);
      final r = s * 0.26;
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        0,
        math.pi * 1.5,
        false,
        stroke,
      );
      final tip = Offset(c.dx + s * 0.1, c.dy - r);
      final h = s * 0.12;
      line([tip.translate(-h, -h), tip, tip.translate(-h, h)]);
    }

    switch (glyph) {
      case TetrisPadGlyph.moveLeft:
        line([p(0.6, 0.25), p(0.35, 0.5), p(0.6, 0.75)]);
      case TetrisPadGlyph.moveRight:
        line([p(0.4, 0.25), p(0.65, 0.5), p(0.4, 0.75)]);
      case TetrisPadGlyph.softDrop:
        line([p(0.25, 0.4), p(0.5, 0.65), p(0.75, 0.4)]);
      case TetrisPadGlyph.hardDrop:
        line([p(0.5, 0.18), p(0.5, 0.62)]);
        line([p(0.3, 0.44), p(0.5, 0.64), p(0.7, 0.44)]);
        line([p(0.22, 0.82), p(0.78, 0.82)]);
      case TetrisPadGlyph.hold:
        line([p(0.35, 0.78), p(0.35, 0.22)]);
        line([p(0.2, 0.37), p(0.35, 0.22), p(0.5, 0.37)]);
        line([p(0.65, 0.22), p(0.65, 0.78)]);
        line([p(0.5, 0.63), p(0.65, 0.78), p(0.8, 0.63)]);
      case TetrisPadGlyph.rotateCW:
        rotateArrow();
      case TetrisPadGlyph.rotateCCW:
        canvas
          ..save()
          ..translate(s, 0)
          ..scale(-1, 1);
        rotateArrow();
        canvas.restore();
      case TetrisPadGlyph.pause:
        canvas
          ..drawRect(
            Rect.fromLTRB(0.28 * s, 0.25 * s, 0.42 * s, 0.75 * s),
            fill,
          )
          ..drawRect(
            Rect.fromLTRB(0.58 * s, 0.25 * s, 0.72 * s, 0.75 * s),
            fill,
          );
      case TetrisPadGlyph.play:
        canvas.drawPath(
          Path()
            ..addPolygon([p(0.32, 0.22), p(0.32, 0.78), p(0.78, 0.5)], true),
          fill,
        );
    }
  }

  @override
  bool shouldRepaint(_GlyphPainter old) =>
      old.glyph != glyph || old.color != color;
}
