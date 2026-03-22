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
    expect(find.textContaining('famous Viennese dessert'), findsOneWidget);
  });

  testWidgets('switch to register mode', (tester) async {
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Auth'));
    await tester.pumpAndSettle();

    // Verify login form is showing initially.
    expect(find.text('Sign In'), findsWidgets);

    // Tap the "Don't have an account? Sign Up" link to switch to register.
    await tester.tap(find.text("Don't have an account? Sign Up"));
    await tester.pumpAndSettle();

    // Verify registration form appears.
    expect(find.text('Create Account'), findsWidgets);
    expect(find.text('Full Name'), findsOneWidget);
  });

  testWidgets('switch to forgot password mode', (tester) async {
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Auth'));
    await tester.pumpAndSettle();

    // Tap the "Forgot password?" link.
    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();

    // Verify forgot password form appears.
    expect(find.text('Reset Password'), findsOneWidget);
    expect(find.text('Send Reset Link'), findsOneWidget);
  });
}
