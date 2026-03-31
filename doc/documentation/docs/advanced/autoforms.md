# AutoForms

**obers_ui_autoforms** is a companion package that provides opt-in, controller-first, enum-keyed form handling for obers_ui.

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  obers_ui_autoforms:
    path: ../packages/obers_ui_autoforms  # or published version
```

Import:

```dart
import 'package:obers_ui_autoforms/obers_ui_autoforms.dart';
```

## Design Philosophy

- **Controller defines data behavior.** Validation, visibility, enabled state, derived fields — all live in the controller.
- **Widgets define visual behavior.** Label, hint, placeholder, icons, layout — all live on the widget.
- **Enum field keys** are the single identity mechanism.
- **Context propagates state.** `OiAfForm` injects an `OiAfScope` via `InheritedWidget`.
- **Layout is fully free.** Fields can be placed in any Flutter layout.

## Quick Start

### 1. Define Field Enum

```dart
enum SignupField { name, email, password, agree }
```

### 2. Create Controller

```dart
class SignupController extends OiAfController<SignupField, SignupData> {
  @override
  void defineFields() {
    addTextField(SignupField.name, required: true,
      validators: [OiAfValidators.minLength(2)]);
    addTextField(SignupField.email, required: true,
      validators: [OiAfValidators.email()]);
    addTextField(SignupField.password, required: true,
      validators: [OiAfValidators.securePassword(minLength: 8)]);
    addBoolField(SignupField.agree, required: true,
      validators: [OiAfValidators.requiredTrue()]);
  }

  @override
  SignupData buildData() => SignupData(
    name: getOr(SignupField.name, ''),
    email: getOr(SignupField.email, ''),
    password: getOr(SignupField.password, ''),
  );
}
```

### 3. Build UI

```dart
OiAfForm<SignupField, SignupData>(
  controller: SignupController(),
  onSubmit: (data, ctrl) async {
    await api.signup(data);
  },
  child: OiPage(
    breakpoint: OiBreakpoint.compact,
    children: [
      OiAfErrorSummary<SignupField>(),
      OiAfTextInput<SignupField>(field: SignupField.name, label: 'Name'),
      OiAfTextInput<SignupField>(field: SignupField.email, label: 'Email'),
      OiAfTextInput.password<SignupField>(field: SignupField.password, label: 'Password'),
      OiAfCheckbox<SignupField>(field: SignupField.agree, label: 'I agree to the terms'),
      OiAfSubmitButton<SignupField, SignupData>(label: 'Sign Up'),
    ],
  ),
)
```

## Validation

### Validate Modes

| Mode | When Errors Appear |
| --- | --- |
| `disabled` | Never (manual only) |
| `onSubmit` | Only on submit |
| `onBlur` | When field loses focus |
| `onChange` | On every keystroke |
| **`onBlurThenChange`** | On blur first, then on each subsequent change |
| `onInit` | Immediately on mount |

The default `onBlurThenChange` provides the best UX:

1. User types — no errors shown
2. User tabs away — errors appear
3. User goes back to fix — errors update in real-time
4. Errors disappear as soon as the fix is valid

### Built-in Validators

Over 60 validators inspired by Laravel:

```dart
OiAfValidators.requiredText()
OiAfValidators.email()
OiAfValidators.url()
OiAfValidators.minLength(3)
OiAfValidators.maxLength(100)
OiAfValidators.securePassword(requiresUppercase: true)
OiAfValidators.min(0)
OiAfValidators.max(100)
OiAfValidators.range(1, 10)
OiAfValidators.equalsField(MyField.password)
OiAfValidators.dateInFuture()
OiAfValidators.minItems(1)
OiAfValidators.requiredIf(MyField.other, 'yes')
OiAfValidators.custom((ctx) => myValidation(ctx.value))
```

## Derived Fields

Fields can be computed from other fields:

```dart
addTextField(
  MyField.username,
  dependsOn: [MyField.name],
  derive: (form) {
    final name = form.get<String>(MyField.name) ?? '';
    return name.trim().toLowerCase().replaceAll(' ', '_');
  },
);
```

## Conditional Visibility

Fields can show/hide based on form state:

```dart
addRadioField<String>(
  MyField.gender,
  visibleWhen: (form) => form.get<bool?>(MyField.newsletter) == true,
);
```

## Multi-Step Wizards

Use one controller with conditional fields per step, or use separate `OiAfForm` per step:

```dart
// Approach: One controller, conditional visibility
addTextField(MyField.step1Name,
  visibleWhen: (form) => currentStep == 0);
addTextField(MyField.step2Email,
  visibleWhen: (form) => currentStep == 1);
```

## Available Field Widgets

| Widget | Wraps | Value Type |
| --- | --- | --- |
| `OiAfTextInput` | `OiTextInput` | `String` |
| `OiAfNumberInput` | `OiNumberInput` | `num` |
| `OiAfCheckbox` | `OiCheckbox` | `bool?` |
| `OiAfSwitch` | `OiSwitch` | `bool` |
| `OiAfRadio` | `OiRadio` | `TValue` |
| `OiAfSelect` | `OiSelect` | `TValue` |
| `OiAfComboBox` | `OiComboBox` | `TValue` |
| `OiAfDateInput` | `OiDateInput` | `DateTime` |
| `OiAfTimeInput` | `OiTimeInput` | `OiTimeOfDay` |
| `OiAfDateTimeInput` | `OiDateTimeInput` | `DateTime` |
| `OiAfDatePickerField` | `OiDatePickerField` | `DateTime` |
| `OiAfDateRangePickerField` | `OiDateRangePickerField` | `(DateTime, DateTime)` |
| `OiAfTimePickerField` | `OiTimePickerField` | `OiTimeOfDay` |
| `OiAfTagInput` | `OiTagInput` | `List<String>` |
| `OiAfSlider` | `OiSlider` | `double` |
| `OiAfColorInput` | `OiColorInput` | `Color` |
| `OiAfFileInput` | `OiFileInput` | `List<String>` |
| `OiAfSegmentedControl` | `OiSegmentedControl` | `TValue` |

## Migration from OiForm

| Old | New |
| --- | --- |
| `OiForm` | `OiAfForm` |
| `OiFormController` | `OiAfController` (subclass) |
| `OiFormField` | `OiAfTextInput` / `OiAfSelect` / etc. |
| `OiFormSection` | Any layout widget |
