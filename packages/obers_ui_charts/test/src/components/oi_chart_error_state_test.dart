import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/src/components/oi_chart_error_state.dart';

import '../../helpers/pump_chart_app.dart';

void main() {
  group('OiChartErrorState', () {
    testWidgets('shows default error message', (tester) async {
      await tester.pumpChartApp(const OiChartErrorState());
      expect(find.text('Failed to load chart data'), findsOneWidget);
    });

    testWidgets('shows custom message', (tester) async {
      await tester.pumpChartApp(
        const OiChartErrorState(message: 'Connection lost'),
      );
      expect(find.text('Connection lost'), findsOneWidget);
    });

    testWidgets('shows retry button when callback provided', (tester) async {
      var retried = false;
      await tester.pumpChartApp(
        OiChartErrorState(onRetry: () => retried = true),
      );
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(retried, isTrue);
    });

    testWidgets('hides retry button when no callback', (tester) async {
      await tester.pumpChartApp(const OiChartErrorState());
      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('has semantics label', (tester) async {
      await tester.pumpChartApp(const OiChartErrorState());
      expect(
        find.bySemanticsLabel(RegExp('Failed to load chart data')),
        findsWidgets,
      );
    });
  });
}
