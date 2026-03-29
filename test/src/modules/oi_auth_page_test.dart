// Tests do not require documentation comments.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('OiAuthPage', () {
    testWidgets('renders login form by default', (tester) async {
      await tester.pumpObers(
        const OiAuthPage(label: 'Auth'),
        surfaceSize: const Size(800, 600),
      );

      // "Sign In" appears as both heading and button label.
      expect(find.text('Sign In'), findsNWidgets(2));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('renders register form when initialMode is register', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiAuthPage(label: 'Auth', initialMode: OiAuthMode.register),
        surfaceSize: const Size(800, 600),
      );

      expect(find.text('Create Account'), findsWidgets);
      expect(find.text('Full Name'), findsOneWidget);
    });

    testWidgets(
      'renders forgot password form when initialMode is forgotPassword',
      (tester) async {
        await tester.pumpObers(
          const OiAuthPage(
            label: 'Auth',
            initialMode: OiAuthMode.forgotPassword,
          ),
          surfaceSize: const Size(800, 600),
        );

        expect(find.text('Reset Password'), findsOneWidget);
        expect(find.text('Send Reset Link'), findsOneWidget);
      },
    );

    testWidgets('switches to register mode via link', (tester) async {
      OiAuthMode? changedMode;
      await tester.pumpObers(
        OiAuthPage(
          label: 'Auth',
          onRegister: (name, email, password) async => true,
          onModeChanged: (mode) => changedMode = mode,
        ),
        surfaceSize: const Size(800, 600),
      );

      // Tap the "Don't have an account? Sign Up" link.
      await tester.tap(find.text("Don't have an account? Sign Up"));
      await tester.pumpAndSettle();

      expect(changedMode, OiAuthMode.register);
      expect(find.text('Create Account'), findsWidgets);
    });

    testWidgets('switches to forgot password mode via link', (tester) async {
      OiAuthMode? changedMode;
      await tester.pumpObers(
        OiAuthPage(
          label: 'Auth',
          onForgotPassword: (email) async => true,
          onModeChanged: (mode) => changedMode = mode,
        ),
        surfaceSize: const Size(800, 600),
      );

      await tester.tap(find.text('Forgot password?'));
      await tester.pumpAndSettle();

      expect(changedMode, OiAuthMode.forgotPassword);
      expect(find.text('Reset Password'), findsOneWidget);
    });

    testWidgets('invokes onLogin callback with email and password', (
      tester,
    ) async {
      String? capturedEmail;
      String? capturedPassword;
      final completer = Completer<bool>();

      await tester.pumpObers(
        OiAuthPage(
          label: 'Auth',
          onLogin: (email, password) {
            capturedEmail = email;
            capturedPassword = password;
            return completer.future;
          },
        ),
        surfaceSize: const Size(800, 600),
      );

      // Enter email.
      await tester.enterText(find.byType(EditableText).at(0), 'user@test.com');
      // Enter password.
      await tester.enterText(find.byType(EditableText).at(1), 'secret123');

      // Tap Sign In button.
      await tester.tap(find.text('Sign In').last);
      await tester.pump();

      expect(capturedEmail, 'user@test.com');
      expect(capturedPassword, 'secret123');

      // Complete the future so the widget settles.
      completer.complete(true);
      await tester.pumpAndSettle();
    });

    testWidgets('invokes onRegister callback with name, email, and password', (
      tester,
    ) async {
      String? capturedName;
      String? capturedEmail;
      String? capturedPassword;
      final completer = Completer<bool>();

      await tester.pumpObers(
        OiAuthPage(
          label: 'Auth',
          initialMode: OiAuthMode.register,
          onRegister: (name, email, password) {
            capturedName = name;
            capturedEmail = email;
            capturedPassword = password;
            return completer.future;
          },
        ),
        surfaceSize: const Size(800, 600),
      );

      // Enter name, email, password.
      await tester.enterText(find.byType(EditableText).at(0), 'Jane Doe');
      await tester.enterText(find.byType(EditableText).at(1), 'jane@test.com');
      await tester.enterText(find.byType(EditableText).at(2), 'pw12345');

      // Tap Create Account button.
      await tester.tap(find.text('Create Account').last);
      await tester.pump();

      expect(capturedName, 'Jane Doe');
      expect(capturedEmail, 'jane@test.com');
      expect(capturedPassword, 'pw12345');

      completer.complete(true);
      await tester.pumpAndSettle();
    });

    testWidgets('disables submit button when callback is null', (tester) async {
      await tester.pumpObers(
        const OiAuthPage(label: 'Auth'),
        surfaceSize: const Size(800, 600),
      );

      // "Sign In" heading + button both render.
      expect(find.text('Sign In'), findsNWidgets(2));
    });

    testWidgets('displays custom logo widget', (tester) async {
      await tester.pumpObers(
        const OiAuthPage(label: 'Auth', logo: Text('MyLogo')),
        surfaceSize: const Size(800, 600),
      );

      expect(find.text('MyLogo'), findsOneWidget);
    });

    testWidgets('displays custom footer widget', (tester) async {
      await tester.pumpObers(
        const OiAuthPage(label: 'Auth', footer: Text('Footer Text')),
        surfaceSize: const Size(800, 600),
      );

      expect(find.text('Footer Text'), findsOneWidget);
    });

    testWidgets('OiAuthPage.login factory creates login-only page', (
      tester,
    ) async {
      await tester.pumpObers(
        OiAuthPage.login(
          label: 'Login',
          onLogin: (email, password) async => true,
        ),
        surfaceSize: const Size(800, 600),
      );

      // "Sign In" heading + button.
      expect(find.text('Sign In'), findsNWidgets(2));
      // No register link should appear.
      expect(find.text("Don't have an account? Sign Up"), findsNothing);
    });

    testWidgets('OiAuthPage.register factory creates register-only page', (
      tester,
    ) async {
      await tester.pumpObers(
        OiAuthPage.register(
          label: 'Register',
          onRegister: (name, email, password) async => true,
        ),
        surfaceSize: const Size(800, 600),
      );

      expect(find.text('Create Account'), findsWidgets);
      // No login link should appear.
      expect(find.text('Already have an account? Sign In'), findsNothing);
    });

    testWidgets('shows error message on failed login', (tester) async {
      await tester.pumpObers(
        OiAuthPage(label: 'Auth', onLogin: (email, password) async => false),
        surfaceSize: const Size(800, 600),
      );

      await tester.enterText(find.byType(EditableText).at(0), 'a@b.com');
      await tester.enterText(find.byType(EditableText).at(1), 'wrong');

      await tester.tap(find.text('Sign In').last);
      await tester.pumpAndSettle();

      expect(find.text('Operation failed. Please try again.'), findsOneWidget);
    });
  });
}
