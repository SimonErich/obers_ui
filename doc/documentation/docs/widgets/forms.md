# Forms & Wizards

These widgets help you collect input from people. You get a way to group fields,
a couple of ready-made dialogs, a step indicator, and a full multi-step wizard.
None of them decide how you store or validate values. That stays your job, so
they drop into whatever state management you already use.

For forms built from a schema instead of hand-placed fields, see the separate
`obers_ui_autoforms` package on the [AutoForms](../advanced/autoforms.md) page.

| Widget | What it does |
| --- | --- |
| `OiFormSection` | Groups related fields under a title and description. |
| `OiFormDialog` | Shows a modal form dialog with managed loading and error state. |
| `OiStepper` | A step indicator (horizontal, vertical, or compact). |
| `OiWizard` | A multi-step form with Next/Previous navigation and validation. |
| `OiNameDialog` | A small dialog that prompts for a name, with built-in validation. |

## OiFormSection

A visual group for a set of related fields. You give it a title, an optional
description, and the field widgets. It handles the heading and the spacing
between fields. It holds no state and imposes no validation.

```dart
OiFormSection(
  title: 'Billing address',
  description: 'Where should we send the invoice?',
  children: [
    OiTextInput(label: 'Street', onChanged: (v) {}),
    OiTextInput(label: 'City', onChanged: (v) {}),
  ],
)
```

### Layout

Set `layout` to control how the children sit. Vertical is the default. Horizontal
gives each child an equal share of the row. Inline wraps children onto the next
line when they run out of space.

```dart
OiFormSection(
  title: 'Name',
  layout: OiFormLayout.horizontal,
  children: [
    OiTextInput(label: 'First name', onChanged: (v) {}),
    OiTextInput(label: 'Last name', onChanged: (v) {}),
  ],
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | **required** | The field widgets to group. |
| `title` | `String?` | `null` | Optional heading above the fields. |
| `description` | `String?` | `null` | Optional text below the title. |
| `layout` | `OiFormLayout` | `vertical` | `vertical`, `horizontal`, or `inline`. |
| `gap` | `double` | `12` | Space between children in pixels. |

## OiFormDialog

A static helper that shows a modal form dialog. It renders a title, your custom
form content, an optional error line, and Cancel plus Submit buttons. You do not
build the dialog widget yourself. You call `OiFormDialog.showCustom` and it
returns a `Future` with the submitted result, or `null` if the user cancels.

The builder receives an `OiFormDialogController`. Use it to drive loading, show
an error, enable or disable Submit, and submit the result.

```dart
final name = await OiFormDialog.showCustom<String>(
  context,
  title: 'Create item',
  builder: (controller) {
    return OiTextInput(
      label: 'Name',
      onChanged: (value) =>
          controller.setSubmitEnabled(enabled: value.isNotEmpty),
    );
  },
);
```

The controller drives the dialog from inside the builder:

```dart
// Submit and close, completing the Future with the result.
controller.submit('New item');

// Cancel and close, completing with null.
controller.cancel();

// Show a spinner and block the barrier while an async call runs.
controller.setLoading(loading: true);

// Show an error line between the content and the buttons.
controller.setError('That name is taken.');

