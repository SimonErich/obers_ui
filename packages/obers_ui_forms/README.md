# obers_ui_forms

Type-safe stateful form management for [obers_ui](../../README.md).

## Quick Start

### 1. Define your fields

```dart
enum SignupFields { name, email, password, passwordRepeat }
```

### 2. Create a form controller

```dart
class SignupFormController extends OiFormController<SignupFields> {
  @override
  Map<SignupFields, OiFormInputController<dynamic>> inputs() => {
    SignupFields.name: OiFormInputController<String>(
      required: true,
      validation: [OiFormValidation.minLength(3)],
    ),
    SignupFields.email: OiFormInputController<String>(
      required: true,
      validation: [OiFormValidation.email()],
    ),
    SignupFields.password: OiFormInputController<String>(
      required: true,
      validation: [
        OiFormValidation.securePassword(
          minLength: 8,
          requiresUppercase: true,
          requiresSpecialChar: true,
        ),
      ],
    ),
    SignupFields.passwordRepeat: OiFormInputController<String>(
      save: false,
      validation: [OiFormValidation.equals<String>(SignupFields.password)],
    ),
  };
}
```

### 3. Build your form UI

```dart
class SignupForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = SignupFormController();

    return OiFormScope<SignupFields>(
      controller: controller,
      child: Column(
        children: [
          OiFormElement<SignupFields>(
            fieldKey: SignupFields.name,
            label: 'Name',
            child: OiTextInput(
              onChanged: (v) => controller.set(SignupFields.name, v),
            ),
          ),
          OiFormElement<SignupFields>(
            fieldKey: SignupFields.email,
            label: 'Email',
            child: OiTextInput(
              onChanged: (v) => controller.set(SignupFields.email, v),
            ),
          ),
          OiFormSubmitButton<SignupFields>(
            label: 'Sign Up',
            onSubmit: (data, ctrl) => print(data),
          ),
        ],
      ),
    );
  }
}
```

## Features

- **Type-safe** — Enum-keyed field access, no `Map<String, dynamic>`
- **Declarative validation** — Built-in validators + custom sync/async
- **Computed fields** — Auto-derived values with watch dependencies
- **Context-based** — InheritedWidget scope, no external state management
- **Fully opt-in** — All input widgets work standalone without forms
- **Accessible** — Screen reader support, required indicators, error announcements

## API Reference

### Validators

| Validator | Description |
|-----------|-------------|
| `OiFormValidation.required()` | Non-null, non-empty |
| `OiFormValidation.minLength(n)` | String min length |
| `OiFormValidation.maxLength(n)` | String max length |
| `OiFormValidation.min(n)` | Numeric minimum |
| `OiFormValidation.max(n)` | Numeric maximum |
| `OiFormValidation.email()` | Valid email format |
| `OiFormValidation.url()` | Valid URL format |
| `OiFormValidation.regex(pattern)` | Regex match |
| `OiFormValidation.securePassword(...)` | Password strength |
| `OiFormValidation.equals(fieldKey)` | Cross-field equality |
| `OiFormValidation.custom(fn)` | Custom sync validator |
| `OiFormValidation.asyncCustom(fn)` | Custom async validator with debounce |

### Controller API

| Method | Description |
|--------|-------------|
| `get<T>(key)` | Get typed field value |
| `set<T>(key, value)` | Set typed field value |
| `validate()` | Run sync validators |
| `validateAsync()` | Run all validators (sync + async) |
| `submit(onSubmit)` | Validate and submit |
| `reset()` | Reset all fields |
| `getData()` | Get saved field values |
| `json()` | Export as JSON map |
| `isValid` | All fields valid |
| `isDirty` | Any field modified |
| `enable()` / `disable()` | Form-level state |
| `getError(key)` | Field errors |
| `setError(key, msg)` | Inject server error |
