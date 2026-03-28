import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_autoforms/obers_ui_autoforms.dart';

import 'package:obers_ui_example/apps/autoforms/models/registration_data.dart';

// ── Field enum ──────────────────────────────────────────────────────────────

/// All fields across the three wizard steps.
enum RegField {
  // Step 1 — Personal Info
  firstName,
  lastName,
  email,

  // Step 2 — Account Setup
  username,
  password,
  passwordConfirm,

  // Step 3 — Preferences
  newsletter,
  theme,
  notificationTags,
}

// ── Controller ──────────────────────────────────────────────────────────────

/// Controller for the multi-step registration wizard.
class RegistrationController
    extends OiAfController<RegField, RegistrationData> {
  @override
  void defineFields() {
    // ── Step 1: Personal Info ─────────────────────────────────────────────
    addTextField(
      RegField.firstName,
      required: true,
      validators: [
        OiAfValidators.minLength(2, message: 'At least 2 characters.'),
      ],
    );

    addTextField(
      RegField.lastName,
      required: true,
      validators: [
        OiAfValidators.minLength(2, message: 'At least 2 characters.'),
      ],
    );

    addTextField(
      RegField.email,
      required: true,
      validators: [
        OiAfValidators.email(),
      ],
    );

    // ── Step 2: Account Setup ─────────────────────────────────────────────
    addTextField(
      RegField.username,
      required: true,
      dependsOn: [RegField.firstName, RegField.lastName],
      derive: (form) {
        final first = form.getOr<String>(RegField.firstName, '').trim();
        final last = form.getOr<String>(RegField.lastName, '').trim();
        if (first.isEmpty && last.isEmpty) return '';
        return '${first}_$last'
            .toLowerCase()
            .replaceAll(RegExp(r'\s+'), '_')
            .replaceAll(RegExp('[^a-z0-9_]'), '');
      },
      validators: [
        OiAfValidators.minLength(3, message: 'At least 3 characters.'),
        OiAfValidators.alphaDash(
          asciiOnly: true,
          message: 'Only letters, numbers, dashes and underscores.',
        ),
      ],
    );

    addTextField(
      RegField.password,
      required: true,
      validators: [
        OiAfValidators.securePassword(
          requiresUppercase: true,
          requiresDigit: true,
          message: 'Needs 8+ chars, an uppercase letter, and a digit.',
        ),
      ],
    );

    addTextField(
      RegField.passwordConfirm,
      required: true,
      revalidateWhen: [RegField.password],
      validators: [
        OiAfValidators.equalsField(
          RegField.password,
          message: 'Passwords do not match.',
        ),
      ],
    );

    // ── Step 3: Preferences ───────────────────────────────────────────────
    addBoolField(
      RegField.newsletter,
      initialValue: false,
    );

    addSegmentedControlField<String>(
      RegField.theme,
      initialValue: 'system',
      segments: const [
        OiAfOption(value: 'light', label: 'Light'),
        OiAfOption(value: 'system', label: 'System'),
        OiAfOption(value: 'dark', label: 'Dark'),
      ],
    );

    addTagField(
      RegField.notificationTags,
      initialValue: const ['general'],
      maxTags: 5,
    );
  }

  @override
  RegistrationData buildData() {
    return RegistrationData(
      firstName: getOr(RegField.firstName, ''),
      lastName: getOr(RegField.lastName, ''),
      email: getOr(RegField.email, ''),
      username: getOr(RegField.username, ''),
      password: getOr(RegField.password, ''),
      newsletter: getOr(RegField.newsletter, false) ?? false,
      theme: getOr(RegField.theme, 'system'),
      notificationTags: getOr(RegField.notificationTags, const <String>[]),
    );
  }

  /// Validates only the fields belonging to the given step.
  Future<bool> validateStep(int step) async {
    final fields = _fieldsForStep(step);
    final results = await Future.wait(
      fields.map((f) => validate(field: f)),
    );
    return results.every((r) => r);
  }

  /// Returns the fields for a given step index.
  static List<RegField> _fieldsForStep(int step) {
    switch (step) {
      case 0:
        return [RegField.firstName, RegField.lastName, RegField.email];
      case 1:
        return [RegField.username, RegField.password, RegField.passwordConfirm];
      case 2:
        return [RegField.newsletter, RegField.theme, RegField.notificationTags];
      default:
        return [];
    }
  }
}

// ── Screen ──────────────────────────────────────────────────────────────────

/// Multi-step registration wizard showcasing step-by-step form flow.
class RegistrationWizardScreen extends StatefulWidget {
  const RegistrationWizardScreen({super.key});

  @override
  State<RegistrationWizardScreen> createState() =>
      _RegistrationWizardScreenState();
}

class _RegistrationWizardScreenState extends State<RegistrationWizardScreen> {
  late final RegistrationController _controller;
  int _currentStep = 0;

  static const _stepTitles = [
    'Personal Info',
    'Account Setup',
    'Preferences',
  ];

  static const _totalSteps = 3;

  @override
  void initState() {
    super.initState();
    _controller = RegistrationController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _goNext() async {
    final valid = await _controller.validateStep(_currentStep);
    if (!valid) return;
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    }
  }

