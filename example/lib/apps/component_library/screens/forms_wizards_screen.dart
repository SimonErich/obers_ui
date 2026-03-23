import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_example/apps/component_library/shared/component_showcase_section.dart';

/// Showcase screen for form, stepper, wizard, and address form widgets.
class FormsWizardsScreen extends StatefulWidget {
  const FormsWizardsScreen({super.key});

  @override
  State<FormsWizardsScreen> createState() => _FormsWizardsScreenState();
}

class _FormsWizardsScreenState extends State<FormsWizardsScreen> {
  // Form controller for the contact form example.
  late final OiFormController _formController;

  // Stepper state.
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _formController = OiFormController();
  }

  @override
  void dispose() {
    _formController.dispose();
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
          // ── OiForm ─────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Form',
            widgetName: 'OiForm',
            description:
                'A declarative form builder that renders fields from a '
                'schema. Supports validation, sections, conditional '
                'fields, autosave, and undo/redo.',
            examples: [
              ComponentExample(
                title: 'Contact form',
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: OiForm(
                    controller: _formController,
                    sections: const [
                      OiFormSection(
                        fields: [
                          OiFormField(
                            key: 'name',
                            label: 'Full Name',
                            type: OiFieldType.text,
                            required: true,
                          ),
                          OiFormField(
                            key: 'email',
                            label: 'Email',
                            type: OiFieldType.email,
                            required: true,
                          ),
                          OiFormField(
                            key: 'message',
                            label: 'Message',
                            type: OiFieldType.text,
                          ),
                        ],
                      ),
                    ],
                    onSubmit: (_) {},
                  ),
                ),
              ),
            ],
          ),

          // ── OiStepper ──────────────────────────────────────────────
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
                        setState(() {
                          _currentStep = index;
                        });
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
                    Wrap(
                      spacing: spacing.sm,
                      children: [
                        if (_currentStep > 0)
                          OiButton.outline(
                            label: 'Previous',
                            onTap: () {
                              setState(() {
                                _currentStep--;
                              });
                            },
                          ),
                        if (_currentStep < 2)
                          OiButton.primary(
                            label: 'Next',
                            onTap: () {
                              setState(() {
                                _currentStep++;
                              });
                            },
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

          // ── OiWizard ───────────────────────────────────────────────
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

          // ── OiAddressForm ──────────────────────────────────────────
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
