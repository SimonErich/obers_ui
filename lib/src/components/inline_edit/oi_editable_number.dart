import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/inline_edit/oi_editable.dart';
import 'package:obers_ui/src/components/inputs/oi_number_input.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// An inline-editable numeric field that toggles between a formatted number
/// label and an [OiNumberInput] stepper.
///
/// In display mode the number is rendered as plain text. Tapping enters edit
/// mode. Committing the input (blur or Enter) calls [onChanged].
///
/// {@category Components}
class OiEditableNumber extends StatelessWidget {
  /// Creates an [OiEditableNumber].
  const OiEditableNumber({
    this.value,
    this.onChanged,
    this.enabled = true,
    this.min,
    this.max,
    this.step = 1,
    super.key,
  });

  /// The current numeric value.
  final double? value;

  /// Called when the user commits a new value.
  final ValueChanged<double?>? onChanged;

  /// Whether editing is enabled.
  final bool enabled;

  /// The minimum allowed value.
  final double? min;

  /// The maximum allowed value.
  final double? max;

  /// The increment/decrement step. Defaults to 1.
  final double step;

  String _format(double? v) {
    if (v == null) return '—';
    if (v == v.truncateToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(6).replaceAll(RegExp(r'0+$'), '');
  }

  @override
  Widget build(BuildContext context) {
    return OiEditable<double?>(
      value: value,
      onChanged: onChanged,
      enabled: enabled,
      displayBuilder: (ctx, v, startEdit) {
        final colors = ctx.colors;
        return GestureDetector(
          onTap: enabled ? startEdit : null,
          behavior: HitTestBehavior.opaque,
          child: MouseRegion(
            cursor: enabled
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,
            child: Text(
              _format(v),
              style: TextStyle(fontSize: 14, color: colors.text),
            ),
          ),
        );
      },
      editBuilder: (ctx, v, commit, cancel) {
        return OiNumberInput(
          value: v,
          min: min,
          max: max,
          step: step,
          enabled: enabled,
          onChanged: commit,
        );
      },
    );
  }
}
