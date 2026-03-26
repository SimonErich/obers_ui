/// Controls the visual complexity level of a chart.
///
/// Used with `OiResponsive<OiChartComplexity>` to adapt chart detail
/// to available space.
///
/// {@category Models}
enum OiChartComplexity {
  /// Minimal: no labels, no grid, no legend, compact markers.
  mini,

  /// Standard: labels, grid, legend, normal markers.
  standard,

  /// Full detail: all labels, annotations, data labels, full legend.
  detailed,
}
