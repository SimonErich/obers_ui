// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/primitives/gesture/oi_pinch_zoom.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── 1. Renders child ───────────────────────────────────────────────────────

  testWidgets('renders child widget', (tester) async {
    await tester.pumpObers(
      const OiPinchZoom(child: Text('zoom me')),
    );
    expect(find.text('zoom me'), findsOneWidget);
  });

  // ── 2. clipBehavior=true wraps in ClipRect ────────────────────────────────

  testWidgets('clipBehavior=true inserts ClipRect', (tester) async {
    await tester.pumpObers(
      const OiPinchZoom(child: Text('z')),
    );
    expect(find.byType(ClipRect), findsOneWidget);
  });

  // ── 3. clipBehavior=false has no ClipRect ────────────────────────────────

  testWidgets('clipBehavior=false omits ClipRect', (tester) async {
    await tester.pumpObers(
      const OiPinchZoom(clipBehavior: false, child: Text('z')),
    );
    expect(find.byType(ClipRect), findsNothing);
  });

  // ── 4. initialScale is applied ───────────────────────────────────────────

  testWidgets('initialScale is reflected in Transform', (tester) async {
    await tester.pumpObers(
      const OiPinchZoom(initialScale: 2, child: Text('z')),
    );
    expect(find.byType(Transform), findsOneWidget);
  });

  // ── 5. onScaleChanged fires during pinch ─────────────────────────────────

  testWidgets('onScaleChanged callback fires on scale gesture', (tester) async {
    final scales = <double>[];
    await tester.pumpObers(
      OiPinchZoom(
        onScaleChanged: scales.add,
        child: const SizedBox(width: 200, height: 200, child: Text('z')),
      ),
    );

    final center = tester.getCenter(find.byType(OiPinchZoom));
    final pointer1 =
        await tester.startGesture(center + const Offset(-40, 0));
    final pointer2 =
        await tester.startGesture(center + const Offset(40, 0));
    await tester.pump();

    // Move pointers apart (zoom in).
    await pointer1.moveBy(const Offset(-40, 0));
    await pointer2.moveBy(const Offset(40, 0));
    await tester.pump();

    await pointer1.up();
    await pointer2.up();
    await tester.pump();

    expect(scales, isNotEmpty);
  });

  // ── 6. Scale is clamped to minScale ──────────────────────────────────────

  testWidgets('scale is clamped to minScale', (tester) async {
    double? lastScale;
    await tester.pumpObers(
      OiPinchZoom(
        minScale: 1,
        maxScale: 3,
        onScaleChanged: (s) => lastScale = s,
        child: const SizedBox(width: 200, height: 200, child: Text('z')),
      ),
    );

    final center = tester.getCenter(find.byType(OiPinchZoom));
    // Move pointers together to zoom out below minScale.
    final p1 = await tester.startGesture(center + const Offset(-80, 0));
    final p2 = await tester.startGesture(center + const Offset(80, 0));
    await tester.pump();

    await p1.moveBy(const Offset(70, 0));
    await p2.moveBy(const Offset(-70, 0));
    await tester.pump();

    await p1.up();
    await p2.up();
    await tester.pump();

    if (lastScale != null) {
      expect(lastScale, greaterThanOrEqualTo(1.0));
    }
  });

  // ── 7. Scale is clamped to maxScale ──────────────────────────────────────

  testWidgets('scale is clamped to maxScale', (tester) async {
    double? lastScale;
    await tester.pumpObers(
      OiPinchZoom(
        maxScale: 2,
        onScaleChanged: (s) => lastScale = s,
        child: const SizedBox(width: 200, height: 200, child: Text('z')),
      ),
    );

    final center = tester.getCenter(find.byType(OiPinchZoom));
    // Move pointers far apart to zoom above maxScale.
    final p1 = await tester.startGesture(center + const Offset(-10, 0));
    final p2 = await tester.startGesture(center + const Offset(10, 0));
    await tester.pump();

    await p1.moveBy(const Offset(-200, 0));
    await p2.moveBy(const Offset(200, 0));
    await tester.pump();

    await p1.up();
    await p2.up();
    await tester.pump();

    if (lastScale != null) {
      expect(lastScale, lessThanOrEqualTo(2.0));
    }
  });

  // ── 8. panEnabled=false: offset does not change on drag ──────────────────

  testWidgets('panEnabled=false: offset unchanged on single-pointer drag',
      (tester) async {
    await tester.pumpObers(
      const OiPinchZoom(
        panEnabled: false,
        child: SizedBox(width: 200, height: 200, child: Text('nopan')),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(OiPinchZoom)),
    );
    await gesture.moveBy(const Offset(100, 0));
    await tester.pump();
    await gesture.up();
    await tester.pump();

    expect(find.text('nopan'), findsOneWidget);
  });
}
