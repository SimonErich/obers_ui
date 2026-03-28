import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_autoforms/obers_ui_autoforms.dart';

import 'package:obers_ui_example/apps/autoforms/models/signup_form_data.dart';

// ── Field enum ──────────────────────────────────────────────────────────────

/// All fields in the signup form.
enum SignupField {
  name,
  username,
  email,
  password,
  passwordConfirm,
  newsletter,
  gender,
  birthDate,
  volume,
}

// ── Controller ──────────────────────────────────────────────────────────────

/// Controller for the signup form.
class SignupFormController
    extends OiAfController<SignupField, SignupFormData> {
  @override
  void defineFields() {
    addTextField(
      SignupField.name,
      required: true,
      validators: [
        OiAfValidators.minLength(2, message: 'Name must be at least 2 characters.'),
      ],
    );

    addTextField(
      SignupField.username,
      required: true,
      dependsOn: [SignupField.name],
      derive: (form) {
        final name = form.getOr<String>(SignupField.name, '');
        return name
            .trim()
            .toLowerCase()
            .replaceAll(RegExp(r'\s+'), '_')
            .replaceAll(RegExp('[^a-z0-9_]'), '');
      },
      validators: [
        OiAfValidators.minLength(3, message: 'Username must be at least 3 characters.'),
        OiAfValidators.alphaDash(
          asciiOnly: true,
          message: 'Only letters, numbers, dashes and underscores.',
        ),
      ],
    );

    addTextField(
      SignupField.email,
      required: true,
      validators: [
        OiAfValidators.email(),
      ],
    );

    addTextField(
      SignupField.password,
      required: true,
      validators: [
        OiAfValidators.securePassword(
          requiresUppercase: true,
          requiresDigit: true,
          message: 'Password must have 8+ chars, an uppercase letter, and a digit.',
        ),
      ],
    );

    addTextField(
      SignupField.passwordConfirm,
      required: true,
      revalidateWhen: [SignupField.password],
      validators: [
        OiAfValidators.equalsField(
          SignupField.password,
          message: 'Passwords do not match.',
        ),
      ],
    );

    addBoolField(
      SignupField.newsletter,
      initialValue: false,
    );

    addRadioField<String>(
      SignupField.gender,
      options: const [
        OiAfOption(value: 'male', label: 'Male'),
        OiAfOption(value: 'female', label: 'Female'),
        OiAfOption(value: 'other', label: 'Other'),
      ],
      visibleWhen: (form) => form.getOr<bool?>(SignupField.newsletter, false) ?? false,
    );

    addDatePickerField(
      SignupField.birthDate,
      maxDate: DateTime.now(),
      minDate: DateTime(1920),
    );

    addSliderField(
      SignupField.volume,
      initialValue: 50,
      min: 0,
      max: 100,
      divisions: 20,
    );
  }

  @override
  SignupFormData buildData() {
    return SignupFormData(
      name: getOr(SignupField.name, ''),
      username: getOr(SignupField.username, ''),
      email: getOr(SignupField.email, ''),
      password: getOr(SignupField.password, ''),
      newsletter: getOr(SignupField.newsletter, false) ?? false,
      gender: get<String>(SignupField.gender),
      birthDate: get<DateTime>(SignupField.birthDate),
      volume: getOr(SignupField.volume, 50),
    );
  }
}

// ── Screen ──────────────────────────────────────────────────────────────────

/// A comprehensive single-screen signup form showcasing autoforms features.
class SignupFormScreen extends StatefulWidget {
  const SignupFormScreen({super.key});

  @override
  State<SignupFormScreen> createState() => _SignupFormScreenState();
}

