import 'package:flutter/material.dart';
import 'tetromino_colors.dart';

/// Full visual theme for the Tetris board and UI panels.
class TetrisTheme {
  final Color boardBackground;
  final Color boardBorderColor;
  final double boardBorderWidth;
  final Color gridLineColor;
  final bool showGridLines;
  final TetrominoColors tetrominoColors;
  final Color ghostCellColor;
  final double cellBorderRadius;
  final Color panelBackground;
  final TextStyle labelStyle;
  final TextStyle valueStyle;
  final Color overlayBackground;

  const TetrisTheme({
    required this.boardBackground,
    required this.boardBorderColor,
    required this.boardBorderWidth,
    required this.gridLineColor,
    required this.showGridLines,
    required this.tetrominoColors,
    required this.ghostCellColor,
    required this.cellBorderRadius,
    required this.panelBackground,
    required this.labelStyle,
    required this.valueStyle,
    required this.overlayBackground,
  });

  TetrisTheme copyWith({
    Color? boardBackground,
    Color? boardBorderColor,
    double? boardBorderWidth,
    Color? gridLineColor,
    bool? showGridLines,
    TetrominoColors? tetrominoColors,
    Color? ghostCellColor,
    double? cellBorderRadius,
    Color? panelBackground,
    TextStyle? labelStyle,
    TextStyle? valueStyle,
    Color? overlayBackground,
  }) =>
      TetrisTheme(
        boardBackground: boardBackground ?? this.boardBackground,
        boardBorderColor: boardBorderColor ?? this.boardBorderColor,
        boardBorderWidth: boardBorderWidth ?? this.boardBorderWidth,
        gridLineColor: gridLineColor ?? this.gridLineColor,
        showGridLines: showGridLines ?? this.showGridLines,
        tetrominoColors: tetrominoColors ?? this.tetrominoColors,
        ghostCellColor: ghostCellColor ?? this.ghostCellColor,
        cellBorderRadius: cellBorderRadius ?? this.cellBorderRadius,
        panelBackground: panelBackground ?? this.panelBackground,
        labelStyle: labelStyle ?? this.labelStyle,
        valueStyle: valueStyle ?? this.valueStyle,
        overlayBackground: overlayBackground ?? this.overlayBackground,
      );
}
