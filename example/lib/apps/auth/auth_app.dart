import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/data/mock_auth.dart';
import 'package:obers_ui_example/shell/showcase_shell.dart';
import 'package:obers_ui_example/theme/theme_state.dart';

/// Root widget for the Auth showcase mini-app.
///
/// Single screen using [OiAuthPage] with demo credentials.
class AuthApp extends StatelessWidget {
  const AuthApp({required this.themeState, super.key});

  final ThemeState themeState;

  @override
  Widget build(BuildContext context) {
    return ShowcaseShell(
      title: 'Auth',
      themeState: themeState,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(context.spacing.lg),
        child: OiAuthPage(
          label: 'Alpenglueck authentication',
          logo: const Center(child: OiLabel.h2('Alpenglueck')),
          footer: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const OiLabel.small(kDemoHint),
                const SizedBox(height: 8),
                OiLabel.small(
                  'Password strength: '
                  '"Your password is weaker than a decaffeinated Melange"',
                  color: context.colors.warning.base,
                ),
              ],
            ),
          ),
          onLogin: (email, password) async {
            await Future<void>.delayed(const Duration(milliseconds: 600));
            final success =
                email == kDemoEmail && password == kDemoPassword;
            if (context.mounted) {
              OiToast.show(
                context,
                message: success ? kLoginSuccess : kLoginFailed,
                level:
                    success ? OiToastLevel.success : OiToastLevel.error,
              );
            }
            return success;
          },
          onRegister: (name, email, password) async {
            await Future<void>.delayed(const Duration(milliseconds: 600));
            if (context.mounted) {
              OiToast.show(
                context,
                message: kRegisterSuccess,
                level: OiToastLevel.success,
              );
            }
            return true;
          },
          onForgotPassword: (email) async {
            await Future<void>.delayed(const Duration(milliseconds: 600));
            if (context.mounted) {
              OiToast.show(
                context,
                message: kForgotSuccess,
              );
            }
            return true;
          },
        ),
      ),
    );
  }
}
