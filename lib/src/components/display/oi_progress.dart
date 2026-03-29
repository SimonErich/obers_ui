import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// The visual style of an [OiProgress] indicator.
///
/// {@category Components}
enum OiProgressStyle {
  /// A horizontal bar track with a filled portion.
  linear,

  /// A circular arc drawn with [CustomPaint].
  circular,

  /// A row of step dots/squares, filled up to [OiProgress.currentStep].
  steps,

  /// A linear bar with a "current / total" counter label and optional
  /// percentage and item description.
  bulk,
}

/// A progress indicator supporting linear, circular, and step styles.
///
/// [value] must be in the range [0.0, 1.0]. When [indeterminate] is `true`
/// the widget animates regardless of [value].
///
/// Use the named constructors for each visual style:
/// - [OiProgress.linear]: horizontal track + fill via [CustomPaint].
/// - [OiProgress.circular]: arc via [CustomPaint].
/// - [OiProgress.steps]: a row of step dots filled to [currentStep].
///
/// ```dart
/// OiProgress.linear(value: 0.6)
/// OiProgress.circular(indeterminate: true)
/// OiProgress.steps(steps: 5, currentStep: 3)
/// ```
///
/// {@category Components}
class OiProgress extends StatefulWidget {
  // ── Private base constructor ──────────────────────────────────────────────

  const OiProgress._({
    required this.style,
    this.value = 0,
    this.steps,
    this.currentStep,
    this.label,
    this.indeterminate = false,
    this.color,
    this.strokeWidth = 4,
    this.size,
    this.current,
    this.total,
    this.currentItemLabel,
    this.showPercentage = true,
    this.onCancel,
    super.key,
  });

  // ── Named variant constructors ────────────────────────────────────────────

  /// Creates a linear progress indicator (horizontal bar).
  const OiProgress.linear({
    double value = 0,
    String? label,
    bool indeterminate = false,
    Color? color,
    double strokeWidth = 4,
    double? size,
    Key? key,
  }) : this._(
         style: OiProgressStyle.linear,
         value: value,
         label: label,
         indeterminate: indeterminate,
         color: color,
         strokeWidth: strokeWidth,
         size: size,
         key: key,
       );

  /// Creates a circular progress indicator (arc).
  const OiProgress.circular({
    double value = 0,
    String? label,
    bool indeterminate = false,
    Color? color,
    double strokeWidth = 4,
    double? size,
    Key? key,
  }) : this._(
         style: OiProgressStyle.circular,
         value: value,
         label: label,
         indeterminate: indeterminate,
         color: color,
         strokeWidth: strokeWidth,
         size: size,
         key: key,
       );

  /// Creates a step-based progress indicator (row of dots).
  const OiProgress.steps({
    int? steps,
    int? currentStep,
    double value = 0,
    String? label,
    Color? color,
    Key? key,
  }) : this._(
         style: OiProgressStyle.steps,
         steps: steps,
         currentStep: currentStep,
         value: value,
         label: label,
         color: color,
         key: key,
       );

  /// Creates a bulk progress indicator showing "label (current/total)" with
  /// an optional percentage and item description.
  ///
  /// ```dart
  /// OiProgress.bulk(
  ///   current: 5,
  ///   total: 18,
  ///   label: 'Generating screen specs',
  ///   currentItemLabel: 'Authentication Screen',
  ///   onCancel: () => cancelGeneration(),
  /// )
  /// ```
  const OiProgress.bulk({
    required int current,
    required int total,
    String? label,
    String? currentItemLabel,
    bool showPercentage = true,
    Color? color,
    double strokeWidth = 4,
    double? size,
    VoidCallback? onCancel,
    Key? key,
  }) : this._(
         style: OiProgressStyle.bulk,
         current: current,
         total: total,
         value: total > 0 ? current / total : 0,
         label: label,
         currentItemLabel: currentItemLabel,
         showPercentage: showPercentage,
         color: color,
         strokeWidth: strokeWidth,
         size: size,
         onCancel: onCancel,
         key: key,
       );

  /// Progress from 0.0 to 1.0.
  final double value;

  /// Visual style.
  final OiProgressStyle style;

  /// Number of steps for [OiProgressStyle.steps].
  final int? steps;

  /// The currently completed step index for [OiProgressStyle.steps].
  final int? currentStep;

  /// Optional label rendered below the indicator.
  final String? label;

  /// When `true` an animated sweep is shown instead of a fixed [value].
  final bool indeterminate;

  /// Override color. Defaults to the theme's primary color.
  final Color? color;

  /// Stroke/line width for linear and circular styles.
  final double strokeWidth;

  /// Diameter for [OiProgressStyle.circular] or height for linear.
  final double? size;

  /// The current item count for [OiProgressStyle.bulk].
  final int? current;

  /// The total item count for [OiProgressStyle.bulk].
  final int? total;

  /// Optional description of the item currently being processed.
  final String? currentItemLabel;

  /// Whether to show a percentage next to the counter label.
  final bool showPercentage;

  /// Optional cancel callback for [OiProgressStyle.bulk].
  ///
  /// When non-null, a small × button is shown to the right of the progress bar.
  final VoidCallback? onCancel;

  @override
  State<OiProgress> createState() => _OiProgressState();
}

