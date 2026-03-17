import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/_internal/oi_input_frame.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/input/oi_raw_input.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

/// A numeric input field with stepper buttons.
///
/// Displays the current [value] as formatted text and provides decrement
/// (`−`) and increment (`+`) buttons as leading/trailing widgets. The value
/// is clamped to [min] and [max] and formatted to [decimalPlaces] precision.
///
/// {@category Components}
class OiNumberInput extends StatefulWidget {
  /// Creates an [OiNumberInput].
  const OiNumberInput({
    this.value,
    this.onChanged,
    this.min,
    this.max,
    this.step = 1,
    this.decimalPlaces,
    this.label,
    this.hint,
    this.error,
    this.enabled = true,
    super.key,
  });

  /// The current numeric value.
  final double? value;

  /// Called with the new value when the user changes the field.
  final ValueChanged<double?>? onChanged;

  /// The minimum allowed value.
  final double? min;

  /// The maximum allowed value.
  final double? max;

  /// The increment/decrement step. Defaults to 1.
  final double step;

  /// Number of decimal places for display and parsing.
  ///
  /// When null the value is shown as an integer when it has no fractional part,
  /// or with up to 6 decimal places otherwise.
  final int? decimalPlaces;

  /// Optional label rendered above the frame.
  final String? label;

  /// Optional hint text rendered below the frame.
  final String? hint;

  /// Validation error message.
  final String? error;

  /// Whether the field accepts input.
  final bool enabled;

  @override
  State<OiNumberInput> createState() => _OiNumberInputState();
}

class _OiNumberInputState extends State<OiNumberInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _format(widget.value));
    _focusNode = FocusNode()..addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(OiNumberInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && !_focused) {
      _controller.text = _format(widget.value);
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    final focused = _focusNode.hasFocus;
    if (focused != _focused) {
      setState(() => _focused = focused);
    }
    if (!focused) {
      // Commit text to value on blur.
      _commitText(_controller.text);
    }
  }

  String _format(double? v) {
    if (v == null) return '';
    if (widget.decimalPlaces != null) {
      return v.toStringAsFixed(widget.decimalPlaces!);
    }
    if (v == v.truncateToDouble()) {
      return v.toStringAsFixed(0);
    }
    return v.toStringAsFixed(6).replaceAll(RegExp(r'0+$'), '');
  }

  double _clamp(double v) {
    var result = v;
    if (widget.min != null && result < widget.min!) result = widget.min!;
    if (widget.max != null && result > widget.max!) result = widget.max!;
    return result;
  }

  void _commitText(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      widget.onChanged?.call(null);
      return;
    }
    final parsed = double.tryParse(trimmed);
    if (parsed == null) {
      // Revert to last valid value.
      _controller.text = _format(widget.value);
      return;
    }
    final clamped = _clamp(parsed);
    widget.onChanged?.call(clamped);
    if (clamped != parsed) {
      _controller.text = _format(clamped);
    }
  }

  void _increment() {
    final current = widget.value ?? 0;
    final next = _clamp(current + widget.step);
    widget.onChanged?.call(next);
    _controller.text = _format(next);
  }

  void _decrement() {
    final current = widget.value ?? 0;
    final next = _clamp(current - widget.step);
    widget.onChanged?.call(next);
    _controller.text = _format(next);
  }

  Widget _stepButton(String symbol, VoidCallback onTap) {
    final colors = context.colors;
    return OiTappable(
      onTap: widget.enabled ? onTap : null,
      enabled: widget.enabled,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          symbol,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: widget.enabled ? colors.text : colors.textMuted,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OiInputFrame(
      label: widget.label,
      hint: widget.hint,
      error: widget.error,
      focused: _focused,
      enabled: widget.enabled,
      leading: _stepButton('−', _decrement),
      trailing: _stepButton('+', _increment),
      child: OiRawInput(
        controller: _controller,
        focusNode: _focusNode,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.center,
        onSubmitted: _commitText,
        enabled: widget.enabled,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[-0-9.]'))],
      ),
    );
  }
}
