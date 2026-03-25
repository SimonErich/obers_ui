import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/src/composites/oi_polar_chart.dart';
import 'package:obers_ui_charts/src/models/oi_polar_series.dart';

import '../../helpers/pump_chart_app.dart';

class _Segment {
  _Segment(this.label, this.value);
  final String label;
  final double value;
}

void main() {
  group('OiPolarChart', () {
    testWidgets('renders with series data', (tester) async {
      final data = [_Segment('A', 30), _Segment('B', 70)];

      await tester.pumpChartApp(
        SizedBox(
          width: 400,
          height: 400,
          child: OiPolarChart<_Segment>(
            label: 'Segments',
            series: [
              OiPolarSeries<_Segment>(
                id: 'seg',
                label: 'Segments',
                data: data,
                valueMapper: (s) => s.value,
                labelMapper: (s) => s.label,
              ),
            ],
            seriesBuilder: (context, viewport, visibleSeries) {
              return const SizedBox(key: Key('polar-content'));
            },
          ),
        ),
      );

      expect(find.byKey(const Key('polar-content')), findsOneWidget);
    });

    testWidgets('empty data shows empty state', (tester) async {
      await tester.pumpChartApp(
        SizedBox(
          width: 400,
          height: 400,
          child: OiPolarChart<_Segment>(
            label: 'Empty polar',
            series: [
              OiPolarSeries<_Segment>(
                id: 'seg',
                label: 'Segments',
                data: const [],
                valueMapper: (s) => s.value,
                labelMapper: (s) => s.label,
              ),
            ],
          ),
        ),
      );

      expect(find.text('No data available'), findsOneWidget);
    });
  });
}
