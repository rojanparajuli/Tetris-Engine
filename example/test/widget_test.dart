import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tetris_engine/tetris_engine.dart';
import 'package:tetris_engine_example/main.dart';

void main() {
  testWidgets('menu starts a game', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const TetrisExampleApp());
    expect(find.text('TETRIS'), findsOneWidget);

    await tester.tap(find.text('START'));
    await tester.pump();
    expect(find.byType(TetrisBoard), findsOneWidget);
    expect(find.byType(TetrisControlPad), findsOneWidget);

    // Leave the game so its timers stop before the test ends.
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pump();
    expect(find.text('START'), findsOneWidget);
  });
}
