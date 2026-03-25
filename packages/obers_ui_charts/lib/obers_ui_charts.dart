/// Chart foundation and visualization composites for the obers_ui design system.
///
/// To use, import `package:obers_ui_charts/obers_ui_charts.dart`.
///
/// {@category Getting Started}
library;

// ── Components: Display ──────────────────────────────────────────────────────

export 'src/components/oi_chart_surface.dart';
// ── Composites: Bar Chart ────────────────────────────────────────────────────

export 'src/composites/oi_bar_chart/oi_bar_chart.dart';
export 'src/composites/oi_bar_chart/oi_bar_chart_accessibility.dart';
export 'src/composites/oi_bar_chart/oi_bar_chart_data.dart';
export 'src/composites/oi_bar_chart/oi_bar_chart_legend.dart';
export 'src/composites/oi_bar_chart/oi_bar_chart_theme.dart';
// ── Composites: Bubble Chart ─────────────────────────────────────────────────

export 'src/composites/oi_bubble_chart/oi_bubble_chart.dart';
export 'src/composites/oi_bubble_chart/oi_bubble_chart_accessibility.dart';
export 'src/composites/oi_bubble_chart/oi_bubble_chart_data.dart';
export 'src/composites/oi_bubble_chart/oi_bubble_chart_interaction.dart';
export 'src/composites/oi_bubble_chart/oi_bubble_chart_legend.dart';
export 'src/composites/oi_bubble_chart/oi_bubble_chart_size_legend.dart';
export 'src/composites/oi_bubble_chart/oi_bubble_chart_theme.dart';
// ── Composites: Line Chart ───────────────────────────────────────────────────

export 'src/composites/oi_line_chart/oi_line_chart.dart';
export 'src/composites/oi_line_chart/oi_line_chart_accessibility.dart';
export 'src/composites/oi_line_chart/oi_line_chart_data.dart';
export 'src/composites/oi_line_chart/oi_line_chart_legend.dart';
export 'src/composites/oi_line_chart/oi_line_chart_theme.dart';
// ── Composites: Shared ───────────────────────────────────────────────────────

export 'src/composites/oi_chart_axis.dart';
export 'src/composites/oi_chart_legend.dart';
export 'src/composites/oi_chart_series_toggle.dart';
// ── Composites: Simple Charts ────────────────────────────────────────────────

export 'src/composites/oi_funnel_chart.dart';
export 'src/composites/oi_gauge.dart';
export 'src/composites/oi_heatmap.dart';
export 'src/composites/oi_pie_chart.dart';
export 'src/composites/oi_radar_chart.dart';
export 'src/composites/oi_sankey.dart';
export 'src/composites/oi_scatter_plot.dart';
export 'src/composites/oi_sparkline.dart';
export 'src/composites/oi_treemap.dart';
// ── Foundation: Behaviors ────────────────────────────────────────────────────

export 'src/foundation/oi_chart_behavior.dart';
export 'src/foundation/oi_chart_brush.dart';
export 'src/foundation/oi_chart_crosshair.dart';
export 'src/foundation/oi_chart_tooltip.dart';
// ── Foundation: Canvas & Rendering ───────────────────────────────────────────

export 'src/foundation/oi_chart_axis_painter.dart';
export 'src/foundation/oi_chart_canvas.dart';
export 'src/foundation/oi_chart_grid_painter.dart';
export 'src/foundation/oi_chart_layer.dart';
export 'src/foundation/oi_chart_marker.dart';
// ── Foundation: Controller & State ───────────────────────────────────────────

export 'src/foundation/oi_chart_controller.dart';
export 'src/foundation/oi_chart_extension.dart';
export 'src/foundation/oi_chart_viewport.dart';
// ── Foundation: Hit Testing ──────────────────────────────────────────────────

export 'src/foundation/oi_chart_hit_test.dart';
export 'src/foundation/oi_chart_hit_tester.dart';
// ── Foundation: Accessibility ────────────────────────────────────────────────

export 'src/foundation/oi_chart_accessibility_bridge.dart';
export 'src/foundation/oi_chart_accessibility_config.dart';
// ── Foundation: Animation & Performance ──────────────────────────────────────

export 'src/foundation/oi_chart_animation_config.dart';
export 'src/foundation/oi_chart_formatters.dart';
export 'src/foundation/oi_chart_performance_config.dart';
// ── Foundation: Persistence ──────────────────────────────────────────────────

export 'src/foundation/oi_chart_settings_driver_binding.dart';
// ── Foundation: Scales ───────────────────────────────────────────────────────

export 'src/foundation/oi_band_scale.dart';
export 'src/foundation/oi_category_scale.dart';
export 'src/foundation/oi_chart_scale.dart';
export 'src/foundation/oi_linear_scale.dart';
export 'src/foundation/oi_logarithmic_scale.dart';
export 'src/foundation/oi_point_scale.dart';
export 'src/foundation/oi_quantile_scale.dart';
export 'src/foundation/oi_threshold_scale.dart';
export 'src/foundation/oi_time_scale.dart';
// ── Foundation: Sync ─────────────────────────────────────────────────────────

export 'src/foundation/oi_chart_sync_coordinator.dart';
export 'src/foundation/oi_chart_sync_group.dart';
// ── Foundation: Theme (re-exported from obers_ui) ────────────────────────────

export 'package:obers_ui/src/foundation/theme/component_themes/oi_chart_palette.dart';
export 'package:obers_ui/src/foundation/theme/component_themes/oi_chart_theme_data.dart';
// ── Models ───────────────────────────────────────────────────────────────────

export 'src/models/oi_chart_settings.dart';
