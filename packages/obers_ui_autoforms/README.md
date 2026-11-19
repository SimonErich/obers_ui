# obers_ui_autoforms

Opt-in, controller-first form handling for [obers_ui](../../README.md). A controller defines the data side of a form (fields, validation, derived values, conditional visibility); the `OiAf*` widgets bind `obers_ui` inputs to it by enum key.

## Installation

The package lives in the `obers_ui` repository and depends on `obers_ui` by path:

```yaml
dependencies:
  obers_ui:
    git:
      url: https://github.com/simonerich/obers_ui.git
  obers_ui_autoforms:
    git:
      url: https://github.com/simonerich/obers_ui.git
      path: packages/obers_ui_autoforms
```

## Usage

```dart
import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_autoforms/obers_ui_autoforms.dart';

// 1. One enum value per field.
enum SignupField { name, email }

// 2. The controller defines the fields and builds the submitted data.
class SignupController
    extends OiAfController<SignupField, Map<String, dynamic>> {
  @override
  void defineFields() {
    addTextField(SignupField.name, required: true);
    addTextField(
      SignupField.email,
      required: true,
      validators: [OiAfValidators.email()],
    );
  }

  @override
  Map<String, dynamic> buildData() => json();
}

// 3. The widgets bind to the controller through OiAfForm.
class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _controller = SignupController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OiAfForm<SignupField, Map<String, dynamic>>(
      controller: _controller,
      onSubmit: (data, controller) async {
        // Save `data`.
      },
      child: OiColumn(
        breakpoint: context.breakpoint,
        children: const [
          OiAfTextInput<SignupField>(field: SignupField.name, label: 'Name'),
          OiAfTextInput<SignupField>(field: SignupField.email, label: 'Email'),
          OiAfSubmitButton<SignupField, Map<String, dynamic>>(label: 'Save'),
        ],
      ),
    );
  }
}
```

## What is in the package

| Area | Examples |
| ---- | -------- |
| **Root** | `OiAfForm`, `OiAfController`, `OiAfFieldController` |
| **Field widgets** | `OiAfTextInput`, `OiAfNumberInput`, `OiAfCheckbox`, `OiAfSwitch`, `OiAfRadio`, `OiAfSelect`, `OiAfComboBox`, `OiAfDateInput`, `OiAfTimeInput`, `OiAfSlider`, `OiAfTagInput`, `OiAfFileInput` |
| **Aggregate widgets** | `OiAfErrorSummary`, `OiAfSubmitButton`, `OiAfResetButton` |
| **Validation** | `OiAfValidators`, `OiAfMessageResolver` |

The full field catalog and the validation modes are described in the autoforms section of [AI_README.md](../../AI_README.md).

## Development

```bash
flutter pub get
dart analyze --fatal-infos
flutter test
```