// Enable or disable the Submit button.
controller.setSubmitEnabled(enabled: true);
```

`showCustom` takes these named arguments:

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `context` | `BuildContext` | **required** | Positional. Used to show the dialog. |
| `title` | `String` | **required** | The dialog heading. |
| `builder` | `Widget Function(OiFormDialogController<T>)` | **required** | Builds the form content. |
| `submitLabel` | `String` | `'Save'` | Label for the primary button. |
| `cancelLabel` | `String` | `'Cancel'` | Label for the cancel button. |
| `dismissible` | `bool` | `true` | Whether tapping the barrier closes it. Blocked while loading. |
| `maxWidth` | `double?` | `null` | Optional maximum dialog width. |
| `semanticLabel` | `String?` | `null` | Accessibility label. Falls back to `title`. |

!!! note
    `submit` and `cancel` close the dialog for you. Do not also pop the route
    yourself, or you will close the wrong thing.

## OiStepper

A step indicator. It shows the current position in a multi-step process as a row
or column of numbered circles, with completed and error states. `OiWizard`
renders one for you, but you can use it on its own when you drive the steps
yourself.

```dart
OiStepper(
  totalSteps: 3,
  currentStep: 1,
  stepLabels: ['Account', 'Profile', 'Done'],
  completedSteps: {0},
)
```

### Styles

Pick a `style` for the layout. Horizontal is the default. Compact drops the
circles and just reads "Step 2 of 3".

```dart
OiStepper(totalSteps: 4, currentStep: 2, style: OiStepperStyle.vertical)
OiStepper(totalSteps: 4, currentStep: 2, style: OiStepperStyle.compact)
```

### Tappable steps

Pass `onStepTap` to let people jump between steps. Limit which steps are live
with `enabledSteps`. Steps outside that set look disabled and ignore taps, which
is handy when people must finish steps in order.

```dart
OiStepper(
  totalSteps: 3,
  currentStep: 1,
  onStepTap: (index) => goToStep(index),
  enabledSteps: {0, 1},
  errorSteps: {2},
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `totalSteps` | `int` | **required** | How many steps there are. |
| `currentStep` | `int` | **required** | Zero-based index of the active step. |
| `stepLabels` | `List<String>?` | `null` | Labels per step. Needs `totalSteps` entries. |
| `stepIcons` | `List<IconData>?` | `null` | Icons inside each circle. Needs `totalSteps` entries. |
| `style` | `OiStepperStyle` | `horizontal` | `horizontal`, `vertical`, or `compact`. |
| `onStepTap` | `ValueChanged<int>?` | `null` | Fires with the tapped step index. |
| `completedSteps` | `Set<int>` | `{}` | Steps marked with a checkmark. |
| `errorSteps` | `Set<int>` | `{}` | Steps marked with an error icon. |
| `enabledSteps` | `Set<int>?` | `null` | When set, only these steps are tappable. |

## OiWizard

A multi-step form. You give it a list of `OiWizardStep`s. It renders an
`OiStepper`, the current step's content, and the Next, Previous, Cancel, and
Complete controls. Each step can validate before the user moves on. Values are
kept in a shared map that every step reads and writes.

```dart
OiWizard(
  onComplete: (values) => submit(values),
  steps: [
    OiWizardStep(
      title: 'Account',
      builder: (ctx) => OiTextInput(
        label: 'Email',
        onChanged: (v) => ctx.setValue('email', v),
      ),
      validate: (values) => (values['email'] as String?)?.isNotEmpty ?? false,
    ),
    OiWizardStep(
      title: 'Profile',
      builder: (ctx) => OiTextInput(
        label: 'Display name',
        onChanged: (v) => ctx.setValue('name', v),
      ),
    ),
  ],
)
```

Each step's `builder` gets an `OiWizardContext`. Use it to read and write shared
values and to navigate.

```dart
OiWizardStep(
  title: 'Review',
  builder: (ctx) {
    // Read a value another step set.
    final email = ctx.values['email'] as String? ?? '';
    return OiColumn(
      children: [
        OiLabel.body('Signing up as $email'),
        OiButton.primary(label: 'Back', onTap: ctx.goPrevious),
      ],
    );
  },
)
```

### OiWizardStep

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `builder` | `Widget Function(OiWizardContext)` | **required** | Builds the step content. |
| `title` | `String?` | `null` | Step title. Also the stepper label unless `stepperLabel` is set. |
| `stepperLabel` | `String?` | `null` | Overrides the stepper label. |
| `subtitle` | `String?` | `null` | Text below the title. |
| `icon` | `IconData?` | `null` | Icon shown in the stepper circle. |
| `validate` | `bool Function(Map<String, dynamic>)?` | `null` | Return `true` to allow advancing. |
| `optional` | `bool` | `false` | Marks the step as skippable. |

### OiWizard attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `steps` | `List<OiWizardStep>` | **required** | The steps to walk through. |
| `onComplete` | `ValueChanged<Map<String, dynamic>>?` | `null` | Fires on the last step with the final values. |
| `onCancel` | `VoidCallback?` | `null` | Fires when the user cancels. Shows a Cancel control when set. |
| `onStepChange` | `ValueChanged<int>?` | `null` | Fires with the new step index. |
| `linear` | `bool` | `true` | `true` forces order. `false` lets people tap any step. |
| `allowSkip` | `bool` | `false` | Lets people skip `optional` steps. |
| `showSummary` | `bool` | `true` | Shows a value summary on the last step. |
| `stepperStyle` | `OiStepperStyle` | `horizontal` | Style of the built-in stepper. |
| `animated` | `bool` | `true` | Animates transitions between steps. |
| `initialValues` | `Map<String, dynamic>?` | `null` | Seeds the shared value map. |

!!! tip
    A failed `validate` marks the current step with an error and blocks Next.
    Clear the cause and the error goes away on the next successful advance.

## OiNameDialog

A small dialog that asks for a name. It wraps `OiDialog` with a single text
input. On open it focuses the input and selects the default text, so people can
type a replacement right away. Enter confirms. Escape cancels.

```dart
OiNameDialog(
  title: 'New folder',
  defaultName: 'Untitled',
  onCreate: (name) => createFolder(name),
  onCancel: () => closeDialog(),
)
```

It validates for you. The name cannot be empty, and it cannot contain the
characters `/ \ < > : " | ? *`. Add your own checks with `validate`. Return an
error message to block the create button and show the message inline, or `null`
when the value is fine.

```dart
OiNameDialog(
  title: 'Rename file',
  defaultName: current,
  validate: (name) => taken.contains(name) ? 'That name is in use.' : null,
  onCreate: (name) => rename(name),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `title` | `String` | **required** | The dialog heading. |
| `onCreate` | `ValueChanged<String>` | **required** | Called with the name on confirm. |
| `onCancel` | `VoidCallback?` | `null` | Called on cancel or Escape. |
| `defaultName` | `String` | `''` | Text pre-filled and selected on open. |
| `inputLabel` | `String?` | `null` | Optional label above the input. |
| `createLabel` | `String` | `'Create'` | Label for the confirm button. |
| `cancelLabel` | `String` | `'Cancel'` | Label for the cancel button. |
| `validate` | `String? Function(String)?` | `null` | Extra check. Return an error string or `null`. |

## Related

- [AutoForms](../advanced/autoforms.md) for building forms from a schema with the `obers_ui_autoforms` package.
- [Buttons & Actions](buttons.md) for the buttons these forms and dialogs use.
- [Overlays & Menus](overlays.md) for the dialog shell behind `OiFormDialog` and `OiNameDialog`.

## Controlled wizard layouts

`OiWizardLayout` renders workflow navigation, a full-width header, current-step
content, pinned actions and a live aside without owning form values. Supply
`List<OiWizardStepPresentation>`, `currentStep`, `completedSteps`, `enabledSteps`
and `onStepTap`. Each presentation contains a title, optional description and
optional summary widget. Only the current, completed or explicitly enabled steps
request navigation; the host validates and updates the controlled index.

Desktop layouts show the step navigation on the left and the aside on the right.
Compact layouts use the shared select control and a summary sheet. Header, footer
and aside are ordinary widgets composed from the same Obers components. Set
`scrollable: true` when the frame should scroll intrinsically sized form content.
Use `stepHeader` for the active step's heading and introduction. It remains above
the scrolling body, separately from the full-width workflow `header` and pinned
`footer`. `stepHeaderPadding` and `stepHeaderMinHeight` (default 132) control this
region. Below 480 logical pixels of body-frame height it joins the scroll area,
so it cannot prevent access to lower inputs. Changing `currentStep` resets the
body scroll offset without taking ownership of the host's values.
The existing `OiWizard` remains a convenience widget for applications that want
it to own a small values map.

`OiRadioTile.card` presents a rich radio choice with `details` and `badge` slots.
The entire card selects the value, while disabled choices retain descriptive
content and do not invoke callbacks.

`OiWizardLayout.contentCard` groups the active step and pinned footer in the card theme's surface; `contentPadding` controls the body inset. The default keeps the 264px step rail and a true 360px aside, with independent scrolling. `OiRadioTile.card` additionally supports a rich `titleWidget`, `controlLeading` and an optional `bordered` outline for inline record choices.

The desktop summary uses the same card surface and available height as the step
content. The connected step rail keeps future steps legible while disabling their
interaction. With a header, cards use the small top gap; without one they use the
normal page inset. `OiRadioTileIndicator.check` presents a trailing check only on
the selected choice, while retaining mutually exclusive selection semantics.
Combine it with `dense: true`, `bordered: false`, and `contentPadding` for compact
search results. The default indicator remains the circular radio.
