import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/_internal/oi_input_frame.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';

/// Two full turns, used to normalize angles into the `[0, 2π)` range.
const double _tau = 2 * math.pi;

// ─────────────────────────────────────────────────────────────────────────────
// Geometry (pure, testable)
// ─────────────────────────────────────────────────────────────────────────────

/// Pure angle/value/offset math for [OiRadialSlider], separated so it can be
/// unit-tested without a widget tree.
///
/// Angles are in radians measured clockwise from the positive x-axis (the
/// 3 o'clock direction) to match canvas coordinates, where y grows
/// downward. A slider's arc runs from `startAngle` clockwise through
/// `sweepAngle`.
///
/// {@category Components}
class OiRadialSliderGeometry {
  const OiRadialSliderGeometry._();

  /// Normalizes [angle] into the `[0, 2π)` range.
  static double normalizeAngle(double angle) {
    var result = angle % _tau;
    if (result < 0) result += _tau;
    return result;
  }

  /// Returns the arc angle representing [value] within `[min, max]`.
  static double angleForValue({
    required double value,
    required double min,
    required double max,
    required double startAngle,
    required double sweepAngle,
  }) {
    final t = max == min ? 0.0 : ((value - min) / (max - min)).clamp(0.0, 1.0);
    return startAngle + t * sweepAngle;
  }

  /// Returns the value in `[min, max]` for a raw pointer [angle].
  ///
  /// Angles that fall in the arc's gap snap to whichever end of the sweep is
  /// closer, so a drag never jumps across the gap.
  static double valueForAngle({
    required double angle,
    required double min,
    required double max,
    required double startAngle,
    required double sweepAngle,
  }) {
    var delta = normalizeAngle(angle - startAngle);
    if (delta > sweepAngle) {
      final distanceToEnd = delta - sweepAngle;
      final distanceToStart = _tau - delta;
      delta = distanceToEnd < distanceToStart ? sweepAngle : 0.0;
    }
    final t = sweepAngle == 0 ? 0.0 : (delta / sweepAngle).clamp(0.0, 1.0);
    return min + t * (max - min);
  }

  /// Returns the point on the arc of [radius] around [center] at [angle].
  static Offset offsetForAngle({
    required double angle,
    required Offset center,
    required double radius,
  }) {
    return center + Offset(radius * math.cos(angle), radius * math.sin(angle));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OiRadialSlider
// ─────────────────────────────────────────────────────────────────────────────

/// A circular knob/dial for choosing a number in a range by dragging around
/// an arc.
///
/// Drag anywhere around the ring to set [value] between [min] and [max]. An
/// optional [step] snaps to discrete increments. The arc geometry is
/// configurable via [startAngle] and [sweepAngle] (radians, clockwise from
/// the 3 o'clock direction); the default is a 270° arc with the gap at the
/// bottom, like a volume knob. The track, active arc, and thumb use theme
/// colors, and the current value is announced as a slider to screen readers.
///
/// ```dart
/// double _volume = 40;
///
/// OiRadialSlider(
///   label: 'Volume',
///   value: _volume,
///   min: 0,
///   max: 100,
///   step: 5,
///   onChanged: (v) => setState(() => _volume = v),
/// )
/// ```
///
/// {@category Components}
class OiRadialSlider extends StatefulWidget {
  /// Creates an [OiRadialSlider].
  const OiRadialSlider({
    required this.value,
    required this.min,
    required this.max,
    this.step,
    this.onChanged,
    this.label,
    this.size,
    this.startAngle = 3 * math.pi / 4,
    this.sweepAngle = 3 * math.pi / 2,
    this.showValue = true,
    this.valueFormatter,
    this.enabled = true,
    this.semanticLabel,
    super.key,
  }) : assert(min <= max, 'min must be <= max'),
       assert(sweepAngle > 0, 'sweepAngle must be positive');

  /// The current value.
  final double value;

  /// The minimum selectable value.
  final double min;

  /// The maximum selectable value.
  final double max;

  /// The increment values snap to. When `null` the slider is continuous.
  final double? step;

  /// Called with the new value while the user drags the knob.
  final ValueChanged<double>? onChanged;

  /// Optional label rendered above the knob via [OiInputFrame].
  final String? label;

  /// The diameter of the knob. When `null`, the knob fills the smaller of
  /// the available width and height (falling back to 140).
  final double? size;

  /// The angle, in radians, where the arc begins (clockwise from the 3
  /// o'clock direction). Defaults to 135°.
  final double startAngle;

  /// The clockwise angular span of the arc, in radians. Defaults to 270°.
  final double sweepAngle;

  /// Whether to render the current value in the center of the knob.
  final bool showValue;

  /// Formats the center value. When `null`, a compact default is used.
  final String Function(double value)? valueFormatter;

  /// Whether the knob responds to drag gestures.
  final bool enabled;

  /// Overrides the semantic label. Defaults to [label].
  final String? semanticLabel;

  @override
  State<OiRadialSlider> createState() => _OiRadialSliderState();
}

class _OiRadialSliderState extends State<OiRadialSlider>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late double _startValue;
  late double _targetValue;
  bool _dragging = false;

  double get _displayValue =>
      _startValue + (_targetValue - _startValue) * _animController.value;

  @override
  void initState() {
    super.initState();
    _targetValue = widget.value;
    _startValue = widget.value;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: 1,
    );
  }

