import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/src/components/oi_chart_empty_state.dart';

import '../../helpers/pump_chart_app.dart';

void main() {
  group('OiChartEmptyState', () {
    testWidgets('shows default message', (tester) async {
      await tester.pumpChartApp(const OiChartEmptyState());
      expect(find.text('No data available'), findsOneWidget);
    });

    testWidgets('shows custom message', (tester) async {
      await tester.pumpChartApp(
        const OiChartEmptyState(message: 'Nothing here'),
      );
      expect(find.text('Nothing here'), findsOneWidget);
    });

    testWidgets('shows optional icon', (tester) async {
      await tester.pumpChartApp(
        const OiChartEmptyState(
          icon: SizedBox(key: Key('test-icon'), width: 24, height: 24),
        ),
      );
      expect(find.byKey(const Key('test-icon')), findsOneWidget);
    });

    testWidgets('has semantics label', (tester) async {
      await tester.pumpChartApp(const OiChartEmptyState());
      expect(find.bySemanticsLabel(RegExp('No data available')), findsWidgets);
    });
  });
}
