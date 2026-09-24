import 'dart:async';
import '../models/game_state.dart';
import '../models/replay_frame.dart';
import '../controllers/input_controller.dart';
import 'replay_recorder.dart';

/// Plays back a recorded replay by scheduling actions via [InputController].
class ReplayPlayer {
  final InputController _input;
  final List<Timer> _timers = [];
  bool _drivingClock = false;
  ReplayRecorder? _detachedRecorder;

  ReplayPlayer(this._input);

  /// Whether a replay is currently scheduled or running.
  bool get isPlaying => _timers.any((t) => t.isActive);

  /// Schedules [frames] at their recorded timestamps.
  ///
  /// When [seed] is given (see [ReplayRecorder.seed]) the game is restarted
  /// with that seed and its internal clock is switched off, so gravity and
  /// locking come from the recording too. The result is an exact
  /// reproduction of the recorded game. While it plays, the game's own
  /// recorder is detached so the replay does not overwrite the recording; if
  /// the replay ends or is stopped mid-game, the game is left paused.
  /// [onComplete] runs after the last frame.
  void play(
    List<ReplayFrame> frames, {
    int? seed,
    void Function()? onComplete,
  }) {
    stop();
    final game = _input.game;
    if (seed != null) {
      game.useInternalClock = false;
      _drivingClock = true;
      _detachedRecorder = game.recorder;
      game.recorder = null;
      game.start(seed: seed);
    }
    for (final frame in frames) {
      _timers.add(
        Timer(Duration(milliseconds: frame.timestampMs), () {
          _input.dispatch(frame.action);
        }),
      );
    }
    final lastMs = frames.isEmpty ? 0 : frames.last.timestampMs;
    _timers.add(
      Timer(Duration(milliseconds: lastMs), () {
        _releaseClock();
        onComplete?.call();
      }),
    );
  }

  void stop() {
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
    _releaseClock();
  }

  void _releaseClock() {
    if (!_drivingClock) return;
    _drivingClock = false;
    final game = _input.game;
    if (game.state.status == TetrisGameStatus.playing) game.pause();
    game.recorder = _detachedRecorder;
    _detachedRecorder = null;
    game.useInternalClock = true;
  }
}
