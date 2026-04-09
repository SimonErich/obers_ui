# Package: obers_ui_autoforms

Overview: controller-first forms on top of obers_ui; **`OiAf*`** types. Import **`package:obers_ui_autoforms/obers_ui_autoforms.dart`**. [← Skill](../SKILL.md)

Root: `packages/obers_ui_autoforms/lib/`.

## Barrel

| Name | Path | Role |
|------|------|------|
| (exports) | `obers_ui_autoforms.dart` | Public API entry |

## Foundation

| Name | Path | Role |
|------|------|------|
| `OiAfController` | `src/runtime/controller/oi_af_controller.dart` | Subclass to define fields and validation |
| `OiAfFieldController` | `src/runtime/controller/oi_af_field_controller.dart` | Per-field runtime state |
| `OiAfFieldDefinition` | `src/definitions/oi_af_field_definition.dart` | Immutable field spec |
| `OiAfOption` | `src/foundation/oi_af_option.dart` | Select/radio option |
| `OiAfSubmitResult` | `src/foundation/oi_af_submit_result.dart` | Sealed submit outcome |
| `OiAfReader` / tracking | `src/foundation/oi_af_reader.dart`, `src/runtime/state/oi_af_tracking_reader.dart` | Value read API |
| `OiAfAggregateState` | `src/foundation/oi_af_aggregate_state.dart` | Cross-field aggregate |
| `OiAfMessageResolver` | `src/foundation/oi_af_message_resolver.dart` | Error message resolution |
| `OiAfEnums` | `src/foundation/oi_af_enums.dart` | Shared enums |
| `OiAfTypedefs` | `src/foundation/oi_af_typedefs.dart` | Type aliases |

## Validation

| Name | Path | Role |
|------|------|------|
| `OiAfValidators` | `src/validation/oi_af_validators.dart` | Built-in validators |
| `OiAfValidationContext` | `src/validation/oi_af_validation_context.dart` | Validation context |
| `OiAfFormValidationContext` | `src/validation/oi_af_form_validation_context.dart` | Form-level context |

## Widgets — root

| Name | Path | Role |
|------|------|------|
| `OiAfForm` | `src/widgets/root/oi_af_form.dart` | Form scope + submit |
| `OiAfScope` | `src/widgets/root/oi_af_scope.dart` | Optional nested scope |

## Widgets — fields (wrap obers_ui inputs)

| Name | Path | Wraps |
|------|------|--------|
| `OiAfTextInput` | `src/widgets/fields/oi_af_text_input.dart` | `OiTextInput` |
| `OiAfNumberInput` | `src/widgets/fields/oi_af_number_input.dart` | `OiNumberInput` |
| `OiAfCheckbox` | `src/widgets/fields/oi_af_checkbox.dart` | `OiCheckbox` |
| `OiAfSwitch` | `src/widgets/fields/oi_af_switch.dart` | `OiSwitch` |
| `OiAfRadio` | `src/widgets/fields/oi_af_radio.dart` | `OiRadio` |
| `OiAfSelect` | `src/widgets/fields/oi_af_select.dart` | `OiSelect` |
| `OiAfComboBox` | `src/widgets/fields/oi_af_combo_box.dart` | `OiComboBox` |
| `OiAfDateInput` | `src/widgets/fields/oi_af_date_input.dart` | `OiDateInput` |
| `OiAfTimeInput` | `src/widgets/fields/oi_af_time_input.dart` | `OiTimeInput` |
| `OiAfDateTimeInput` | `src/widgets/fields/oi_af_date_time_input.dart` | `OiDateTimeInput` |
| `OiAfDatePickerField` | `src/widgets/fields/oi_af_date_picker_field.dart` | `OiDatePickerField` |
| `OiAfDateRangePickerField` | `src/widgets/fields/oi_af_date_range_picker_field.dart` | `OiDateRangePickerField` |
| `OiAfTimePickerField` | `src/widgets/fields/oi_af_time_picker_field.dart` | `OiTimePickerField` |
| `OiAfTagInput` | `src/widgets/fields/oi_af_tag_input.dart` | `OiTagInput` |
| `OiAfSlider` | `src/widgets/fields/oi_af_slider.dart` | `OiSlider` |
| `OiAfColorInput` | `src/widgets/fields/oi_af_color_input.dart` | `OiColorInput` |
| `OiAfFileInput` | `src/widgets/fields/oi_af_file_input.dart` | `OiFileInput` |
| `OiAfSegmentedControl` | `src/widgets/fields/oi_af_segmented_control.dart` | `OiSegmentedControl` |
| `OiAfArrayInput` | `src/widgets/fields/oi_af_array_input.dart` | `OiArrayInput` |
| `OiAfRichEditor` | `src/widgets/fields/oi_af_rich_editor.dart` | `OiRichEditor` |

## Widgets — aggregate

| Name | Path | Role |
|------|------|------|
| `OiAfErrorSummary` | `src/widgets/aggregate/oi_af_error_summary.dart` | Lists field errors |
| `OiAfSubmitButton` | `src/widgets/aggregate/oi_af_submit_button.dart` | Submit with loading |
| `OiAfResetButton` | `src/widgets/aggregate/oi_af_reset_button.dart` | Reset/discard |

## Runtime graphs (advanced)

| Name | Path | Role |
|------|------|------|
| `OiAfDependencyGraph` | `src/runtime/graphs/oi_af_dependency_graph.dart` | Field dependencies |
| `OiAfFocusGraph` | `src/runtime/graphs/oi_af_focus_graph.dart` | Focus order |
| `OiAfConditionTracker` | `src/runtime/graphs/oi_af_condition_tracker.dart` | Conditional visibility |

## Persistence & diagnostics

| Name | Path | Role |
|------|------|------|
| `OiAfPersistenceDriver` | `src/persistence/oi_af_persistence_driver.dart` | Draft persistence |
| `OiAfDraftPayload` | `src/persistence/oi_af_draft_payload.dart` | Serialized draft |
| `OiAfJsonExporter` | `src/persistence/oi_af_json_exporter.dart` | Export values as JSON |
| `OiAfDebugOverlay` | `src/diagnostics/oi_af_debug_overlay.dart` | Debug UI |
| `OiAfObserver` | `src/diagnostics/oi_af_observer.dart` | Change observer |

## Field binder (internal)

| `_OiAfFieldBinder` | `src/widgets/fields/_oi_af_field_binder.dart` | Internal glue—use public `OiAf*` fields |
