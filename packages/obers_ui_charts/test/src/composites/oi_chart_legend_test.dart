import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

import '../../helpers/pump_chart_app.dart';

void main() {
  const redItem = OiChartLegendItem(
    id: 'revenue',
    label: 'Revenue',
    color: Color(0xFFFF0000),
  );
  const blueItem = OiChartLegendItem(
    id: 'cost',
    label: 'Cost',
    color: Color(0xFF0000FF),
  );
  const hiddenItem = OiChartLegendItem(
    id: 'profit',
    label: 'Profit',
    color: Color(0xFF00FF00),
    visible: false,
  );

  group('OiChartLegend', () {
    testWidgets('renders all series items with correct labels', (
      WidgetTester tester,
    ) async {
      await tester.pumpChartApp(
        const OiChartLegend(items: [redItem, blueItem, hiddenItem]),
      );

      expect(find.text('Revenue'), findsOneWidget);
      expect(find.text('Cost'), findsOneWidget);
      expect(find.text('Profit'), findsOneWidget);
    });

    testWidgets('tapping a legend item fires onToggle callback', (
      WidgetTester tester,
    ) async {
      String? toggledId;

      await tester.pumpChartApp(
        OiChartLegend(
          items: const [redItem, blueItem],
          onToggle: (id) => toggledId = id,
        ),
      );

      await tester.tap(find.text('Revenue'));
      await tester.pump();

      expect(toggledId, equals('revenue'));
    });

    testWidgets('tapping second item fires onToggle with correct id', (
      WidgetTester tester,
    ) async {
      String? toggledId;

      await tester.pumpChartApp(
        OiChartLegend(
          items: const [redItem, blueItem],
          onToggle: (id) => toggledId = id,
        ),
      );

      await tester.tap(find.text('Cost'));
      await tester.pump();

      expect(toggledId, equals('cost'));
    });

    testWidgets('hidden series items have reduced opacity (0.4)', (
      WidgetTester tester,
    ) async {
      await tester.pumpChartApp(
        const OiChartLegend(items: [redItem, hiddenItem]),
      );

      // The hidden item is wrapped in an Opacity widget with 0.4 opacity.
      // Find the Opacity widget whose child contains the 'Profit' text.
      final opacityWidgets = tester.widgetList<Opacity>(find.byType(Opacity));
      final opacityValues = opacityWidgets.map((o) => o.opacity).toList();

      // At least one Opacity with 0.4 (hidden item) and one with 1.0 (visible item).
      expect(opacityValues, containsAll(<double>[0.4, 1]));
    });

    testWidgets('visible item has full opacity (1.0)', (
      WidgetTester tester,
    ) async {
      await tester.pumpChartApp(const OiChartLegend(items: [redItem]));

      final opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, equals(1.0));
    });

    testWidgets('custom itemBuilder replaces default rendering', (
      WidgetTester tester,
    ) async {
      const customKey = Key('custom_legend_item');
      var builderCallCount = 0;

      await tester.pumpChartApp(
        OiChartLegend(
          items: const [redItem, blueItem],
          itemBuilder: (context, item, index, onTap, onDoubleTap) {
            builderCallCount++;
            return GestureDetector(
              key: Key('${customKey}_$index'),
              onTap: onTap,
              child: Text('custom_${item.label}'),
            );
          },
        ),
      );

      expect(find.text('custom_Revenue'), findsOneWidget);
      expect(find.text('custom_Cost'), findsOneWidget);
      // Default Text widgets should not appear.
      expect(find.text('Revenue'), findsNothing);
      expect(find.text('Cost'), findsNothing);
      expect(builderCallCount, equals(2));
    });

    testWidgets('itemBuilder receives correct index values', (
      WidgetTester tester,
    ) async {
      final indices = <int>[];

      await tester.pumpChartApp(
        OiChartLegend(
          items: const [redItem, blueItem, hiddenItem],
          itemBuilder: (context, item, index, onTap, onDoubleTap) {
            indices.add(index);
            return Text('item_$index');
          },
        ),
      );

      expect(indices, orderedEquals([0, 1, 2]));
    });

    testWidgets(
      'itemBuilder receives onTap and onDoubleTap when callbacks set',
      (WidgetTester tester) async {
        VoidCallback? capturedTap;
        VoidCallback? capturedDoubleTap;

        await tester.pumpChartApp(
          OiChartLegend(
            items: const [redItem],
            onToggle: (_) {},
            onExclusiveFocus: (_) {},
            itemBuilder: (context, item, index, onTap, onDoubleTap) {
              capturedTap = onTap;
              capturedDoubleTap = onDoubleTap;
              return Text(item.label);
            },
          ),
        );

        expect(capturedTap, isNotNull);
        expect(capturedDoubleTap, isNotNull);
      },
    );

    testWidgets('itemBuilder receives null callbacks when not set', (
      WidgetTester tester,
    ) async {
      VoidCallback? capturedTap;
      VoidCallback? capturedDoubleTap;

      await tester.pumpChartApp(
        OiChartLegend(
          items: const [redItem],
          // onToggle and onExclusiveFocus are NOT set.
          itemBuilder: (context, item, index, onTap, onDoubleTap) {
            capturedTap = onTap;
            capturedDoubleTap = onDoubleTap;
            return Text(item.label);
          },
        ),
      );

      expect(capturedTap, isNull);
      expect(capturedDoubleTap, isNull);
    });

    testWidgets('double-tap fires onExclusiveFocus callback', (
      WidgetTester tester,
    ) async {
      String? focusedId;

      await tester.pumpChartApp(
        OiChartLegend(
          items: const [redItem, blueItem],
          onExclusiveFocus: (id) => focusedId = id,
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Revenue'));
      await tester.pump(kDoubleTapMinTime);
      await tester.tap(find.text('Revenue'));
      await tester.pumpAndSettle();

      expect(focusedId, equals('revenue'));
    });

    testWidgets('legend renders with key oi_chart_legend', (
      WidgetTester tester,
    ) async {
      await tester.pumpChartApp(const OiChartLegend(items: [redItem]));

      expect(find.byKey(const Key('oi_chart_legend')), findsOneWidget);
    });

    testWidgets('individual items have per-item keys', (
      WidgetTester tester,
    ) async {
      await tester.pumpChartApp(
        const OiChartLegend(items: [redItem, blueItem]),
      );

      expect(
        find.byKey(const Key('oi_chart_legend_item_revenue')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('oi_chart_legend_item_cost')),
        findsOneWidget,
      );
    });
  });

  group('OiChartLegendItem', () {
    test('equality holds when all fields match', () {
      const a = OiChartLegendItem(
        id: 'a',
        label: 'Series A',
        color: Color(0xFF112233),
        markerShape: OiLegendMarkerShape.circle,
      );
      const b = OiChartLegendItem(
        id: 'a',
        label: 'Series A',
        color: Color(0xFF112233),
        markerShape: OiLegendMarkerShape.circle,
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('inequality when id differs', () {
      const a = OiChartLegendItem(
        id: 'x',
        label: 'X',
        color: Color(0xFF000000),
      );
      const b = OiChartLegendItem(
        id: 'y',
        label: 'X',
        color: Color(0xFF000000),
      );
      expect(a, isNot(equals(b)));
    });

    test('inequality when visible differs', () {
      const a = OiChartLegendItem(
        id: 'x',
        label: 'X',
        color: Color(0xFF000000),
      );
      const b = OiChartLegendItem(
        id: 'x',
        label: 'X',
        color: Color(0xFF000000),
        visible: false,
      );
      expect(a, isNot(equals(b)));
    });

    test('copyWith produces updated item', () {
      const original = OiChartLegendItem(
        id: 'a',
        label: 'Original',
        color: Color(0xFF000000),
      );

      final updated = original.copyWith(
        label: 'Updated',
        visible: false,
        emphasized: true,
      );

      expect(updated.id, equals('a'));
      expect(updated.label, equals('Updated'));
      expect(updated.color, equals(const Color(0xFF000000)));
      expect(updated.visible, isFalse);
      expect(updated.emphasized, isTrue);
    });

    test('default values are set correctly', () {
      const item = OiChartLegendItem(
        id: 'a',
        label: 'A',
        color: Color(0xFF000000),
      );

      expect(item.visible, isTrue);
      expect(item.emphasized, isFalse);
      expect(item.markerShape, isNull);
    });
  });
}
