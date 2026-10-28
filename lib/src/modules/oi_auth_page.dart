import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/display/oi_avatar.dart';
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

  /// Lock screen: a known user's avatar and name with a password-only
  /// unlock field.
  lock,
}

/// The texts of an [OiAuthPage], in English by default; pass translations
/// to localize the page.
///
/// {@category Modules}
class OiAuthPageLabels {
  /// Creates an [OiAuthPageLabels].
  const OiAuthPageLabels({
    this.signIn = 'Sign In',
    this.createAccount = 'Create Account',
    this.signUp = 'Sign Up',
    this.resetPassword = 'Reset Password',
    this.resetDescription =
        'Enter your email and we will send you a reset link.',
    this.sendResetLink = 'Send Reset Link',
    this.backToSignIn = 'Back to Sign In',
    this.forgotPassword = 'Forgot password?',
    this.noAccount = "Don't have an account? ",
    this.haveAccount = 'Already have an account? ',
    this.email = 'Email',
    this.emailPlaceholder = 'you@example.com',
    this.password = 'Password',
    this.passwordPlaceholder = 'Enter your password',
    this.newPasswordPlaceholder = 'Choose a password',
    this.fullName = 'Full Name',
    this.fullNamePlaceholder = 'Jane Doe',
    this.unlock = 'Unlock',
    this.defaultUserName = 'User',
    this.operationFailed = 'Operation failed. Please try again.',
  });

  /// Title and button label of the sign-in form, and the link to it.
  final String signIn;

  /// Title and button label of the sign-up form.
  final String createAccount;

  /// Label of the link to the sign-up form.
  final String signUp;

  /// Title of the reset password form.
  final String resetPassword;

  /// Description of the reset password form.
  final String resetDescription;

  /// Label of the reset password button.
  final String sendResetLink;

  /// Label of the link from the reset form back to sign in.
  final String backToSignIn;

  /// Label of the link to the reset password form.
  final String forgotPassword;

  /// Text before the link to the sign-up form.
  final String noAccount;

  /// Text before the link to the sign-in form.
  final String haveAccount;

  /// Label of the email inputs.
  final String email;

  /// Placeholder of the email inputs.
  final String emailPlaceholder;

  /// Label of the password inputs.
  final String password;

  /// Placeholder of the sign-in and unlock password inputs.
  final String passwordPlaceholder;

  /// Placeholder of the sign-up password input.
  final String newPasswordPlaceholder;

  /// Label of the name input.
  final String fullName;

  /// Placeholder of the name input.
  final String fullNamePlaceholder;

  /// Label of the unlock button.
  final String unlock;

  /// Name shown on the lock screen when no user name is given.
  final String defaultUserName;

  /// Error shown when an action fails.
  final String operationFailed;
}

