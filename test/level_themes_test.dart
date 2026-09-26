import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tetris_engine/tetris_engine.dart';

void main() {
  group('LevelThemes', () {
    test('each level gets the next palette and wraps around', () {
      final themes = LevelThemes(base: darkTetrisTheme);
      final count = LevelPalette.classic.length;

      expect(
        themes.forLevel(2).tetrominoColors,
        LevelPalette.classic[1].pieces,
      );
      expect(themes.forLevel(1), isNot(same(themes.forLevel(2))));
      expect(themes.forLevel(1), same(themes.forLevel(1 + count)));
      expect(
        themes.forLevel(3).boardBackground,
        LevelPalette.classic[2].boardBackground,
      );
    });

    test('levelsPerPalette groups levels', () {
      final themes = LevelThemes(base: darkTetrisTheme, levelsPerPalette: 3);
      expect(themes.forLevel(1), same(themes.forLevel(3)));
      expect(themes.forLevel(3), isNot(same(themes.forLevel(4))));
    });

    test('light base keeps its board colors by default', () {
      final themes = LevelThemes(base: defaultTetrisTheme);
      final t = themes.forLevel(4);
      expect(t.boardBackground, defaultTetrisTheme.boardBackground);
      expect(t.tetrominoColors, LevelPalette.classic[3].pieces);
      expect(t.valueStyle, defaultTetrisTheme.valueStyle);
    });

    test('custom palettes and fromFills borders', () {
      final palette = LevelPalette.fromFills({
        for (final type in TetrominoType.values) type: Colors.red,
      });
      final themes = LevelThemes(base: darkTetrisTheme, palettes: [palette]);
      final t = themes.forLevel(7);
      expect(t.tetrominoColors.fillFor(TetrominoType.T), Colors.red);
      expect(t.tetrominoColors.borderFor(TetrominoType.T), isNot(Colors.red));
      expect(t.boardBackground, darkTetrisTheme.boardBackground);
    });
  });

  testWidgets('LevelThemeBuilder uses the game level theme', (tester) async {
    final themes = LevelThemes(base: darkTetrisTheme);
    TetrisTheme? seen;
    Widget build(TetrisGame game) => LevelThemeBuilder(
      game: game,
      levelThemes: themes,
      builder: (_, theme, _) {
        seen = theme;
        return const SizedBox();
      },
    );

    final first = TetrisGame(seed: 1)..useInternalClock = false;
    first.start();
    await tester.pumpWidget(build(first));
    expect(seen, same(themes.forLevel(1)));

    final second = TetrisGame(seed: 1, startLevel: 5)..useInternalClock = false;
    second.start();
    await tester.pumpWidget(build(second));
    expect(seen, same(themes.forLevel(5)));

    first.dispose();
    second.dispose();
  });
}
