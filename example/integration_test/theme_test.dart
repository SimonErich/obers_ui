// Test files do not need public API docs.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_example/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app starts and theme toggle can be tapped without crash',
      (tester) async {
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    // Verify initial state — the home screen is visible.
    expect(find.text('obers_ui Showcase'), findsOneWidget);

    // Find and tap the theme toggle button.
    final themeToggleFinder = find.byType(OiThemeToggle);
    expect(themeToggleFinder, findsOneWidget);

    await tester.tap(themeToggleFinder);
    await tester.pumpAndSettle();

    // App should still render correctly after toggling theme.
    expect(find.text('obers_ui Showcase'), findsOneWidget);
  });
}
