# Contributing

Thanks for helping improve `tetris_engine`! Bug reports, fixes and features are
all welcome.

## Reporting bugs

Open an issue using the **Bug report** template. For gameplay bugs, the most
useful thing you can attach is a replay, which reproduces the game exactly:

```dart
final recorder = ReplayRecorder();
final game = TetrisGame(recorder: recorder);
// ... play until the bug happens ...
print(recorder.exportJson());
```

## Development

```sh
flutter pub get
flutter analyze
flutter test
dart format lib test example/lib example/test
```

Run the example app with `cd example && flutter run`.

The engine (`lib/engine`, `lib/models`) has no widget dependencies beyond
`ChangeNotifier` and should stay that way. Game logic changes need unit tests.
For timer behaviour, drive the game with `useInternalClock = false` and
`applyGravity()`, or use `fakeAsync` (see `test/tetris_game_test.dart`).

## Pull requests

- Keep changes focused, with one feature or fix per PR.
- Add a line under an `## Unreleased` heading in `CHANGELOG.md`.
- Don't break the public API in a minor release. Deprecate first with
  `@Deprecated`, then remove in the next major version.

## Releasing (maintainers)

1. Move the `Unreleased` changelog entries under the new version.
2. Bump `version` in `pubspec.yaml`.
3. Commit, then tag and push: `git tag v1.2.0 && git push origin v1.2.0`.
   The `Publish to pub.dev` workflow publishes the tag (automated publishing
   must be enabled once in the pub.dev admin page).