  @override
  void didUpdateWidget(OiRadialSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _targetValue) {
      _startValue = _displayValue;
      _targetValue = widget.value;
      if (_dragging) {
        _animController.value = 1;
      } else {
        _animController.value = 0;
        unawaited(_animController.animateTo(1, curve: Curves.easeOutCubic));
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  double _clamp(double v) => v.clamp(widget.min, widget.max);

  double _snap(double v) {
    final step = widget.step;
    if (step == null || step <= 0) return v;
    return widget.min + ((v - widget.min) / step).round() * step;
  }

  void _emit(Offset localPosition, double diameter) {
    if (!widget.enabled) return;
    final center = Offset(diameter / 2, diameter / 2);
    final vector = localPosition - center;
    if (vector.distance == 0) return;
    final angle = math.atan2(vector.dy, vector.dx);
    final raw = OiRadialSliderGeometry.valueForAngle(
      angle: angle,
      min: widget.min,
      max: widget.max,
      startAngle: widget.startAngle,
      sweepAngle: widget.sweepAngle,
    );
    widget.onChanged?.call(_clamp(_snap(raw)));
  }

  String _formatValue(double value) {
    final formatter = widget.valueFormatter;
    if (formatter != null) return formatter(value);
    return value == value.roundToDouble()
        ? value.round().toString()
        : value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final reduceMotion =
        context.animations.reducedMotion ||
        MediaQuery.disableAnimationsOf(context);
    _animController.duration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 250);

    Widget knob = LayoutBuilder(
      builder: (context, constraints) {
        final available = math.min(
          constraints.maxWidth.isFinite ? constraints.maxWidth : 140.0,
          constraints.maxHeight.isFinite ? constraints.maxHeight : 140.0,
        );
        final diameter =
            widget.size ?? (available.isFinite ? available : 140.0);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanDown: (d) {
            _dragging = true;
            _emit(d.localPosition, diameter);
          },
          onPanUpdate: (d) => _emit(d.localPosition, diameter),
          onPanEnd: (_) => _dragging = false,
          child: Semantics(
            slider: true,
            enabled: widget.enabled,
            label: widget.semanticLabel ?? widget.label,
            value: _formatValue(widget.value),
            child: SizedBox(
              width: diameter,
              height: diameter,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: AnimatedBuilder(
                        animation: _animController,
                        builder: (context, _) => CustomPaint(
                          key: const Key('oi_radial_slider_painter'),
                          painter: _OiRadialSliderPainter(
                            value: _displayValue,
                            min: widget.min,
                            max: widget.max,
                            startAngle: widget.startAngle,
                            sweepAngle: widget.sweepAngle,
                            trackColor: colors.border,
                            activeColor: colors.primary.base,
                            thumbColor: colors.primary.base,
                            thumbInnerColor: colors.surface,
                            enabled: widget.enabled,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (widget.showValue)
                    OiLabel.h3(
                      _formatValue(widget.value),
                      color: widget.enabled ? colors.text : colors.textMuted,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (widget.label != null) {
      knob = OiInputFrame(label: widget.label, child: knob);
    }
    return knob;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Painter
// ─────────────────────────────────────────────────────────────────────────────

class _OiRadialSliderPainter extends CustomPainter {
  const _OiRadialSliderPainter({
    required this.value,
    required this.min,
    required this.max,
    required this.startAngle,
    required this.sweepAngle,
    required this.trackColor,
    required this.activeColor,
    required this.thumbColor,
    required this.thumbInnerColor,
    required this.enabled,
  });

  final double value;
  final double min;
  final double max;
  final double startAngle;
  final double sweepAngle;
  final Color trackColor;
  final Color activeColor;
  final Color thumbColor;
  final Color thumbInnerColor;
  final bool enabled;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 8.0;
    const thumbRadius = 9.0;
    final center = size.center(Offset.zero);
    final radius =
        (math.min(size.width, size.height) - strokeWidth) / 2 - thumbRadius / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = enabled ? trackColor : trackColor.withValues(alpha: 0.4)
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final activePaint = Paint()
      ..color = enabled ? activeColor : activeColor.withValues(alpha: 0.4)
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final valueAngle = OiRadialSliderGeometry.angleForValue(
      value: value,
      min: min,
      max: max,
      startAngle: startAngle,
      sweepAngle: sweepAngle,
    );
    final activeSweep = valueAngle - startAngle;

    canvas
      ..drawArc(rect, startAngle, sweepAngle, false, trackPaint)
      ..drawArc(rect, startAngle, activeSweep, false, activePaint);

    final thumbCenter = OiRadialSliderGeometry.offsetForAngle(
      angle: valueAngle,
      center: center,
      radius: radius,
    );
    canvas
      ..drawCircle(
        thumbCenter,
        thumbRadius,
        Paint()
          ..color = enabled ? thumbColor : thumbColor.withValues(alpha: 0.4),
      )
      ..drawCircle(
        thumbCenter,
        thumbRadius - 3,
        Paint()..color = thumbInnerColor,
      );
  }

  @override
  bool shouldRepaint(_OiRadialSliderPainter old) =>
      old.value != value ||
      old.min != min ||
      old.max != max ||
      old.startAngle != startAngle ||
      old.sweepAngle != sweepAngle ||
      old.activeColor != activeColor ||
      old.enabled != enabled;
}
