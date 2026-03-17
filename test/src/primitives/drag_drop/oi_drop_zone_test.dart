// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/primitives/drag_drop/oi_drop_zone.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── 1. Renders idle state by default ──────────────────────────────────────

  testWidgets('renders idle state initially', (tester) async {
    await tester.pumpObers(
      OiDropZone<String>(
        onAccept: (_) {},
        builder: (context, state) => Text(state.name),
      ),
    );
    expect(find.text('idle'), findsOneWidget);
  });

  // ── 2. Builder receives hovering when drag enters ─────────────────────────

  testWidgets('state becomes hovering when drag is over zone', (tester) async {
    OiDropState? lastState;
    await tester.pumpObers(
      Row(
        children: [
          const Draggable<String>(
            data: 'hello',
            feedback: Text('ghost'),
            child: SizedBox(
              key: Key('src'),
              width: 80,
              height: 80,
              child: Text('drag'),
            ),
          ),
          OiDropZone<String>(
            onAccept: (_) {},
            builder: (context, state) {
              lastState = state;
              return SizedBox(
                key: const Key('zone'),
                width: 80,
                height: 80,
                child: Text(state.name),
              );
            },
          ),
        ],
      ),
    );

    expect(lastState, OiDropState.idle);

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const Key('src'))),
    );
    await gesture.moveBy(const Offset(100, 0));
    await tester.pump();

    expect(lastState, OiDropState.hovering);
    await gesture.up();
    await tester.pump();
  });

  // ── 3. State resets to idle when drag leaves ──────────────────────────────

  testWidgets('state resets to idle when drag leaves zone', (tester) async {
    OiDropState? lastState;
    await tester.pumpObers(
      Row(
        children: [
          const Draggable<String>(
            data: 'hello',
            feedback: Text('ghost'),
            child: SizedBox(
              key: Key('src'),
              width: 80,
              height: 80,
              child: Text('drag'),
            ),
          ),
          OiDropZone<String>(
            onAccept: (_) {},
            builder: (context, state) {
              lastState = state;
              return SizedBox(
                key: const Key('zone'),
                width: 80,
                height: 80,
                child: Text(state.name),
              );
            },
          ),
        ],
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const Key('src'))),
    );
    // Move onto zone.
    await gesture.moveBy(const Offset(100, 0));
    await tester.pump();
    expect(lastState, OiDropState.hovering);

    // Move back off zone.
    await gesture.moveBy(const Offset(-100, 0));
    await tester.pump();
    expect(lastState, OiDropState.idle);

    await gesture.up();
    await tester.pump();
  });

  // ── 4. onAccept is called with the dropped data ───────────────────────────

  testWidgets('onAccept fires with correct data when dropped', (tester) async {
    String? accepted;
    await tester.pumpObers(
      Row(
        children: [
          const Draggable<String>(
            data: 'payload',
            feedback: Text('ghost'),
            child: SizedBox(
              key: Key('src'),
              width: 80,
              height: 80,
              child: Text('drag'),
            ),
          ),
          OiDropZone<String>(
            onAccept: (data) => accepted = data,
            builder: (context, state) =>
                const SizedBox(key: Key('zone'), width: 80, height: 80),
          ),
        ],
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const Key('src'))),
    );
    await gesture.moveBy(const Offset(100, 0));
    await tester.pump();
    await gesture.up();
    await tester.pump();

    expect(accepted, 'payload');
  });

  // ── 5. onWillAccept=false → rejected state ────────────────────────────────

  testWidgets('state is rejected when onWillAccept returns false', (
    tester,
  ) async {
    OiDropState? lastState;
    await tester.pumpObers(
      Row(
        children: [
          const Draggable<String>(
            data: 'hello',
            feedback: Text('ghost'),
            child: SizedBox(
              key: Key('src'),
              width: 80,
              height: 80,
              child: Text('drag'),
            ),
          ),
          OiDropZone<String>(
            onWillAccept: (_) => false,
            onAccept: (_) {},
            builder: (context, state) {
              lastState = state;
              return SizedBox(
                key: const Key('zone'),
                width: 80,
                height: 80,
                child: Text(state.name),
              );
            },
          ),
        ],
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const Key('src'))),
    );
    await gesture.moveBy(const Offset(100, 0));
    await tester.pump();

    expect(lastState, OiDropState.rejected);
    await gesture.up();
    await tester.pump();
  });

  // ── 6. OiDropState enum values ────────────────────────────────────────────

  test('OiDropState has expected values', () {
    expect(OiDropState.values, [
      OiDropState.idle,
      OiDropState.hovering,
      OiDropState.accepted,
      OiDropState.rejected,
    ]);
  });
}
