
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
  group('OiComboChart', () {
    testWidgets('renders mixed line + bar series', (tester) async {
      await tester.pumpChartApp(
        SizedBox(
          width: 400,
          height: 300,
          child: OiComboChart<_Point>(
            label: 'Combo',
            series: [
              OiCartesianSeries<_Point>(
                id: 'line',
                label: 'Line',
                data: const [_Point(1, 100), _Point(2, 200)],
                xMapper: (p) => p.x,
                yMapper: (p) => p.y,
              ),
              OiComboBarSeries<_Point>(
                id: 'bar',
                label: 'Bar',
                data: const [_Point(1, 50), _Point(2, 150)],
                xMapper: (p) => p.x,
                yMapper: (p) => p.y,
              ),
            ],
          ),
        ),
        surfaceSize: const Size(400, 300),
      );

      expect(find.byType(OiComboChart<_Point>), findsOneWidget);
    });

    testWidgets('renders with empty series', (tester) async {
      await tester.pumpChartApp(
        const SizedBox(
          width: 400,
          height: 300,
          child: OiComboChart<_Point>(label: 'Empty combo', series: []),
        ),
        surfaceSize: const Size(400, 300),
      );

      expect(find.byType(OiComboChart<_Point>), findsOneWidget);
    });
  });
}
