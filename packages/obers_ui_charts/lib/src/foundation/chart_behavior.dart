import 'package:flutter/animation.dart';

/// Interaction mode for chart gestures.
enum OiChartInteractionMode {
  /// Touch-optimized with larger hit targets.
  touch,

  /// Pointer-optimized with hover states.
  pointer,

  /// Automatically detect based on platform.
  auto,
}

/// Configuration for chart animation and interaction behavior.
class OiChartBehavior {
  const OiChartBehavior({
    this.animateOnLoad = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
    this.interactionMode = OiChartInteractionMode.auto,
  });

  final bool animateOnLoad;
  final Duration animationDuration;
  final Curve animationCurve;
  final OiChartInteractionMode interactionMode;
}
