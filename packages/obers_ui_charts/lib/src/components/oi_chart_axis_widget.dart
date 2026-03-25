import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_charts/src/composites/oi_chart_axis.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_axis_painter.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_viewport.dart';

/// A widget that renders an axis line, tick marks, tick labels, and an
/// optional title along one edge of the chart plot area.
///
/// [OiChartAxisWidget] composes `OiChartAxisPainter` and
/// `OiChartLabelPainter` into a single [CustomPaint] surface, applying
/// [OiChartThemeData] tokens for all visual properties and respecting the
/// [OiChartAxis.maxVisibleTicks] responsive limit and
/// [OiChartAxis.labelOverflow] strategy.
///
/// The axis orientation (edge) is derived from `axis.position`; when
/// that is null it defaults to `OiAxisPosition.bottom`.
///
/// ```dart
/// OiChartAxisWidget(
///   axis: OiChartAxis<double>(
///     label: 'Revenue',
///     position: OiAxisPosition.left,
///     showGrid: false,
///   ),
///   viewport: viewport,
///   tickPositions: [100, 200, 300],
///   tickLabels: ['\$1k', '\$2k', '\$3k'],
/// )
/// ```
///
/// {@category Components}
class OiChartAxisWidget extends StatelessWidget {
  /// Creates an [OiChartAxisWidget].
  const OiChartAxisWidget({
    required this.axis,
    required this.viewport,
    super.key,
    this.tickPositions = const [],
    this.tickLabels = const [],
    this.theme,
  });

  /// The axis configuration model.
  final OiChartAxis<dynamic> axis;

  /// The chart viewport that supplies the plot bounds for rendering.
  final OiChartViewport viewport;

  /// Pixel positions of each tick mark along the axis edge.
  ///
  /// For bottom/top axes these are x-coordinates; for left/right axes
  /// these are y-coordinates. Both lists must have the same length.
  final List<double> tickPositions;

  /// The formatted label strings corresponding to each tick position.
  final List<String> tickLabels;

  /// Optional theme data; visual properties fall back to sensible
  /// defaults when null.
  final OiChartThemeData? theme;

