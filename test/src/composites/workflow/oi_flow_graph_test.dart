// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/workflow/oi_flow_graph.dart';

import '../../../helpers/pump_app.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

const _nodes = [
  OiFlowNode(
    key: 'input',
    position: Offset(10, 50),
    label: 'Input',
    outputs: ['out'],
  ),
  OiFlowNode(
    key: 'process',
    position: Offset(200, 50),
    label: 'Process',
    inputs: ['in'],
    outputs: ['out'],
  ),
  OiFlowNode(
    key: 'output',
    position: Offset(400, 50),
    label: 'Output',
    inputs: ['in'],
  ),
];

const _edges = [
  OiFlowEdge(
    sourceNode: 'input',
    sourcePort: 'out',
    targetNode: 'process',
    targetPort: 'in',
  ),
  OiFlowEdge(
    sourceNode: 'process',
    sourcePort: 'out',
    targetNode: 'output',
    targetPort: 'in',
    label: 'result',
  ),
];

Widget _graph({
  List<OiFlowNode>? nodes,
  List<OiFlowEdge>? edges,
  Widget Function(OiFlowNode)? nodeBuilder,
  ValueChanged<OiFlowNode>? onNodeTap,
  void Function(OiFlowNode, Offset)? onNodeMove,
  void Function(String, String)? onEdgeCreate,
  ValueChanged<OiFlowEdge>? onEdgeDelete,
  bool editable = true,
  bool zoomable = true,
  bool pannable = true,
  bool snapToGrid = true,
  double gridSize = 20,
  double? width,
  double? height,
  String label = 'Test Flow Graph',
}) {
  return SizedBox(
    width: 700,
    height: 500,
    child: OiFlowGraph(
      nodes: nodes ?? _nodes,
      edges: edges ?? _edges,
      label: label,
      nodeBuilder: nodeBuilder,
      onNodeTap: onNodeTap,
      onNodeMove: onNodeMove,
      onEdgeCreate: onEdgeCreate,
      onEdgeDelete: onEdgeDelete,
      editable: editable,
      zoomable: zoomable,
      pannable: pannable,
      snapToGrid: snapToGrid,
      gridSize: gridSize,
      width: width ?? 600,
      height: height ?? 400,
    ),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // 1. Nodes render at positions with labels.
  testWidgets('renders node labels', (tester) async {
    await tester.pumpObers(_graph());
    expect(find.text('Input'), findsOneWidget);
    expect(find.text('Process'), findsOneWidget);
    expect(find.text('Output'), findsOneWidget);
  });

  // 2. Node widgets have expected keys.
  testWidgets('node widgets have expected keys', (tester) async {
    await tester.pumpObers(_graph());
    expect(find.byKey(const ValueKey('oi_flow_node_input')), findsOneWidget);
    expect(find.byKey(const ValueKey('oi_flow_node_process')), findsOneWidget);
    expect(find.byKey(const ValueKey('oi_flow_node_output')), findsOneWidget);
  });

  // 3. Edges connect nodes via CustomPaint.
  testWidgets('edges are drawn via CustomPaint', (tester) async {
    await tester.pumpObers(_graph());
    expect(find.byType(CustomPaint), findsWidgets);
  });

  // 4. onNodeTap fires with correct node.
  testWidgets('onNodeTap fires with correct node', (tester) async {
    OiFlowNode? tappedNode;
    await tester.pumpObers(_graph(onNodeTap: (node) => tappedNode = node));
    await tester.tap(find.text('Process'));
    await tester.pump();
    expect(tappedNode?.key, 'process');
  });

  // 5. onNodeTap fires for different nodes.
  testWidgets('onNodeTap fires for first node', (tester) async {
    OiFlowNode? tappedNode;
    await tester.pumpObers(_graph(onNodeTap: (node) => tappedNode = node));
    await tester.tap(find.text('Input'));
    await tester.pump();
    expect(tappedNode?.key, 'input');
  });

  // 6. Custom nodeBuilder renders.
  testWidgets('custom nodeBuilder renders custom widgets', (tester) async {
    await tester.pumpObers(
      _graph(
        nodeBuilder: (node) => Container(
          key: ValueKey('custom_${node.key}'),
          child: Text('Custom: ${node.label}'),
        ),
      ),
    );
    expect(find.byKey(const ValueKey('custom_input')), findsOneWidget);
    expect(find.text('Custom: Input'), findsOneWidget);
    expect(find.text('Custom: Process'), findsOneWidget);
  });

  // 7. Grid renders when snapToGrid is true.
  testWidgets('grid is rendered when snapToGrid is true', (tester) async {
    await tester.pumpObers(_graph());
    expect(find.byKey(const ValueKey('oi_flow_graph_grid')), findsOneWidget);
  });

  // 8. Grid not rendered when snapToGrid is false.
  testWidgets('grid is not rendered when snapToGrid is false', (tester) async {
    await tester.pumpObers(_graph(snapToGrid: false));
    expect(find.byKey(const ValueKey('oi_flow_graph_grid')), findsNothing);
  });

  // 9. Semantics label is applied.
  testWidgets('semantics label is applied to flow graph', (tester) async {
    await tester.pumpObers(_graph(label: 'My Workflow'));
    expect(
      find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'My Workflow',
      ),
      findsOneWidget,
    );
  });

  // 10. editable=false prevents onNodeMove from being wired.
  testWidgets('editable=false does not wire onNodeMove', (tester) async {
    var moved = false;
    await tester.pumpObers(
      _graph(editable: false, onNodeMove: (_, _) => moved = true),
    );
    // Attempt to drag a node.
    await tester.drag(find.text('Input'), const Offset(50, 0));
    await tester.pump();
    expect(moved, isFalse);
  });

  // 11. Empty nodes list renders without errors.
  testWidgets('empty nodes list renders without errors', (tester) async {
    await tester.pumpObers(_graph(nodes: const [], edges: const []));
    expect(find.byType(SizedBox), findsWidgets);
  });

  // 12. Node with icon renders the icon.
  testWidgets('node with icon renders the icon', (tester) async {
    const iconNodes = [
      OiFlowNode(
        key: 'withIcon',
        position: Offset(10, 10),
        label: 'With Icon',
        icon: IconData(0xe87c, fontFamily: 'MaterialIcons'), // home
      ),
    ];
    await tester.pumpObers(_graph(nodes: iconNodes, edges: const []));
    expect(
      find.byIcon(const IconData(0xe87c, fontFamily: 'MaterialIcons')),
      findsOneWidget,
    );
  });

  // 13. Node with custom color uses it.
  testWidgets('node with custom color applies it', (tester) async {
    const colorNodes = [
      OiFlowNode(
        key: 'colored',
        position: Offset(10, 10),
        label: 'Colored',
        color: Color(0xFFFF0000),
      ),
    ];
    await tester.pumpObers(_graph(nodes: colorNodes, edges: const []));
    // Find the inner Container that holds the default node rendering.
    // The container is inside the SizedBox keyed with the node key.
    final containers = tester.widgetList<Container>(
      find.descendant(
        of: find.byKey(const ValueKey('oi_flow_node_colored')),
        matching: find.byType(Container),
      ),
    );
    final decoratedContainer = containers.where((c) {
      final dec = c.decoration;
      if (dec is BoxDecoration) return dec.color == const Color(0xFFFF0000);
      return false;
    });
    expect(decoratedContainer, isNotEmpty);
  });

  // 14. Port indicators render for inputs and outputs.
  testWidgets('port indicators render for node inputs and outputs', (
    tester,
  ) async {
    await tester.pumpObers(_graph());
    // Input node has 1 output port.
    expect(
      find.byKey(const ValueKey('oi_flow_port_out_input_out')),
      findsOneWidget,
    );
    // Process node has 1 input and 1 output port.
    expect(
      find.byKey(const ValueKey('oi_flow_port_in_process_in')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('oi_flow_port_out_process_out')),
      findsOneWidget,
    );
    // Output node has 1 input port.
    expect(
      find.byKey(const ValueKey('oi_flow_port_in_output_in')),
      findsOneWidget,
    );
  });

  // 15. Custom dimensions are applied.
  testWidgets('custom width and height are applied', (tester) async {
    await tester.pumpObers(_graph(width: 300, height: 200));
    final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
    final graphBox = sizedBoxes.where(
      (sb) => sb.width == 300 && sb.height == 200,
    );
    expect(graphBox, isNotEmpty);
  });

  // 16. No onNodeTap means tapping does not throw.
  testWidgets('tapping node without onNodeTap does not throw', (tester) async {
    await tester.pumpObers(_graph());
    await tester.tap(find.text('Input'));
    await tester.pump();
    // No exception means success.
  });

  // 17. Edge with label is accepted.
  testWidgets('edge with label renders without error', (tester) async {
    await tester.pumpObers(_graph());
    // The second edge has label 'result'; painted on canvas.
    expect(find.byType(CustomPaint), findsWidgets);
  });

  // 18. Animated edge flag is accepted without error.
  testWidgets('animated edge flag does not cause errors', (tester) async {
    const animatedEdges = [
      OiFlowEdge(
        sourceNode: 'input',
        sourcePort: 'out',
        targetNode: 'process',
        targetPort: 'in',
        animated: true,
      ),
    ];
    await tester.pumpObers(_graph(edges: animatedEdges));
    expect(find.byType(CustomPaint), findsWidgets);
  });

  // 19. Grid size is configurable.
  testWidgets('custom gridSize is accepted', (tester) async {
    await tester.pumpObers(_graph(gridSize: 40));
    expect(find.byKey(const ValueKey('oi_flow_graph_grid')), findsOneWidget);
  });

  // 20. Node data field is preserved.
  testWidgets('node data field is accessible via the node', (tester) async {
    OiFlowNode? tappedNode;
    const dataNodes = [
      OiFlowNode(
        key: 'dataNode',
        position: Offset(10, 10),
        label: 'Data',
        data: {'type': 'transform'},
      ),
    ];
    await tester.pumpObers(
      _graph(
        nodes: dataNodes,
        edges: const [],
        onNodeTap: (node) => tappedNode = node,
      ),
    );
    await tester.tap(find.text('Data'));
    await tester.pump();
    expect(tappedNode?.data, {'type': 'transform'});
  });
}
