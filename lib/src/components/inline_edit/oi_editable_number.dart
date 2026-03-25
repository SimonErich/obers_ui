import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/inputs/oi_number_input.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

/// An inline-editable numeric field that toggles between a formatted number
/// label and an [OiNumberInput] stepper.
///
/// In display mode the number is rendered as plain text. Tapping enters edit
/// mode. Committing the input (blur or Enter) calls [onChanged].
///
/// {@category Components}
class OiEditableNumber extends StatefulWidget {
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

  @override
  State<OiEditableNumber> createState() => _OiEditableNumberState();
}

class _OiEditableNumberState extends State<OiEditableNumber> {
  bool _editing = false;
  double? _pendingValue;
  final FocusNode _focusNode = FocusNode();

  String _format(double? v) {
    if (v == null) return '—';
    if (v == v.truncateToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(6).replaceAll(RegExp(r'0+$'), '');
  }

  void _startEdit() {
    if (!widget.enabled || _editing) return;
    setState(() {
      _editing = true;
      _pendingValue = widget.value;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _handleChanged(double? newVal) {
    setState(() => _pendingValue = newVal);
    widget.onChanged?.call(newVal);
  }

  void _finishEdit() {
    setState(() => _editing = false);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (_editing) {
      return TapRegion(
        onTapOutside: (_) => _finishEdit(),
        child: OiNumberInput(
          value: _pendingValue,
          min: widget.min,
          max: widget.max,
          step: widget.step,
          enabled: widget.enabled,
          onChanged: _handleChanged,
        ),
      );
    }

    return OiTappable(
      onTap: _startEdit,
      enabled: widget.enabled,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Text(
          _format(widget.value),
          style: TextStyle(fontSize: 14, color: colors.text),
        ),
      ),
    );
  }
}
