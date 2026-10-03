# AutoForms

`obers_ui_autoforms` is a companion package for building forms. It is
controller-first and enum-keyed. You define the fields in a controller, then
lay out the UI with matching widgets. The controller owns validation,
visibility, and derived values. The widgets own labels, hints, and layout.

Use it when a form has more than a couple of fields, or when you need
validation, conditional fields, or a submit and reset flow that stays in sync.

## Install and import

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  obers_ui_autoforms:
    path: ../packages/obers_ui_autoforms  # or the published version
```

Then import it. Every public class uses the `OiAf` prefix.

```dart
import 'package:obers_ui_autoforms/obers_ui_autoforms.dart';
```

## The flow

A form has three parts. You write them in this order.

1. A field enum. One entry per field. This is the only identity for a field.
2. A controller. Subclass `OiAfController` and register each field in
   `defineFields()`.
3. The UI. Wrap it in `OiAfForm` and drop in the matching `OiAf` field widgets.

## Quick start

### 1. Define the field enum

```dart
enum SignupField { name, email, password, agree }
```

### 2. Write the controller

Subclass `OiAfController<TField, TData>`. `TField` is your enum. `TData` is the
typed object you build on submit. Register fields in `defineFields()` and build
the payload in `buildData()`.

```dart
class SignupController extends OiAfController<SignupField, Map<String, dynamic>> {
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
  Map<String, dynamic> buildData() => json();
}
```

`json()` returns a `Map<String, dynamic>` keyed by enum name. For a typed model,
read each field with `getOr` instead:

```dart
@override
SignupData buildData() => SignupData(
  name: getOr(SignupField.name, ''),
  email: getOr(SignupField.email, ''),
);
```

### 3. Build the UI

Put `OiAfForm` at the root. Give it the controller and an `onSubmit` callback.
Every `OiAf` field widget inside binds to the controller by its field enum.

```dart
OiAfForm<SignupField, Map<String, dynamic>>(
  controller: SignupController(),
  onSubmit: (data, ctrl) async {
    await api.signup(data);
  },
  child: OiColumn(
    children: [
      OiAfErrorSummary<SignupField>(),
      OiAfTextInput<SignupField>(field: SignupField.name, label: 'Name'),
      OiAfTextInput<SignupField>(field: SignupField.email, label: 'Email'),
      OiAfTextInput.password<SignupField>(
        field: SignupField.password,
        label: 'Password',
      ),
      OiAfCheckbox<SignupField>(
        field: SignupField.agree,
        label: 'I agree to the terms',
      ),
      OiAfSubmitButton<SignupField, Map<String, dynamic>>(label: 'Sign Up'),
    ],
  ),
)
```

Layout is free. Fields can sit in any layout widget, so reach for `OiRow`,
`OiColumn`, or `OiGrid` as usual.

## Key types

These are the types you touch most.

| Type | Purpose |
| --- | --- |
| `OiAfController<TField, TData>` | Abstract controller. Subclass it and register fields. |
| `OiAfForm<TField, TData>` | Root widget. Provides the controller to the subtree. |
| `OiAfFieldController<TField, TValue>` | Per-field runtime state: value, dirty, errors. |
| `OiAfFieldDefinition<TField, TValue>` | Immutable spec for one field. |
| `OiAfValidators` | 60+ built-in validators. |
| `OiAfOption<T>` | A selectable option for select, radio, and combo box. |
| `OiAfSubmitResult<TData>` | Result of a submit: success, invalid, or failure. |

## OiAfForm

The root widget. Place it above your form layout. It attaches the controller and
exposes it to every field widget below.

```dart
OiAfForm<SignupField, Map<String, dynamic>>(
  controller: _controller,
  onSubmit: (data, ctrl) async => await api.signup(data),
  child: myFormLayout,
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `controller` | `OiAfController<TField, TData>` | **required** | The controller that holds all field state. |
| `child` | `Widget` | **required** | The form layout. Put `OiAf` field widgets here. |
| `onSubmit` | `Future<void> Function(TData, controller)?` | `null` | Runs on a valid submit. |
| `onSubmitResult` | `void Function(result, controller)?` | `null` | Runs on every submit attempt. |
| `errorMapper` | `OiAfSubmitErrorMapper?` | `null` | Maps a submit exception to field or global errors. |
| `validateMode` | `OiAfValidateMode` | `onBlurThenChange` | When fields auto-validate. |
| `autofocusFirstField` | `bool` | `false` | Focus the first field on mount. |
| `submitOnEnterFromLastField` | `bool` | `true` | Enter on the last field submits. |
| `focusFirstInvalidFieldOnSubmitFailure` | `bool` | `true` | Focus the first invalid field after a failed submit. |
| `clearGlobalErrorsOnFieldChange` | `bool` | `true` | Clear global errors when a field changes. |
| `enabled` | `bool` | `true` | Enable or disable the whole form. |

## Registering fields

You register fields inside `defineFields()`. Each helper takes the field enum
first, then options. Common ones:

```dart
addTextField(field, required: true, validators: [...])
addNumberField(field, min: 0, max: 100)
addBoolField(field, initialValue: false)
addSelectField<String>(field, options: [...])
addRadioField<String>(field, options: [...])
addDateField(field, minDate: ...)
addSliderField(field, min: 0, max: 100)
addFormValidator(validator)
```

There are more helpers, one per field type: `addComboBoxField`, `addTagField`,
`addColorField`, `addFileField`, `addSegmentedControlField`, `addTimeField`,
`addDateTimeField`, `addDatePickerField`, `addDateRangePickerField`,
`addTimePickerField`, `addMultiSelectField`, `addRichTextField`, and
`addArrayField`.

Shared options across the field helpers:

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `initialValue` | `TValue?` | `null` | Starting value. |
| `required` | `bool` | `false` | Marks the field required. |
| `save` | `bool` | `true` | Include the field in `json()` output. |
| `validators` | `List<OiAfValidator<TField, TValue>>` | `const []` | Field validators. |
| `visibleWhen` | `OiAfVisibleWhen<TField>?` | `null` | Show or hide based on form state. |
| `enabledWhen` | `OiAfEnabledWhen<TField>?` | `null` | Enable or disable based on form state. |
| `validateModeOverride` | `OiAfValidateMode?` | `null` | Override the form's validate mode for this field. |

For options in a select, radio, or combo field, use `OiAfOption`:

```dart
addSelectField<String>(
  ProfileField.role,
  options: const [
    OiAfOption(value: 'admin', label: 'Admin'),
    OiAfOption(value: 'member', label: 'Member'),
  ],
);
```

## Field widgets

Each field widget wraps a core `obers_ui` input and binds it to a field. Give it
the `field` enum. The controller supplies the value, error, visibility, and
enabled state.

| Widget | Wraps | Value type |
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

### OiAfTextInput

The text field. It has variants for password, multiline, and search.

```dart
OiAfTextInput<SignupField>(
  field: SignupField.email,
  label: 'Email',
  placeholder: 'you@example.com',
)
```

Named constructors cover the common shapes:

```dart
OiAfTextInput.password<SignupField>(field: SignupField.password, label: 'Password')
OiAfTextInput.multiline<NoteField>(field: NoteField.body, label: 'Notes', minLines: 3)
OiAfTextInput.search<SearchField>(field: SearchField.query, hint: 'Search')
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `field` | `TField` | **required** | The field enum this input binds to. |
| `label` | `String?` | `null` | Visible label above the input. |
| `hint` | `String?` | `null` | Helper text below the input. |
| `placeholder` | `String?` | `null` | Placeholder shown when empty. |
| `maxLines` | `int?` | `1` | Max visible lines. |
| `maxLength` | `int?` | `null` | Max character count. |
| `enabled` | `bool` | `true` | Set `false` to disable. |
| `semanticLabel` | `String?` | `null` | Screen-reader label if it differs from `label`. |

### OiAfSelect

A single-select dropdown. Pass its options as `OiAfOption` values. The value
type comes from the field you registered with `addSelectField`.

```dart
OiAfSelect<ProfileField, String>(
  field: ProfileField.role,
  label: 'Role',
  options: const [
    OiAfOption(value: 'admin', label: 'Admin'),
    OiAfOption(value: 'member', label: 'Member'),
  ],
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `field` | `TField` | **required** | The field enum this select binds to. |
| `options` | `List<OiAfOption<TValue>>` | **required** | The selectable options. |
| `label` | `String?` | `null` | Visible label. |
| `hint` | `String?` | `null` | Helper text below the field. |
| `placeholder` | `String?` | `null` | Text shown when nothing is selected. |
| `searchable` | `bool` | `false` | Show a search box in the dropdown. |
| `enabled` | `bool` | `true` | Set `false` to disable. |

### OiAfCheckbox

A single checkbox bound to a `bool?` field. The value is tristate, so it can be
`true`, `false`, or `null`.

```dart
OiAfCheckbox<SignupField>(
  field: SignupField.agree,
  label: 'I agree to the terms',
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `field` | `TField` | **required** | The field enum this checkbox binds to. |
| `label` | `String?` | `null` | Text next to the checkbox. |
| `enabled` | `bool` | `true` | Set `false` to disable. |

## Aggregate widgets

These widgets read the whole form, not a single field.

| Widget | Purpose |
| --- | --- |
| `OiAfSubmitButton<TField, TData>` | Submits the form. Shows a spinner while submitting. |
| `OiAfResetButton<TField>` | Resets the form. |
| `OiAfErrorSummary<TField>` | Lists every error. Tap a field error to focus it. |

### OiAfSubmitButton

The submit button. It calls `controller.submit()`, runs validation, then your
`onSubmit`. It shows a spinner while the submit runs.

```dart
OiAfSubmitButton<SignupField, Map<String, dynamic>>(
  label: 'Sign Up',
  loadingLabel: 'Signing up...',
  disableWhenInvalid: true,
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Button text. |
| `loadingLabel` | `String?` | `null` | Text shown while submitting. Defaults to `label`. |
| `icon` | `IconData?` | `null` | Optional leading icon. |
| `variant` | `OiButtonVariant` | `primary` | Button style. |
| `disableWhenInvalid` | `bool` | `false` | Disable while the form has errors. |
| `disableWhenClean` | `bool` | `false` | Disable while no field is dirty. |
| `fullWidth` | `bool` | `false` | Stretch to the parent's width. |

### OiAfResetButton

Resets the form to its initial values. Set `resetMode` for other behaviors.

```dart
OiAfResetButton<SignupField>(
  label: 'Reset',
  hideWhenClean: true,
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Button text. |
| `variant` | `OiButtonVariant` | `secondary` | Button style. |
| `hideWhenClean` | `bool` | `false` | Hide when no field is dirty. |
| `resetMode` | `OiAfResetMode` | `toInitial` | `toInitial`, `toCurrentPatchedValues`, or `clear`. |
| `fullWidth` | `bool` | `false` | Stretch to the parent's width. |

### OiAfErrorSummary

Lists all current errors. Global errors come first, then field errors in
registration order. Tapping a field error focuses that field.

```dart
OiAfErrorSummary<SignupField>(
  title: 'Please fix these',
  showOnlyAfterSubmit: true,
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `title` | `String?` | `null` | Optional heading above the list. |
| `showFieldErrors` | `bool` | `true` | Include field-level errors. |
| `showGlobalErrors` | `bool` | `true` | Include form-level errors. |
| `showOnlyAfterSubmit` | `bool` | `false` | Only show after a submit attempt. |
| `hideWhenEmpty` | `bool` | `true` | Hide when there are no errors. |
| `focusFieldOnTap` | `bool` | `true` | Focus a field when its error is tapped. |
| `maxItems` | `int?` | `null` | Cap the number of listed errors. |

## Validation

### Validate modes

The form's `validateMode` decides when errors appear. Set it once on `OiAfForm`,
or override per field with `validateModeOverride`.

| Mode | When errors appear |
| --- | --- |
| `disabled` | Never. You validate manually. |
| `onSubmit` | Only when the form submits. |
| `onBlur` | When a field loses focus. |
| `onChange` | On every keystroke. |
| `onBlurThenChange` | On blur first, then on each later change. This is the default. |
| `onInit` | Right away, when the field mounts. |

The default `onBlurThenChange` keeps the form quiet while the user types. Errors
first show when they leave the field. After that, they update live as the user
fixes the value. They clear the moment the value is valid.

### Built-in validators

`OiAfValidators` has more than 60 validators. They are inspired by Laravel's
rules. A few in each group:

```dart
OiAfValidators.requiredText()
OiAfValidators.email()
OiAfValidators.url()
OiAfValidators.minLength(3)
OiAfValidators.maxLength(100)
OiAfValidators.securePassword(minLength: 8, requiresUppercase: true)
OiAfValidators.min(0)
OiAfValidators.max(100)
OiAfValidators.range(1, 10)
OiAfValidators.equalsField(SignupField.password)
OiAfValidators.dateInFuture()
OiAfValidators.minItems(1)
OiAfValidators.requiredIf(SignupField.other, 'yes')
OiAfValidators.custom((ctx) => ctx.value == null ? 'Required' : null)
```

Pass them in the `validators` list of the matching `add*Field` helper. A field
can take several validators. They run in order.

## Derived fields

A field can compute its value from other fields. List the sources in `dependsOn`
and return the value in `derive`. Once the user edits the field by hand, it
stops deriving.

```dart
addTextField(
  ProfileField.username,
  dependsOn: [ProfileField.name],
  derive: (form) {
    final name = form.get<String>(ProfileField.name) ?? '';
    return name.trim().toLowerCase().replaceAll(' ', '_');
  },
);
```

## Conditional visibility

A field can show or hide based on the form's current state. Return a bool from
`visibleWhen`. Use `enabledWhen` the same way to enable or disable a field.

```dart
addRadioField<String>(
  ProfileField.gender,
  options: const [
    OiAfOption(value: 'f', label: 'Female'),
    OiAfOption(value: 'm', label: 'Male'),
  ],
  visibleWhen: (form) => form.get<bool?>(ProfileField.newsletter) == true,
);
```

## Multi-step wizards

You have two options for a wizard. Use one controller with `visibleWhen` per
step, or use a separate `OiAfForm` for each step. The single-controller approach
keeps all values in one place:

```dart
addTextField(WizardField.step1Name,
  visibleWhen: (form) => currentStep == 0);
addTextField(WizardField.step2Email,
  visibleWhen: (form) => currentStep == 1);
```

## Related

- [Forms](../widgets/forms.md) for the core `obers_ui` form inputs the field widgets wrap.
- [Text Inputs](../widgets/text-inputs.md) for `OiTextInput` and its variants.
- [Selection Controls](../widgets/selection-controls.md) for checkboxes, switches, and radios.
- [Buttons & Actions](../widgets/buttons.md) for the button variants the submit and reset buttons use.
