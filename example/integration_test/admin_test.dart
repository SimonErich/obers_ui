// Test files do not need public API docs.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:obers_ui_example/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('admin dashboard shows metrics', (tester) async {
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    // Navigate to Admin.
    await tester.tap(find.text('Admin'));
    await tester.pumpAndSettle();

    // The admin overview screen shows dashboard metrics.
    expect(find.text('Revenue'), findsOneWidget);
    expect(find.text('Orders'), findsOneWidget);
  });

  testWidgets('admin users screen shows employee table', (tester) async {
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Admin'));
    await tester.pumpAndSettle();

    // Tap "Users" in sidebar navigation.
    await tester.tap(find.text('Users'));
    await tester.pumpAndSettle();

    // Verify the user table renders with an employee name.
    expect(find.text('Leopold Brandauer'), findsOneWidget);
    expect(find.text('Hans Gruber'), findsOneWidget);
  });

  testWidgets('admin settings screen shows form', (tester) async {
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Admin'));
    await tester.pumpAndSettle();

    // Tap "Settings" in sidebar navigation.
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    // Verify the settings form renders.
    expect(find.text('General'), findsOneWidget);
    expect(find.text('Site Name'), findsOneWidget);
  });
}
