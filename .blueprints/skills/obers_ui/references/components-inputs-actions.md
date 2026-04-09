# Components — inputs, actions, inline edit

Overview: buttons, form fields, inline editors, keyboard/selection helpers, and shop-specific input blocks. [← Skill](../SKILL.md)

Paths: `lib/src/components/<area>/...`.

## Buttons


| Name             | Path                            | Role                               |
| ---------------- | ------------------------------- | ---------------------------------- |
| `OiButton`       | `buttons/oi_button.dart`        | Primary button variants and states |
| `OiButtonGroup`  | `buttons/oi_button_group.dart`  | Grouped button row                 |
| `OiIconButton`   | `buttons/oi_icon_button.dart`   | Icon-only action                   |
| `OiToggleButton` | `buttons/oi_toggle_button.dart` | Toggle pressed state               |
| `OiBackButton`   | `buttons/oi_back_button.dart`   | Standard back affordance           |
| `OiExportButton` | `buttons/oi_export_button.dart` | Export menu trigger                |
| `OiSortButton`   | `buttons/oi_sort_button.dart`   | Sort options control               |


## Inputs (core)


| Name                     | Path                                     | Role                                                           |
| ------------------------ | ---------------------------------------- | -------------------------------------------------------------- |
| `OiTextInput`            | `inputs/oi_text_input.dart`              | Text field variants (search, password, multiline, OTP styling) |
| `OiNumberInput`          | `inputs/oi_number_input.dart`            | Numeric stepping input                                         |
| `OiDateInput`            | `inputs/oi_date_input.dart`              | Date text/picker field                                         |
| `OiTimeInput`            | `inputs/oi_time_input.dart`              | Time input; defines `**OiTimeOfDay**`                          |
| `OiDateTimeInput`        | `inputs/oi_date_time_input.dart`         | Combined date and time                                         |
| `OiDatePickerField`      | `inputs/oi_date_picker_field.dart`       | Field bound to date picker                                     |
| `OiDateRangePickerField` | `inputs/oi_date_range_picker_field.dart` | Range field; `**OiDateRangePreset**`                           |
| `OiTimePickerField`      | `inputs/oi_time_picker_field.dart`       | Field bound to time picker                                     |
| `OiSelect`               | `inputs/oi_select.dart`                  | Dropdown select                                                |
| `OiComboBox`             | `composites/search/oi_combo_box.dart` | Searchable select (under `lib/src/`; composite tier) |
| `OiCheckbox`             | `inputs/oi_checkbox.dart`                | Checkbox                                                       |
| `OiSwitch`               | `inputs/oi_switch.dart`                  | Switch                                                         |
| `OiSwitchTile`           | `inputs/oi_switch_tile.dart`             | Labeled switch row                                             |
| `OiCheckboxTile`         | `inputs/oi_switch_tile.dart`             | Labeled checkbox row                                           |
| `OiRadioTile`            | `inputs/oi_switch_tile.dart`             | Labeled radio row                                              |
| `OiRadio`                | `inputs/oi_radio.dart`                   | Radio group item                                               |
| `OiSlider`               | `inputs/oi_slider.dart`                  | Slider                                                         |
| `OiSegmentedControl`     | `inputs/oi_segmented_control.dart`       | Segmented options                                              |
| `OiTagInput`             | `inputs/oi_tag_input.dart`               | Tag chips entry                                                |
| `OiColorInput`           | `inputs/oi_color_input.dart`             | Color picker field                                             |
| `OiFileInput`            | `inputs/oi_file_input.dart`              | File picker field                                              |
| `OiFormSelect`           | `inputs/oi_form_select.dart`             | `FormField`-style select when validator is used                |
| `OiArrayInput`           | `inputs/oi_array_input.dart`             | Dynamic list of values (admin)                                 |
| `OiColorPalettePicker`   | `inputs/oi_color_palette_picker.dart`    | Palette slots UI                                               |


## Input utilities


| Name            | Path                          | Role                                                 |
| --------------- | ----------------------------- | ---------------------------------------------------- |
| `OiSelectScope` | `inputs/oi_select_scope.dart` | Ensures one open select; `**OiSelectScopeNotifier**` |


## Inline edit


| Name               | Path                                  | Role                     |
| ------------------ | ------------------------------------- | ------------------------ |
| `OiEditable`       | `inline_edit/oi_editable.dart`        | Generic inline edit host |
| `OiEditableText`   | `inline_edit/oi_editable_text.dart`   | Inline text              |
| `OiEditableNumber` | `inline_edit/oi_editable_number.dart` | Inline number            |
| `OiEditableDate`   | `inline_edit/oi_editable_date.dart`   | Inline date              |
| `OiEditableSelect` | `inline_edit/oi_editable_select.dart` | Inline select            |


## Interaction helpers


| Name                 | Path                                    | Role                        |
| -------------------- | --------------------------------------- | --------------------------- |
| `OiKbd`              | `interaction/oi_kbd.dart`               | Keyboard shortcut display   |
| `OiSelectionOverlay` | `interaction/oi_selection_overlay.dart` | Selection rectangle overlay |


## Shop inputs


| Name                     | Path                                  | Role                   |
| ------------------------ | ------------------------------------- | ---------------------- |
| `OiQuantitySelector`     | `shop/oi_quantity_selector.dart`      | Cart quantity stepper  |
| `OiAddressForm`          | `shop/oi_address_form.dart`           | Address capture block  |
| `OiCouponInput`          | `shop/oi_coupon_input.dart`           | Coupon code field      |
| `OiShippingMethodPicker` | `shop/oi_shipping_method_picker.dart` | Shipping method choice |
| `OiPaymentMethodPicker`  | `shop/oi_payment_method_picker.dart`  | Payment method choice  |
| `OiWishlistButton`       | `shop/oi_wishlist_button.dart`        | Wishlist toggle action |
