import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_divider.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/layout/oi_column.dart';

/// The authentication modes available in an [OiAuthPage].
///
/// {@category Modules}
enum OiAuthMode {
  /// Email + password login form.
  login,

  /// Name + email + password registration form.
  register,

  /// Email-only forgot-password form.
  forgotPassword,
}

/// A full-page authentication module with login, registration, and
/// forgot-password flows.
///
/// Coverage: REQ-0071
///
/// Composes [OiTextInput], [OiButton], [OiLabel], [OiColumn], [OiDivider].
///
/// The page centres its content in a card-like column (max 400 dp) and
/// switches between forms via [OiAuthMode]. All action callbacks are optional;
/// when a callback is `null` the corresponding submit button is disabled.
///
/// {@category Modules}
class OiAuthPage extends StatefulWidget {
  /// Creates an [OiAuthPage] with all modes available.
  const OiAuthPage({
    required this.label,
    this.initialMode = OiAuthMode.login,
    this.onModeChanged,
    this.onLogin,
    this.onRegister,
    this.onForgotPassword,
    this.logo,
    this.footer,
    super.key,
  });

  /// Creates an [OiAuthPage] locked to [OiAuthMode.login].
  const OiAuthPage.login({
    required this.label,
    this.onLogin,
    this.onModeChanged,
    this.logo,
    this.footer,
    super.key,
  }) : initialMode = OiAuthMode.login,
       onRegister = null,
       onForgotPassword = null;

  /// Creates an [OiAuthPage] locked to [OiAuthMode.register].
  const OiAuthPage.register({
    required this.label,
    this.onRegister,
    this.onModeChanged,
    this.logo,
    this.footer,
    super.key,
  }) : initialMode = OiAuthMode.register,
       onLogin = null,
       onForgotPassword = null;

  /// Accessibility label announced by screen readers.
  final String label;

  /// The initial authentication mode to display. Defaults to
  /// [OiAuthMode.login].
  final OiAuthMode initialMode;

  /// Called when the user switches between authentication modes.
  final ValueChanged<OiAuthMode>? onModeChanged;

  /// Called when the user submits the login form. Returns `true` on success.
  final Future<bool> Function(String email, String password)? onLogin;

  /// Called when the user submits the register form. Returns `true` on success.
  final Future<bool> Function(String name, String email, String password)?
  onRegister;

  /// Called when the user submits the forgot-password form. Returns `true` on
  /// success.
  final Future<bool> Function(String email)? onForgotPassword;

  /// An optional logo widget displayed above the form.
  final Widget? logo;

  /// An optional footer widget displayed below the form.
  final Widget? footer;

  @override
  State<OiAuthPage> createState() => _OiAuthPageState();
}

class _OiAuthPageState extends State<OiAuthPage> {
  late OiAuthMode _mode;
  bool _isSubmitting = false;
  String? _error;

  // Controllers shared across forms. Disposed in [dispose].
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Mode switching
  // ---------------------------------------------------------------------------

  void _switchMode(OiAuthMode mode) {
    setState(() {
      _mode = mode;
      _error = null;
    });
    widget.onModeChanged?.call(mode);
  }

  // ---------------------------------------------------------------------------
  // Submission
  // ---------------------------------------------------------------------------

