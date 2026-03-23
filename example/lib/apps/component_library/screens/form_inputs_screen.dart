import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/apps/component_library/shared/component_showcase_section.dart';

/// Showcase screen for all form input widgets.
class FormInputsScreen extends StatefulWidget {
  const FormInputsScreen({super.key});

  @override
  State<FormInputsScreen> createState() => _FormInputsScreenState();
}

class _FormInputsScreenState extends State<FormInputsScreen> {
  // ── State for interactive demos ──────────────────────────────────────────

  double _numberValue = 5;
  bool _checkboxValue = false;
  bool _switchValue = true;
  String _radioValue = 'a';
  double _sliderValue = 0.5;
  List<String> _tags = ['flutter', 'dart', 'obers'];

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OiLabel.h2('Form Inputs'),
          SizedBox(height: spacing.xs),
          OiLabel.body(
            'Interactive input components for building forms.',
            color: context.colors.textSubtle,
          ),
          SizedBox(height: spacing.xl),

          // ── Text Input ──────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Text Input',
            widgetName: 'OiTextInput',
            description:
                'A versatile text input with search, password, and multiline '
                'variants. Supports label, hint, placeholder, and error states.',
            examples: [
              ComponentExample(
                title: 'Default',
                child: OiTextInput(
                  label: 'Name',
                  placeholder: 'Enter your name',
                  onChanged: (_) {},
                ),
              ),
              ComponentExample(
                title: 'Search variant',
                child: OiTextInput.search(onChanged: (_) {}),
              ),
              ComponentExample(
                title: 'Password variant',
                child: OiTextInput.password(
                  label: 'Password',
                  placeholder: 'Enter password',
                  onChanged: (_) {},
                ),
              ),
              ComponentExample(
                title: 'Multiline variant',
                child: OiTextInput.multiline(
                  label: 'Bio',
                  placeholder: 'Tell us about yourself...',
                  onChanged: (_) {},
                ),
              ),
              ComponentExample(
                title: 'With hint and error',
                child: Column(
                  children: [
                    OiTextInput(
                      label: 'Email',
                      hint: 'We will never share your email.',
                      placeholder: 'user@example.com',
                      onChanged: (_) {},
                    ),
                    SizedBox(height: spacing.md),
                    OiTextInput(
                      label: 'Username',
                      error: 'This username is already taken.',
                      onChanged: (_) {},
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── OTP Input ───────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'OTP Input',
            widgetName: 'OiTextInput.otp',
            description:
                'A one-time password input rendered as separate digit boxes. '
                'Supports paste and auto-advance.',
            examples: [
              ComponentExample(
                title: '6-digit code',
                child: OiTextInput.otp(
                  length: 6,
                  autofocus: false,
                  onCompleted: (_) {},
                ),
              ),
              ComponentExample(
                title: '4-digit obscured code',
                child: OiTextInput.otp(
                  length: 4,
                  obscure: true,
                  autofocus: false,
                  onCompleted: (_) {},
                ),
              ),
            ],
          ),

          // ── Number Input ────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Number Input',
            widgetName: 'OiNumberInput',
            description:
                'A numeric input with increment/decrement stepper buttons.',
            examples: [
              ComponentExample(
                title: 'Interactive stepper',
                child: OiNumberInput(
                  label: 'Quantity',
                  value: _numberValue,
                  min: 0,
                  max: 100,
                  onChanged: (v) {
                    if (v != null) setState(() => _numberValue = v);
                  },
                ),
              ),
            ],
          ),

          // ── Select ──────────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Select',
            widgetName: 'OiSelect',
            description:
                'A dropdown select input with searchable option support.',
            examples: [
              ComponentExample(
                title: 'Basic select',
                child: OiSelect<String>(
                  label: 'Country',
                  placeholder: 'Choose a country',
                  options: const [
                    OiSelectOption(value: 'us', label: 'United States'),
                    OiSelectOption(value: 'uk', label: 'United Kingdom'),
                    OiSelectOption(value: 'de', label: 'Germany'),
                    OiSelectOption(value: 'fr', label: 'France'),
                    OiSelectOption(value: 'jp', label: 'Japan'),
                  ],
                  onChanged: (_) {},
                ),
              ),
              ComponentExample(
                title: 'Searchable select',
                child: OiSelect<String>(
                  label: 'Language',
                  placeholder: 'Search languages...',
                  searchable: true,
                  options: const [
                    OiSelectOption(value: 'dart', label: 'Dart'),
                    OiSelectOption(value: 'ts', label: 'TypeScript'),
                    OiSelectOption(value: 'py', label: 'Python'),
                    OiSelectOption(value: 'rs', label: 'Rust'),
                    OiSelectOption(value: 'go', label: 'Go'),
                  ],
                  onChanged: (_) {},
                ),
              ),
            ],
          ),

          // ── Checkbox ────────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Checkbox',
            widgetName: 'OiCheckbox',
            description:
                'A custom-painted checkbox with checked, unchecked, and '
                'indeterminate states.',
            examples: [
              ComponentExample(
                title: 'Interactive checkbox',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OiCheckbox(
                      label: 'Accept terms and conditions',
                      value: _checkboxValue,
                      onChanged: (v) => setState(() => _checkboxValue = v),
                    ),
                    SizedBox(height: spacing.sm),
                    OiCheckbox(
                      label: 'Indeterminate state',
                      value: null,
                      onChanged: (_) {},
                    ),
                    SizedBox(height: spacing.sm),
                    const OiCheckbox(
                      label: 'Disabled checkbox',
                      value: true,
                      enabled: false,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Switch ──────────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Switch',
            widgetName: 'OiSwitch',
            description: 'An animated toggle switch with on/off states.',
            examples: [
              ComponentExample(
                title: 'Interactive toggle',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OiSwitch(
                      label: 'Notifications',
                      value: _switchValue,
                      onChanged: (v) => setState(() => _switchValue = v),
                    ),
                    SizedBox(height: spacing.sm),
                    const OiSwitch(
                      label: 'Disabled switch',
                      value: false,
                      enabled: false,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Radio ───────────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Radio',
            widgetName: 'OiRadio',
            description:
                'A group of radio-button options. Only one option may be '
                'selected at a time.',
            examples: [
              ComponentExample(
                title: 'Vertical radio group',
                child: OiRadio<String>(
                  value: _radioValue,
                  options: const [
                    OiRadioOption(value: 'a', label: 'Option A'),
                    OiRadioOption(value: 'b', label: 'Option B'),
                    OiRadioOption(value: 'c', label: 'Option C'),
                  ],
                  onChanged: (v) => setState(() => _radioValue = v),
                ),
              ),
              ComponentExample(
                title: 'Horizontal radio group',
                child: OiRadio<String>(
                  value: _radioValue,
                  direction: Axis.horizontal,
                  options: const [
                    OiRadioOption(value: 'a', label: 'Small'),
                    OiRadioOption(value: 'b', label: 'Medium'),
                    OiRadioOption(value: 'c', label: 'Large'),
                  ],
                  onChanged: (v) => setState(() => _radioValue = v),
                ),
              ),
            ],
          ),

          // ── Slider ──────────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Slider',
            widgetName: 'OiSlider',
            description:
                'A draggable slider for selecting a value in a continuous '
                'or discrete range.',
            examples: [
              ComponentExample(
                title: 'Interactive slider',
                child: OiSlider(
                  label: 'Volume',
                  value: _sliderValue,
                  min: 0,
                  max: 1,
                  onChanged: (v) => setState(() => _sliderValue = v),
                ),
              ),
              ComponentExample(
                title: 'Discrete slider with labels',
                child: OiSlider(
                  label: 'Rating',
                  value: 3,
                  min: 1,
                  max: 5,
                  divisions: 4,
                  showLabels: true,
                  showTicks: true,
                  onChanged: (_) {},
                ),
              ),
            ],
          ),

          // ── Date, Time & DateTime Inputs ────────────────────────────────
          ComponentShowcaseSection(
            title: 'Date & Time Inputs',
            widgetName: 'OiDateInput / OiTimeInput / OiDateTimeInput',
            description:
                'Date and time picker inputs with overlay wheel selectors.',
            examples: [
              ComponentExample(
                title: 'Date input',
                child: OiDateInput(label: 'Start date', onChanged: (_) {}),
              ),
              ComponentExample(
                title: 'Time input',
                child: OiTimeInput(label: 'Start time', onChanged: (_) {}),
              ),
              ComponentExample(
                title: 'Combined date & time',
                child: OiDateTimeInput(
                  label: 'Event date/time',
                  onChanged: (_) {},
                ),
              ),
            ],
          ),

          // ── Tag Input ───────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Tag Input',
            widgetName: 'OiTagInput',
            description:
                'A tag/chip input for adding and removing string tags. '
                'Supports suggestions and max tag limits.',
            examples: [
              ComponentExample(
                title: 'With initial tags',
                child: OiTagInput(
                  label: 'Tags',
                  tags: _tags,
                  placeholder: 'Add a tag...',
                  onChanged: (tags) => setState(() => _tags = tags),
                ),
              ),
            ],
          ),

          // ── Color Input ─────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Color Input',
            widgetName: 'OiColorInput',
            description:
                'A color picker input with a swatch preview, hex entry, and '
                'optional opacity slider.',
            examples: [
              ComponentExample(
                title: 'Default color picker',
                child: OiColorInput(label: 'Brand color', onChanged: (_) {}),
              ),
            ],
          ),

          // ── File Input ──────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'File Input',
            widgetName: 'OiFileInput',
            description:
                'A file picker input that opens the platform file browser. '
                'Selected files are shown as removable chips.',
            examples: [
              ComponentExample(
                title: 'Single file',
                child: OiFileInput(label: 'Upload document', onChanged: (_) {}),
              ),
              ComponentExample(
                title: 'Multiple files with drop zone',
                child: OiFileInput(
                  label: 'Attachments',
                  multipleFiles: true,
                  dropZone: true,
                  onChanged: (_) {},
                ),
              ),
            ],
          ),

          // ── Array Input ─────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Array Input',
            widgetName: 'OiArrayInput',
            description:
                'A repeatable form field group with add, remove, and reorder '
                'controls for building dynamic lists.',
            examples: [
              ComponentExample(
                title: 'Email list',
                child: OiArrayInput<String>(
                  label: 'Email addresses',
                  items: const ['alice@example.com', 'bob@example.com'],
                  createEmpty: () => '',
                  itemBuilder: (context, index, value, onItemChanged) =>
                      OiTextInput(
                        placeholder: 'Enter email',
                        onChanged: (v) => onItemChanged(v),
                      ),
                  onChanged: (_) {},
                ),
              ),
            ],
          ),

          // ── Coupon Input ────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Coupon Input',
            widgetName: 'OiCouponInput',
            description:
                'A text input with an Apply button for discount/coupon codes. '
                'Shows success or error inline after applying.',
            examples: [
              ComponentExample(
                title: 'Coupon code entry',
                child: OiCouponInput(
                  label: 'Coupon code',
                  onApply: (code) async => const OiCouponResult(
                    valid: true,
                    message: '10% off applied!',
                    discountAmount: 5,
                  ),
                ),
              ),
            ],
          ),

          // ── Inline Editing ──────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Inline Editing',
            widgetName:
                'OiEditableText / OiEditableDate / OiEditableNumber / OiEditableSelect',
            description:
                'Click-to-edit fields that toggle between a display label '
                'and an input. Commit with Enter or blur; cancel with Escape.',
            examples: [
              ComponentExample(
                title: 'Editable text',
                child: OiEditableText(
                  value: 'Click to edit this text',
                  onChanged: (_) {},
                ),
              ),
              ComponentExample(
                title: 'Editable date',
                child: OiEditableDate(
                  value: DateTime(2026, 3, 23),
                  onChanged: (_) {},
                ),
              ),
              ComponentExample(
                title: 'Editable number',
                child: OiEditableNumber(
                  value: 42,
                  min: 0,
                  max: 100,
                  onChanged: (_) {},
                ),
              ),
              ComponentExample(
                title: 'Editable select',
                child: OiEditableSelect<String>(
                  value: 'Active',
                  options: const [
                    OiSelectOption(value: 'Active', label: 'Active'),
                    OiSelectOption(value: 'Inactive', label: 'Inactive'),
                    OiSelectOption(value: 'Archived', label: 'Archived'),
                  ],
                  onChanged: (_) {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
