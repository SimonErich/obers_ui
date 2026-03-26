import 'dart:ui' show Size;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

import '../../helpers/pump_chart_app.dart';

class _Item {
  const _Item(this.name, this.amount, {this.isTotal = false});
  final String name;
  final double amount;
  final bool isTotal;
}

OiWaterfallSeries<_Item> _makeSeries(List<_Item> items) {
  return OiWaterfallSeries<_Item>(
    id: 'test',
    label: 'Test',
    data: items,
    categoryMapper: (i) => i.name,
    valueMapper: (i) => i.amount,
    isTotal: (i) => i.isTotal,
  );
}

void main() {
  group('computeWaterfallBars', () {
    test('running total correct after positive + negative values', () {
      final series = _makeSeries(const [
        _Item('A', 100),
        _Item('B', -30),
        _Item('C', 50),
      ]);
      final bars = computeWaterfallBars(series);
      expect(bars[0].runningTotal, 100);
      expect(bars[1].runningTotal, 70);
      expect(bars[2].runningTotal, 120);
    });

    test('total bar resets to baseline', () {
      final series = _makeSeries(const [
        _Item('A', 100),
        _Item('B', -30),
        _Item('Total', 0, isTotal: true),
      ]);
      final bars = computeWaterfallBars(series);
      expect(bars[2].isTotal, isTrue);
      expect(bars[2].barStart, 0);
    });

    test('empty data produces empty bars', () {
      final series = _makeSeries(const []);
      final bars = computeWaterfallBars(series);
      expect(bars, isEmpty);
    });
  });

  group('OiWaterfallChart widget', () {
    testWidgets('renders with data', (tester) async {
      await tester.pumpChartApp(
        SizedBox(
          width: 400,
          height: 300,
          child: OiWaterfallChart<_Item>(
            label: 'Revenue',
            series: [
              _makeSeries(const [
                _Item('Q1', 500),
                _Item('Q2', -100),
                _Item('Q3', 200),
                _Item('Total', 0, isTotal: true),
              ]),
            ],
          ),
        ),
        surfaceSize: const Size(400, 300),
      );
      expect(find.byType(OiWaterfallChart<_Item>), findsOneWidget);
    });
  });
}
