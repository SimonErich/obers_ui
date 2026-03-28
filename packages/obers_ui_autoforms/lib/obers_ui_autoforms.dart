/// Opt-in, controller-first, enum-keyed, context-bound stateful form handling
/// for obers_ui.
///
/// To use, import `package:obers_ui_autoforms/obers_ui_autoforms.dart`.
library;

// ── Definitions ──────────────────────────────────────────────────────────────

export 'src/definitions/oi_af_field_definition.dart';

// ── Diagnostics ──────────────────────────────────────────────────────────────

export 'src/diagnostics/oi_af_debug_overlay.dart';
export 'src/diagnostics/oi_af_observer.dart';

// ── Foundation ───────────────────────────────────────────────────────────────

export 'src/foundation/oi_af_aggregate_state.dart';
export 'src/foundation/oi_af_enums.dart';
export 'src/foundation/oi_af_message_resolver.dart';
export 'src/foundation/oi_af_option.dart';
export 'src/foundation/oi_af_reader.dart';
export 'src/foundation/oi_af_submit_result.dart';
export 'src/foundation/oi_af_typedefs.dart';

// ── Persistence ──────────────────────────────────────────────────────────────

export 'src/persistence/oi_af_draft_payload.dart';
export 'src/persistence/oi_af_json_exporter.dart';
export 'src/persistence/oi_af_persistence_driver.dart';

// ── Runtime ──────────────────────────────────────────────────────────────────

export 'src/runtime/controller/oi_af_controller.dart';
export 'src/runtime/controller/oi_af_field_controller.dart';
export 'src/runtime/state/oi_af_tracking_reader.dart';

// ── Validation ───────────────────────────────────────────────────────────────

export 'src/validation/oi_af_form_validation_context.dart';
export 'src/validation/oi_af_validation_context.dart';
export 'src/validation/oi_af_validators.dart';

// ── Widgets ──────────────────────────────────────────────────────────────────

export 'src/widgets/aggregate/oi_af_error_summary.dart';
export 'src/widgets/aggregate/oi_af_reset_button.dart';
export 'src/widgets/aggregate/oi_af_submit_button.dart';
export 'src/widgets/fields/oi_af_array_input.dart';
export 'src/widgets/fields/oi_af_checkbox.dart';
export 'src/widgets/fields/oi_af_color_input.dart';
export 'src/widgets/fields/oi_af_combo_box.dart';
export 'src/widgets/fields/oi_af_date_input.dart';
export 'src/widgets/fields/oi_af_date_picker_field.dart';
export 'src/widgets/fields/oi_af_date_range_picker_field.dart';
export 'src/widgets/fields/oi_af_date_time_input.dart';
export 'src/widgets/fields/oi_af_file_input.dart';
export 'src/widgets/fields/oi_af_number_input.dart';
export 'src/widgets/fields/oi_af_radio.dart';
export 'src/widgets/fields/oi_af_rich_editor.dart';
export 'src/widgets/fields/oi_af_segmented_control.dart';
export 'src/widgets/fields/oi_af_select.dart';
export 'src/widgets/fields/oi_af_slider.dart';
export 'src/widgets/fields/oi_af_switch.dart';
export 'src/widgets/fields/oi_af_tag_input.dart';
export 'src/widgets/fields/oi_af_text_input.dart';
export 'src/widgets/fields/oi_af_time_input.dart';
export 'src/widgets/fields/oi_af_time_picker_field.dart';
export 'src/widgets/root/oi_af_form.dart';
export 'src/widgets/root/oi_af_scope.dart';
