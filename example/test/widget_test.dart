import 'package:material_ui/material_ui.dart';
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

  testWidgets('every mode starts and fits a phone screen', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const TetrisExampleApp());
    for (final mode in TetrisGameMode.values) {
      expect(find.text('MODE: ${mode.name.toUpperCase()}'), findsOneWidget);
      await tester.tap(find.text('START'));
      await tester.pump();
      expect(find.byType(GameModePanel), findsOneWidget);
      if (mode.lineGoal != null) {
        expect(find.text('LINES LEFT'), findsOneWidget);
      }
      if (mode.isTimed) expect(find.text('TIME LEFT'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pump();
      await tester.tap(find.text('MODE: ${mode.name.toUpperCase()}'));
      await tester.pump();
    }
  });
}
