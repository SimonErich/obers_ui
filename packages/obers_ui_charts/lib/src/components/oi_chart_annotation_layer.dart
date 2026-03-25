import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' hide OiAnnotationType;

import 'package:obers_ui_charts/src/foundation/oi_chart_viewport.dart';
import 'package:obers_ui_charts/src/models/oi_chart_annotation.dart';
import 'package:obers_ui_charts/src/models/oi_chart_threshold.dart';

/// A widget that renders [OiChartAnnotation] items and [OiChartThreshold]
/// lines within the chart plot area.
///
/// Annotations include horizontal/vertical reference lines, shaded region
/// bands, and floating text labels. Thresholds are horizontal lines drawn
/// at specific y-values with optional labels.
///
/// All rendering is clipped to the plot bounds. Annotation positions
/// are expressed as **normalized (0–1) fractions** of the plot width/height,
/// where 0 is the left/top edge and 1 is the right/bottom edge.
///
/// Thresholds use normalized y-values in the same (0–1) space — callers
/// are responsible for mapping their data-domain values to normalized
/// coordinates before passing them in.
///
/// ```dart
/// OiChartAnnotationLayer(
///   viewport: viewport,
///   thresholds: [
///     OiChartThreshold(value: 0.75, label: 'Target', color: Colors.green),
///   ],
///   annotations: [
///     OiChartAnnotation.horizontalLine(value: 0.5, label: 'Average'),
///   ],
/// )
/// ```
///
/// {@category Components}
class OiChartAnnotationLayer extends StatelessWidget {
  /// Creates an [OiChartAnnotationLayer].
  const OiChartAnnotationLayer({
    required this.viewport,
    super.key,
    this.annotations = const [],
    this.thresholds = const [],
    this.theme,
  });

  /// The chart viewport supplying the plot bounds for clipping and sizing.
  final OiChartViewport viewport;

  /// The list of annotations to render.
  final List<OiChartAnnotation> annotations;

  /// The list of threshold lines to render.
  final List<OiChartThreshold> thresholds;

