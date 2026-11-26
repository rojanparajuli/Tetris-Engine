import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tetris_engine/tetris_engine.dart';

Widget host(Widget child) => Directionality(
  textDirection: TextDirection.ltr,
  child: Align(
    alignment: Alignment.topLeft,
    child: SizedBox(width: 200, child: child),
  ),
);

Finder padButton(TetrisPadGlyph glyph) =>
    find.byWidgetPredicate((w) => w is TetrisPadButton && w.glyph == glyph);

void main() {
  testWidgets('TetrisBoard renders and handles keyboard input', (tester) async {
    final game = TetrisGame(seed: 1)..useInternalClock = false;
    game.start();
    await tester.pumpWidget(host(TetrisBoard(game: game)));
    await tester.pump();

    final col = game.state.activePiece!.position.col;
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    expect(game.state.activePiece!.position.col, col - 1);

    await tester.sendKeyEvent(LogicalKeyboardKey.keyP);
    await tester.pump();
    expect(game.state.status, TetrisGameStatus.paused);
    expect(find.text('PAUSED'), findsOneWidget);
    game.dispose();
  });

  testWidgets('custom keyMap replaces the defaults', (tester) async {
    final game = TetrisGame(seed: 1)..useInternalClock = false;
    game.start();
    await tester.pumpWidget(
      host(
        TetrisBoard(game: game, keyMap: {LogicalKeyboardKey.keyJ: 'moveLeft'}),
      ),
    );
    await tester.pump();

    final col = game.state.activePiece!.position.col;
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    expect(game.state.activePiece!.position.col, col);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyJ);
    expect(game.state.activePiece!.position.col, col - 1);
    game.dispose();
  });

  testWidgets('onGameOver fires once and onScoreChanged only on change', (
    tester,
  ) async {
    final game = TetrisGame(seed: 1)..useInternalClock = false;
    var gameOvers = 0;
    final scores = <int>[];
    await tester.pumpWidget(
      host(
        TetrisBoard(
          game: game,
          onGameOver: () => gameOvers++,
          onScoreChanged: scores.add,
        ),
      ),
    );
    game.start();
    game.moveLeft();
    game.moveRight();
    expect(scores, isEmpty);

    while (game.state.status == TetrisGameStatus.playing) {
      game.hardDrop();
    }
    game.pause(); // extra notifications after game over
    await tester.pump();
    expect(gameOvers, 1);
    expect(scores, isNotEmpty);
    expect(scores.toSet().length, scores.length);
    game.dispose();
  });

  testWidgets('TetrisBoard follows a replaced game', (tester) async {
    final first = TetrisGame(seed: 1)..useInternalClock = false;
    final second = TetrisGame(seed: 2)..useInternalClock = false;
    first.start();
    second.start();
    await tester.pumpWidget(host(TetrisBoard(game: first)));
    await tester.pumpWidget(host(TetrisBoard(game: second)));
    await tester.pump();

    final col = second.state.activePiece!.position.col;
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    expect(second.state.activePiece!.position.col, col + 1);
    first.dispose();
    second.dispose();
  });

  testWidgets('TetrisBoard pauses when the app is hidden', (tester) async {
    final game = TetrisGame(seed: 1)..useInternalClock = false;
    game.start();
    await tester.pumpWidget(host(TetrisBoard(game: game)));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    expect(game.state.status, TetrisGameStatus.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    game.dispose();
  });

  testWidgets('TetrisControlPad buttons act and auto-repeat', (tester) async {
    final game = TetrisGame(seed: 1)..useInternalClock = false;
    game.start();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: TetrisControlPad(game: game),
      ),
    );

    final col = game.state.activePiece!.position.col;
    await tester.tap(padButton(TetrisPadGlyph.moveLeft));
    expect(game.state.activePiece!.position.col, col - 1);

    // Holding right: one move, then repeats after the delay.
    final gesture = await tester.startGesture(
      tester.getCenter(padButton(TetrisPadGlyph.moveRight)),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(game.state.activePiece!.position.col, col);
    await tester.pump(const Duration(milliseconds: 170));
    await tester.pump(const Duration(milliseconds: 50));
    expect(game.state.activePiece!.position.col, greaterThan(col));
    await gesture.up();

    await tester.tap(padButton(TetrisPadGlyph.pause));
    await tester.pump();
    expect(game.state.status, TetrisGameStatus.paused);
    expect(padButton(TetrisPadGlyph.play), findsOneWidget);
    game.dispose();
  });
}