  @override
  Widget build(BuildContext context) {
    final size = viewport.size;
    final edge = (axis.position ?? OiAxisPosition.bottom).toEdge();
    final themeAxis = theme?.axis;

    return CustomPaint(
      size: size,
      painter: _OiAxisCompositePainter(
        edge: edge,
        tickPositions: tickPositions,
        tickLabels: axis.showTickMarks ? tickLabels : const [],
        showAxisLine: axis.showAxisLine,
        overflow: axis.labelOverflow,
        maxVisibleTicks: axis.maxVisibleTicks,
        title: axis.label,
        titleAlignment: axis.titleAlignment,
        viewport: viewport,
        themeAxis: themeAxis,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal composite painter
// ─────────────────────────────────────────────────────────────────────────────

class _OiAxisCompositePainter extends CustomPainter {
  _OiAxisCompositePainter({
    required this.edge,
    required this.tickPositions,
    required this.tickLabels,
    required this.showAxisLine,
    required this.overflow,
    required this.maxVisibleTicks,
    required this.title,
    required this.titleAlignment,
    required this.viewport,
    this.themeAxis,
  });

  final OiChartAxisEdge edge;
  final List<double> tickPositions;
  final List<String> tickLabels;
  final bool showAxisLine;
  final OiChartLabelOverflow overflow;
  final OiResponsive<int>? maxVisibleTicks;
  final String? title;
  final OiAxisTitleAlignment titleAlignment;
  final OiChartViewport viewport;
  final OiChartAxisTheme? themeAxis;

  static const Color _fallbackLineColor = Color(0xFF9E9E9E);
  static const double _fallbackLineWidth = 1;
  static const double _fallbackTickLength = 6;
  static const double _fallbackTickWidth = 1;
  static const double _labelGap = 4;
  static const double _maxLabelWidth = 80;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = viewport.plotBounds;

    final lineColor = themeAxis?.lineColor ?? _fallbackLineColor;
    final lineWidth = themeAxis?.lineWidth ?? _fallbackLineWidth;
    final tickColor = themeAxis?.tickColor ?? lineColor;
    final tickLength = themeAxis?.tickLength ?? _fallbackTickLength;
    final tickWidth = themeAxis?.tickWidth ?? _fallbackTickWidth;

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke;

    final tickPaint = Paint()
      ..color = tickColor
      ..strokeWidth = tickWidth
      ..style = PaintingStyle.stroke;

    // ── Axis line ──────────────────────────────────────────────────────────
    if (showAxisLine) {
      switch (edge) {
        case OiChartAxisEdge.bottom:
          canvas.drawLine(
            Offset(bounds.left, bounds.bottom),
            Offset(bounds.right, bounds.bottom),
            linePaint,
          );
        case OiChartAxisEdge.top:
          canvas.drawLine(
            Offset(bounds.left, bounds.top),
            Offset(bounds.right, bounds.top),
            linePaint,
          );
        case OiChartAxisEdge.left:
          canvas.drawLine(
            Offset(bounds.left, bounds.top),
            Offset(bounds.left, bounds.bottom),
            linePaint,
          );
        case OiChartAxisEdge.right:
          canvas.drawLine(
            Offset(bounds.right, bounds.top),
            Offset(bounds.right, bounds.bottom),
            linePaint,
          );
      }
    }

    // ── Tick marks ─────────────────────────────────────────────────────────
    switch (edge) {
      case OiChartAxisEdge.bottom:
        for (final x in tickPositions) {
          canvas.drawLine(
            Offset(x, bounds.bottom),
            Offset(x, bounds.bottom + tickLength),
            tickPaint,
          );
        }
      case OiChartAxisEdge.top:
        for (final x in tickPositions) {
          canvas.drawLine(
            Offset(x, bounds.top),
            Offset(x, bounds.top - tickLength),
            tickPaint,
          );
        }
      case OiChartAxisEdge.left:
        for (final y in tickPositions) {
          canvas.drawLine(
            Offset(bounds.left, y),
            Offset(bounds.left - tickLength, y),
            tickPaint,
          );
        }
      case OiChartAxisEdge.right:
        for (final y in tickPositions) {
          canvas.drawLine(
            Offset(bounds.right, y),
            Offset(bounds.right + tickLength, y),
            tickPaint,
          );
        }
    }

    // ── Tick labels ────────────────────────────────────────────────────────
    if (tickLabels.isNotEmpty && tickPositions.isNotEmpty) {
      final labelStyle = themeAxis?.labelStyle ?? const TextStyle(fontSize: 11);
      final labelColor = themeAxis?.labelColor;
      final effectiveStyle = labelColor != null
          ? labelStyle.copyWith(color: labelColor)
          : labelStyle.copyWith(color: const Color(0xFF666666));

      final count = math.min(tickLabels.length, tickPositions.length);
      final visibleIndices = _computeVisibleIndices(count);

      _paintLabels(canvas, bounds, effectiveStyle, visibleIndices);
    }

    // ── Axis title ─────────────────────────────────────────────────────────
    if (title != null && title!.isNotEmpty) {
      _paintTitle(canvas, bounds);
    }
  }

  List<int> _computeVisibleIndices(int totalCount) {
    if (maxVisibleTicks == null) {
      return List.generate(totalCount, (i) => i);
    }
    final resolved = maxVisibleTicks!.resolve(
      OiBreakpoint.compact,
      OiBreakpointScale.defaultScale,
    );
    if (resolved >= totalCount) return List.generate(totalCount, (i) => i);
    if (resolved <= 0) return const [];
    if (resolved == 1) return [0];
    if (resolved == 2) return [0, totalCount - 1];

    final indices = <int>[0];
    final step = (totalCount - 1) / (resolved - 1);
    for (var i = 1; i < resolved - 1; i++) {
      indices.add((i * step).round());
    }
    indices.add(totalCount - 1);
    return indices;
  }

  void _paintLabels(
    Canvas canvas,
    Rect bounds,
    TextStyle style,
    List<int> indices,
  ) {
    Rect? lastRect;

    for (final i in indices) {
      final label = tickLabels[i];
      final pos = tickPositions[i];

      final tp = TextPainter(
        text: TextSpan(text: label, style: style),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: overflow == OiChartLabelOverflow.truncate ? '…' : null,
      )..layout(maxWidth: _maxLabelWidth);

      final anchor = _labelAnchor(bounds, pos);
      final offset = _labelOffset(anchor, tp);
      final labelRect = offset & Size(tp.width, tp.height);

      if (overflow == OiChartLabelOverflow.skip) {
        if (lastRect != null && lastRect.overlaps(labelRect)) {
          tp.dispose();
          continue;
        }
      } else if (overflow == OiChartLabelOverflow.rotate) {
        canvas
          ..save()
          ..translate(anchor.dx, anchor.dy)
          ..rotate(-math.pi / 4);
        tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
        canvas.restore();
        tp.dispose();
        lastRect = labelRect;
        continue;
      }

      tp.paint(canvas, offset);
      lastRect = labelRect;
      tp.dispose();
    }
  }

  Offset _labelAnchor(Rect bounds, double pos) {
    return switch (edge) {
      OiChartAxisEdge.bottom => Offset(pos, bounds.bottom + _labelGap),
      OiChartAxisEdge.top => Offset(pos, bounds.top - _labelGap),
      OiChartAxisEdge.left => Offset(bounds.left - _labelGap, pos),
      OiChartAxisEdge.right => Offset(bounds.right + _labelGap, pos),
    };
  }

  Offset _labelOffset(Offset anchor, TextPainter tp) {
    return switch (edge) {
      OiChartAxisEdge.bottom => Offset(anchor.dx - tp.width / 2, anchor.dy),
      OiChartAxisEdge.top => Offset(
        anchor.dx - tp.width / 2,
        anchor.dy - tp.height,
      ),
      OiChartAxisEdge.left => Offset(
        anchor.dx - tp.width,
        anchor.dy - tp.height / 2,
      ),
      OiChartAxisEdge.right => Offset(anchor.dx, anchor.dy - tp.height / 2),
    };
  }

  void _paintTitle(Canvas canvas, Rect bounds) {
    final titleStyle =
        themeAxis?.titleStyle ??
        const TextStyle(fontSize: 12, fontWeight: FontWeight.w500);
    final titleColor = themeAxis?.titleColor;
    final effectiveStyle = titleColor != null
        ? titleStyle.copyWith(color: titleColor)
        : titleStyle.copyWith(color: const Color(0xFF444444));

    final tp = TextPainter(
      text: TextSpan(text: title, style: effectiveStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    final isHorizontal =
        edge == OiChartAxisEdge.bottom || edge == OiChartAxisEdge.top;

    if (isHorizontal) {
      final axisCenter = (bounds.left + bounds.right) / 2;
      final titleX = switch (titleAlignment) {
        OiAxisTitleAlignment.start => bounds.left,
        OiAxisTitleAlignment.center => axisCenter - tp.width / 2,
        OiAxisTitleAlignment.end => bounds.right - tp.width,
      };
      final titleY = edge == OiChartAxisEdge.bottom
          ? bounds.bottom + _labelGap + 16
          : bounds.top - _labelGap - 16 - tp.height;
      tp.paint(canvas, Offset(titleX, titleY));
    } else {
      // Vertical axis — rotate title 90°.
      final axisCenter = (bounds.top + bounds.bottom) / 2;
      final titleY = switch (titleAlignment) {
        OiAxisTitleAlignment.start => bounds.top,
        OiAxisTitleAlignment.center => axisCenter + tp.width / 2,
        OiAxisTitleAlignment.end => bounds.bottom + tp.width / 2,
      };
      final titleX = edge == OiChartAxisEdge.left
          ? bounds.left - _labelGap - 24
          : bounds.right + _labelGap + 24;

      canvas
        ..save()
        ..translate(titleX, titleY)
        ..rotate(-math.pi / 2);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }

    tp.dispose();
  }

  @override
  bool shouldRepaint(covariant _OiAxisCompositePainter old) {
    return old.edge != edge ||
        !listEquals(old.tickPositions, tickPositions) ||
        !listEquals(old.tickLabels, tickLabels) ||
        old.showAxisLine != showAxisLine ||
        old.overflow != overflow ||
        old.maxVisibleTicks != maxVisibleTicks ||
        old.title != title ||
        old.titleAlignment != titleAlignment ||
        old.viewport != viewport ||
        old.themeAxis != themeAxis;
  }
}
