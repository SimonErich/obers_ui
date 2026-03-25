import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/src/composites/oi_hierarchical_chart.dart';
import 'package:obers_ui_charts/src/models/oi_hierarchical_series.dart';

import '../../helpers/pump_chart_app.dart';

class _OrgNode {
  _OrgNode(this.id, this.parentId, this.name, this.headcount);
  final String id;
  final String? parentId;
  final String name;
  final int headcount;
}

void main() {
  group('OiHierarchicalChart', () {
    testWidgets('builds tree from flat list and aggregates leaf values', (
      tester,
    ) async {
      final data = [
        _OrgNode('root', null, 'Company', 0),
        _OrgNode('eng', 'root', 'Engineering', 50),
        _OrgNode('sales', 'root', 'Sales', 30),
        _OrgNode('frontend', 'eng', 'Frontend', 20),
        _OrgNode('backend', 'eng', 'Backend', 30),
      ];

      List<OiHierarchyNode<_OrgNode>>? builtRoots;

      await tester.pumpChartApp(
        SizedBox(
          width: 400,
          height: 300,
          child: OiHierarchicalChart<_OrgNode>(
            label: 'Org chart',
            series: OiHierarchicalSeries<_OrgNode>(
              id: 'org',
              label: 'Organization',
              data: data,
              nodeIdMapper: (n) => n.id,
              parentIdMapper: (n) => n.parentId,
              valueMapper: (n) => n.headcount,
              nodeLabelMapper: (n) => n.name,
            ),
            seriesBuilder: (context, viewport, roots) {
              builtRoots = roots;
              return const SizedBox(key: Key('tree-content'));
            },
          ),
        ),
      );

      expect(find.byKey(const Key('tree-content')), findsOneWidget);
      expect(builtRoots, isNotNull);
      expect(builtRoots!.length, 1); // Single root
      expect(builtRoots!.first.id, 'root');
      expect(builtRoots!.first.children.length, 2); // eng, sales
      expect(builtRoots!.first.depth, 0);

      final eng = builtRoots!.first.children.firstWhere((c) => c.id == 'eng');
      expect(eng.depth, 1);
      expect(eng.children.length, 2); // frontend, backend

      // Aggregated value: eng's children sum = 20 + 30 = 50
      expect(eng.aggregatedValue, 50);

      // Root aggregated: eng(50) + sales(30) = 80
      // But root's own value is 0, and it has children, so aggregated = sum of children
      expect(builtRoots!.first.aggregatedValue, 80);
    });

    testWidgets('empty data shows empty state', (tester) async {
      await tester.pumpChartApp(
        SizedBox(
          width: 400,
          height: 300,
          child: OiHierarchicalChart<_OrgNode>(
            label: 'Empty tree',
            series: OiHierarchicalSeries<_OrgNode>(
              id: 'org',
              label: 'Organization',
              data: const [],
              nodeIdMapper: (n) => n.id,
              parentIdMapper: (n) => n.parentId,
              valueMapper: (n) => n.headcount,
              nodeLabelMapper: (n) => n.name,
            ),
          ),
        ),
      );

      expect(find.text('No data available'), findsOneWidget);
    });
  });
}
