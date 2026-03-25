import 'dart:ui' show Offset, Size;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

import '../../helpers/pump_chart_app.dart';

/// A test behavior that tracks attach/detach calls.
class _TrackingBehavior extends OiChartBehavior {
  int attachCount = 0;
  int detachCount = 0;

  @override
  void attach(OiChartBehaviorContext context) {
    super.attach(context);
    attachCount++;
  }

  @override
  void detach() {
    detachCount++;
    super.detach();
  }
}

class _SalesPoint {
  const _SalesPoint(this.month, this.revenue);
  final String month;
  final double revenue;
}

OiCartesianSeries<_SalesPoint> _makeSeries({
  String id = 'revenue',
  bool visible = true,
  List<_SalesPoint>? data,
}) {
  return OiCartesianSeries<_SalesPoint>(
    id: id,
    label: id,
    visible: visible,
    data: data ?? const [_SalesPoint('Jan', 100), _SalesPoint('Feb', 200)],
    xMapper: (p) => p.month,
    yMapper: (p) => p.revenue,
  );
}

void main() {
  group('OiCartesianChart behavior wiring', () {
    testWidgets('attaches behaviors on mount', (tester) async {
      final behavior = _TrackingBehavior();

      await tester.pumpChartApp(
        SizedBox(
          width: 400,
          height: 300,
          child: OiCartesianChart<_SalesPoint>(
            label: 'Test',
            series: [_makeSeries()],
            behaviors: [behavior],
          ),
        ),
        surfaceSize: const Size(400, 300),
      );

      await tester.pump(); // Post-frame callback.

      expect(behavior.attachCount, 1);
      expect(behavior.isAttached, isTrue);
    });

    testWidgets('detaches behaviors on unmount', (tester) async {
      final behavior = _TrackingBehavior();

      await tester.pumpChartApp(
        SizedBox(
          width: 400,
          height: 300,
          child: OiCartesianChart<_SalesPoint>(
            label: 'Test',
            series: [_makeSeries()],
            behaviors: [behavior],
          ),
        ),
        surfaceSize: const Size(400, 300),
      );
      await tester.pump();

      // Remove the chart.
      await tester.pumpChartApp(
        const SizedBox(width: 400, height: 300),
        surfaceSize: const Size(400, 300),
      );

      expect(behavior.detachCount, greaterThanOrEqualTo(1));
      expect(behavior.isAttached, isFalse);
    });

    testWidgets('shows "all series hidden" when all toggled off', (
      tester,
    ) async {
      final controller = OiDefaultChartController();
      controller.toggleSeries('s1');
      controller.toggleSeries('s2');

      await tester.pumpChartApp(
        SizedBox(
          width: 400,
          height: 300,
          child: OiCartesianChart<_SalesPoint>(
            label: 'Test',
            series: [
              _makeSeries(id: 's1'),
              _makeSeries(id: 's2'),
            ],
            controller: controller,
          ),
        ),
        surfaceSize: const Size(400, 300),
      );

      expect(find.text('All series are hidden'), findsOneWidget);

      controller.dispose();
    });
  });
}
