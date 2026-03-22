import 'package:obers_ui/obers_ui.dart' show OiFieldDisplay, OiForm, OiFormField;

/// The type of a field, shared by form inputs and read-only display widgets.
///
/// Determines which input widget [OiForm] renders and how [OiFieldDisplay]
/// formats a read-only value.
///
/// {@category Models}
///
/// Coverage: REQ-0001
enum OiFieldType {
  /// A single- or multi-line text input.
  text,

  /// A numeric input with stepper buttons.
  number,

  /// A monetary value with currency symbol/code.
  currency,

  /// A date picker field.
  date,

  /// A date and time picker field.
  dateTime,

  /// A boolean value rendered as a check/cross icon.
  boolean,

  /// An email address rendered as a tappable mailto link.
  email,

  /// A URL rendered as a tappable external link.
  url,

  /// A phone number rendered as a tappable tel link.
  phone,

  /// A time picker field.
  time,

  /// A dropdown select input.
  select,

  /// A checkbox toggle.
  checkbox,

  /// A switch toggle.
  switchField,

  /// A radio button group.
  radio,

  /// A slider input.
  slider,

  /// A color picker field.
  color,

  /// A file picker field.
  file,

  /// An image displayed as a thumbnail.
  image,

  /// A tag/chip input for entering multiple string values.
  tag,

  /// Multiple tags displayed as a row of badges.
  tags,

  /// A JSON value rendered as formatted code.
  json,

  /// A custom widget supplied via [OiFormField.customBuilder].
  custom,
}
