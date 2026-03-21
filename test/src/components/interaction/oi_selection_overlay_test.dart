// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/interaction/oi_selection_overlay.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders child widget', (tester) async {
    await tester.pumpObers(
      OiSelectionOverlay(
        onSelectionRect: (_) {},
        onSelectionStart: () {},
        onSelectionEnd: () {},
        child: const Text('Content'),
      ),
    );
    expect(find.text('Content'), findsOneWidget);
  });

  testWidgets('renders without error when enabled', (tester) async {
    await tester.pumpObers(
      OiSelectionOverlay(
        onSelectionRect: (_) {},
        onSelectionStart: () {},
        onSelectionEnd: () {},
        child: const SizedBox(width: 400, height: 400),
      ),
    );
    expect(find.byType(OiSelectionOverlay), findsOneWidget);
  });

  testWidgets('fires onSelectionStart on drag begin', (tester) async {
    var started = false;
    await tester.pumpObers(
      SizedBox(
        width: 400,
        height: 400,
        child: OiSelectionOverlay(
          onSelectionRect: (_) {},
          onSelectionStart: () => started = true,
          onSelectionEnd: () {},
          child: const SizedBox.expand(),
        ),
      ),
    );

    final center = tester.getCenter(find.byType(OiSelectionOverlay));
    final gesture = await tester.startGesture(center);
    // Move past kPanSlop (18px) to trigger onPanStart
    await gesture.moveBy(const Offset(0, 20));
    await tester.pump();

    expect(started, isTrue);

    await gesture.up();
    await tester.pump();
  });

  testWidgets('fires onSelectionRect during drag', (tester) async {
    Rect? lastRect;
    await tester.pumpObers(
      SizedBox(
        width: 400,
        height: 400,
        child: OiSelectionOverlay(
          onSelectionRect: (rect) => lastRect = rect,
          onSelectionStart: () {},
          onSelectionEnd: () {},
          child: const SizedBox.expand(),
        ),
      ),
    );

    final center = tester.getCenter(find.byType(OiSelectionOverlay));
    final gesture = await tester.startGesture(center);
    await gesture.moveBy(const Offset(0, 20));
    await tester.pump();
    await gesture.moveBy(const Offset(50, 50));
    await tester.pump();

    expect(lastRect, isNotNull);

    await gesture.up();
    await tester.pump();
  });

  testWidgets('fires onSelectionEnd on drag end', (tester) async {
    var ended = false;
    await tester.pumpObers(
      SizedBox(
        width: 400,
        height: 400,
        child: OiSelectionOverlay(
          onSelectionRect: (_) {},
          onSelectionStart: () {},
          onSelectionEnd: () => ended = true,
          child: const SizedBox.expand(),
        ),
      ),
    );

    final center = tester.getCenter(find.byType(OiSelectionOverlay));
    final gesture = await tester.startGesture(center);
    await gesture.moveBy(const Offset(0, 20));
    await tester.pump();
    await gesture.up();
    await tester.pump();

    expect(ended, isTrue);
  });

  testWidgets('shows selection rectangle during drag', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 400,
        height: 400,
        child: OiSelectionOverlay(
          onSelectionRect: (_) {},
          onSelectionStart: () {},
          onSelectionEnd: () {},
          child: const SizedBox.expand(),
        ),
      ),
    );

    final center = tester.getCenter(find.byType(OiSelectionOverlay));
    final gesture = await tester.startGesture(center);
    await gesture.moveBy(const Offset(0, 20));
    await tester.pump();
    await gesture.moveBy(const Offset(50, 50));
    await tester.pump();

    // During drag, there should be an IgnorePointer(ignoring: true) for the rect
    expect(
      find.byWidgetPredicate((w) => w is IgnorePointer && w.ignoring),
      findsOneWidget,
    );

    await gesture.up();
    await tester.pump();
  });

  testWidgets('selection rectangle is removed after drag ends', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 400,
        height: 400,
        child: OiSelectionOverlay(
          onSelectionRect: (_) {},
          onSelectionStart: () {},
          onSelectionEnd: () {},
          child: const SizedBox.expand(),
        ),
      ),
    );

    final center = tester.getCenter(find.byType(OiSelectionOverlay));
    final gesture = await tester.startGesture(center);
    await gesture.moveBy(const Offset(0, 20));
    await tester.pump();
    await gesture.up();
    await tester.pump();

    // After drag ends, the IgnorePointer(ignoring: true) selection rect
    // should be gone
    expect(
      find.byWidgetPredicate((w) => w is IgnorePointer && w.ignoring),
      findsNothing,
    );
  });

  testWidgets('does not fire onSelectionStart when disabled', (tester) async {
    var started = false;
    await tester.pumpObers(
      SizedBox(
        width: 400,
        height: 400,
        child: OiSelectionOverlay(
          enabled: false,
          onSelectionRect: (_) {},
          onSelectionStart: () => started = true,
          onSelectionEnd: () {},
          child: const SizedBox.expand(),
        ),
      ),
    );

    final center = tester.getCenter(find.byType(OiSelectionOverlay));
    final gesture = await tester.startGesture(center);
    await gesture.moveBy(const Offset(0, 20));
    await tester.pump();
    await gesture.moveBy(const Offset(50, 50));
    await tester.pump();
    await gesture.up();
    await tester.pump();

    // onPanStart still fires (GestureDetector still recognizes the gesture),
    // but the _onPanStart handler returns early because enabled is false
    expect(started, isFalse);
  });

  testWidgets('uses GestureDetector with translucent hit behavior', (
    tester,
  ) async {
    await tester.pumpObers(
      OiSelectionOverlay(
        onSelectionRect: (_) {},
        onSelectionStart: () {},
        onSelectionEnd: () {},
        child: const SizedBox(width: 400, height: 400),
      ),
    );
    final gestureDetector = tester.widget<GestureDetector>(
      find.byType(GestureDetector),
    );
    expect(gestureDetector.behavior, HitTestBehavior.translucent);
  });

  testWidgets('child is always rendered in Stack', (tester) async {
    await tester.pumpObers(
      OiSelectionOverlay(
        onSelectionRect: (_) {},
        onSelectionStart: () {},
        onSelectionEnd: () {},
        child: const Text('Always visible'),
      ),
    );
    expect(find.byType(Stack), findsOneWidget);
    expect(find.text('Always visible'), findsOneWidget);
  });
}
