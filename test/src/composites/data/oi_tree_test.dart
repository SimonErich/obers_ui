// Tests do not require documentation comments.

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/data/oi_tree.dart';

import '../../../helpers/pump_app.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

final _nodes = <OiTreeNode<String>>[
  const OiTreeNode(
    id: 'root1',
    label: 'Root 1',
    children: [
      OiTreeNode(id: 'child1', label: 'Child 1'),
      OiTreeNode(
        id: 'child2',
        label: 'Child 2',
        children: [OiTreeNode(id: 'grandchild1', label: 'Grandchild 1')],
      ),
    ],
  ),
  const OiTreeNode(id: 'root2', label: 'Root 2'),
];

Widget _tree({
  String label = 'Test tree',
  List<OiTreeNode<String>>? nodes,
  OiTreeController? controller,
  bool selectable = false,
  bool multiSelect = false,
  void Function(OiTreeNode<String>)? onNodeTap,
  void Function(OiTreeNode<String>)? onNodeDoubleTap,
  void Function(OiTreeNode<String>, {required bool expanded})?
  onExpansionChanged,
  void Function(Set<String>)? onSelectionChanged,
  Widget Function(
    BuildContext,
    OiTreeNode<String>,
    int, {
    required bool expanded,
    required bool selected,
  })?
  nodeBuilder,
  double indentWidth = 24,
  double rowHeight = 40,
  bool showLines = false,
}) {
  return SizedBox(
    width: 400,
    height: 600,
    child: OiTree<String>(
      label: label,
      nodes: nodes ?? _nodes,
      controller: controller,
      selectable: selectable,
      multiSelect: multiSelect,
      onNodeTap: onNodeTap,
      onNodeDoubleTap: onNodeDoubleTap,
      onExpansionChanged: onExpansionChanged,
      onSelectionChanged: onSelectionChanged,
      nodeBuilder: nodeBuilder,
      indentWidth: indentWidth,
      rowHeight: rowHeight,
      showLines: showLines,
    ),
  );
}

/// Tap and pump past the double-tap timeout so the single-tap resolves.
Future<void> _tapAndSettle(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pump(kDoubleTapTimeout + const Duration(milliseconds: 50));
}

