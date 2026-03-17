// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/media/oi_lightbox.dart';

import '../../../helpers/pump_app.dart';

// ── Image error suppression ──────────────────────────────────────────────────

FlutterExceptionHandler? _originalOnError;

void _ignoreImageErrors() {
  _originalOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
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

const _items = [
  OiLightboxItem(src: 'https://example.com/a.png', alt: 'Image A', caption: 'Caption A'),
  OiLightboxItem(src: 'https://example.com/b.png', alt: 'Image B'),
  OiLightboxItem(src: 'https://example.com/c.png', alt: 'Image C', caption: 'Caption C'),
];

Widget _lightbox({
  List<OiLightboxItem> items = _items,
  int initialIndex = 0,
  VoidCallback? onDismiss,
  bool showThumbnails = true,
  bool enableZoom = true,
  bool enableSwipe = true,
}) {
  return SizedBox(
    width: 800,
    height: 600,
    child: OiLightbox(
      items: items,
      initialIndex: initialIndex,
      onDismiss: onDismiss,
      showThumbnails: showThumbnails,
      enableZoom: enableZoom,
      enableSwipe: enableSwipe,
      label: 'Test lightbox',
    ),
  );
}

void main() {
  group('OiLightbox', () {
    setUp(_ignoreImageErrors);
    tearDown(_restoreOnError);

    testWidgets('renders the lightbox widget', (tester) async {
      await tester.pumpObers(
        _lightbox(),
        surfaceSize: const Size(800, 600),
      );
      await tester.pump();

      expect(find.byKey(const Key('oi_lightbox')), findsOneWidget);
    });

    testWidgets('displays image at initial index', (tester) async {
      await tester.pumpObers(
        _lightbox(initialIndex: 1),
        surfaceSize: const Size(800, 600),
      );
      await tester.pump();

      // The image with key containing index 1 should be rendered.
      expect(
        find.byKey(const ValueKey('oi_lightbox_image_1')),
        findsOneWidget,
      );
    });

    testWidgets('next arrow navigates to next image', (tester) async {
      await tester.pumpObers(
        _lightbox(),
        surfaceSize: const Size(800, 600),
      );
      await tester.pump();

      // Initially at index 0.
      expect(
        find.byKey(const ValueKey('oi_lightbox_image_0')),
        findsOneWidget,
      );

      // Tap next.
      await tester.tap(find.byKey(const Key('oi_lightbox_next')));
      await tester.pump();

      expect(
        find.byKey(const ValueKey('oi_lightbox_image_1')),
        findsOneWidget,
      );
    });

    testWidgets('previous arrow navigates to previous image', (tester) async {
      await tester.pumpObers(
        _lightbox(initialIndex: 2),
        surfaceSize: const Size(800, 600),
      );
      await tester.pump();

      expect(
        find.byKey(const ValueKey('oi_lightbox_image_2')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('oi_lightbox_previous')));
      await tester.pump();

      expect(
        find.byKey(const ValueKey('oi_lightbox_image_1')),
        findsOneWidget,
      );
    });

    testWidgets('close button calls onDismiss', (tester) async {
      var dismissed = false;
      await tester.pumpObers(
        _lightbox(onDismiss: () => dismissed = true),
        surfaceSize: const Size(800, 600),
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('oi_lightbox_close')));
      await tester.pump();

      expect(dismissed, isTrue);
    });

    testWidgets('caption is displayed when present', (tester) async {
      await tester.pumpObers(
        _lightbox(),
        surfaceSize: const Size(800, 600),
      );
      await tester.pump();

      // First item has caption "Caption A".
      expect(find.text('Caption A'), findsOneWidget);
    });

    testWidgets('caption is hidden when not present', (tester) async {
      await tester.pumpObers(
        _lightbox(initialIndex: 1),
        surfaceSize: const Size(800, 600),
      );
      await tester.pump();

      // Second item has no caption.
      expect(find.byKey(const Key('oi_lightbox_caption')), findsNothing);
    });

    testWidgets('keyboard arrow right navigates to next', (tester) async {
      await tester.pumpObers(
        _lightbox(),
        surfaceSize: const Size(800, 600),
      );
      await tester.pump();

      // Wait for focus to be requested.
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();

      expect(
        find.byKey(const ValueKey('oi_lightbox_image_1')),
        findsOneWidget,
      );
    });

    testWidgets('keyboard arrow left navigates to previous', (tester) async {
      await tester.pumpObers(
        _lightbox(initialIndex: 1),
        surfaceSize: const Size(800, 600),
      );
      await tester.pump();
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();

      expect(
        find.byKey(const ValueKey('oi_lightbox_image_0')),
        findsOneWidget,
      );
    });

    testWidgets('escape key calls onDismiss', (tester) async {
      var dismissed = false;
      await tester.pumpObers(
        _lightbox(onDismiss: () => dismissed = true),
        surfaceSize: const Size(800, 600),
      );
      await tester.pump();
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();

      expect(dismissed, isTrue);
    });

    testWidgets('thumbnail strip is shown with multiple items', (tester) async {
      await tester.pumpObers(
        _lightbox(),
        surfaceSize: const Size(800, 600),
      );
      await tester.pump();

      expect(
        find.byKey(const Key('oi_lightbox_thumbnails')),
        findsOneWidget,
      );
    });

    testWidgets('thumbnail strip is hidden when showThumbnails is false',
        (tester) async {
      await tester.pumpObers(
        _lightbox(showThumbnails: false),
        surfaceSize: const Size(800, 600),
      );
      await tester.pump();

      expect(
        find.byKey(const Key('oi_lightbox_thumbnails')),
        findsNothing,
      );
    });

    testWidgets('semantics label is applied', (tester) async {
      await tester.pumpObers(
        _lightbox(),
        surfaceSize: const Size(800, 600),
      );
      await tester.pump();

      expect(
        find.bySemanticsLabel('Test lightbox'),
        findsOneWidget,
      );
    });

    testWidgets('renders empty widget for empty items list', (tester) async {
      await tester.pumpObers(
        _lightbox(items: const []),
        surfaceSize: const Size(800, 600),
      );
      await tester.pump();

      expect(find.byKey(const Key('oi_lightbox')), findsNothing);
    });

    testWidgets('initialIndex is clamped to valid range', (tester) async {
      await tester.pumpObers(
        _lightbox(initialIndex: 100),
        surfaceSize: const Size(800, 600),
      );
      await tester.pump();

      // Should clamp to the last valid index (2).
      expect(
        find.byKey(const ValueKey('oi_lightbox_image_2')),
        findsOneWidget,
      );
    });
  });
}
