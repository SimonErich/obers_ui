import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:obers_ui_charts/src/composites/polar/oi_polar_data.dart';
import 'package:obers_ui_charts/src/foundation/theme/chart_theme_data.dart';

/// Abstract base painter for polar/radial chart types.
///
/// Provides shared radial coordinate system. Subclasses implement
/// [paintSegments] for their specific visualization.
abstract class OiPolarPainter extends CustomPainter {
  OiPolarPainter({
    required this.data,
    required this.theme,
  });

  final OiPolarData data;
  final OiChartThemeData theme;

  /// Paints the radial background (optional circle).
  void paintBackground(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    final paint = Paint()
      ..color = theme.colors.gridColor
      ..strokeWidth = theme.gridLineWidth
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, paint);
  }

  /// Paints the chart-specific segments. Subclasses must implement.
  void paintSegments(Canvas canvas, Size size);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    if (data.isEmpty) return;

    canvas
      ..save()
      ..clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    paintSegments(canvas, size);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant OiPolarPainter oldDelegate) =>
      data != oldDelegate.data || theme != oldDelegate.theme;
}
