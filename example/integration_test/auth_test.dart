// Test files do not need public API docs.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:obers_ui_example/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('auth screen shows login form', (tester) async {
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    // Navigate to Auth.
    await tester.tap(find.text('Auth'));
    await tester.pumpAndSettle();

    // Verify login form renders with the logo.
    expect(find.text('Alpenglueck'), findsOneWidget);
  });

  testWidgets('auth screen shows demo credentials hint', (tester) async {
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Auth'));
    await tester.pumpAndSettle();

    // Verify the demo hint is visible.
    expect(
      find.textContaining('famous Viennese dessert'),
      findsOneWidget,
    );
  });
}
