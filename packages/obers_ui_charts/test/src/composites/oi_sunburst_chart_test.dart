import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

import '../../helpers/pump_chart_app.dart';

// Simple data model for sunburst nodes.
class _SbItem {
  const _SbItem({
    required this.id,
    required this.label,
    required this.value,
    this.parentId,
  });

  final String id;
  final String label;
  final double value;
  final String? parentId;
}

void main() {
  group('OiSunburstChart', () {
    // Flat node list that forms a parent-child hierarchy:
    //   root → child-a, child-b
    //   child-a → leaf-a1, leaf-a2
    final sampleData = [
      const _SbItem(id: 'root', label: 'Root', value: 0),
      const _SbItem(
        id: 'child-a',
        label: 'Child A',
        value: 0,
        parentId: 'root',
      ),
      const _SbItem(
        id: 'child-b',
        label: 'Child B',
        value: 40,
        parentId: 'root',
      ),
      const _SbItem(
        id: 'leaf-a1',
        label: 'Leaf A1',
        value: 30,
        parentId: 'child-a',
      ),
      const _SbItem(
        id: 'leaf-a2',
        label: 'Leaf A2',
        value: 20,
        parentId: 'child-a',
      ),
    ];

    testWidgets('renders with flat node list (parent-child hierarchy)', (
      tester,
    ) async {
      await tester.pumpChartApp(
        SizedBox(
          width: 300,
          height: 300,
          child: OiSunburstChart<_SbItem>(
            label: 'Sunburst Chart',
            data: sampleData,
            nodeId: (item) => item.id,
            parentId: (item) => item.parentId,
            value: (item) => item.value,
            nodeLabel: (item) => item.label,
          ),
        ),
        surfaceSize: const Size(400, 400),
      );

      expect(find.byKey(const Key('oi_sunburst_chart')), findsOneWidget);
      expect(
        find.byKey(const Key('oi_sunburst_chart_painter')),
        findsOneWidget,
      );
    });

    testWidgets('empty data shows empty state', (tester) async {
      await tester.pumpChartApp(
        const SizedBox(
          width: 300,
          height: 300,
          child: OiSunburstChart<_SbItem>(
            label: 'Empty Sunburst Chart',
            data: [],
            nodeId: _sbNodeId,
            parentId: _sbParentId,
            value: _sbValue,
            nodeLabel: _sbLabel,
          ),
        ),
        surfaceSize: const Size(400, 400),
      );

      expect(find.byKey(const Key('oi_sunburst_chart_empty')), findsOneWidget);
    });

    testWidgets('center content renders when provided', (tester) async {
      const centerKey = Key('center_content');

      await tester.pumpChartApp(
        SizedBox(
          width: 300,
          height: 300,
          child: OiSunburstChart<_SbItem>(
            label: 'Sunburst With Center',
            data: sampleData,
            nodeId: (item) => item.id,
            parentId: (item) => item.parentId,
            value: (item) => item.value,
            nodeLabel: (item) => item.label,
            centerContent: const SizedBox(
              key: centerKey,
              width: 40,
              height: 40,
            ),
          ),
        ),
        surfaceSize: const Size(400, 400),
      );

      expect(find.byKey(centerKey), findsOneWidget);
    });
  });
}

// Top-level helpers required for const constructor.
String _sbNodeId(_SbItem item) => item.id;
String? _sbParentId(_SbItem item) => item.parentId;
double _sbValue(_SbItem item) => item.value;
String _sbLabel(_SbItem item) => item.label;
