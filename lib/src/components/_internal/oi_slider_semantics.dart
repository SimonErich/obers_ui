import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A slider value as text, for the thumb labels and for screen readers: up to
/// two decimals, no trailing zeros ("5", "0.5", "0.25").
String oiSliderValueText(double value) {
  final text = value.toStringAsFixed(2);
  if (!text.contains('.')) return text;
  return text.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
}

/// The semantics of an `OiSlider`, one node per thumb, for its painter.
///
/// Each node is a slider with its value, and increase / decrease actions that
/// move it by one division, or by a tenth of the range when continuous. In a
/// range ([secondaryValue] set) the start thumb stops at the end thumb and the
/// other way round.
List<CustomPainterSemantics> oiSliderSemantics({
  required Size size,
  required double thumbRadius,
  required double value,
  required double min,
  required double max,
  required bool enabled,
  required TextDirection textDirection,
  double? secondaryValue,
  int? divisions,
  String? label,
  ValueChanged<double>? onChanged,
  void Function(double start, double end)? onRangeChanged,
}) {
  final span = max - min;
  final step = divisions != null && divisions > 0
      ? span / divisions
      : span / 10;

  CustomPainterSemantics thumb(
    String id,
    Rect rect,
    double at, {
    required double low,
    required double high,
    required ValueChanged<double> moveTo,
  }) {
    final up = (at + step).clamp(low, high);
    final down = (at - step).clamp(low, high);
    return CustomPainterSemantics(
      key: ValueKey(id),
      rect: rect,
      properties: SemanticsProperties(
        slider: true,
        enabled: enabled,
        textDirection: textDirection,
        label: label,
        value: oiSliderValueText(at),
        increasedValue: oiSliderValueText(up),
        decreasedValue: oiSliderValueText(down),
        onIncrease: enabled && up > at ? () => moveTo(up) : null,
        onDecrease: enabled && down < at ? () => moveTo(down) : null,
      ),
    );
  }

  final end = secondaryValue;
  if (end == null) {
    return [
      thumb(
        'value',
        Offset.zero & size,
        value,
        low: min,
        high: max,
        moveTo: (v) => onChanged?.call(v),
      ),
    ];
  }

  Rect around(double at) => Rect.fromCenter(
    center: Offset(
      span <= 0 ? 0 : (at - min) / span * size.width,
      size.height / 2,
    ),
    width: thumbRadius * 2,
    height: size.height,
  );
  return [
    thumb(
      'start',
      around(value),
      value,
      low: min,
      high: end,
      moveTo: (v) => onRangeChanged?.call(v, end),
    ),
    thumb(
      'end',
      around(end),
      end,
      low: value,
      high: max,
      moveTo: (v) => onRangeChanged?.call(value, v),
    ),
  ];
}
