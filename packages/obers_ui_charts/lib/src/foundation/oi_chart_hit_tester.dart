import 'dart:ui' show Offset;

import 'package:obers_ui_charts/src/foundation/oi_chart_controller.dart';

/// Abstract hit-testing interface for chart elements.
///
/// Each chart type implements this to map pointer positions to data
/// references. The `OiChartBehavior` system uses the hit tester to
/// translate pointer events into data-level interactions.
///
/// {@category Foundation}
abstract class OiChartHitTester {
  /// Performs a hit test at the given widget-local [position].
  ///
  /// Returns the nearest [OiChartHitResult] within [tolerance] logical
  /// pixels, or null if no element is close enough.
  OiChartHitResult? hitTest(Offset position, {double tolerance = 16});

  /// Returns all hit results within [tolerance] of the given [position],
  /// sorted by distance (nearest first).
  List<OiChartHitResult> hitTestAll(Offset position, {double tolerance = 16});
}
