import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_autoforms/obers_ui_autoforms.dart';
import 'package:obers_ui_example/apps/component_library/shared/component_showcase_section.dart';

// ── Contact form controller ───────────────────────────────────────────────────

enum _ContactField { name, email, message }

class _ContactController
    extends OiAfController<_ContactField, Map<String, dynamic>> {
  @override
  void defineFields() {
    addTextField(_ContactField.name, required: true);
    addTextField(
      _ContactField.email,
      required: true,
      validators: [OiAfValidators.email()],
    );
    addTextField(_ContactField.message);
  }

  @override
  Map<String, dynamic> buildData() => json();
}

// ── Screen ───────────────────────────────────────────────────────────────────

/// Showcase screen for form, stepper, wizard, and address form widgets.
class FormsWizardsScreen extends StatefulWidget {
  const FormsWizardsScreen({super.key});

  @override
  State<FormsWizardsScreen> createState() => _FormsWizardsScreenState();
}

class _FormsWizardsScreenState extends State<FormsWizardsScreen> {
  late final _ContactController _contactController;
  late final _ContactController _horizontalController;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _contactController = _ContactController();
    _horizontalController = _ContactController();
  }

  @override
  void dispose() {
    _contactController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── OiFormSection ──────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Form Section',
            widgetName: 'OiFormSection',
            description:
                'A visual grouping widget for form fields with an optional '
                'title and description header. Works with any state '
                'management — pair it with OiAfForm from '
                'obers_ui_autoforms or bring your own controller.',
            examples: [
              ComponentExample(
                title: 'Contact form',
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: OiAfForm<_ContactField, Map<String, dynamic>>(
                    controller: _contactController,
                    onSubmit: (_, __) async {},
                    child: const OiFormSection(
                      title: 'Contact Us',
                      description:
                          "Fill in your details and we'll get back to you.",
                      children: [
                        OiAfTextInput(
                          field: _ContactField.name,
                          label: 'Full Name',
                        ),
                        OiAfTextInput(
                          field: _ContactField.email,
                          label: 'Email',
                        ),
                        OiAfTextInput(
                          field: _ContactField.message,
                          label: 'Message',
                          maxLines: 3,
                        ),
                        OiAfSubmitButton<_ContactField, Map<String, dynamic>>(
                          label: 'Send',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ComponentExample(
                title: 'Horizontal layout',
                child: OiAfForm<_ContactField, Map<String, dynamic>>(
                  controller: _horizontalController,
                  onSubmit: (_, __) async {},
                  child: const OiFormSection(
                    title: 'Name',
                    layout: OiFormLayout.horizontal,
                    children: [
                      OiAfTextInput(
                        field: _ContactField.name,
                        label: 'First Name',
                      ),
                      OiAfTextInput(
                        field: _ContactField.email,
                        label: 'Last Name',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── OiStepper ──────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Stepper',
            widgetName: 'OiStepper',
            description:
                'A visual step indicator showing progress through a '
                'multi-step process. Supports horizontal, vertical, and '
                'compact styles with completed and error states.',
            examples: [
              ComponentExample(
                title: 'Horizontal stepper',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OiStepper(
                      totalSteps: 3,
                      currentStep: _currentStep,
                      stepLabels: const ['Account', 'Profile', 'Confirm'],
                      onStepTap: (index) {
                        setState(() => _currentStep = index);
                      },
                    ),
                    SizedBox(height: spacing.lg),
                    if (_currentStep == 0)
                      const OiLabel.body('Enter your account details.'),
                    if (_currentStep == 1)
                      const OiLabel.body('Set up your profile information.'),
                    if (_currentStep == 2)
                      const OiLabel.body(
                        'Review and confirm your registration.',
                      ),
                    SizedBox(height: spacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_currentStep > 0)
                          OiButton.outline(
                            label: 'Previous',
                            onTap: () => setState(() => _currentStep--),
                          )
                        else
                          const SizedBox.shrink(),
                        if (_currentStep < 2)
                          OiButton.primary(
                            label: 'Next',
                            onTap: () => setState(() => _currentStep++),
                          ),
                        if (_currentStep == 2)
                          OiButton.primary(label: 'Submit', onTap: () {}),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── OiWizard ───────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Wizard',
            widgetName: 'OiWizard',
            description:
                'A multi-step form wizard with built-in navigation, '
                'per-step validation, and a shared values map. Renders '
                'an OiStepper indicator and Next/Previous buttons '
                'automatically.',
            examples: [
              ComponentExample(
                title: 'Setup wizard',
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: SizedBox(
                    height: 300,
                    child: OiWizard(
                      steps: [
                        OiWizardStep(
                          title: 'Account',
                          builder: (ctx) => const OiLabel.body(
                            'Step 1: Create your account credentials.',
                          ),
                        ),
                        OiWizardStep(
                          title: 'Preferences',
                          builder: (ctx) => const OiLabel.body(
                            'Step 2: Configure your preferences.',
                          ),
                        ),
                        OiWizardStep(
                          title: 'Finish',
                          builder: (ctx) => const OiLabel.body(
                            'Step 3: Review and complete setup.',
                          ),
                        ),
                      ],
                      onComplete: (_) {},
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── OiAddressForm ──────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Address Form',
            widgetName: 'OiAddressForm',
            description:
                'A pre-built address form with fields for name, company, '
                'address lines, city, state, postal code, country, and '
                'phone. Responsive layout adapts to screen width.',
            examples: [
              ComponentExample(
                title: 'Shipping address',
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: OiAddressForm.shipping(onChange: (_) {}),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
