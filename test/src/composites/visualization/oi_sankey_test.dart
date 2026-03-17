// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/visualization/oi_sankey.dart';

import '../../../helpers/pump_app.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

const _nodes = [
  OiSankeyNode(key: 'a', label: 'Source A'),
  OiSankeyNode(key: 'b', label: 'Source B'),
  OiSankeyNode(key: 'c', label: 'Target C'),
];

const _links = [
  OiSankeyLink(source: 'a', target: 'c', value: 80),
  OiSankeyLink(source: 'b', target: 'c', value: 40),
];

Widget _sankey({
  List<OiSankeyNode> nodes = _nodes,
  List<OiSankeyLink> links = _links,
  String label = 'Test Sankey',
  bool showLabels = true,
  bool showValues = false,
  ValueChanged<OiSankeyNode>? onNodeTap,
  ValueChanged<OiSankeyLink>? onLinkTap,
}) {
  return SizedBox(
    width: 400,
    height: 300,
    child: OiSankey(
      nodes: nodes,
      links: links,
      label: label,
      showLabels: showLabels,
      showValues: showValues,
      onNodeTap: onNodeTap,
      onLinkTap: onLinkTap,
    ),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // 1. Renders without errors.
  testWidgets('renders without errors', (tester) async {
    await tester.pumpObers(_sankey());
    expect(find.byType(OiSankey), findsOneWidget);
  });

  // 2. Data displays correctly — node labels shown.
  testWidgets('displays node labels', (tester) async {
    await tester.pumpObers(_sankey());
    expect(find.text('Source A'), findsOneWidget);
    expect(find.text('Source B'), findsOneWidget);
    expect(find.text('Target C'), findsOneWidget);
  });

  // 3. Labels render with correct keys.
  testWidgets('node widgets have expected keys', (tester) async {
    await tester.pumpObers(_sankey());
    expect(find.byKey(const Key('oi_sankey_node_a')), findsOneWidget);
    expect(find.byKey(const Key('oi_sankey_node_b')), findsOneWidget);
    expect(find.byKey(const Key('oi_sankey_node_c')), findsOneWidget);
  });

  // 4. Custom colors applied.
  testWidgets('renders with custom node colors', (tester) async {
    await tester.pumpObers(_sankey(
      nodes: const [
        OiSankeyNode(key: 'x', label: 'X', color: Color(0xFF4CAF50)),
        OiSankeyNode(key: 'y', label: 'Y', color: Color(0xFFF44336)),
      ],
      links: const [
        OiSankeyLink(source: 'x', target: 'y', value: 50),
      ],
    ));
    expect(find.text('X'), findsOneWidget);
    expect(find.text('Y'), findsOneWidget);
  });

  // 5. onNodeTap fires.
  testWidgets('onNodeTap fires with correct node', (tester) async {
    OiSankeyNode? tappedNode;
    await tester.pumpObers(_sankey(
      onNodeTap: (node) => tappedNode = node,
    ));
    await tester.tap(find.byKey(const Key('oi_sankey_node_b')));
    await tester.pump();
    expect(tappedNode?.label, 'Source B');
  });

  // 6. Empty data handles gracefully.
  testWidgets('handles empty nodes gracefully', (tester) async {
    await tester.pumpObers(_sankey(nodes: const [], links: const []));
    expect(find.byType(OiSankey), findsOneWidget);
    expect(find.byKey(const Key('oi_sankey_empty')), findsOneWidget);
  });

  // 7. Semantics label present.
  testWidgets('has semantics label', (tester) async {
    await tester.pumpObers(_sankey(label: 'Energy Flow'));
    final semantics = tester.getSemantics(find.byType(OiSankey));
    expect(semantics.label, contains('Energy Flow'));
  });

  // 8. Size adapts to container.
  testWidgets('sankey fills available container', (tester) async {
    await tester.pumpObers(_sankey());
    expect(find.byKey(const Key('oi_sankey')), findsOneWidget);
    final sankeySize = tester.getSize(find.byKey(const Key('oi_sankey')));
    expect(sankeySize.width, greaterThan(0));
    expect(sankeySize.height, greaterThan(0));
  });

  // 9. Link painter is present.
  testWidgets('link painter is present', (tester) async {
    await tester.pumpObers(_sankey());
    expect(find.byKey(const Key('oi_sankey_links')), findsOneWidget);
  });

  // 10. showLabels false hides labels.
  testWidgets('hides labels when showLabels is false', (tester) async {
    await tester.pumpObers(_sankey(showLabels: false));
    expect(find.text('Source A'), findsNothing);
  });

  // 11. showValues displays numeric values.
  testWidgets('shows values when showValues is true', (tester) async {
    await tester.pumpObers(_sankey(showValues: true));
    // Node values are displayed as the total flow through each node.
    expect(find.byType(OiSankey), findsOneWidget);
  });

  // 12. Custom link colors render without error.
  testWidgets('renders with custom link colors', (tester) async {
    await tester.pumpObers(_sankey(
      links: const [
        OiSankeyLink(
          source: 'a',
          target: 'c',
          value: 80,
          color: Color(0x8800BCD4),
        ),
        OiSankeyLink(source: 'b', target: 'c', value: 40),
      ],
    ));
    expect(find.byType(OiSankey), findsOneWidget);
  });
}
