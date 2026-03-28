import 'package:obers_ui_charts/obers_ui_charts.dart' show OiChartExplorer;
import 'package:obers_ui_charts/src/modules/oi_chart_explorer.dart' show OiChartExplorer;

/// The data type of an [OiExplorerColumn].
///
/// Used by [OiChartExplorer] to infer compatible chart types, axis roles,
/// and aggregation strategies for each column.
///
/// {@category Modules}
enum OiColumnType {
  /// A column containing numeric values (int, double).
  numeric,

  /// A column containing discrete category strings.
  categorical,

  /// A column containing [DateTime] values.
  date,
}

/// A column descriptor for use with [OiChartExplorer].
///
/// Each [OiExplorerColumn] defines how to extract a single dimension of data
/// from domain objects of type `T` via the [accessor] function.
///
/// [id] is used to identify the column when assigning it to x/y/groupBy axes.
/// [label] is the human-readable column name shown in the column picker.
/// [type] tells the explorer whether the column contains numeric, categorical,
/// or date values.
///
/// ```dart
/// OiExplorerColumn<SalesRecord>(
///   id: 'date',
///   label: 'Date',
///   accessor: (r) => r.date,
///   type: OiColumnType.date,
/// )
/// OiExplorerColumn<SalesRecord>(
///   id: 'revenue',
///   label: 'Revenue',
///   accessor: (r) => r.revenue,
///   type: OiColumnType.numeric,
/// )
/// ```
///
/// {@category Modules}
class OiExplorerColumn<T> {
  /// Creates an [OiExplorerColumn].
  const OiExplorerColumn({
    required this.id,
    required this.label,
    required this.accessor,
    required this.type,
  });

  /// A unique identifier for this column within the explorer.
  final String id;

  /// The human-readable column name shown in the column picker UI.
  final String label;

  /// Extracts the column's value from a domain object of type [T].
  ///
  /// The returned value is typed as `dynamic` so that numeric, String, and
  /// [DateTime] values can all be represented through the same interface.
  // ignore: avoid_annotating_with_dynamic
  final dynamic Function(T item) accessor;

  /// The semantic type of this column's values.
  final OiColumnType type;
}
