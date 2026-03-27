
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

import '../../helpers/pump_chart_app.dart';

class _Candle {
  const _Candle(this.date, this.open, this.high, this.low, this.close);
  final DateTime date;
  final double open;
  final double high;
  final double low;
  final double close;
}

void main() {
  group('OiCandlestickChart', () {
    final sampleData = [
      _Candle(DateTime(2024), 100, 120, 95, 115), // bull
      _Candle(DateTime(2024, 1, 2), 115, 125, 105, 108), // bear
      _Candle(DateTime(2024, 1, 3), 108, 130, 100, 128), // bull
    ];

    testWidgets('renders candlestick body and wicks', (tester) async {
      await tester.pumpChartApp(
        SizedBox(
          width: 400,
          height: 300,
          child: OiCandlestickChart<_Candle>(
            label: 'Stock Price',
            series: [
              OiCandlestickSeries<_Candle>(
                id: 'stock',
                label: 'AAPL',
                data: sampleData,
                xMapper: (c) => c.date,
                openMapper: (c) => c.open,
                highMapper: (c) => c.high,
                lowMapper: (c) => c.low,
                closeMapper: (c) => c.close,
              ),
            ],
          ),
        ),
        surfaceSize: const Size(400, 300),
      );

      expect(find.byType(OiCandlestickChart<_Candle>), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('empty data shows empty state', (tester) async {
      await tester.pumpChartApp(
        SizedBox(
          width: 400,
          height: 300,
          child: OiCandlestickChart<_Candle>(
            label: 'Empty',
            series: [
              OiCandlestickSeries<_Candle>(
                id: 'empty',
                label: 'Empty',
                data: const [],
                xMapper: (c) => c.date,
                openMapper: (c) => c.open,
                highMapper: (c) => c.high,
                lowMapper: (c) => c.low,
                closeMapper: (c) => c.close,
              ),
            ],
          ),
        ),
        surfaceSize: const Size(400, 300),
      );

      expect(find.byType(OiCandlestickChart<_Candle>), findsOneWidget);
    });
  });
}
