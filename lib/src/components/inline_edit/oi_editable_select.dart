import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/inputs/oi_select.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

/// An inline-editable select field that toggles between a label display and
/// an [OiSelect] dropdown.
///
/// In display mode the selected option label (or an em-dash placeholder) is
/// shown as plain text. Tapping enters edit mode where the dropdown opens
/// immediately. Selecting an option commits the edit; losing focus cancels.
///
/// {@category Components}
class OiEditableSelect<T> extends StatefulWidget {
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

  @override
  State<OiEditableSelect<T>> createState() => _OiEditableSelectState<T>();
}

class _OiEditableSelectState<T> extends State<OiEditableSelect<T>> {
  bool _editing = false;

  String _labelFor(T? v) {
    if (v == null) return '—';
    for (final o in widget.options) {
      if (o.value == v) return o.label;
    }
    return '—';
  }

  void _startEdit() {
    if (!widget.enabled || _editing) return;
    setState(() => _editing = true);
  }

  void _handleChanged(T? newVal) {
    widget.onChanged?.call(newVal);
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (_editing) {
      return OiSelect<T>(
        options: widget.options,
        value: widget.value,
        enabled: widget.enabled,
        onChanged: _handleChanged,
      );
    }

    return OiTappable(
      onTap: _startEdit,
      enabled: widget.enabled,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Text(
          _labelFor(widget.value),
          style: TextStyle(fontSize: 14, color: colors.text),
        ),
      ),
    );
  }
}
