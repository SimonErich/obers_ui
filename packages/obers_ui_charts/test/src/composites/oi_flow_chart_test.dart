import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/src/composites/oi_flow_chart.dart';
import 'package:obers_ui_charts/src/models/oi_flow_series.dart';

import '../../helpers/pump_chart_app.dart';

class _FlowNode {
  _FlowNode(this.id, this.name);
  final String id;
  final String name;
}

class _FlowLink {
  _FlowLink(this.source, this.target, this.value);
  final String source;
  final String target;
  final double value;
}

void main() {
  group('OiFlowChart', () {
    testWidgets('renders with node/link data', (tester) async {
      final nodes = [_FlowNode('a', 'Source A'), _FlowNode('b', 'Target B')];
      final links = [_FlowLink('a', 'b', 100)];

      await tester.pumpChartApp(
        SizedBox(
          width: 400,
          height: 300,
          child: OiFlowChart<_FlowNode, _FlowLink>(
            label: 'Flow',
            series: OiFlowSeries<_FlowNode, _FlowLink>(
              id: 'flow',
              label: 'Flow',
              data: nodes,
              links: links,
              nodeIdMapper: (n) => n.id,
              nodeLabelMapper: (n) => n.name,
              sourceIdMapper: (l) => l.source,
              targetIdMapper: (l) => l.target,
              linkValueMapper: (l) => l.value,
            ),
            seriesBuilder: (context, viewport, series) {
              return const SizedBox(key: Key('flow-content'));
            },
          ),
        ),
      );

      expect(find.byKey(const Key('flow-content')), findsOneWidget);
    });

    testWidgets('empty data shows empty state', (tester) async {
      await tester.pumpChartApp(
        SizedBox(
          width: 400,
          height: 300,
          child: OiFlowChart<_FlowNode, _FlowLink>(
            label: 'Empty flow',
            series: OiFlowSeries<_FlowNode, _FlowLink>(
              id: 'flow',
              label: 'Flow',
              data: const [],
              links: const [],
              nodeIdMapper: (n) => n.id,
              nodeLabelMapper: (n) => n.name,
              sourceIdMapper: (l) => l.source,
              targetIdMapper: (l) => l.target,
              linkValueMapper: (l) => l.value,
            ),
          ),
        ),
      );

      expect(find.text('No data available'), findsOneWidget);
    });
  });
}
