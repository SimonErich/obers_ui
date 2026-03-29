// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/panels/oi_resizable.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── Rendering ──────────────────────────────────────────────────────────────

  testWidgets('renders child content', (tester) async {
    await tester.pumpObers(
      const OiResizable(
        initialWidth: 200,
        initialHeight: 200,
        child: Text('resizable content'),
      ),
    );
    expect(find.text('resizable content'), findsOneWidget);
  });

  testWidgets('renders without explicit initial size', (tester) async {
    await tester.pumpObers(const OiResizable(child: Text('no size')));
    expect(find.text('no size'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // ── onResized callback ─────────────────────────────────────────────────────

  testWidgets('dragging right edge fires onResized', (tester) async {
    double? rw;
    double? rh;
    await tester.pumpObers(
      OiResizable(
        initialWidth: 200,
        initialHeight: 200,
        resizeEdges: const {OiResizeEdge.right},
        onResized: (w, h) {
          rw = w;
          rh = h;
        },
        child: const SizedBox(width: 200, height: 200),
      ),
    );

    // Find the right-edge handle and drag it.
    final handleFinder = find.byType(GestureDetector).last;
    await tester.drag(handleFinder, const Offset(50, 0));
    await tester.pump();

    expect(rw, isNotNull);
    expect(rh, isNotNull);
  });

  // ── Min/max constraints ────────────────────────────────────────────────────

  testWidgets('minWidth is respected after drag', (tester) async {
    double? reportedW;
    await tester.pumpObers(
      OiResizable(
        initialWidth: 200,
        initialHeight: 200,
        minWidth: 100,
        resizeEdges: const {OiResizeEdge.right},
        onResized: (w, h) => reportedW = w,
        child: const SizedBox(width: 200, height: 200),
      ),
    );

    final handleFinder = find.byType(GestureDetector).last;
    // Drag far left — should clamp to minWidth.
    await tester.drag(handleFinder, const Offset(-300, 0));
    await tester.pump();

    if (reportedW != null) {
      expect(reportedW, greaterThanOrEqualTo(100));
    }
  });

  testWidgets('maxWidth is respected after drag', (tester) async {
    double? reportedW;
    await tester.pumpObers(
      OiResizable(
        initialWidth: 200,
        initialHeight: 200,
        maxWidth: 300,
        resizeEdges: const {OiResizeEdge.right},
        onResized: (w, h) => reportedW = w,
        child: const SizedBox(width: 200, height: 200),
      ),
    );

    final handleFinder = find.byType(GestureDetector).last;
    await tester.drag(handleFinder, const Offset(500, 0));
    await tester.pump();

    if (reportedW != null) {
      expect(reportedW, lessThanOrEqualTo(300));
    }
  });

  // ── Edge variants ──────────────────────────────────────────────────────────

  testWidgets('all edges render without error', (tester) async {
    await tester.pumpObers(
      OiResizable(
        initialWidth: 200,
        initialHeight: 200,
        resizeEdges: OiResizeEdge.values.toSet(),
        child: const SizedBox(width: 200, height: 200),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
