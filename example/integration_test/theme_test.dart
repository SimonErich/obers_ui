// Test files do not need public API docs.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_example/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app starts in light mode and can switch to dark mode', (
    tester,
  ) async {
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    // Verify initial state — the home screen is visible.
    expect(find.text('obers_ui Showcase'), findsOneWidget);

    // Find the theme toggle button.
    final themeToggleFinder = find.byType(OiThemeToggle);
    expect(themeToggleFinder, findsOneWidget);

    // Tap the toggle to open the popover.
    await tester.tap(themeToggleFinder);
    await tester.pumpAndSettle();

    // Verify the popover shows both light and dark options.
    expect(find.text('Light mode'), findsOneWidget);
    expect(find.text('Dark mode'), findsOneWidget);

    // Tap "Dark mode" to switch theme.
    await tester.tap(find.text('Dark mode'));
    await tester.pumpAndSettle();

    // App should still render correctly in dark mode.
    expect(find.text('obers_ui Showcase'), findsOneWidget);

    // Open the popover again to verify we can toggle back.
    await tester.tap(themeToggleFinder);
    await tester.pumpAndSettle();

    // Tap "Light mode" to switch back.
    await tester.tap(find.text('Light mode'));
    await tester.pumpAndSettle();

    // App should still render correctly after toggling back.
    expect(find.text('obers_ui Showcase'), findsOneWidget);
  });
}
