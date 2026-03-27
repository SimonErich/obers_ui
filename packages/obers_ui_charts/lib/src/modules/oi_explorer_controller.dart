import 'package:flutter/cupertino.dart' show AnimatedBuilder, ListenableBuilder;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show AnimatedBuilder, ListenableBuilder;
import 'package:flutter/widgets.dart' show AnimatedBuilder, ListenableBuilder;
import 'package:obers_ui_charts/obers_ui_charts.dart' show OiChartExplorer;
import 'package:obers_ui_charts/src/modules/oi_chart_explorer.dart' show OiChartExplorer;
import 'package:obers_ui_charts/src/modules/oi_explorer_chart_type.dart';

/// Manages the axis assignments, chart type, and grouping configuration for
/// an [OiChartExplorer].
///
/// [OiExplorerController] extends [ChangeNotifier], so widgets can rebuild
/// automatically in response to any state change by wrapping them in a
/// [ListenableBuilder] or [AnimatedBuilder].
///
/// ```dart
/// final controller = OiExplorerController(
///   chartType: OiExplorerChartType.line,
/// );
///
/// // Assign axes:
/// controller.setXColumn('date');
/// controller.setYColumn('revenue');
/// controller.setGroupBy('category');
///
/// // Switch chart type:
/// controller.setChartType(OiExplorerChartType.bar);
///
/// // Dispose when done:
/// controller.dispose();
/// ```
///
/// {@category Modules}
class OiExplorerController extends ChangeNotifier {
  /// Creates an [OiExplorerController].
  ///
  /// [chartType] sets the initial chart type. [xColumnId], [yColumnId], and
  /// [groupByColumnId] set the initial axis assignments. All default to null
  /// (unassigned).
  OiExplorerController({
    this.chartType = OiExplorerChartType.line,
    this.xColumnId,
    this.yColumnId,
    this.groupByColumnId,
  });

  /// The currently active chart type.
  OiExplorerChartType chartType;

  /// The id of the column assigned to the x-axis, or null if unassigned.
  String? xColumnId;

  /// The id of the column assigned to the y-axis, or null if unassigned.
  String? yColumnId;

  /// The id of the column used to split the data into series groups, or null.
  String? groupByColumnId;

  /// Changes the active chart type and notifies listeners.
  void setChartType(OiExplorerChartType type) {
    if (chartType == type) return;
    chartType = type;
    notifyListeners();
  }

  /// Assigns [id] to the x-axis and notifies listeners.
  void setXColumn(String id) {
    if (xColumnId == id) return;
    xColumnId = id;
    notifyListeners();
  }

  /// Assigns [id] to the y-axis and notifies listeners.
  void setYColumn(String id) {
    if (yColumnId == id) return;
    yColumnId = id;
    notifyListeners();
  }

  /// Sets the group-by column to [id] and notifies listeners.
  ///
  /// Pass null to clear the group-by assignment.
  void setGroupBy(String? id) {
    if (groupByColumnId == id) return;
    groupByColumnId = id;
    notifyListeners();
  }

  /// Clears all axis assignments and resets the chart type to [defaultType].
  ///
  /// Notifies listeners after resetting.
  void reset({OiExplorerChartType defaultType = OiExplorerChartType.line}) {
    chartType = defaultType;
    xColumnId = null;
    yColumnId = null;
    groupByColumnId = null;
    notifyListeners();
  }
}
