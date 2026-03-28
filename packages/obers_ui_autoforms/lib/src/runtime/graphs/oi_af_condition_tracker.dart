import 'package:obers_ui_autoforms/src/definitions/oi_af_field_definition.dart';
import 'package:obers_ui_autoforms/src/foundation/oi_af_reader.dart';
import 'package:obers_ui_autoforms/src/runtime/controller/oi_af_field_controller.dart';
import 'package:obers_ui_autoforms/src/runtime/state/oi_af_tracking_reader.dart';

/// Tracks dependencies for `visibleWhen` and `enabledWhen` conditions using
/// [OiAfTrackingReader] proxy-based automatic dependency discovery.
///
/// When a field value changes, this tracker identifies which conditional fields
/// need re-evaluation and updates their cached dependency sets.
class OiAfConditionTracker<TField extends Enum> {
  OiAfConditionTracker();

  /// Cached: which fields does each visible condition read?
  final Map<TField, Set<TField>> visibleDeps = {};

  /// Cached: which fields does each enabled condition read?
  final Map<TField, Set<TField>> enabledDeps = {};

  /// Evaluates all conditions on all fields and populates the dependency caches.
  ///
  /// Called once during controller initialization.
  void evaluateAll({
    required OiAfReader<TField> reader,
    required Map<TField, OiAfFieldDefinition<TField, dynamic>> definitions,
    required Map<TField, OiAfFieldController<TField>> controllers,
  }) {
    final tracker = OiAfTrackingReader<TField>(reader);
    for (final def in definitions.values) {
      if (def.visibleWhen != null) {
        tracker.reset();
        final visible = def.visibleWhen!(tracker);
        visibleDeps[def.field] = tracker.readFields;
        controllers[def.field]!.setVisible(visible: visible, notify: false);
      }
      if (def.enabledWhen != null) {
        tracker.reset();
        final enabled = def.enabledWhen!(tracker);
        enabledDeps[def.field] = tracker.readFields;
        controllers[def.field]!.setEnabled(enabled: enabled, notify: false);
      }
    }
  }

  /// Re-evaluates only the conditions affected by a change to [changedField].
  ///
  /// Updates cached dependency sets and field controller state.
  void reevaluateFor({
    required TField changedField,
    required OiAfReader<TField> reader,
    required Map<TField, OiAfFieldDefinition<TField, dynamic>> definitions,
    required Map<TField, OiAfFieldController<TField>> controllers,
  }) {
    final tracker = OiAfTrackingReader<TField>(reader);

    // Visible conditions that depend on the changed field.
    for (final entry in visibleDeps.entries) {
      if (entry.value.contains(changedField)) {
        final def = definitions[entry.key]!;
        if (def.visibleWhen != null) {
          tracker.reset();
          final visible = def.visibleWhen!(tracker);
          visibleDeps[entry.key] = tracker.readFields;
          controllers[entry.key]!.setVisible(visible: visible);
        }
      }
    }

    // Also check fields not yet tracked (first encounter).
    for (final def in definitions.values) {
      if (def.visibleWhen != null && !visibleDeps.containsKey(def.field)) {
        tracker.reset();
        final visible = def.visibleWhen!(tracker);
        visibleDeps[def.field] = tracker.readFields;
        controllers[def.field]!.setVisible(visible: visible);
      }
    }

    // Enabled conditions that depend on the changed field.
    for (final entry in enabledDeps.entries) {
      if (entry.value.contains(changedField)) {
        final def = definitions[entry.key]!;
        if (def.enabledWhen != null) {
          tracker.reset();
          final enabled = def.enabledWhen!(tracker);
          enabledDeps[entry.key] = tracker.readFields;
          controllers[entry.key]!.setEnabled(enabled: enabled);
        }
      }
    }
  }
}
