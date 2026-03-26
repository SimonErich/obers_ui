import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// A segment of the gauge for coloring ranges.
///
/// Each segment covers a value range from [from] to [to] and is painted
/// with the given [color]. An optional [label] can describe the segment.
class OiGaugeSegment {
  /// Creates an [OiGaugeSegment].
  const OiGaugeSegment({
    required this.from,
    required this.to,
    required this.color,
    this.label,
  });

  /// The start value of this segment range.
  final double from;

  /// The end value of this segment range.
  final double to;

  /// The color used to paint this segment arc.
  final Color color;

  /// An optional human-readable label for this segment.
  final String? label;
}

/// A gauge / speedometer visualization showing a value within a range.
///
/// The gauge renders a 240-degree arc from [min] to [max] with an optional
/// needle indicator at [value]. Colored [segments] can highlight ranges,
/// and a [target] marker can indicate a goal value.
///
/// When [showValue] is `true`, the current value is displayed below the arc.
/// The [formatValue] callback can be used to customize the value string.
///
/// {@category Composites}
class OiGauge extends StatelessWidget {
  /// Creates an [OiGauge].
  const OiGauge({
    required this.value,
    required this.label,
    super.key,
    this.min = 0,
    this.max = 100,
    this.segments,
    this.formatValue,
    this.showValue = true,
    this.target,
    this.size,
  });

  /// The current value displayed by the needle.
  final double value;

  /// The accessibility label for the gauge.
  final String label;

  /// The minimum value of the gauge range.
  final double min;

  /// The maximum value of the gauge range.
  final double max;

  /// Optional colored segments defining value ranges on the arc.
  final List<OiGaugeSegment>? segments;

  /// An optional callback to format the displayed value string.
  final String Function(double)? formatValue;

  /// Whether to display the numeric value below the gauge.
  final bool showValue;

  /// An optional target/goal value shown as a marker on the arc.
  final double? target;

  /// The diameter of the gauge. Defaults to the available width.
  final double? size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final effectiveSize = size ?? 200.0;

    final gauge = SizedBox(
      width: effectiveSize,
      height: effectiveSize * 0.7,
      child: CustomPaint(
        key: const Key('oi_gauge_painter'),
        size: Size(effectiveSize, effectiveSize * 0.7),
        painter: _OiGaugePainter(
          value: value.clamp(min, max),
          min: min,
          max: max,
          segments: segments,
          target: target,
          trackColor: colors.borderSubtle,
          needleColor: colors.primary.base,
          targetColor: colors.warning.base,
          defaultSegmentColor: colors.primary.base,
        ),
        child: showValue
            ? Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    _formattedValue,
                    key: const Key('oi_gauge_value'),
                    style: TextStyle(
                      color: colors.text,
                      fontSize: effectiveSize * 0.1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            : null,
      ),
    );

    return Semantics(
      label: label,
      value: _formattedValue,
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: gauge,
        ),
      ),
    );
  }

  String get _formattedValue =>
      formatValue?.call(value) ?? value.toStringAsFixed(0);
}

/// Custom painter for the gauge arc, segments, needle, and target marker.
class _OiGaugePainter extends CustomPainter {
  _OiGaugePainter({
    required this.value,
    required this.min,
    required this.max,
    required this.segments,
    required this.target,
    required this.trackColor,
    required this.needleColor,
    required this.targetColor,
    required this.defaultSegmentColor,
  });

  /// The current gauge value.
  final double value;

  /// The minimum gauge value.
  final double min;

  /// The maximum gauge value.
  final double max;

  /// Optional colored segments.
  final List<OiGaugeSegment>? segments;

  /// Optional target marker value.
  final double? target;

  /// The color of the background track arc.
  final Color trackColor;

  /// The color of the needle.
  final Color needleColor;

  /// The color of the target marker.
  final Color targetColor;

  /// The default segment color when none is provided.
  final Color defaultSegmentColor;

  static const double _startAngle = math.pi * 0.75; // 135 degrees
  static const double _sweepAngle = math.pi * 1.5; // 270 degrees

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.72);
    final radius = math.min(size.width, size.height * 1.4) / 2 * 0.8;
    final strokeWidth = radius * 0.15;

    // Draw track arc.
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      _startAngle,
      _sweepAngle,
      false,
      trackPaint,
    );

    // Draw segments.
    if (segments != null) {
      for (final segment in segments!) {
        final segStart = _valueToAngle(segment.from.clamp(min, max));
        final segEnd = _valueToAngle(segment.to.clamp(min, max));
        final segPaint = Paint()
          ..color = segment.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.butt;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          segStart,
          segEnd - segStart,
          false,
          segPaint,
        );
      }
    }

    // Draw target marker.
    if (target != null) {
      final targetAngle = _valueToAngle(target!.clamp(min, max));
      final markerPaint = Paint()
        ..color = targetColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      final innerR = radius - strokeWidth;
      final outerR = radius + strokeWidth;
      final innerPoint = Offset(
        center.dx + innerR * math.cos(targetAngle),
        center.dy + innerR * math.sin(targetAngle),
      );
      final outerPoint = Offset(
        center.dx + outerR * math.cos(targetAngle),
        center.dy + outerR * math.sin(targetAngle),
      );
      canvas.drawLine(innerPoint, outerPoint, markerPaint);
    }

    // Draw needle.
    final needleAngle = _valueToAngle(value);
    final needleLength = radius * 0.85;
    final needleTip = Offset(
      center.dx + needleLength * math.cos(needleAngle),
      center.dy + needleLength * math.sin(needleAngle),
    );

    final needlePaint = Paint()
      ..color = needleColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, needleTip, needlePaint);

    // Draw center dot.
    final dotPaint = Paint()..color = needleColor;
    canvas.drawCircle(center, 4, dotPaint);
  }

  double _valueToAngle(double v) {
    final ratio = (v - min) / (max - min);
    return _startAngle + ratio * _sweepAngle;
  }

  @override
  bool shouldRepaint(_OiGaugePainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.min != min ||
      oldDelegate.max != max ||
      oldDelegate.target != target ||
      oldDelegate.segments != segments ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.needleColor != needleColor;
}
