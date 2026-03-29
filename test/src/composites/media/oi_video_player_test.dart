// Tests do not require documentation comments.

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/media/oi_video_player.dart';

import '../../../helpers/pump_app.dart';

// ── Image error suppression ──────────────────────────────────────────────────

FlutterExceptionHandler? _originalOnError;

void _ignoreImageErrors() {
  _originalOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.exception.toString().contains('NetworkImageLoadException') ||
        details.exception.toString().contains('Unable to load asset') ||
        details.library == 'image resource service') {
      return; // swallow image errors
    }
    _originalOnError?.call(details);
  };
}

void _restoreOnError() {
  FlutterError.onError = _originalOnError;
  _originalOnError = null;
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget _player({
  String src = 'https://example.com/video.mp4',
  bool autoPlay = false,
  bool loop = false,
  bool showControls = true,
  double? aspectRatio,
  String? posterUrl,
  VoidCallback? onPlay,
  VoidCallback? onPause,
}) {
  return SizedBox(
    width: 400,
    height: 300,
    child: OiVideoPlayer(
      src: src,
      label: 'Test video player',
      autoPlay: autoPlay,
      loop: loop,
      showControls: showControls,
      aspectRatio: aspectRatio,
      posterUrl: posterUrl,
      onPlay: onPlay,
      onPause: onPause,
    ),
  );
}

void main() {
  group('OiVideoPlayer', () {
    setUp(_ignoreImageErrors);
    tearDown(_restoreOnError);

    testWidgets('renders the video player widget', (tester) async {
      await tester.pumpObers(_player(), surfaceSize: const Size(400, 300));
      await tester.pump();

      expect(find.byKey(const Key('oi_video_player_surface')), findsOneWidget);
    });

    testWidgets('displays poster image when posterUrl is provided', (
      tester,
    ) async {
      await tester.pumpObers(
        _player(posterUrl: 'https://example.com/poster.png'),
        surfaceSize: const Size(400, 300),
      );
      await tester.pump();

      expect(find.byKey(const Key('oi_video_player_poster')), findsOneWidget);
    });

    testWidgets('hides poster when posterUrl is null', (tester) async {
      await tester.pumpObers(_player(), surfaceSize: const Size(400, 300));
      await tester.pump();

      expect(find.byKey(const Key('oi_video_player_poster')), findsNothing);
    });

    testWidgets('shows source text when no poster', (tester) async {
      await tester.pumpObers(_player(), surfaceSize: const Size(400, 300));
      await tester.pump();

      expect(find.byKey(const Key('oi_video_player_src')), findsOneWidget);
    });

    testWidgets('controls are visible when showControls is true', (
      tester,
    ) async {
      await tester.pumpObers(_player(), surfaceSize: const Size(400, 300));
      await tester.pump();

      expect(find.byKey(const Key('oi_video_player_controls')), findsOneWidget);
    });

    testWidgets('controls are hidden when showControls is false', (
      tester,
    ) async {
      await tester.pumpObers(
        _player(showControls: false),
        surfaceSize: const Size(400, 300),
      );
      await tester.pump();

      expect(find.byKey(const Key('oi_video_player_controls')), findsNothing);
    });

    testWidgets('progress bar is hidden when showControls is false', (
      tester,
    ) async {
      await tester.pumpObers(
        _player(showControls: false),
        surfaceSize: const Size(400, 300),
      );
      await tester.pump();

      expect(find.byKey(const Key('oi_video_player_progress')), findsNothing);
    });

    testWidgets('aspect ratio is applied', (tester) async {
      await tester.pumpObers(
        _player(aspectRatio: 4 / 3),
        surfaceSize: const Size(400, 300),
      );
      await tester.pump();

      final aspectRatio = tester.widget<AspectRatio>(
        find.byKey(const Key('oi_video_player_aspect')),
      );
      expect(aspectRatio.aspectRatio, closeTo(4 / 3, 0.01));
    });

    testWidgets('default aspect ratio is 16:9', (tester) async {
      await tester.pumpObers(_player(), surfaceSize: const Size(400, 300));
      await tester.pump();

      final aspectRatio = tester.widget<AspectRatio>(
        find.byKey(const Key('oi_video_player_aspect')),
      );
      expect(aspectRatio.aspectRatio, closeTo(16 / 9, 0.01));
    });

    testWidgets('tapping play button fires onPlay', (tester) async {
      var playCalled = false;
      await tester.pumpObers(
        _player(onPlay: () => playCalled = true),
        surfaceSize: const Size(400, 300),
      );
      await tester.pump();

      // Tap the controls area to toggle play.
      await tester.tap(find.byKey(const Key('oi_video_player_controls')));
      await tester.pump();

      expect(playCalled, isTrue);
    });

    testWidgets('tapping pause fires onPause after playing', (tester) async {
      var pauseCalled = false;
      await tester.pumpObers(
        _player(onPlay: () {}, onPause: () => pauseCalled = true),
        surfaceSize: const Size(400, 300),
      );
      await tester.pump();

      // First tap: play.
      await tester.tap(find.byKey(const Key('oi_video_player_controls')));
      await tester.pump();

      // Second tap: pause.
      await tester.tap(find.byKey(const Key('oi_video_player_controls')));
      await tester.pump();

      expect(pauseCalled, isTrue);
    });

    testWidgets('autoPlay fires onPlay on init', (tester) async {
      var playCalled = false;
      await tester.pumpObers(
        _player(autoPlay: true, onPlay: () => playCalled = true),
        surfaceSize: const Size(400, 300),
      );
      // Allow the post-frame callback to fire.
      await tester.pump();

      expect(playCalled, isTrue);
    });

    testWidgets('semantics label is applied', (tester) async {
      await tester.pumpObers(_player(), surfaceSize: const Size(400, 300));
      await tester.pump();

      expect(find.bySemanticsLabel('Test video player'), findsOneWidget);
    });

    testWidgets('play icon changes after toggle', (tester) async {
      await tester.pumpObers(_player(), surfaceSize: const Size(400, 300));
      await tester.pump();

      // Initially should show play icon (▶).
      final playIcon = tester.widget<Text>(
        find.byKey(const Key('oi_video_player_play_icon')),
      );
      expect(playIcon.data, '\u25B6');

      // Tap to play — icon should change to pause (⏸).
      await tester.tap(find.byKey(const Key('oi_video_player_controls')));
      await tester.pump();

      final pauseIcon = tester.widget<Text>(
        find.byKey(const Key('oi_video_player_play_icon')),
      );
      expect(pauseIcon.data, '\u23F8');
    });
  });
}
