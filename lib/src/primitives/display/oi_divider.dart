import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_decoration_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// A horizontal or vertical divider line with optional centered content.
///
/// Solid dividers are rendered as a thin [Container]. Dashed or dotted
/// dividers use a [CustomPainter].
///
/// Use [OiDivider.withLabel] to show a text string centred in the divider,
/// or [OiDivider.withContent] to show an arbitrary widget.
///
/// {@category Primitives}
class OiDivider extends StatelessWidget {
  /// Creates a plain [OiDivider].
  const OiDivider({
    this.axis = Axis.horizontal,
    this.thickness = 1.0,
    this.color,
    this.style = OiBorderLineStyle.solid,
    this.spacing = 0,
    super.key,
  })  : _label = null,
        _content = null;

  /// Creates a [OiDivider] with a text [label] centred in the line.
  const OiDivider.withLabel(
    String label, {
    this.axis = Axis.horizontal,
    this.thickness = 1.0,
    this.color,
    this.style = OiBorderLineStyle.solid,
    this.spacing = 0,
    super.key,
  })  : _label = label,
        _content = null;

  /// Creates a [OiDivider] with an arbitrary [content] widget centred in
  /// the line.
  const OiDivider.withContent(
    Widget content, {
    this.axis = Axis.horizontal,
    this.thickness = 1.0,
    this.color,
    this.style = OiBorderLineStyle.solid,
    this.spacing = 0,
    super.key,
  })  : _label = null,
        _content = content;

  /// The direction of the divider line.
  final Axis axis;

  /// Stroke thickness in logical pixels.
  final double thickness;

  /// Color of the divider.  Defaults to [OiColorScheme.border] when null.
  final Color? color;

  /// The line drawing style: solid, dashed, or dotted.
  final OiBorderLineStyle style;

  /// Extra space added on both sides of the divider.
  ///
  /// For a horizontal divider this is vertical padding; for a vertical
  /// divider it is horizontal padding.
  final double spacing;

  final String? _label;
  final Widget? _content;

  // ---------------------------------------------------------------------------

  Color _resolvedColor(BuildContext context) =>
      color ?? context.colors.border;

  Widget _buildLine(BuildContext context, {bool flex = true}) {
    final resolvedColor = _resolvedColor(context);

    if (style == OiBorderLineStyle.solid) {
      final line = axis == Axis.horizontal
          ? Container(height: thickness, color: resolvedColor)
          : Container(width: thickness, color: resolvedColor);
      return flex ? Expanded(child: line) : line;
    }

    // Dashed / dotted — delegate to CustomPainter.
    final painter = _OiDividerPainter(
      axis: axis,
      thickness: thickness,
      color: resolvedColor,
      style: style,
    );
    final line = axis == Axis.horizontal
        ? SizedBox(height: thickness, child: CustomPaint(painter: painter))
        : SizedBox(width: thickness, child: CustomPaint(painter: painter));
    return flex ? Expanded(child: line) : line;
  }

  @override
  Widget build(BuildContext context) {
    final hasContent = _label != null || _content != null;
    final centreWidget = _label != null ? Text(_label) : _content;

    Widget divider;

    if (!hasContent) {
      divider = _buildLine(context, flex: false);
    } else if (axis == Axis.horizontal) {
      divider = Row(
        children: [
          _buildLine(context),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: centreWidget,
          ),
          _buildLine(context),
        ],
      );
    } else {
      divider = Column(
        children: [
          _buildLine(context),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: centreWidget,
          ),
          _buildLine(context),
        ],
      );
    }

    if (spacing > 0) {
      divider = axis == Axis.horizontal
          ? Padding(
              padding: EdgeInsets.symmetric(vertical: spacing),
              child: divider,
            )
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing),
              child: divider,
            );
    }

    return divider;
  }
}

// ---------------------------------------------------------------------------
// Painter
// ---------------------------------------------------------------------------

/// Paints a dashed or dotted line along the given [axis].
class _OiDividerPainter extends CustomPainter {
  const _OiDividerPainter({
    required this.axis,
    required this.thickness,
    required this.color,
    required this.style,
  });

  final Axis axis;
  final double thickness;
  final Color color;
  final OiBorderLineStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke;

    final segmentLength =
        style == OiBorderLineStyle.dashed ? thickness * 4 : thickness;
    final gapLength = segmentLength * 1.5;
    final total =
        axis == Axis.horizontal ? size.width : size.height;

    var pos = 0.0;
    var draw = true;

    while (pos < total) {
      final len = draw ? segmentLength : gapLength;
      final end = math.min(pos + len, total);
      if (draw) {
        final p1 = axis == Axis.horizontal
            ? Offset(pos, size.height / 2)
            : Offset(size.width / 2, pos);
        final p2 = axis == Axis.horizontal
            ? Offset(end, size.height / 2)
            : Offset(size.width / 2, end);
        canvas.drawLine(p1, p2, paint);
      }
      pos += len;
      draw = !draw;
    }
  }

  @override
  bool shouldRepaint(_OiDividerPainter oldDelegate) =>
      oldDelegate.axis != axis ||
      oldDelegate.thickness != thickness ||
      oldDelegate.color != color ||
      oldDelegate.style != style;
}
