import 'package:flutter/widgets.dart';

import 'package:obers_ui_charts/src/foundation/oi_chart_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// OiDetectedChartInsight
// ─────────────────────────────────────────────────────────────────────────────

/// An automatically detected insight about the chart data.
///
/// Used in accessibility summaries to communicate notable patterns
/// such as trends, extrema, or anomalies.
///
/// {@category Foundation}
@immutable
class OiDetectedChartInsight {
  /// Creates an [OiDetectedChartInsight].
  const OiDetectedChartInsight({
    required this.type,
    required this.description,
    this.seriesId,
  });

  /// The type of insight (e.g. 'trend', 'max', 'min', 'anomaly').
  final String type;

  /// Human-readable description of the insight.
  final String description;

  /// The series this insight applies to, if specific to one series.
  final String? seriesId;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiDetectedChartInsight &&
        other.type == type &&
        other.description == description &&
        other.seriesId == seriesId;
  }

  @override
  int get hashCode => Object.hash(type, description, seriesId);

  @override
  String toString() =>
      'OiDetectedChartInsight(type: $type, description: $description)';
}

// ─────────────────────────────────────────────────────────────────────────────
// OiChartAccessibilityBridge
// ─────────────────────────────────────────────────────────────────────────────

/// Abstract bridge between chart internals and the accessibility system.
///
/// Provides methods for chart behaviors to announce state changes, describe
/// data elements, and manage focus for assistive technologies.
///
/// {@category Foundation}
abstract class OiChartAccessibilityBridge {
  /// Announces [message] to screen readers.
  ///
  /// When [assertive] is true, the announcement interrupts the current
  /// speech (use for important state changes like selection).
  void announce(String message, {bool assertive = false});

  /// Announces a specific data point to screen readers.
  ///
  /// Delegates to [announce] with a formatted message.
  void announcePoint({
    required String seriesLabel,
    required String xFormatted,
    required String yFormatted,
  }) {
    announce('$seriesLabel: $xFormatted, $yFormatted');
  }

  /// Announces a chart summary to screen readers.
  ///
  /// Delegates to [announce] with the summary text.
  void announceSummary(String summary) {
    announce(summary);
  }

  /// Announces a keyboard navigation action to screen readers.
  ///
  /// Delegates to [announce] with a navigation description.
  void announceNavigation({
    required String direction,
    required String targetDescription,
  }) {
    announce('$direction: $targetDescription');
  }

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

/// A no-op accessibility bridge for use when no real bridge is available.
///
/// All methods are safe to call but produce no side effects.
///
/// {@category Foundation}
class OiNoOpAccessibilityBridge extends OiChartAccessibilityBridge {
  /// Creates an [OiNoOpAccessibilityBridge] with the given [context].
  OiNoOpAccessibilityBridge(this._context);

  final BuildContext _context;

  @override
  void announce(String message, {bool assertive = false}) {}

  @override
  String describeDataPoint(OiChartDataRef ref) => '';

  @override
  String describeSelection(Set<OiChartDataRef> refs) => '';

  @override
  void focusDataPoint(OiChartDataRef ref) {}

  @override
  bool get reducedMotion => false;

  @override
  bool get highContrast => false;

  @override
  BuildContext get context => _context;
}
