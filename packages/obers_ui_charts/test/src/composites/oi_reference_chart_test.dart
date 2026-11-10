import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';
import 'package:obers_ui_charts/src/composites/oi_bar_chart/oi_bar_chart_painter.dart';

void main() {
  test(
    'diagonal fill paints authored strokes and translucent background',
    () async {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      OiBarChartPainter(
        categoryLabels: ['Day'],
        values: [
          [10],
        ],
        colors: [const Color(0xff6655aa)],
        categoryColors: [
          [const Color(0xffcc8800)],
        ],
        patterns: [
          [OiBarPattern.diagonal],
        ],
        chartRect: const Rect.fromLTWH(20, 20, 80, 80),
        horizontal: false,
        stacked: false,
        showValues: false,
        showGrid: false,
        barRadius: 0,
        gridColor: const Color(0x00000000),
        axisLabelColor: const Color(0x00000000),
        textColor: const Color(0x00000000),
        highContrast: false,
        compact: true,
        numSeries: 1,
        yLabels: const [],
        yDivisions: 0,
      ).paint(canvas, const Size(120, 120));
      final picture = recorder.endRecording();
      final image = await picture.toImage(120, 120);
      final bytes = (await image.toByteData())!;
      final alphas = <int>{};
      for (var y = 30; y < 80; y++) {
        for (var x = 45; x < 75; x++) {
          alphas.add(bytes.getUint8((y * 120 + x) * 4 + 3));
        }
      }
      expect(alphas.any((alpha) => alpha > 200), isTrue);
      expect(alphas.any((alpha) => alpha > 0 && alpha < 100), isTrue);
      image.dispose();
      picture.dispose();
    },
  );

  testWidgets('donut rich center and side legend fit bounded card', (
    tester,
  ) async {
    await tester.pumpWidget(
      const OiApp(
        home: Center(
          child: SizedBox(
            width: 300,
            height: 220,
            child: OiDonutChart(
              label: 'Status',
              segments: [
                OiPieSegment(label: 'Paid', value: 4),
                OiPieSegment(label: 'Pending', value: 2),
              ],
              center: Column(
                mainAxisSize: MainAxisSize.min,
                children: [OiLabel.bodyStrong('6'), OiLabel.small('Orders')],
              ),
              legendPosition: OiChartLegendPosition.right,
              legendWidth: 130,
              legend: OiChartLegend(
                position: OiChartLegendPosition.right,
                items: [
                  OiChartLegendItem(
                    id: 'paid',
                    label: 'Paid',
                    value: '4',
                    color: Color(0xff33aa66),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Orders'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('donut inner radius leaves the declared center hollow', (
    tester,
  ) async {
    await tester.pumpWidget(
      const OiApp(
        home: Center(
          child: SizedBox(
            width: 200,
            height: 200,
            child: OiDonutChart(
              label: 'Ring',
              innerRadiusFraction: .76,
              showLegend: false,
              showLabels: false,
              showPercentages: false,
              segments: [
                OiPieSegment(label: 'All', value: 1, color: Color(0xffff0000)),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final painter = tester
        .widget<CustomPaint>(find.byKey(const Key('oi_pie_chart_painter')))
        .painter!;
    final recorder = ui.PictureRecorder();
    painter.paint(Canvas(recorder), const Size(200, 200));
    final picture = recorder.endRecording();
    final pixels = (await tester.runAsync(() async {
      final image = await picture.toImage(200, 200);
      final bytes = await image.toByteData();
      image.dispose();
      picture.dispose();
      return bytes;
    }))!;
    expect(pixels.getUint8((100 * 200 + 140) * 4 + 3), 0);
    expect(pixels.getUint8((100 * 200 + 175) * 4 + 3), greaterThan(240));
  });

  testWidgets('bar axis bounds drive ticks and bar geometry together', (
    tester,
  ) async {
    await tester.pumpWidget(
      const OiApp(
        home: SizedBox(
          width: 400,
          height: 240,
          child: OiBarChart(
            label: 'Orders',
            showLegend: false,
            yAxis: OiChartAxis<num>(min: 100, max: 500, divisions: 4),
            categories: [
              OiBarCategory(label: 'Day', values: [300]),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final painter =
        tester
                .widget<CustomPaint>(
                  find.byKey(const Key('oi_bar_chart_painter')),
                )
                .painter!
            as OiBarChartPainter;
    expect(painter.domainMin, 100);
    expect(painter.domainMax, 500);
    expect(painter.yLabels, ['100', '200', '300', '400', '500']);
    final recorder = ui.PictureRecorder();
    painter.paint(Canvas(recorder), const Size(800, 600));
    final picture = recorder.endRecording();
    final bytes = (await tester.runAsync(() async {
      final image = await picture.toImage(800, 600);
      final bytes = await image.toByteData();
      image.dispose();
      picture.dispose();
      return bytes;
    }))!;
    final plot = painter.chartRect;
    final x = plot.center.dx.floor();
    final above = (plot.top + plot.height * .2).floor();
    final below = (plot.top + plot.height * .8).floor();
    expect(bytes.getUint8((below * 800 + x) * 4 + 3), greaterThan(200));
    expect(bytes.getUint8((above * 800 + x) * 4 + 3), lessThan(200));
  });
}
