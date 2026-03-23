import 'package:flutter/widgets.dart';

import 'package:obers_ui/src/foundation/scales/oi_chart_controller.dart';

/// Abstract bridge between chart internals and the accessibility system.
///
/// [OiChartAccessibilityBridge] provides methods for chart behaviors to
/// announce state changes, describe data elements, and manage focus for
/// assistive technologies.
///
/// {@category Foundation}
abstract class OiChartAccessibilityBridge {
  /// Announces [message] to screen readers.
  ///
  /// When [assertive] is true, the announcement interrupts the current
  /// speech (use for important state changes like selection).
  void announce(String message, {bool assertive = false});

  /// Returns a human-readable description for the given data [ref].
  ///
  /// Used to build semantic labels for chart elements.
  String describeDataPoint(OiChartDataRef ref);

  /// Returns a human-readable summary of the current selection.
  String describeSelection(Set<OiChartDataRef> refs);

  /// Moves the accessibility focus to the element identified by [ref].
  void focusDataPoint(OiChartDataRef ref);

  /// Whether the user has requested reduced motion.
  bool get reducedMotion;

  /// Whether the user has requested high-contrast mode.
  bool get highContrast;

  /// The [BuildContext] associated with this bridge.
  BuildContext get context;
}
