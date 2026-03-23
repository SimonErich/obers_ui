/// Chart widgets for the ObersUI design system.
///
/// Provides a 5-tier composition hierarchy matching the main obers_ui
/// architecture. Charts are organized into five architectural families:
/// Cartesian, Polar, Matrix, Hierarchical, and Flow.
library;

// ──────────────────────────────────────────────────────────
// Foundation (Tier 0) — Theme, scales, data, behavior, a11y
// ──────────────────────────────────────────────────────────
export 'src/foundation/chart_accessibility.dart';
export 'src/foundation/chart_behavior.dart';
export 'src/foundation/data/chart_data.dart';
export 'src/foundation/data/chart_padding.dart';
export 'src/foundation/scales/oi_band_scale.dart';
export 'src/foundation/scales/oi_linear_scale.dart';
export 'src/foundation/theme/chart_colors.dart';
export 'src/foundation/theme/chart_text_styles.dart';
export 'src/foundation/theme/chart_theme_data.dart';

// ──────────────────────────────────────────────────────────
// Primitives (Tier 1) — Painters, markers, layers, hit regions
// ──────────────────────────────────────────────────────────
export 'src/primitives/hit_testing/chart_gesture_handler.dart';
export 'src/primitives/hit_testing/chart_hit_result.dart';
export 'src/primitives/layers/chart_layer.dart';
export 'src/primitives/markers/chart_marker.dart';
export 'src/primitives/painters/chart_painter.dart';

// ──────────────────────────────────────────────────────────
// Components (Tier 2) — Axes, legend, tooltip, crosshair,
//                        annotations, thresholds
// ──────────────────────────────────────────────────────────
export 'src/components/annotations/chart_annotation.dart';
export 'src/components/axes/chart_axis_config.dart';
export 'src/components/crosshair/chart_crosshair.dart';
export 'src/components/legend/chart_legend.dart';
export 'src/components/threshold/chart_threshold.dart';
export 'src/components/tooltip/chart_tooltip.dart';

// ──────────────────────────────────────────────────────────
// Composites (Tier 3) — Chart family bases + chart widgets
// ──────────────────────────────────────────────────────────

// Cartesian family
export 'src/composites/cartesian/bar/bar_chart.dart';
export 'src/composites/cartesian/bar/bar_chart_data_processor.dart';
export 'src/composites/cartesian/bar/bar_chart_orientation.dart';
export 'src/composites/cartesian/bar/bar_chart_painter.dart';
export 'src/composites/cartesian/line/line_chart.dart';
export 'src/composites/cartesian/line/line_chart_data_processor.dart';
export 'src/composites/cartesian/line/line_chart_painter.dart';
export 'src/composites/cartesian/oi_cartesian_chart.dart';
export 'src/composites/cartesian/oi_cartesian_painter.dart';

// Polar family
export 'src/composites/polar/oi_polar_chart.dart';
export 'src/composites/polar/oi_polar_data.dart';
export 'src/composites/polar/oi_polar_painter.dart';
export 'src/composites/polar/pie/pie_chart.dart';
export 'src/composites/polar/pie/pie_chart_data_processor.dart';
export 'src/composites/polar/pie/pie_chart_painter.dart';
export 'src/composites/polar/pie/pie_slice.dart';

// Matrix family
export 'src/composites/matrix/oi_matrix_chart.dart';
export 'src/composites/matrix/oi_matrix_data.dart';

// Hierarchical family
export 'src/composites/hierarchical/oi_hierarchical_chart.dart';
export 'src/composites/hierarchical/oi_hierarchical_data.dart';

// Flow family
export 'src/composites/flow/oi_flow_chart.dart';
export 'src/composites/flow/oi_flow_data.dart';

// ──────────────────────────────────────────────────────────
// Modules (Tier 4) — Assembled experiences (future)
// ──────────────────────────────────────────────────────────
// No modules yet — placeholder tier for dashboard experiences.

// ──────────────────────────────────────────────────────────
// Backward-compatible type aliases
// ──────────────────────────────────────────────────────────
/// Alias for [OiChartThemeData] to maintain backward compatibility.
typedef OiChartTheme = OiChartThemeData;
