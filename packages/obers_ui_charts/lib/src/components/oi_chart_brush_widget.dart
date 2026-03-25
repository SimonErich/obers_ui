import 'package:flutter/widgets.dart';

/// A widget that renders a visual brush selection rectangle as a
/// semi-transparent fill with an optional border.
///
/// [OiChartBrushWidget] is a pure rendering widget — it does not capture
/// pointer events. Manage the selection [rect] externally (e.g. via
/// `OiChartBrushBehavior`) and rebuild with the updated rectangle on each
/// frame.
///
/// The [rect] is expressed in widget-local coordinates. If the rect is
/// empty or degenerate it is not rendered.
///
/// ```dart
/// OiChartBrushWidget(
///   rect: selectionRect,
///   fillColor: const Color(0x203388FF),
///   borderColor: const Color(0x803388FF),
///   borderWidth: 1.0,
/// )
/// ```
///
/// {@category Components}
class OiChartBrushWidget extends StatelessWidget {
  /// Creates an [OiChartBrushWidget].
  const OiChartBrushWidget({
    required this.rect,
    super.key,
    this.fillColor,
    this.borderColor,
    this.borderWidth = 1.0,
  });

  /// The selection rectangle in widget-local coordinates.
  ///
  /// When the rect is empty (zero area) nothing is rendered.
  final Rect rect;

  /// Fill color for the selection area.
  ///
  /// Defaults to a semi-transparent blue when null.
  final Color? fillColor;

  /// Border color for the selection outline.
  ///
  /// Defaults to a more opaque variant of [fillColor] when null.
  final Color? borderColor;

  /// Border stroke width in logical pixels.
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _OiBrushPainter(
        rect: rect,
        fillColor: fillColor ?? const Color(0x203388FF),
        borderColor: borderColor ?? const Color(0x803388FF),
        borderWidth: borderWidth,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal painter
// ─────────────────────────────────────────────────────────────────────────────

class _OiBrushPainter extends CustomPainter {
  _OiBrushPainter({
    required this.rect,
    required this.fillColor,
    required this.borderColor,
    required this.borderWidth,
  });

  final Rect rect;
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (rect.isEmpty) return;

    // Fill.
    canvas.drawRect(
      rect,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill,
    );

    // Border.
    if (borderWidth > 0) {
      canvas.drawRect(
        rect,
        Paint()
          ..color = borderColor
          ..strokeWidth = borderWidth
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OiBrushPainter old) {
    return old.rect != rect ||
        old.fillColor != fillColor ||
        old.borderColor != borderColor ||
        old.borderWidth != borderWidth;
  }
}
