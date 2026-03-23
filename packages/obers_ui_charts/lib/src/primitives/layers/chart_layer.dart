import 'dart:ui';

/// A composable painting layer for chart rendering.
///
/// Each layer wraps a painting function and can be toggled on/off.
class OiChartLayer {
  const OiChartLayer({
    required this.painter,
    this.opacity = 1.0,
    this.visible = true,
  });

  final void Function(Canvas, Size) painter;
  final double opacity;
  final bool visible;

  /// Paints this layer onto [canvas] at [size] if visible.
  void paint(Canvas canvas, Size size) {
    if (!visible) return;

    if (opacity < 1.0) {
      canvas.saveLayer(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = Color.fromRGBO(0, 0, 0, opacity),
      );
      painter(canvas, size);
      canvas.restore();
    } else {
      painter(canvas, size);
    }
  }
}
