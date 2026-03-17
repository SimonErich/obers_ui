// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/visualization/oi_treemap.dart';

import '../../../helpers/pump_app.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

const _nodes = [
  OiTreemapNode(key: 'a', label: 'Alpha', value: 50),
  OiTreemapNode(key: 'b', label: 'Beta', value: 30),
  OiTreemapNode(key: 'c', label: 'Gamma', value: 20),
];

Widget _treemap({
  List<OiTreemapNode> nodes = _nodes,
  String label = 'Test Treemap',
  bool showLabels = true,
  bool showValues = false,
  ValueChanged<OiTreemapNode>? onNodeTap,
}) {
  return SizedBox(
    width: 400,
    height: 300,
    child: OiTreemap(
      nodes: nodes,
      label: label,
      showLabels: showLabels,
      showValues: showValues,
      onNodeTap: onNodeTap,
    ),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // 1. Renders without errors.
  testWidgets('renders without errors', (tester) async {
    await tester.pumpObers(_treemap());
    expect(find.byType(OiTreemap), findsOneWidget);
  });

  // 2. Data displays correctly — node labels shown.
  testWidgets('displays node labels', (tester) async {
    await tester.pumpObers(_treemap());
    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('Beta'), findsOneWidget);
    expect(find.text('Gamma'), findsOneWidget);
  });

  // 3. Labels render with correct keys.
  testWidgets('node widgets have expected keys', (tester) async {
    await tester.pumpObers(_treemap());
    expect(find.byKey(const Key('oi_treemap_node_a')), findsOneWidget);
    expect(find.byKey(const Key('oi_treemap_node_b')), findsOneWidget);
    expect(find.byKey(const Key('oi_treemap_node_c')), findsOneWidget);
  });

  // 4. Custom colors applied.
  testWidgets('renders with custom node colors', (tester) async {
    await tester.pumpObers(
      _treemap(
        nodes: const [
          OiTreemapNode(
            key: 'x',
            label: 'X',
            value: 100,
            color: Color(0xFFE91E63),
          ),
        ],
      ),
    );
    expect(find.text('X'), findsOneWidget);
  });

  // 5. onNodeTap fires.
  testWidgets('onNodeTap fires with correct node', (tester) async {
    OiTreemapNode? tappedNode;
    await tester.pumpObers(_treemap(onNodeTap: (node) => tappedNode = node));
    await tester.tap(find.byKey(const Key('oi_treemap_node_b')));
    await tester.pump();
    expect(tappedNode?.label, 'Beta');
  });

  // 6. Empty data handles gracefully.
  testWidgets('handles empty nodes gracefully', (tester) async {
    await tester.pumpObers(_treemap(nodes: const []));
    expect(find.byType(OiTreemap), findsOneWidget);
    expect(find.byKey(const Key('oi_treemap_empty')), findsOneWidget);
  });

  // 7. Semantics label present.
  testWidgets('has semantics label', (tester) async {
    await tester.pumpObers(_treemap(label: 'Disk Usage'));
    final semantics = tester.getSemantics(find.byType(OiTreemap));
    expect(semantics.label, contains('Disk Usage'));
  });

  // 8. Size adapts to container.
  testWidgets('treemap fills available container width', (tester) async {
    await tester.pumpObers(_treemap());
    expect(find.byKey(const Key('oi_treemap')), findsOneWidget);
    final treemapSize = tester.getSize(find.byKey(const Key('oi_treemap')));
    // The treemap fills the LayoutBuilder width which is the full test surface.
    expect(treemapSize.width, greaterThan(0));
  });

  // 9. showValues displays numeric values.
  testWidgets('shows values when showValues is true', (tester) async {
    await tester.pumpObers(_treemap(showValues: true));
    expect(find.text('50'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);
    expect(find.text('20'), findsOneWidget);
  });

  // 10. showLabels false hides labels.
  testWidgets('hides labels when showLabels is false', (tester) async {
    await tester.pumpObers(_treemap(showLabels: false));
    expect(find.text('Alpha'), findsNothing);
    expect(find.text('Beta'), findsNothing);
  });

  // 11. onNodeTap null does not throw.
  testWidgets('tapping node without onNodeTap does not throw', (tester) async {
    await tester.pumpObers(_treemap());
    await tester.tap(find.byKey(const Key('oi_treemap_node_a')));
    await tester.pump();
    expect(find.byType(OiTreemap), findsOneWidget);
  });

  // 12. Hierarchical nodes with children.
  testWidgets('renders nodes with children without error', (tester) async {
    await tester.pumpObers(
      _treemap(
        nodes: const [
          OiTreemapNode(
            key: 'parent',
            label: 'Parent',
            value: 100,
            children: [
              OiTreemapNode(key: 'child1', label: 'Child 1', value: 60),
              OiTreemapNode(key: 'child2', label: 'Child 2', value: 40),
            ],
          ),
        ],
      ),
    );
    expect(find.text('Parent'), findsOneWidget);
  });
}
