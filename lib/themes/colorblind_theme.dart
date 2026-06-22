import 'package:flutter/material.dart';
import 'tetris_theme.dart';
import 'tetromino_colors.dart';

/// Colorblind-accessible theme using the Wong palette.
final TetrisTheme colorblindTetrisTheme = TetrisTheme(
  boardBackground: const Color(0xFFF5F5F5),
  boardBorderColor: const Color(0xFF333333),
  boardBorderWidth: 2.0,
  gridLineColor: const Color(0xFFDDDDDD),
  showGridLines: true,
  tetrominoColors: TetrominoColors.colorblind,
  ghostCellColor: const Color(0x44000000),
  cellBorderRadius: 2.0,
  panelBackground: const Color(0xFFFFFFFF),
  labelStyle: const TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: Color(0xFF777777),
    letterSpacing: 1.2,
  ),
  valueStyle: const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: Color(0xFF111111),
  ),
  overlayBackground: const Color(0xCC000000),
);
