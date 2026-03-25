import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/src/components/oi_chart_loading_state.dart';

import '../../helpers/pump_chart_app.dart';

void main() {
  group('OiChartLoadingState', () {
    testWidgets('shows default loading message', (tester) async {
      await tester.pumpChartApp(const OiChartLoadingState());
      expect(find.text('Loading chart data\u2026'), findsOneWidget);
    });

    testWidgets('shows custom message', (tester) async {
      await tester.pumpChartApp(
        const OiChartLoadingState(message: 'Fetching...'),
      );
      expect(find.text('Fetching...'), findsOneWidget);
    });

    testWidgets('has semantics label', (tester) async {
      await tester.pumpChartApp(const OiChartLoadingState());
      expect(find.bySemanticsLabel(RegExp('Loading chart data')), findsWidgets);
    });
  });
}