  Future<void> _submit() async {
    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      bool success;
      switch (_mode) {
        case OiAuthMode.login:
          success = await widget.onLogin!(
            _emailController.text,
            _passwordController.text,
          );
        case OiAuthMode.register:
          success = await widget.onRegister!(
            _nameController.text,
            _emailController.text,
            _passwordController.text,
          );
        case OiAuthMode.forgotPassword:
          success = await widget.onForgotPassword!(_emailController.text);
      }
      if (!success && mounted) {
        setState(() {
          _error = 'Operation failed. Please try again.';
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  bool get _canSubmit {
    switch (_mode) {
      case OiAuthMode.login:
        return widget.onLogin != null;
      case OiAuthMode.register:
        return widget.onRegister != null;
      case OiAuthMode.forgotPassword:
        return widget.onForgotPassword != null;
    }
  }

  // ---------------------------------------------------------------------------
  // Login form
  // ---------------------------------------------------------------------------

  Widget _buildLoginForm(BuildContext context) {
    final sp = context.spacing;
    final breakpoint = context.breakpoint;

    return OiColumn(
      breakpoint: breakpoint,
      gap: OiResponsive(sp.sm),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const OiLabel.h2('Sign In', textAlign: TextAlign.center,),
        SizedBox(height: sp.sm),
        OiTextInput(
          controller: _emailController,
          label: 'Email',
          placeholder: 'you@example.com',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        OiTextInput(
          controller: _passwordController,
          label: 'Password',
          placeholder: 'Enter your password',
          obscureText: true,
          textInputAction: TextInputAction.done,
          onSubmitted: _canSubmit && !_isSubmitting ? (_) => _submit() : null,
        ),
        if (_error != null) _buildError(context),
        SizedBox(height: sp.sm),
        OiButton.primary(
          label: 'Sign In',
          onTap: _canSubmit && !_isSubmitting ? _submit : null,
          loading: _isSubmitting,
        ),
        SizedBox(height: sp.sm),
        const OiDivider(),
        SizedBox(height: sp.sm),
        if (widget.onForgotPassword != null)
          _buildLink(
            'Forgot password?',
            () => _switchMode(OiAuthMode.forgotPassword),
          ),
        if (widget.onRegister != null)
          _buildLink(
            "Don't have an account? Sign Up",
            () => _switchMode(OiAuthMode.register),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Register form
  // ---------------------------------------------------------------------------

  Widget _buildRegisterForm(BuildContext context) {
    final sp = context.spacing;
    final breakpoint = context.breakpoint;

    return OiColumn(
      breakpoint: breakpoint,
      gap: OiResponsive(sp.sm),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const OiLabel.h2('Create Account', textAlign: TextAlign.center,),
        SizedBox(height: sp.sm),
        OiTextInput(
          controller: _nameController,
          label: 'Full Name',
          placeholder: 'Jane Doe',
          textInputAction: TextInputAction.next,
        ),
        OiTextInput(
          controller: _emailController,
          label: 'Email',
          placeholder: 'you@example.com',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        OiTextInput(
          controller: _passwordController,
          label: 'Password',
          placeholder: 'Choose a password',
          obscureText: true,
          textInputAction: TextInputAction.done,
          onSubmitted: _canSubmit && !_isSubmitting ? (_) => _submit() : null,
        ),
        if (_error != null) _buildError(context),
        SizedBox(height: sp.sm),
        OiButton.primary(
          label: 'Create Account',
          onTap: _canSubmit && !_isSubmitting ? _submit : null,
          loading: _isSubmitting,
          fullWidth: true,
        ),
        SizedBox(height: sp.sm),
        const OiDivider(),
        SizedBox(height: sp.sm),
        if (widget.onLogin != null)
          _buildLink(
            'Already have an account? Sign In',
            () => _switchMode(OiAuthMode.login),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Forgot password form
  // ---------------------------------------------------------------------------

  Widget _buildForgotPasswordForm(BuildContext context) {
    final sp = context.spacing;
    final breakpoint = context.breakpoint;

    return OiColumn(
      breakpoint: breakpoint,
      gap: OiResponsive(sp.sm),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const OiLabel.h2('Reset Password', textAlign: TextAlign.center,),
        SizedBox(height: sp.sm),
        const OiLabel.body(
          'Enter your email and we will send you a reset link.',
        ),
        OiTextInput(
          controller: _emailController,
          label: 'Email',
          placeholder: 'you@example.com',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onSubmitted: _canSubmit && !_isSubmitting ? (_) => _submit() : null,
        ),
        if (_error != null) _buildError(context),
        SizedBox(height: sp.sm),
        OiButton.primary(
          label: 'Send Reset Link',
          onTap: _canSubmit && !_isSubmitting ? _submit : null,
          loading: _isSubmitting,
          fullWidth: true,
        ),
        SizedBox(height: sp.sm),
        const OiDivider(),
        SizedBox(height: sp.sm),
        if (widget.onLogin != null)
          _buildLink('Back to Sign In', () => _switchMode(OiAuthMode.login)),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Shared helpers
  // ---------------------------------------------------------------------------

  Widget _buildError(BuildContext context) {
    final colors = context.colors;
    final sp = context.spacing;
    return Container(
      padding: EdgeInsets.all(sp.sm),
      decoration: BoxDecoration(
        color: colors.error.muted,
        borderRadius: context.radius.sm,
      ),
      child: OiLabel.body(_error!, color: colors.error.base),
    );
  }

  Widget _buildLink(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Semantics(
        button: true,
        label: text,
        child: Builder(
          builder: (context) {
            return OiLabel.small(text, color: context.colors.primary.base);
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final sp = context.spacing;

    final Widget form;
    switch (_mode) {
      case OiAuthMode.login:
        form = _buildLoginForm(context);
      case OiAuthMode.register:
        form = _buildRegisterForm(context);
      case OiAuthMode.forgotPassword:
        form = _buildForgotPasswordForm(context);
    }

    return Semantics(
      label: widget.label,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.logo != null) ...[
                widget.logo!,
                SizedBox(height: sp.sm),
              ],
              form,
              if (widget.footer != null) ...[
                SizedBox(height: sp.lg),
                widget.footer!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
