import 'dart:async';
import '../models/replay_frame.dart';
import '../controllers/input_controller.dart';

/// Plays back a recorded replay by scheduling actions via [InputController].
class ReplayPlayer {
  final InputController _input;
  final List<Timer> _timers = [];

  ReplayPlayer(this._input);

  void play(List<ReplayFrame> frames) {
    stop();
    for (final frame in frames) {
      _timers.add(
        Timer(Duration(milliseconds: frame.timestampMs), () {
          _input.dispatch(frame.action);
        }),
      );
    }
  }

  void stop() {
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
  }
}