/// A full-page authentication module with login, registration,
/// forgot-password, and lock-screen flows.
///
/// Coverage: REQ-0071
///
/// Composes [OiTextInput], [OiButton], [OiLabel], [OiColumn], [OiDivider],
/// and [OiAvatar] (lock screen).
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
    this.onUnlock,
    this.userName,
    this.avatar,
    this.logo,
    this.footer,
    this.labels = const OiAuthPageLabels(),
    super.key,
  });

  /// Creates an [OiAuthPage] locked to [OiAuthMode.login].
  const OiAuthPage.login({
    required this.label,
    this.onLogin,
    this.onModeChanged,
    this.logo,
    this.footer,
    this.labels = const OiAuthPageLabels(),
    super.key,
  }) : initialMode = OiAuthMode.login,
       onRegister = null,
       onForgotPassword = null,
       onUnlock = null,
       userName = null,
       avatar = null;

  /// Creates an [OiAuthPage] locked to [OiAuthMode.register].
  const OiAuthPage.register({
    required this.label,
    this.onRegister,
    this.onModeChanged,
    this.logo,
    this.footer,
    this.labels = const OiAuthPageLabels(),
    super.key,
  }) : initialMode = OiAuthMode.register,
       onLogin = null,
       onForgotPassword = null,
       onUnlock = null,
       userName = null,
       avatar = null;

  /// Creates an [OiAuthPage] locked to [OiAuthMode.lock].
  ///
  /// Shows the known user's [avatar] and [userName] above a password-only
  /// field and an unlock button that invokes [onUnlock].
  const OiAuthPage.lock({
    required this.label,
    this.onUnlock,
    this.userName,
    this.avatar,
    this.onModeChanged,
    this.logo,
    this.footer,
    this.labels = const OiAuthPageLabels(),
    super.key,
  }) : initialMode = OiAuthMode.lock,
       onLogin = null,
       onRegister = null,
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

  /// Called when the user submits the lock-screen unlock form. Returns
  /// `true` on success.
  final Future<bool> Function(String password)? onUnlock;

  /// The known user's display name, shown on the lock screen.
  final String? userName;

  /// An avatar widget for the lock screen. When `null`, a default
  /// [OiAvatar] built from [userName]'s initials is shown.
  final Widget? avatar;

  /// An optional logo widget displayed above the form.
  final Widget? logo;

  /// An optional footer widget displayed below the form.
  final Widget? footer;

  /// The page's texts; pass translations to localize it.
  final OiAuthPageLabels labels;

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
        case OiAuthMode.lock:
          success = await widget.onUnlock!(_passwordController.text);
      }
      if (!success && mounted) {
        setState(() {
          _error = widget.labels.operationFailed;
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
      case OiAuthMode.lock:
        return widget.onUnlock != null;
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
        OiLabel.h2(
          widget.labels.signIn,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: sp.sm),
        OiTextInput(
          controller: _emailController,
          label: widget.labels.email,
          placeholder: widget.labels.emailPlaceholder,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        OiTextInput(
          controller: _passwordController,
          label: widget.labels.password,
          placeholder: widget.labels.passwordPlaceholder,
          obscureText: true,
          textInputAction: TextInputAction.done,
          onSubmitted: _canSubmit && !_isSubmitting ? (_) => _submit() : null,
        ),
        if (_error != null) _buildError(context),
        SizedBox(height: sp.sm),
        OiButton.primary(
          label: widget.labels.signIn,
          onTap: _canSubmit && !_isSubmitting ? _submit : null,
          loading: _isSubmitting,
        ),
        SizedBox(height: sp.sm),
        const OiDivider(),
        SizedBox(height: sp.sm),
        if (widget.onForgotPassword != null)
          _buildLink(
            widget.labels.forgotPassword,
            () => _switchMode(OiAuthMode.forgotPassword),
          ),
        if (widget.onRegister != null)
          _buildLink(
            widget.labels.signUp,
            () => _switchMode(OiAuthMode.register),
            prefix: widget.labels.noAccount,
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
        OiLabel.h2(
          widget.labels.createAccount,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: sp.sm),
        OiTextInput(
          controller: _nameController,
          label: widget.labels.fullName,
          placeholder: widget.labels.fullNamePlaceholder,
          textInputAction: TextInputAction.next,
        ),
        OiTextInput(
          controller: _emailController,
          label: widget.labels.email,
          placeholder: widget.labels.emailPlaceholder,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        OiTextInput(
          controller: _passwordController,
          label: widget.labels.password,
          placeholder: widget.labels.newPasswordPlaceholder,
          obscureText: true,
          textInputAction: TextInputAction.done,
          onSubmitted: _canSubmit && !_isSubmitting ? (_) => _submit() : null,
        ),
        if (_error != null) _buildError(context),
        SizedBox(height: sp.sm),
        OiButton.primary(
          label: widget.labels.createAccount,
          onTap: _canSubmit && !_isSubmitting ? _submit : null,
          loading: _isSubmitting,
          fullWidth: true,
        ),
        SizedBox(height: sp.sm),
        const OiDivider(),
        SizedBox(height: sp.sm),
        if (widget.onLogin != null)
          _buildLink(
            widget.labels.signIn,
            () => _switchMode(OiAuthMode.login),
            prefix: widget.labels.haveAccount,
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
        OiLabel.h2(
          widget.labels.resetPassword,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: sp.sm),
        OiLabel.body(
          widget.labels.resetDescription,
        ),
        OiTextInput(
          controller: _emailController,
          label: widget.labels.email,
          placeholder: widget.labels.emailPlaceholder,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onSubmitted: _canSubmit && !_isSubmitting ? (_) => _submit() : null,
        ),
        if (_error != null) _buildError(context),
        SizedBox(height: sp.sm),
        OiButton.primary(
          label: widget.labels.sendResetLink,
          onTap: _canSubmit && !_isSubmitting ? _submit : null,
          loading: _isSubmitting,
          fullWidth: true,
        ),
        SizedBox(height: sp.sm),
        const OiDivider(),
        SizedBox(height: sp.sm),
        if (widget.onLogin != null)
          _buildLink(
            widget.labels.backToSignIn,
            () => _switchMode(OiAuthMode.login),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Lock form
  // ---------------------------------------------------------------------------

  Widget _buildLockForm(BuildContext context) {
    final sp = context.spacing;
    final breakpoint = context.breakpoint;
    final name = widget.userName ?? widget.labels.defaultUserName;

    return OiColumn(
      breakpoint: breakpoint,
      gap: OiResponsive(sp.sm),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child:
              widget.avatar ??
              OiAvatar(
                semanticLabel: name,
                initials: _initials(name),
                size: OiAvatarSize.xl,
              ),
        ),
        SizedBox(height: sp.sm),
        OiLabel.h2(name, textAlign: TextAlign.center),
        SizedBox(height: sp.sm),
        OiTextInput(
          controller: _passwordController,
          label: widget.labels.password,
          placeholder: widget.labels.passwordPlaceholder,
          obscureText: true,
          textInputAction: TextInputAction.done,
          onSubmitted: _canSubmit && !_isSubmitting ? (_) => _submit() : null,
        ),
        if (_error != null) _buildError(context),
        SizedBox(height: sp.sm),
        OiButton.primary(
          label: widget.labels.unlock,
          onTap: _canSubmit && !_isSubmitting ? _submit : null,
          loading: _isSubmitting,
          fullWidth: true,
        ),
      ],
    );
  }

  /// Derives up to two uppercase initials from a display [name].
  String _initials(String name) {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) {
      return words.first.substring(0, 1).toUpperCase();
    }
    return (words.first.substring(0, 1) + words.last.substring(0, 1))
        .toUpperCase();
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

  Widget _buildLink(
    String buttonLabel,
    VoidCallback onTap, {
    String? prefix,
  }) {
    return Wrap(
      children: [
        if (prefix != null) OiLabel.body(prefix),
        GestureDetector(
          onTap: onTap,
          child: Semantics(
            button: true,
            label: buttonLabel,
            child: OiLabel.link(buttonLabel),
          ),
        ),
      ],
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
      case OiAuthMode.lock:
        form = _buildLockForm(context);
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
