
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

import '../../helpers/pump_chart_app.dart';

void main() {
  group('OiChartAxisWidget', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpChartApp(
        const SizedBox(
          width: 400,
          height: 50,
          child: OiChartAxisWidget(
            axis: OiChartAxis<num>(label: 'X Axis', showGrid: false),
            viewport: OiChartViewport(size: Size(400, 300)),
          ),
        ),
        surfaceSize: const Size(400, 300),
      );

      expect(find.byType(OiChartAxisWidget), findsOneWidget);
    });
  });

  group('OiChartCrosshairWidget', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpChartApp(
        const SizedBox(
          width: 400,
          height: 300,
          child: OiChartCrosshairWidget(
            position: Offset(200, 150),
            viewport: OiChartViewport(size: Size(400, 300)),
          ),
        ),
        surfaceSize: const Size(400, 300),
      );

      expect(find.byType(OiChartCrosshairWidget), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('can disable horizontal/vertical lines', (tester) async {
      await tester.pumpChartApp(
        const SizedBox(
          width: 400,
          height: 300,
          child: OiChartCrosshairWidget(
            position: Offset(200, 150),
            viewport: OiChartViewport(size: Size(400, 300)),
            showHorizontal: false,
          ),
        ),
        surfaceSize: const Size(400, 300),
      );

      expect(find.byType(OiChartCrosshairWidget), findsOneWidget);
    });
  });

  group('OiChartBrushWidget', () {
    testWidgets('renders selection rectangle', (tester) async {
      await tester.pumpChartApp(
        const SizedBox(
          width: 400,
          height: 300,
          child: OiChartBrushWidget(
            rect: Rect.fromLTWH(50, 50, 200, 100),
            fillColor: Color(0x200000FF),
            borderColor: Color(0xFF0000FF),
          ),
        ),
        surfaceSize: const Size(400, 300),
      );

      expect(find.byType(OiChartBrushWidget), findsOneWidget);
    });
  });

  group('OiChartAnnotationLayer', () {
    testWidgets('renders annotations and thresholds', (tester) async {
      await tester.pumpChartApp(
        const SizedBox(
          width: 400,
          height: 300,
          child: OiChartAnnotationLayer(
            viewport: OiChartViewport(size: Size(400, 300)),
            annotations: [
              OiChartAnnotation.horizontalLine(value: 0.5, label: 'Mid'),
              OiChartAnnotation.verticalLine(value: 0.3),
              OiChartAnnotation.region(start: 0.1, end: 0.4),
            ],
            thresholds: [OiChartThreshold(value: 0.8, label: 'Target')],
          ),
        ),
        surfaceSize: const Size(400, 300),
      );

      expect(find.byType(OiChartAnnotationLayer), findsOneWidget);
    });

    testWidgets('renders empty lists without error', (tester) async {
      await tester.pumpChartApp(
        const SizedBox(
          width: 400,
          height: 300,
          child: OiChartAnnotationLayer(
            viewport: OiChartViewport(size: Size(400, 300)),
          ),
        ),
        surfaceSize: const Size(400, 300),
      );

      expect(find.byType(OiChartAnnotationLayer), findsOneWidget);
    });
  });

  group('OiChartTooltipWidget', () {
    testWidgets('renders tooltip model', (tester) async {
      const model = OiChartTooltipModel(
        globalPosition: Offset(100, 100),
        entries: [
          OiChartTooltipEntry(
            seriesLabel: 'Revenue',
            formattedX: 'Jan',
            formattedY: r'$1,000',
            color: Color(0xFFFF0000),
          ),
        ],
        title: 'January 2026',
      );

      await tester.pumpChartApp(
        const SizedBox(
          width: 400,
          height: 300,
          child: OiChartTooltipWidget(model: model),
        ),
        surfaceSize: const Size(400, 300),
      );

      expect(find.byType(OiChartTooltipWidget), findsOneWidget);
    });
  });
}
