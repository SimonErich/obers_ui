// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_metric.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders value and label', (tester) async {
    await tester.pumpObers(
      const OiMetric(label: 'Revenue', value: r'$1,234'),
    );
    expect(find.text(r'$1,234'), findsOneWidget);
    expect(find.text('Revenue'), findsOneWidget);
  });

  testWidgets('renders sub-value when provided', (tester) async {
    await tester.pumpObers(
      const OiMetric(label: 'Sales', value: '42', subValue: 'vs last month'),
    );
    expect(find.text('vs last month'), findsOneWidget);
  });

  testWidgets('renders up trend arrow', (tester) async {
    await tester.pumpObers(
      const OiMetric(
        label: 'Growth',
        value: '99',
        trend: OiMetricTrend.up,
        trendPercent: 12.5,
      ),
    );
    expect(find.text('↑'), findsOneWidget);
    expect(find.text('12.5%'), findsOneWidget);
  });

  testWidgets('renders down trend arrow', (tester) async {
    await tester.pumpObers(
      const OiMetric(
        label: 'Churn',
        value: '5',
        trend: OiMetricTrend.down,
      ),
    );
    expect(find.text('↓'), findsOneWidget);
  });

  testWidgets('sparkline slot renders provided widget', (tester) async {
    await tester.pumpObers(
      const OiMetric(
        label: 'Orders',
        value: '100',
        sparkline: SizedBox(width: 80, height: 32, key: Key('spark')),
      ),
    );
    expect(find.byKey(const Key('spark')), findsOneWidget);
  });

  testWidgets('no trend indicator when trend is null', (tester) async {
    await tester.pumpObers(
      const OiMetric(label: 'Total', value: '0'),
    );
    expect(find.text('↑'), findsNothing);
    expect(find.text('↓'), findsNothing);
  });
}