class _OiProgressState extends State<OiProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.indeterminate) unawaited(_controller.repeat());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.duration =
        context.animations.reducedMotion ||
            MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 1200);
  }

  @override
  void didUpdateWidget(OiProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.indeterminate && !_controller.isAnimating) {
      unawaited(_controller.repeat());
    } else if (!widget.indeterminate && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveColor = widget.color ?? colors.primary.base;
    final trackColor = colors.borderSubtle;

    Widget indicator;

    switch (widget.style) {
      case OiProgressStyle.linear:
        final height = widget.size ?? widget.strokeWidth;
        indicator = AnimatedBuilder(
          animation: _controller,
          builder: (ctx, _) {
            return CustomPaint(
              size: Size(double.infinity, height),
              painter: _LinearProgressPainter(
                value: widget.indeterminate ? _controller.value : widget.value,
                indeterminate: widget.indeterminate,
                color: effectiveColor,
                trackColor: trackColor,
                strokeWidth: height,
              ),
            );
          },
        );

      case OiProgressStyle.circular:
        final diameter = widget.size ?? 48;
        indicator = AnimatedBuilder(
          animation: _controller,
          builder: (ctx, _) {
            return CustomPaint(
              size: Size(diameter, diameter),
              painter: _CircularProgressPainter(
                value: widget.indeterminate ? _controller.value : widget.value,
                indeterminate: widget.indeterminate,
                color: effectiveColor,
                trackColor: trackColor,
                strokeWidth: widget.strokeWidth,
              ),
            );
          },
        );

      case OiProgressStyle.steps:
        final stepCount = widget.steps ?? 5;
        final filled =
            (widget.currentStep ?? (widget.value * stepCount).round()).clamp(
              0,
              stepCount,
            );
        const dotSize = 12.0;
        const dotSpacing = 6.0;
        // REQ-0025: completed steps show a check icon so color is never the
        // sole indicator.
        indicator = Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(stepCount, (i) {
            final isActive = i < filled;
            return Padding(
              padding: EdgeInsets.only(left: i == 0 ? 0 : dotSpacing),
              child: Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  color: isActive ? effectiveColor : trackColor,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: isActive
                    ? Center(
                        child: Icon(
                          OiIcons.check, // check
                          size: dotSize * 0.7,
                          color: colors.textOnPrimary,
                        ),
                      )
                    : null,
              ),
            );
          }),
        );

      case OiProgressStyle.bulk:
        final cur = widget.current ?? 0;
        final tot = widget.total ?? 0;
        final clampedValue = tot > 0 ? (cur / tot).clamp(0.0, 1.0) : 0.0;
        final height = widget.size ?? widget.strokeWidth;
        final bar = CustomPaint(
          size: Size(double.infinity, height),
          painter: _LinearProgressPainter(
            value: clampedValue,
            indeterminate: false,
            color: effectiveColor,
            trackColor: trackColor,
            strokeWidth: height,
          ),
        );

        // Build the counter text: "Label (cur/tot)" or just "cur/tot".
        final counter = widget.label != null
            ? '${widget.label} ($cur/$tot)'
            : '$cur/$tot';

        final percentage = widget.showPercentage && tot > 0
            ? '${(clampedValue * 100).round()}%'
            : null;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: bar),
                if (widget.onCancel != null) ...[
                  const SizedBox(width: 8),
                  OiButton.ghost(
                    label: 'Cancel',
                    icon: OiIcons.x,
                    onTap: widget.onCancel,
                    size: OiButtonSize.small,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    counter,
                    style: TextStyle(fontSize: 12, color: colors.textMuted),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (percentage != null)
                  Text(
                    percentage,
                    style: TextStyle(fontSize: 12, color: colors.textMuted),
                  ),
              ],
            ),
            if (widget.currentItemLabel != null) ...[
              const SizedBox(height: 2),
              Text(
                widget.currentItemLabel!,
                style: TextStyle(fontSize: 11, color: colors.textMuted),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        );
    }

    if (widget.label != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          indicator,
          const SizedBox(height: 4),
          Text(
            widget.label!,
            style: TextStyle(fontSize: 12, color: colors.textMuted),
          ),
        ],
      );
    }

    return indicator;
  }
}

// ---------------------------------------------------------------------------
// Painters
// ---------------------------------------------------------------------------

class _LinearProgressPainter extends CustomPainter {
  const _LinearProgressPainter({
    required this.value,
    required this.indeterminate,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  final double value;
  final bool indeterminate;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final y = size.height / 2;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), trackPaint);

    if (indeterminate) {
      // Sweep a section across the track.
      final start = size.width * ((value - 0.3).clamp(0.0, 1.0));
      final end = size.width * (value.clamp(0.0, 1.0));
      canvas.drawLine(Offset(start, y), Offset(end, y), fillPaint);
    } else {
      final end = size.width * value.clamp(0.0, 1.0);
      if (end > 0) {
        canvas.drawLine(Offset(0, y), Offset(end, y), fillPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_LinearProgressPainter old) =>
      old.value != value ||
      old.color != color ||
      old.trackColor != trackColor ||
      old.indeterminate != indeterminate;
}

class _CircularProgressPainter extends CustomPainter {
  const _CircularProgressPainter({
    required this.value,
    required this.indeterminate,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  final double value;
  final bool indeterminate;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    const startAngle = -math.pi / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    final sweepAngle = indeterminate
        ? math.pi * 1.2
        : math.pi * 2 * value.clamp(0.0, 1.0);

    final arcStart = indeterminate
        ? startAngle + math.pi * 2 * value
        : startAngle;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      arcStart,
      sweepAngle,
      false,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter old) =>
      old.value != value ||
      old.color != color ||
      old.trackColor != trackColor ||
      old.indeterminate != indeterminate;
}
