import 'dart:ui' show Size;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

import '../../helpers/pump_chart_app.dart';

class _Point {
  const _Point(this.x, this.y);
  final double x;
  final double y;
}

void main() {
  group('OiCartesianChart edge cases', () {
    testWidgets('single data point renders with domain padding', (
      tester,
    ) async {
      await tester.pumpChartApp(
        SizedBox(
          width: 400,
          height: 300,
          child: OiCartesianChart<_Point>(
            label: 'Test',
            series: [
              OiCartesianSeries<_Point>(
                id: 'single',
                label: 'Single',
                data: const [_Point(50, 100)],
                xMapper: (p) => p.x,
                yMapper: (p) => p.y,
              ),
            ],
            seriesBuilder: (context, viewport, series) {
              // Viewport should have a visible domain (padding applied).
              expect(viewport.visibleDomain, isNotNull);
              final domain = viewport.visibleDomainX;
              expect(domain, isNotNull);
              // Domain should be wider than a single point.
              expect(domain!.max - domain.min, greaterThan(0));
              return const SizedBox.expand();
            },
          ),
        ),
        surfaceSize: const Size(400, 300),
      );
    });

    testWidgets('controller dispose detaches behaviors', (tester) async {
      final controller = OiDefaultChartController();
      final behavior = _TrackingBehavior();

      await tester.pumpChartApp(
        SizedBox(
          width: 400,
          height: 300,
          child: OiCartesianChart<_Point>(
            label: 'Test',
            series: [
              OiCartesianSeries<_Point>(
                id: 's1',
                label: 'S1',
                data: const [_Point(1, 10), _Point(2, 20)],
                xMapper: (p) => p.x,
                yMapper: (p) => p.y,
              ),
            ],
            controller: controller,
            behaviors: [behavior],
          ),
        ),
        surfaceSize: const Size(400, 300),
      );
      await tester.pump();

      // Replace chart with empty widget (triggers dispose).
      await tester.pumpChartApp(
        const SizedBox(width: 400, height: 300),
        surfaceSize: const Size(400, 300),
      );

      // Behavior should be detached.
      expect(behavior.isAttached, isFalse);

      // Disposing controller after chart is gone should not throw.
      controller.dispose();
    });
  });
}

class _TrackingBehavior extends OiChartBehavior {
  int detachCount = 0;

  @override
  void detach() {
    detachCount++;
    super.detach();
  }
}
