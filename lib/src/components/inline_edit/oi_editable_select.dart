import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/inline_edit/oi_editable.dart';
import 'package:obers_ui/src/components/inputs/oi_select.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// An inline-editable select field that toggles between a label display and
/// an [OiSelect] dropdown.
///
/// In display mode the selected option label (or an em-dash placeholder) is
/// shown as plain text. Tapping enters edit mode where the dropdown opens
/// immediately. Selecting an option commits the edit; losing focus cancels.
///
/// {@category Components}
class OiEditableSelect<T> extends StatelessWidget {
  /// Creates an [OiEditableSelect].
  const OiEditableSelect({
    required this.options,
    this.value,
    this.onChanged,
    this.enabled = true,
    super.key,
  });

  /// The currently selected value.
  final T? value;

  /// The list of options displayed in the dropdown.
  final List<OiSelectOption<T>> options;

  /// Called when the user selects a new value.
  final ValueChanged<T?>? onChanged;

  /// Whether editing is enabled.
  final bool enabled;

  String _labelFor(T? v) {
    if (v == null) return '—';
    for (final o in options) {
      if (o.value == v) return o.label;
    }
    return '—';
  }

  @override
  Widget build(BuildContext context) {
    return OiEditable<T?>(
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
              _labelFor(v),
              style: TextStyle(fontSize: 14, color: colors.text),
            ),
          ),
        );
      },
      editBuilder: (ctx, v, commit, cancel) {
        return OiSelect<T>(
          options: options,
          value: v,
          enabled: enabled,
          onChanged: (newVal) => commit(newVal),
        );
      },
    );
  }
}