  void _goBack() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colors = context.colors;

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: OiAfForm<RegField, RegistrationData>(
            controller: _controller,
            onSubmit: (data, ctrl) async {
              await Future<void>.delayed(const Duration(seconds: 1));
              if (!context.mounted) return;
              OiToast.show(
                context,
                message: 'Welcome, ${data.firstName}! Account created.',
                level: OiToastLevel.success,
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: spacing.md),
                const OiLabel.h2('Registration Wizard'),
                SizedBox(height: spacing.xs),
                OiLabel.body(
                  'Complete all steps to create your account.',
                  color: colors.textSubtle,
                ),
                SizedBox(height: spacing.lg),

                // ── Progress indicator ──────────────────────────────────
                _StepProgress(
                  current: _currentStep,
                  total: _totalSteps,
                  titles: _stepTitles,
                ),
                SizedBox(height: spacing.lg),

                // ── Step title ──────────────────────────────────────────
                OiLabel.h3(
                  'Step ${_currentStep + 1}: ${_stepTitles[_currentStep]}',
                ),
                SizedBox(height: spacing.md),

                // ── Step content ────────────────────────────────────────
                _buildStep(_currentStep),

                SizedBox(height: spacing.xl),

                // ── Navigation buttons ──────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentStep > 0)
                      OiButton.secondary(
                        label: 'Back',
                        icon: OiIcons.chevronLeft,
                        onTap: _goBack,
                      )
                    else
                      const SizedBox.shrink(),
                    if (_currentStep < _totalSteps - 1)
                      OiButton.primary(
                        label: 'Next',
                        icon: OiIcons.chevronRight,
                        onTap: _goNext,
                      )
                    else
                      const OiAfSubmitButton<RegField, RegistrationData>(
                        label: 'Complete Registration',
                        loadingLabel: 'Submitting…',
                        icon: OiIcons.check,
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

  Widget _buildStep(int step) {
    final spacing = context.spacing;

    switch (step) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const OiAfTextInput<RegField>(
              field: RegField.firstName,
              label: 'First Name',
              placeholder: 'e.g. Maria',
            ),
            SizedBox(height: spacing.md),
            const OiAfTextInput<RegField>(
              field: RegField.lastName,
              label: 'Last Name',
              placeholder: 'e.g. Hofmann',
            ),
            SizedBox(height: spacing.md),
            const OiAfTextInput<RegField>(
              field: RegField.email,
              label: 'Email Address',
              placeholder: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        );

      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const OiAfTextInput<RegField>(
              field: RegField.username,
              label: 'Username',
              hint: 'Auto-derived from your name — edit freely.',
              placeholder: 'e.g. maria_hofmann',
            ),
            SizedBox(height: spacing.md),
            const OiAfTextInput<RegField>.password(
              field: RegField.password,
              label: 'Password',
            ),
            SizedBox(height: spacing.md),
            const OiAfTextInput<RegField>.password(
              field: RegField.passwordConfirm,
              label: 'Confirm Password',
            ),
          ],
        );

      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const OiAfSwitch<RegField>(
              field: RegField.newsletter,
              label: 'Subscribe to newsletter',
            ),
            SizedBox(height: spacing.lg),
            const OiLabel.bodyStrong('Theme Preference'),
            SizedBox(height: spacing.xs),
            const OiAfSegmentedControl<RegField, String>(
              field: RegField.theme,
              options: [
                OiAfOption(value: 'light', label: 'Light'),
                OiAfOption(value: 'system', label: 'System'),
                OiAfOption(value: 'dark', label: 'Dark'),
              ],
              expand: true,
              semanticLabel: 'Theme preference',
            ),
            SizedBox(height: spacing.lg),
            const OiAfTagInput<RegField>(
              field: RegField.notificationTags,
              label: 'Notification Topics',
              hint: 'Add up to 5 tags.',
              placeholder: 'Type and press Enter…',
              maxTags: 5,
              suggestions: [
                'general',
                'promotions',
                'updates',
                'security',
                'billing',
                'events',
              ],
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

// ── Step progress indicator ─────────────────────────────────────────────────

class _StepProgress extends StatelessWidget {
  const _StepProgress({
    required this.current,
    required this.total,
    required this.titles,
  });

  final int current;
  final int total;
  final List<String> titles;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radius = context.radius;

    return Column(
      children: [
        // ── Progress bar ──────────────────────────────────────────────
        ClipRRect(
          borderRadius: radius.sm,
          child: SizedBox(
            height: 6,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final fraction = (current + 1) / total;
                return Stack(
                  children: [
                    Container(color: colors.surfaceSubtle),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: constraints.maxWidth * fraction,
                      decoration: BoxDecoration(
                        color: colors.primary.base,
                        borderRadius: radius.sm,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        SizedBox(height: spacing.sm),

        // ── Step labels ───────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(total, (i) {
            final isActive = i == current;
            final isDone = i < current;
            return Expanded(
              child: Center(
                child: OiLabel.caption(
                  titles[i],
                  color: isActive
                      ? colors.primary.base
                      : isDone
                          ? colors.success.base
                          : colors.textMuted,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
