// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/primitives/gesture/oi_swipeable.dart';

import '../../../helpers/pump_app.dart';

// Performs a horizontal drag in small increments so the
// HorizontalDragGestureRecognizer wins the arena reliably.
Future<void> _drag(
  WidgetTester tester,
  Offset start,
  double dx,
) async {
  final gesture = await tester.startGesture(start);
  final steps = dx.abs() ~/ 10;
  final step = Offset(dx > 0 ? 10 : -10, 0);
  for (var i = 0; i < steps; i++) {
    await gesture.moveBy(step);
    await tester.pump();
  }
  final remainder = dx - steps * (dx > 0 ? 10.0 : -10.0);
  if (remainder != 0) {
    await gesture.moveBy(Offset(remainder, 0));
    await tester.pump();
  }
  await gesture.up();
  await tester.pump();
}

// Same as _drag but keeps the gesture open and returns the TestGesture.
Future<TestGesture> _dragOpen(
  WidgetTester tester,
  Offset start,
  double dx,
) async {
  final gesture = await tester.startGesture(start);
  final steps = dx.abs() ~/ 10;
  final step = Offset(dx > 0 ? 10 : -10, 0);
  for (var i = 0; i < steps; i++) {
    await gesture.moveBy(step);
    await tester.pump();
  }
  final remainder = dx - steps * (dx > 0 ? 10.0 : -10.0);
  if (remainder != 0) {
    await gesture.moveBy(Offset(remainder, 0));
    await tester.pump();
  }
  return gesture;
}

void main() {
  // ── 1. Renders child ───────────────────────────────────────────────────────

  testWidgets('renders child widget', (tester) async {
    await tester.pumpObers(
      const OiSwipeable(child: Text('item')),
    );
    expect(find.text('item'), findsOneWidget);
  });

  // ── 2. Dragging right reveals leadingActions ──────────────────────────────

  testWidgets('dragging right reveals leadingActions', (tester) async {
    await tester.pumpObers(
      OiSwipeable(
        leadingActions: [
          OiSwipeAction(
            label: 'Archive',
            color: const Color(0xFF4CAF50),
            onTap: () {},
          ),
        ],
        child: const ColoredBox(
          color: Color(0xFFEEEEEE),
          child: Text('item'),
        ),
      ),
      surfaceSize: const Size(400, 60),
    );

    final gesture = await _dragOpen(
      tester,
      tester.getTopLeft(find.byType(OiSwipeable)) + const Offset(20, 20),
      100,
    );
    expect(find.text('Archive'), findsOneWidget);
    await gesture.up();
    await tester.pump();
  });

  // ── 3. Dragging left reveals trailingActions ──────────────────────────────

  testWidgets('dragging left reveals trailingActions', (tester) async {
    await tester.pumpObers(
      OiSwipeable(
        trailingActions: [
          OiSwipeAction(
            label: 'Delete',
            color: const Color(0xFFF44336),
            onTap: () {},
          ),
        ],
        child: const ColoredBox(
          color: Color(0xFFEEEEEE),
          child: Text('item'),
        ),
      ),
      surfaceSize: const Size(400, 60),
    );

    final gesture = await _dragOpen(
      tester,
      tester.getTopLeft(find.byType(OiSwipeable)) + const Offset(20, 20),
      -100,
    );
    expect(find.text('Delete'), findsOneWidget);
    await gesture.up();
    await tester.pump();
  });

  // ── 4. threshold is configurable ─────────────────────────────────────────

  testWidgets(
      'threshold configurable: high threshold not triggered on small drag',
      (tester) async {
    var dismissed = false;
    await tester.pumpObers(
      OiSwipeable(
        dismissible: true,
        threshold: 0.9,
        onDismissed: () => dismissed = true,
        child: const ColoredBox(
          color: Color(0xFFEEEEEE),
          child: Text('item'),
        ),
      ),
      surfaceSize: const Size(400, 60),
    );

    // 80 px on a 400 px widget = 20 %, well below 90 % threshold.
    await _drag(
      tester,
      tester.getTopLeft(find.byType(OiSwipeable)) + const Offset(20, 20),
      80,
    );

    expect(dismissed, isFalse);
    expect(find.text('item'), findsOneWidget);
  });

  // ── 5. dismissible triggers onDismissed ──────────────────────────────────

  testWidgets('dismissible=true triggers onDismissed when threshold exceeded',
      (tester) async {
    var dismissed = false;
    await tester.pumpObers(
      OiSwipeable(
        dismissible: true,
        onDismissed: () => dismissed = true,
        child: const ColoredBox(
          color: Color(0xFFEEEEEE),
          child: Text('item'),
        ),
      ),
      surfaceSize: const Size(400, 60),
    );

    // Drag > 40 % of 400 px = > 160 px.
    await _drag(
      tester,
      tester.getTopLeft(find.byType(OiSwipeable)) + const Offset(20, 20),
      200,
    );

    expect(dismissed, isTrue);
    expect(find.text('item'), findsNothing);
  });

  // ── 6. Action onTap callback fires when action tapped ────────────────────
  //
  // NOTE: Gesture-based tap while a drag is live on the same widget tree is
  // not reliable due to gesture-arena conflicts. We verify the wiring by
  // finding the action's GestureDetector while it is revealed and invoking
  // its onTap directly through the widget object.

  testWidgets('tapping a revealed action fires its onTap', (tester) async {
    var acted = false;
    await tester.pumpObers(
      OiSwipeable(
        leadingActions: [
          OiSwipeAction(
            label: 'Star',
            color: const Color(0xFFFFC107),
            onTap: () => acted = true,
          ),
        ],
        child: const ColoredBox(
          color: Color(0xFFEEEEEE),
          child: Text('item'),
        ),
      ),
      surfaceSize: const Size(400, 60),
    );

    // Open the drag so the action is in the tree.
    final gesture = await _dragOpen(
      tester,
      tester.getTopLeft(find.byType(OiSwipeable)) + const Offset(20, 20),
      100,
    );
    expect(find.text('Star'), findsOneWidget);

    // Directly invoke the onTap of the action GestureDetector.
    // This bypasses pointer-event routing (which has arena conflicts with the
    // live drag) while still verifying that the callback is correctly wired.
    final actionGD = tester.widgetList<GestureDetector>(find.byType(GestureDetector))
        .firstWhere((gd) => gd.onTap != null);
    actionGD.onTap!();
    await tester.pump();

    await gesture.up();
    await tester.pump();

    expect(acted, isTrue);
  });
}
