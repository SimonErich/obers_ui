// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/oi_app.dart';
import 'package:obers_ui/src/primitives/drag_drop/oi_draggable.dart';

import '../../../helpers/pump_app.dart';

Widget _withDensity(OiDensity density, Widget child) {
  return OiDensityScope(density: density, child: child);
}

void main() {
  // ── 1. Renders child ───────────────────────────────────────────────────────

  testWidgets('renders child widget', (tester) async {
    await tester.pumpObers(
      const OiDraggable<String>(data: 'test', child: Text('drag me')),
    );
    expect(find.text('drag me'), findsOneWidget);
  });

  // ── 2. Pointer density uses Draggable ─────────────────────────────────────

  testWidgets('pointer density uses Draggable', (tester) async {
    await tester.pumpObers(
      _withDensity(
        OiDensity.compact,
        const OiDraggable<String>(data: 'value', child: Text('drag me')),
      ),
    );
    expect(find.byType(Draggable<String>), findsOneWidget);
    expect(find.byType(LongPressDraggable<String>), findsNothing);
  });

  // ── 3. Touch density uses LongPressDraggable ──────────────────────────────

  testWidgets('touch density uses LongPressDraggable', (tester) async {
    await tester.pumpObers(
      _withDensity(
        OiDensity.comfortable,
        const OiDraggable<String>(data: 'value', child: Text('drag me')),
      ),
    );
    expect(find.byType(LongPressDraggable<String>), findsOneWidget);
    expect(find.byType(Draggable<String>), findsNothing);
  });

  // ── 4. onDragStarted fires ────────────────────────────────────────────────

  testWidgets('onDragStarted callback fires on drag start', (tester) async {
    var started = false;
    await tester.pumpObers(
      _withDensity(
        OiDensity.compact,
        OiDraggable<String>(
          data: 'value',
          onDragStarted: () => started = true,
          child: const SizedBox(width: 100, height: 100, child: Text('drag')),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('drag')),
    );
    await gesture.moveBy(const Offset(20, 20));
    await tester.pump();
    expect(started, isTrue);
    await gesture.up();
    await tester.pump();
  });

  // ── 5. onDragCompleted fires when dropped on accepting target ─────────────

  testWidgets('onDragCompleted fires when dropped on DragTarget', (
    tester,
  ) async {
    var completed = false;
    await tester.pumpObers(
      _withDensity(
        OiDensity.compact,
        Row(
          children: [
            OiDraggable<String>(
              data: 'payload',
              onDragCompleted: () => completed = true,
              child: const SizedBox(
                key: Key('src'),
                width: 80,
                height: 80,
                child: Text('src'),
              ),
            ),
            DragTarget<String>(
              onAcceptWithDetails: (_) {},
              builder: (_, __, ___) => const SizedBox(
                key: Key('tgt'),
                width: 80,
                height: 80,
                child: Text('tgt'),
              ),
            ),
          ],
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const Key('src'))),
    );
    await gesture.moveBy(const Offset(100, 0));
    await tester.pump();
    await gesture.up();
    await tester.pump();
    expect(completed, isTrue);
  });

  // ── 6. Custom feedback widget is used when provided ───────────────────────

  testWidgets('custom feedback widget is shown during drag', (tester) async {
    await tester.pumpObers(
      _withDensity(
        OiDensity.compact,
        const OiDraggable<String>(
          data: 'value',
          feedback: Text('custom feedback'),
          child: SizedBox(width: 80, height: 80, child: Text('drag me')),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('drag me')),
    );
    await gesture.moveBy(const Offset(20, 20));
    await tester.pump();
    expect(find.text('custom feedback'), findsOneWidget);
    await gesture.up();
    await tester.pump();
  });

  // ── 7. childWhenDragging is shown at origin during drag ───────────────────

  testWidgets('childWhenDragging shown at original position during drag', (
    tester,
  ) async {
    await tester.pumpObers(
      _withDensity(
        OiDensity.compact,
        const OiDraggable<String>(
          data: 'value',
          childWhenDragging: Text('placeholder'),
          child: SizedBox(width: 80, height: 80, child: Text('drag me')),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('drag me')),
    );
    await gesture.moveBy(const Offset(20, 20));
    await tester.pump();
    expect(find.text('placeholder'), findsOneWidget);
    await gesture.up();
    await tester.pump();
  });
}
