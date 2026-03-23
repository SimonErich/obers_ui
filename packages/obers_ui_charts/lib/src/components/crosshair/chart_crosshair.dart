import 'dart:ui';

/// Style options for crosshair display.
enum OiChartCrosshairStyle { both, horizontal, vertical }

/// Configuration for a chart crosshair overlay.
class OiChartCrosshair {
  const OiChartCrosshair({
    this.color,
    this.strokeWidth = 1,
    this.style = OiChartCrosshairStyle.both,
  });

  final Color? color;
  final double strokeWidth;
  final OiChartCrosshairStyle style;
}
