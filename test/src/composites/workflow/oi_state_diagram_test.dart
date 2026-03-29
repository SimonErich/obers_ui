// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/workflow/oi_state_diagram.dart';

import '../../../helpers/pump_app.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

const _states = [
  OiStateNode(key: 'idle', label: 'Idle', position: Offset(10, 100)),
  OiStateNode(key: 'loading', label: 'Loading', position: Offset(180, 100)),
  OiStateNode(key: 'done', label: 'Done', position: Offset(350, 100)),
];

const _transitions = [
  OiStateTransition(from: 'idle', to: 'loading', label: 'fetch'),
  OiStateTransition(from: 'loading', to: 'done', label: 'success'),
];

Widget _diagram({
  List<OiStateNode>? states,
  List<OiStateTransition>? transitions,
  Object? currentState,
  bool editable = false,
  ValueChanged<Object>? onStateSelect,
  double? width,
  double? height,
  String label = 'Test Diagram',
}) {
  return SizedBox(
    width: 600,
    height: 400,
    child: OiStateDiagram(
      states: states ?? _states,
      transitions: transitions ?? _transitions,
      label: label,
      currentState: currentState,
      editable: editable,
      onStateSelect: onStateSelect,
      width: width ?? 500,
      height: height ?? 300,
    ),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // 1. States render at positions.
  testWidgets('renders state labels', (tester) async {
    await tester.pumpObers(_diagram());
    expect(find.text('Idle'), findsOneWidget);
    expect(find.text('Loading'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
  });

  // 2. State nodes have expected keys.
  testWidgets('state nodes have expected keys', (tester) async {
    await tester.pumpObers(_diagram());
    expect(find.byKey(const ValueKey('oi_state_node_idle')), findsOneWidget);
    expect(find.byKey(const ValueKey('oi_state_node_loading')), findsOneWidget);
    expect(find.byKey(const ValueKey('oi_state_node_done')), findsOneWidget);
  });

  // 3. Transitions drawn via CustomPaint.
  testWidgets('transitions are drawn via CustomPaint', (tester) async {
    await tester.pumpObers(_diagram());
    // The CustomPaint layer for transitions should exist.
    expect(find.byType(CustomPaint), findsWidgets);
  });

  // 4. Current state is highlighted.
  testWidgets('current state node gets highlighted border', (tester) async {
    await tester.pumpObers(_diagram(currentState: 'loading'));
    // The node container for 'loading' should have a wider border.
    final container = tester.widget<Container>(
      find.byKey(const ValueKey('oi_state_node_loading')),
    );
    final decoration = container.decoration! as BoxDecoration;
    final border = decoration.border! as Border;
    // Current state has 3.0 border width.
    expect(border.top.width, 3.0);
  });

  // 5. Non-current state has thinner border.
  testWidgets('non-current state node has thinner border', (tester) async {
    await tester.pumpObers(_diagram(currentState: 'loading'));
    final container = tester.widget<Container>(
      find.byKey(const ValueKey('oi_state_node_idle')),
    );
    final decoration = container.decoration! as BoxDecoration;
    final border = decoration.border! as Border;
    expect(border.top.width, 1.5);
  });

  // 6. Initial state has incoming marker.
  testWidgets('initial state shows incoming marker', (tester) async {
    const initialStates = [
      OiStateNode(
        key: 'start',
        label: 'Start',
        position: Offset(10, 50),
        initial: true,
      ),
    ];
    await tester.pumpObers(
      _diagram(states: initialStates, transitions: const []),
    );
    expect(
      find.byKey(const ValueKey('oi_state_initial_marker')),
      findsOneWidget,
    );
  });

  // 7. Final state has double border.
  testWidgets('final state has double border container', (tester) async {
    const finalStates = [
      OiStateNode(
        key: 'end',
        label: 'End',
        position: Offset(10, 50),
        terminal: true,
      ),
    ];
    await tester.pumpObers(
      _diagram(states: finalStates, transitions: const []),
    );
    expect(find.byKey(const ValueKey('oi_state_final_end')), findsOneWidget);
  });

  // 8. onStateSelect fires when a state is tapped.
  testWidgets('onStateSelect fires with correct key', (tester) async {
    Object? selectedKey;
    await tester.pumpObers(_diagram(onStateSelect: (key) => selectedKey = key));
    await tester.tap(find.text('Loading'));
    await tester.pump();
    expect(selectedKey, 'loading');
  });

  // 9. onStateSelect fires for different states.
  testWidgets('onStateSelect fires for first state', (tester) async {
    Object? selectedKey;
    await tester.pumpObers(_diagram(onStateSelect: (key) => selectedKey = key));
    await tester.tap(find.text('Idle'));
    await tester.pump();
    expect(selectedKey, 'idle');
  });

  // 10. Labels render on transitions (via CustomPaint, verified indirectly).
  testWidgets('transition labels are provided to painter', (tester) async {
    // We verify the transitions are configured with labels; the painter
    // renders them on the canvas which is hard to assert in widget tests.
    await tester.pumpObers(_diagram());
    // No exception thrown means transitions with labels are handled.
    expect(find.byType(CustomPaint), findsWidgets);
  });

  // 11. Semantics label is applied.
  testWidgets('semantics label is applied to diagram', (tester) async {
    await tester.pumpObers(_diagram(label: 'State Machine'));
    expect(
      find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'State Machine',
      ),
      findsOneWidget,
    );
  });

  // 12. Empty states list renders without errors.
  testWidgets('empty states list renders without errors', (tester) async {
    await tester.pumpObers(_diagram(states: const [], transitions: const []));
    expect(find.byType(SizedBox), findsWidgets);
  });

  // 13. Custom width and height are applied.
  testWidgets('custom width and height are applied', (tester) async {
    await tester.pumpObers(_diagram(width: 300, height: 200));
    final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
    final diagramBox = sizedBoxes.where(
      (sb) => sb.width == 300 && sb.height == 200,
    );
    expect(diagramBox, isNotEmpty);
  });

  // 14. State with custom color uses that color.
  testWidgets('state with custom color uses it for background', (tester) async {
    const customStates = [
      OiStateNode(
        key: 'custom',
        label: 'Custom',
        position: Offset(10, 50),
        color: Color(0xFFFF0000),
      ),
    ];
    await tester.pumpObers(
      _diagram(states: customStates, transitions: const []),
    );
    final container = tester.widget<Container>(
      find.byKey(const ValueKey('oi_state_node_custom')),
    );
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, const Color(0xFFFF0000));
  });

  // 15. Transition with custom color is accepted.
  testWidgets('transition with custom color renders without error', (
    tester,
  ) async {
    const customTransitions = [
      OiStateTransition(from: 'idle', to: 'loading', color: Color(0xFF00FF00)),
    ];
    await tester.pumpObers(_diagram(transitions: customTransitions));
    expect(find.byType(CustomPaint), findsWidgets);
  });

  // 16. No onStateSelect means tapping does not throw.
  testWidgets('tapping state without onStateSelect does not throw', (
    tester,
  ) async {
    await tester.pumpObers(_diagram());
    await tester.tap(find.text('Idle'));
    await tester.pump();
    // No exception means success.
  });

  // 17. Both initial and final on same node.
  testWidgets('node that is both initial and final renders both markers', (
    tester,
  ) async {
    const bothStates = [
      OiStateNode(
        key: 'both',
        label: 'Both',
        position: Offset(30, 50),
        initial: true,
        terminal: true,
      ),
    ];
    await tester.pumpObers(_diagram(states: bothStates, transitions: const []));
    expect(
      find.byKey(const ValueKey('oi_state_initial_marker')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('oi_state_final_both')), findsOneWidget);
  });
}