void main() {
  group('OiTree', () {
    // ════════════════════════════════════════════════════════════════════════
    // ── Accessibility / Label tests (REQ-0022) ────────────────────────────
    // ════════════════════════════════════════════════════════════════════════

    // 1. Semantics label is set from the label prop
    testWidgets('Semantics label is set from label prop', (tester) async {
      await tester.pumpObers(_tree(label: 'File browser'));
      final semantics = tester.widget<Semantics>(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'File browser',
        ),
      );
      expect(semantics.properties.label, 'File browser');
    });

    // 2. Semantics has explicitChildNodes enabled
    testWidgets('Semantics has explicitChildNodes enabled', (tester) async {
      await tester.pumpObers(_tree());
      final semantics = tester.widget<Semantics>(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Test tree',
        ),
      );
      expect(semantics.explicitChildNodes, isTrue);
    });

    // 3. Changing label prop updates Semantics
    testWidgets('changing label updates Semantics', (tester) async {
      await tester.pumpObers(_tree(label: 'First label'));
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'First label',
        ),
        findsOneWidget,
      );

      await tester.pumpObers(_tree(label: 'Second label'));
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Second label',
        ),
        findsOneWidget,
      );
    });

    // ════════════════════════════════════════════════════════════════════════
    // ── Rendering tests ───────────────────────────────────────────────────
    // ════════════════════════════════════════════════════════════════════════

    // 4. Root nodes are rendered
    testWidgets('renders root nodes', (tester) async {
      await tester.pumpObers(_tree());
      expect(find.text('Root 1'), findsOneWidget);
      expect(find.text('Root 2'), findsOneWidget);
    });

    // 5. Children are hidden by default (collapsed)
    testWidgets('children are hidden when collapsed', (tester) async {
      await tester.pumpObers(_tree());
      expect(find.text('Child 1'), findsNothing);
      expect(find.text('Child 2'), findsNothing);
    });

    // 6. Tapping expand toggle shows children
    testWidgets('tapping expand toggle shows children', (tester) async {
      await tester.pumpObers(_tree());
      await _tapAndSettle(tester, find.byKey(const ValueKey('toggle_root1')));
      expect(find.text('Child 1'), findsOneWidget);
      expect(find.text('Child 2'), findsOneWidget);
    });

    // 7. Tapping expand toggle again collapses children
    testWidgets('tapping expand toggle again collapses children', (
      tester,
    ) async {
      await tester.pumpObers(_tree());
      await _tapAndSettle(tester, find.byKey(const ValueKey('toggle_root1')));
      expect(find.text('Child 1'), findsOneWidget);

      await _tapAndSettle(tester, find.byKey(const ValueKey('toggle_root1')));
      expect(find.text('Child 1'), findsNothing);
    });

    // 8. Expanding nested children
    testWidgets('expanding nested children works', (tester) async {
      await tester.pumpObers(_tree());
      await _tapAndSettle(tester, find.byKey(const ValueKey('toggle_root1')));
      await _tapAndSettle(tester, find.byKey(const ValueKey('toggle_child2')));
      expect(find.text('Grandchild 1'), findsOneWidget);
    });

    // ════════════════════════════════════════════════════════════════════════
    // ── Controller tests ──────────────────────────────────────────────────
    // ════════════════════════════════════════════════════════════════════════

    // 9. External controller expands nodes
    testWidgets('external controller can expand nodes', (tester) async {
      final ctrl = OiTreeController();
      addTearDown(ctrl.dispose);
      await tester.pumpObers(_tree(controller: ctrl));
      expect(find.text('Child 1'), findsNothing);

      ctrl.expand('root1');
      await tester.pump();
      expect(find.text('Child 1'), findsOneWidget);
    });

    // 10. External controller collapses nodes
    testWidgets('external controller can collapse nodes', (tester) async {
      final ctrl = OiTreeController();
      addTearDown(ctrl.dispose);
      ctrl.expand('root1');
      await tester.pumpObers(_tree(controller: ctrl));
      expect(find.text('Child 1'), findsOneWidget);

      ctrl.collapse('root1');
      await tester.pump();
      expect(find.text('Child 1'), findsNothing);
    });

    // ════════════════════════════════════════════════════════════════════════
    // ── Selection tests ───────────────────────────────────────────────────
    // ════════════════════════════════════════════════════════════════════════

    // 11. Tapping node fires onNodeTap
    testWidgets('tapping node fires onNodeTap', (tester) async {
      OiTreeNode<String>? tappedNode;
      await tester.pumpObers(_tree(onNodeTap: (n) => tappedNode = n));
      await _tapAndSettle(tester, find.text('Root 2'));
      expect(tappedNode?.id, 'root2');
    });

    // 12. Single selection works
    testWidgets('single selection works when selectable', (tester) async {
      Set<String>? selected;
      await tester.pumpObers(
        _tree(selectable: true, onSelectionChanged: (ids) => selected = ids),
      );
      await _tapAndSettle(tester, find.text('Root 1'));
      expect(selected, {'root1'});

      await _tapAndSettle(tester, find.text('Root 2'));
      expect(selected, {'root2'});
    });

    // 13. onExpansionChanged callback fires
    testWidgets('onExpansionChanged fires on expand/collapse', (tester) async {
      final events = <(String, bool)>[];
      await tester.pumpObers(
        _tree(
          onExpansionChanged: (node, {required expanded}) {
            events.add((node.id, expanded));
          },
        ),
      );
      await _tapAndSettle(tester, find.byKey(const ValueKey('toggle_root1')));
      expect(events, [('root1', true)]);

      await _tapAndSettle(tester, find.byKey(const ValueKey('toggle_root1')));
      expect(events, [('root1', true), ('root1', false)]);
    });

    // 14. Leaf nodes do not show expand toggle
    testWidgets('leaf nodes do not show expand toggle', (tester) async {
      await tester.pumpObers(_tree());
      expect(find.byKey(const ValueKey('toggle_root2')), findsNothing);
    });

    // 15. Double tap fires onNodeDoubleTap
    testWidgets('double tap fires onNodeDoubleTap', (tester) async {
      OiTreeNode<String>? doubleTapped;
      await tester.pumpObers(_tree(onNodeDoubleTap: (n) => doubleTapped = n));
      final nodeFinder = find.byKey(const ValueKey('node_root2'));
      await tester.tap(nodeFinder);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(nodeFinder);
      await tester.pumpAndSettle();
      expect(doubleTapped?.id, 'root2');
    });
  });
}
