// Test files do not need public API docs.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:obers_ui_example/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('home screen shows all 7 category card titles', (tester) async {
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    expect(find.text('Shop'), findsOneWidget);
    expect(find.text('Chat'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);
    expect(find.text('Projects'), findsOneWidget);
    expect(find.text('Files'), findsOneWidget);
    expect(find.text('Content'), findsOneWidget);
    expect(find.text('Auth'), findsOneWidget);
  });

  testWidgets('tapping Shop card navigates to shop screen', (tester) async {
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Shop'));
    await tester.pumpAndSettle();

    // The shop screen shows a "Products" heading.
    expect(find.text('Products'), findsOneWidget);
  });

  testWidgets('tapping Admin card navigates to admin screen', (tester) async {
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Admin'));
    await tester.pumpAndSettle();

    // The admin overview screen shows dashboard metrics.
    expect(find.text('Revenue'), findsOneWidget);
  });

  testWidgets('navigating to Shop and going back returns to home', (
    tester,
  ) async {
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Shop'));
    await tester.pumpAndSettle();

    // Verify we are on the shop screen.
    expect(find.text('Products'), findsOneWidget);

    // Tap the back button (semanticLabel: 'Go back').
    await tester.tap(find.bySemanticsLabel('Go back'));
    await tester.pumpAndSettle();

    // Verify we are back on the home screen.
    expect(find.text('obers_ui Showcase'), findsOneWidget);
  });
}