class _SignupFormScreenState extends State<SignupFormScreen> {
  late final SignupFormController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SignupFormController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: OiAfForm<SignupField, SignupFormData>(
            controller: _controller,
            onSubmit: (data, ctrl) async {
              // Simulate network delay.
              await Future<void>.delayed(const Duration(seconds: 1));
              if (!context.mounted) return;
              OiToast.show(
                context,
                message: 'Account created for ${data.name}!',
                level: OiToastLevel.success,
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: spacing.md),
                const OiLabel.h2('Create Account'),
                SizedBox(height: spacing.xs),
                OiLabel.body(
                  'Fill in the details below to sign up.',
                  color: context.colors.textSubtle,
                ),
                SizedBox(height: spacing.lg),

                // ── Error summary ───────────────────────────────────────
                const OiAfErrorSummary<SignupField>(
                  showOnlyAfterSubmit: true,
                ),
                SizedBox(height: spacing.md),

                // ── Name ────────────────────────────────────────────────
                const OiAfTextInput<SignupField>(
                  field: SignupField.name,
                  label: 'Full Name',
                  placeholder: 'e.g. Maria Hofmann',
                ),
                SizedBox(height: spacing.md),

                // ── Username (derived from name) ────────────────────────
                const OiAfTextInput<SignupField>(
                  field: SignupField.username,
                  label: 'Username',
                  hint: 'Auto-derived from your name — edit freely.',
                  placeholder: 'e.g. maria_hofmann',
                ),
                SizedBox(height: spacing.md),

                // ── Email ───────────────────────────────────────────────
                const OiAfTextInput<SignupField>(
                  field: SignupField.email,
                  label: 'Email Address',
                  placeholder: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: spacing.md),

                // ── Password ────────────────────────────────────────────
                const OiAfTextInput<SignupField>.password(
                  field: SignupField.password,
                  label: 'Password',
                ),
                SizedBox(height: spacing.md),

                // ── Confirm password ────────────────────────────────────
                const OiAfTextInput<SignupField>.password(
                  field: SignupField.passwordConfirm,
                  label: 'Confirm Password',
                ),
                SizedBox(height: spacing.lg),

                // ── Newsletter checkbox ─────────────────────────────────
                const OiAfCheckbox<SignupField>(
                  field: SignupField.newsletter,
                  label: 'Subscribe to our newsletter',
                ),
                SizedBox(height: spacing.md),

                // ── Gender radio (conditional) ──────────────────────────
                _ConditionalSection(
                  controller: _controller,
                  field: SignupField.gender,
                  label: 'Gender Preference',
                  child: const OiAfRadio<SignupField, String>(
                    field: SignupField.gender,
                    options: [
                      OiAfOption(value: 'male', label: 'Male'),
                      OiAfOption(value: 'female', label: 'Female'),
                      OiAfOption(value: 'other', label: 'Other'),
                    ],
                    direction: Axis.horizontal,
                  ),
                ),
                SizedBox(height: spacing.md),

                // ── Birth date ──────────────────────────────────────────
                OiAfDatePickerField<SignupField>(
                  field: SignupField.birthDate,
                  label: 'Date of Birth',
                  placeholder: 'Select your birth date',
                  maxDate: DateTime.now(),
                  minDate: DateTime(1920),
                  clearable: true,
                  semanticLabel: 'Date of birth picker',
                ),
                SizedBox(height: spacing.lg),

                // ── Volume slider ───────────────────────────────────────
                const OiLabel.bodyStrong('Notification Volume'),
                SizedBox(height: spacing.xs),
                const OiAfSlider<SignupField>(
                  field: SignupField.volume,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  label: 'Volume',
                  showLabels: true,
                ),
                SizedBox(height: spacing.xl),

                // ── Actions ─────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const OiAfResetButton<SignupField>(
                      label: 'Reset',
                      hideWhenClean: true,
                    ),
                    SizedBox(width: spacing.sm),
                    const OiAfSubmitButton<SignupField, SignupFormData>(
                      label: 'Create Account',
                      loadingLabel: 'Creating…',
                      icon: OiIcons.userPlus,
                    ),
                  ],
                ),
                SizedBox(height: spacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Helper widget ───────────────────────────────────────────────────────────

/// Shows a labeled section only when the field is visible.
class _ConditionalSection extends StatefulWidget {
  const _ConditionalSection({
    required this.controller,
    required this.field,
    required this.label,
    required this.child,
  });

  final SignupFormController controller;
  final SignupField field;
  final String label;
  final Widget child;

  @override
  State<_ConditionalSection> createState() => _ConditionalSectionState();
}

class _ConditionalSectionState extends State<_ConditionalSection> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.controller.isFieldVisible(widget.field)) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OiLabel.bodyStrong(widget.label),
        SizedBox(height: context.spacing.xs),
        widget.child,
      ],
    );
  }
}