  /// Optional theme data; visual tokens fall back to built-in defaults
  /// when null.
  final OiChartThemeData? theme;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: viewport.size,
      painter: _OiAnnotationLayerPainter(
        plotBounds: viewport.plotBounds,
        annotations: annotations,
        thresholds: thresholds,
        themeAnnotation: theme?.annotation,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal painter
// ─────────────────────────────────────────────────────────────────────────────

class _OiAnnotationLayerPainter extends CustomPainter {
  _OiAnnotationLayerPainter({
    required this.plotBounds,
    required this.annotations,
    required this.thresholds,
    this.themeAnnotation,
  });

  final Rect plotBounds;
  final List<OiChartAnnotation> annotations;
  final List<OiChartThreshold> thresholds;
  final OiChartAnnotationTheme? themeAnnotation;

  static const Color _fallbackLineColor = Color(0xFF9E9E9E);
  static const double _fallbackLineWidth = 1;
  static const Color _fallbackBandColor = Color(0x203388FF);
  static const double _labelGap = 4;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..clipRect(plotBounds);

    for (final annotation in annotations) {
      if (!annotation.visible) continue;
      _paintAnnotation(canvas, annotation);
    }

    canvas.restore();

    // Thresholds are drawn on top, with labels potentially outside plotBounds.
    for (final threshold in thresholds) {
      _paintThreshold(canvas, threshold);
    }
  }

  // ── Annotation rendering ─────────────────────────────────────────────────

  void _paintAnnotation(Canvas canvas, OiChartAnnotation annotation) {
    final style = annotation.style;
    final lineColor =
        style?.color ?? themeAnnotation?.lineColor ?? _fallbackLineColor;
    final lineWidth =
        style?.strokeWidth ?? themeAnnotation?.lineWidth ?? _fallbackLineWidth;
    final dashPattern = style?.dashPattern ?? themeAnnotation?.lineDashPattern;
    final fill =
        style?.fill ?? themeAnnotation?.bandColor ?? _fallbackBandColor;

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke;

    switch (annotation.type) {
      case OiAnnotationType.horizontalLine:
        final v = annotation.value;
        if (v == null) return;
        final y = plotBounds.top + v * plotBounds.height;
        final start = Offset(plotBounds.left, y);
        final end = Offset(plotBounds.right, y);
        _drawLine(canvas, start, end, linePaint, dashPattern);
        if (annotation.label != null) {
          _paintLineLabel(
            canvas,
            annotation.label!,
            Offset(plotBounds.right + _labelGap, y),
            style?.labelStyle,
            lineColor,
            vertical: false,
          );
        }

      case OiAnnotationType.verticalLine:
        final v = annotation.value;
        if (v == null) return;
        final x = plotBounds.left + v * plotBounds.width;
        final start = Offset(x, plotBounds.top);
        final end = Offset(x, plotBounds.bottom);
        _drawLine(canvas, start, end, linePaint, dashPattern);
        if (annotation.label != null) {
          _paintLineLabel(
            canvas,
            annotation.label!,
            Offset(x, plotBounds.top - _labelGap),
            style?.labelStyle,
            lineColor,
            vertical: true,
          );
        }

      case OiAnnotationType.region:
        final start = annotation.start;
        final end = annotation.end;
        if (start == null || end == null) return;
        final left = plotBounds.left + start * plotBounds.width;
        final right = plotBounds.left + end * plotBounds.width;
        final regionRect = Rect.fromLTRB(
          left,
          plotBounds.top,
          right,
          plotBounds.bottom,
        );
        canvas.drawRect(
          regionRect,
          Paint()
            ..color = fill
            ..style = PaintingStyle.fill,
        );
        canvas.drawRect(regionRect, linePaint);
        if (annotation.label != null) {
          _paintLineLabel(
            canvas,
            annotation.label!,
            Offset(left + (right - left) / 2, plotBounds.top - _labelGap),
            style?.labelStyle,
            lineColor,
            vertical: false,
            centerX: true,
          );
        }

      case OiAnnotationType.point:
        final v = annotation.value;
        if (v == null) return;
        // For a point, treat value as x and use 0.5 y by default.
        final x = plotBounds.left + v * plotBounds.width;
        final y = plotBounds.center.dy;
        canvas.drawCircle(
          Offset(x, y),
          4,
          Paint()
            ..color = lineColor
            ..style = PaintingStyle.fill,
        );

      case OiAnnotationType.label:
        final v = annotation.value;
        if (v == null || annotation.label == null) return;
        final x = plotBounds.left + v * plotBounds.width;
        final y = plotBounds.center.dy;
        _paintLineLabel(
          canvas,
          annotation.label!,
          Offset(x, y),
          style?.labelStyle,
          lineColor,
          vertical: false,
        );
    }
  }

  // ── Threshold rendering ───────────────────────────────────────────────────

  void _paintThreshold(Canvas canvas, OiChartThreshold threshold) {
    final normalizedY = threshold.value.toDouble();
    // Normalize: 0 = bottom of plot, 1 = top — flip for canvas coordinates.
    final y = plotBounds.bottom - normalizedY * plotBounds.height;

    final lineColor =
        threshold.color ?? themeAnnotation?.lineColor ?? _fallbackLineColor;
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = threshold.strokeWidth
      ..style = PaintingStyle.stroke;

    canvas
      ..save()
      ..clipRect(plotBounds);
    _drawLine(
      canvas,
      Offset(plotBounds.left, y),
      Offset(plotBounds.right, y),
      linePaint,
      threshold.dashPattern,
    );
    canvas.restore();

    if (threshold.showLabel && threshold.label != null) {
      final labelX = switch (threshold.labelPosition) {
        OiThresholdLabelPosition.start => plotBounds.left + _labelGap,
        OiThresholdLabelPosition.end ||
        OiThresholdLabelPosition.above ||
        OiThresholdLabelPosition.below ||
        OiThresholdLabelPosition.inline => plotBounds.right - _labelGap,
      };

      final labelStyle =
          themeAnnotation?.labelStyle ?? const TextStyle(fontSize: 11);
      final labelColor = themeAnnotation?.labelColor ?? lineColor;
      final effectiveStyle = labelStyle.copyWith(color: labelColor);

      final tp = TextPainter(
        text: TextSpan(text: threshold.label, style: effectiveStyle),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();

      final dy = threshold.labelPosition == OiThresholdLabelPosition.below
          ? y + _labelGap
          : y - tp.height - _labelGap;

      tp
        ..paint(canvas, Offset(labelX - tp.width, dy))
        ..dispose();
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static void _drawLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
    List<double>? dashPattern,
  ) {
    if (dashPattern == null || dashPattern.isEmpty) {
      canvas.drawLine(start, end, paint);
      return;
    }

    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final distance = Offset(dx, dy).distance;
    if (distance == 0) return;

    final dirX = dx / distance;
    final dirY = dy / distance;
    var drawn = 0.0;
    var dashIndex = 0;
    var drawing = true;

    while (drawn < distance) {
      final dashLen = dashPattern[dashIndex % dashPattern.length];
      final segEnd = (drawn + dashLen).clamp(0.0, distance);

      if (drawing) {
        canvas.drawLine(
          Offset(start.dx + dirX * drawn, start.dy + dirY * drawn),
          Offset(start.dx + dirX * segEnd, start.dy + dirY * segEnd),
          paint,
        );
      }

      drawn = segEnd;
      dashIndex++;
      drawing = !drawing;
    }
  }

  void _paintLineLabel(
    Canvas canvas,
    String text,
    Offset anchor,
    TextStyle? overrideStyle,
    Color fallbackColor, {
    required bool vertical,
    bool centerX = false,
  }) {
    final labelStyle =
        overrideStyle ??
        themeAnnotation?.labelStyle ??
        const TextStyle(fontSize: 11);
    final labelColor = themeAnnotation?.labelColor ?? fallbackColor;
    final effectiveStyle = labelStyle.copyWith(color: labelColor);

    final tp = TextPainter(
      text: TextSpan(text: text, style: effectiveStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    final offsetX = centerX ? anchor.dx - tp.width / 2 : anchor.dx;
    tp
      ..paint(canvas, Offset(offsetX, anchor.dy - tp.height / 2))
      ..dispose();
  }

  @override
  bool shouldRepaint(covariant _OiAnnotationLayerPainter old) {
    return old.plotBounds != plotBounds ||
        !listEquals(old.annotations, annotations) ||
        !listEquals(old.thresholds, thresholds) ||
        old.themeAnnotation != themeAnnotation;
  }
}
