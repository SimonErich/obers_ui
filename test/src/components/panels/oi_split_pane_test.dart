// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/panels/oi_split_pane.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── Rendering ──────────────────────────────────────────────────────────────

  testWidgets('renders both panes', (tester) async {
    await tester.pumpObers(
      const OiSplitPane(leading: Text('Leading'), trailing: Text('Trailing')),
      surfaceSize: const Size(600, 400),
    );
    expect(find.text('Leading'), findsOneWidget);
    expect(find.text('Trailing'), findsOneWidget);
  });

  testWidgets('vertical split renders both panes', (tester) async {
    await tester.pumpObers(
      const OiSplitPane(
        leading: Text('Top'),
        trailing: Text('Bottom'),
        direction: Axis.vertical,
      ),
      surfaceSize: const Size(400, 600),
    );
    expect(find.text('Top'), findsOneWidget);
    expect(find.text('Bottom'), findsOneWidget);
  });

  // ── Divider drag ───────────────────────────────────────────────────────────

  testWidgets('dragging divider fires onRatioChanged', (tester) async {
    double? ratio;
    await tester.pumpObers(
      OiSplitPane(
        leading: const Text('L'),
        trailing: const Text('R'),
        onRatioChanged: (r) => ratio = r,
      ),
      surfaceSize: const Size(600, 400),
    );

    final divider = find.byType(GestureDetector).first;
    await tester.drag(divider, const Offset(60, 0));
    await tester.pump();

    expect(ratio, isNotNull);
  });

  testWidgets('ratio is clamped to minRatio', (tester) async {
    double? ratio;
    await tester.pumpObers(
      OiSplitPane(
        leading: const Text('L'),
        trailing: const Text('R'),
        minRatio: 0.2,
        maxRatio: 0.8,
        onRatioChanged: (r) => ratio = r,
      ),
      surfaceSize: const Size(600, 400),
    );

    final divider = find.byType(GestureDetector).first;
    // Drag far left — should clamp to minRatio.
    await tester.drag(divider, const Offset(-600, 0));
    await tester.pump();

    if (ratio != null) {
      expect(ratio, greaterThanOrEqualTo(0.2));
    }
  });

  testWidgets('ratio is clamped to maxRatio', (tester) async {
    double? ratio;
    await tester.pumpObers(
      OiSplitPane(
        leading: const Text('L'),
        trailing: const Text('R'),
        minRatio: 0.2,
        maxRatio: 0.8,
        onRatioChanged: (r) => ratio = r,
      ),
      surfaceSize: const Size(600, 400),
    );

    final divider = find.byType(GestureDetector).first;
    // Drag far right — should clamp to maxRatio.
    await tester.drag(divider, const Offset(600, 0));
    await tester.pump();

    if (ratio != null) {
      expect(ratio, lessThanOrEqualTo(0.8));
    }
  });

  // ── onDividerDragStart ─────────────────────────────────────────────────────

  testWidgets('onDividerDragStart fires when drag begins', (tester) async {
    var started = false;
    await tester.pumpObers(
      OiSplitPane(
        leading: const Text('L'),
        trailing: const Text('R'),
        onDividerDragStart: () => started = true,
      ),
      surfaceSize: const Size(600, 400),
    );

    final divider = find.byType(GestureDetector).first;
    await tester.drag(divider, const Offset(10, 0));
    await tester.pump();

    expect(started, isTrue);
  });
}
