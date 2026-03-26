import 'package:flutter/widgets.dart';
import 'package:obers_ui_charts/src/modules/oi_grid_position.dart';

/// A single panel in an [OiAnalyticsDashboard].
///
/// Each panel combines a unique [id], a display [title], a [gridPosition]
/// describing its location and span within the dashboard grid, and the
/// [chart] widget to render inside the panel body.
///
/// ```dart
/// OiDashboardPanel(
///   id: 'revenue',
///   title: 'Revenue Over Time',
///   gridPosition: OiGridPosition(row: 0, col: 0, colSpan: 2),
///   chart: OiLineChart(...),
/// )
/// ```
///
/// {@category Modules}
class OiDashboardPanel {
  /// Creates an [OiDashboardPanel].
  const OiDashboardPanel({
    required this.id,
    required this.title,
    required this.gridPosition,
    required this.chart,
  });

  /// A unique identifier for this panel within the dashboard.
  final String id;

  /// The title displayed in the panel's header bar.
  final String title;

  /// The grid position and span for this panel.
  final OiGridPosition gridPosition;

  /// The chart widget rendered inside the panel body.
  final Widget chart;
}
