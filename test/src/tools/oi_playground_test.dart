// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';
import 'package:obers_ui/src/tools/oi_playground.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('OiPlayground', () {
    testWidgets('renders with default themes', (tester) async {
      await tester.pumpObers(
        const SizedBox(width: 800, height: 600, child: OiPlayground()),
        surfaceSize: const Size(800, 600),
      );

      expect(find.byKey(const ValueKey('playground_title')), findsOneWidget);
      expect(find.text('OiPlayground'), findsOneWidget);
    });

    testWidgets('shows category sidebar', (tester) async {
      await tester.pumpObers(
        const SizedBox(width: 800, height: 600, child: OiPlayground()),
        surfaceSize: const Size(800, 600),
      );

      // Buttons appears in both sidebar and content title
      expect(find.text('Buttons'), findsWidgets);
      expect(find.text('Inputs'), findsOneWidget);
      expect(find.text('Display'), findsOneWidget);
    });

    testWidgets('defaults to first category', (tester) async {
      await tester.pumpObers(
        const SizedBox(width: 800, height: 600, child: OiPlayground()),
        surfaceSize: const Size(800, 600),
      );

      expect(
        find.byKey(const ValueKey('playground_category_title')),
        findsOneWidget,
      );
      expect(find.text('Buttons'), findsWidgets);
    });

    testWidgets('respects initialCategory', (tester) async {
      await tester.pumpObers(
        const SizedBox(
          width: 800,
          height: 600,
          child: OiPlayground(initialCategory: 'Inputs'),
        ),
        surfaceSize: const Size(800, 600),
      );

      // The category title Text widget should show Inputs
      final titleWidget = tester.widget<Text>(
        find.byKey(const ValueKey('playground_category_title')),
      );
      expect(titleWidget.data, 'Inputs');
    });

    testWidgets('switching category updates content', (tester) async {
      await tester.pumpObers(
        const SizedBox(width: 800, height: 600, child: OiPlayground()),
        surfaceSize: const Size(800, 600),
      );

      // Tap on Display category
      await tester.tap(find.byKey(const ValueKey('playground_cat_Display')));
      await tester.pump();

      // The category title should now show Display
      final titleWidget = tester.widget<Text>(
        find.byKey(const ValueKey('playground_category_title')),
      );
      expect(titleWidget.data, 'Display');
    });

    testWidgets('theme toggle switches between light and dark', (tester) async {
      await tester.pumpObers(
        const SizedBox(width: 800, height: 600, child: OiPlayground()),
        surfaceSize: const Size(800, 600),
      );

      // Initially shows "Dark" toggle (meaning we're in light mode)
      expect(find.text('Dark'), findsOneWidget);

      // Tap theme toggle
      await tester.tap(find.byKey(const ValueKey('playground_theme_toggle')));
      await tester.pump();

      // Now shows "Light" toggle (meaning we're in dark mode)
      expect(find.text('Light'), findsOneWidget);
    });

    testWidgets('accepts custom themes', (tester) async {
      final customLight = OiThemeData.light();
      final customDark = OiThemeData.dark();

      await tester.pumpObers(
        SizedBox(
          width: 800,
          height: 600,
          child: OiPlayground(theme: customLight, darkTheme: customDark),
        ),
        surfaceSize: const Size(800, 600),
      );

      expect(find.byType(OiPlayground), findsOneWidget);
    });

    testWidgets('renders button samples in Buttons category', (tester) async {
      await tester.pumpObers(
        const SizedBox(width: 800, height: 600, child: OiPlayground()),
        surfaceSize: const Size(800, 600),
      );

      // Should show button labels
      expect(find.text('Primary'), findsWidgets);
      expect(find.text('Ghost'), findsOneWidget);
    });

    testWidgets('renders placeholder for unimplemented categories', (
      tester,
    ) async {
      await tester.pumpObers(
        const SizedBox(width: 800, height: 600, child: OiPlayground()),
        surfaceSize: const Size(800, 600),
      );

      // Switch to Feedback (unimplemented)
      await tester.tap(find.byKey(const ValueKey('playground_cat_Feedback')));
      await tester.pump();

      expect(find.text('Coming soon: Feedback'), findsOneWidget);
    });
  });
}
