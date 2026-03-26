/// The chart type displayed in the [OiChartExplorer] canvas area.
///
/// The explorer infers a sensible default chart type from the assigned column
/// types, but the user can freely switch between types using the type switcher.
///
/// {@category Modules}
enum OiExplorerChartType {
  /// A line chart — best for ordered/time-series x columns.
  line,

  /// A bar chart — best for categorical or discrete x columns.
  bar,

  /// A scatter plot — requires both x and y to be numeric.
  scatter,

  /// A pie chart — uses the y column as segment values and x/group as labels.
  pie,

  /// A heatmap — requires categorical x and y columns.
  heatmap,

  /// A histogram — uses only the y column to build frequency bins.
  histogram,
}
