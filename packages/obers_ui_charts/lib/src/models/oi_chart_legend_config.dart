import 'package:flutter/widgets.dart';

import 'package:obers_ui/obers_ui.dart' show OiResponsive;
import 'package:obers_ui_charts/src/composites/oi_chart_legend.dart';

// ─────────────────────────────────────────────────────────────────────────────
// OiLegendWrapBehavior
// ─────────────────────────────────────────────────────────────────────────────

/// How the legend handles overflow when items exceed the available space.
///
/// {@category Models}
enum OiLegendWrapBehavior {
  /// Wrap items to the next row/column.
  wrap,

  /// Scroll items within a fixed area.
  scroll,

  /// Collapse items into a "Show more" button.
  collapse,
}

// ─────────────────────────────────────────────────────────────────────────────
// OiChartLegendConfig
// ─────────────────────────────────────────────────────────────────────────────

/// Configuration for the chart legend.
///
/// Controls the legend's visibility, position, layout behavior, and
/// interaction capabilities.
///
/// {@category Models}
@immutable
class OiChartLegendConfig {
  /// Creates an [OiChartLegendConfig].
  const OiChartLegendConfig({
    this.show = true,
    this.position,
    this.wrapBehavior = OiLegendWrapBehavior.wrap,
    this.allowSeriesToggle = true,
    this.allowExclusiveFocus = true,
    this.itemBuilder,
  });

  /// Whether the legend is visible.
  final bool show;

  /// Legend position, responsive to breakpoints.
  ///
  /// When null, defaults to bottom for narrow viewports and right for wide.
  final OiResponsive<OiChartLegendPosition>? position;

  /// How the legend handles overflow.
  final OiLegendWrapBehavior wrapBehavior;

  /// Whether tapping a legend item toggles series visibility.
  final bool allowSeriesToggle;

  /// Whether long-pressing a legend item focuses that series exclusively.
  final bool allowExclusiveFocus;

  /// Custom builder for individual legend items.
  ///
  /// When null, a default legend item widget is used.
  final Widget Function(BuildContext context, OiChartLegendItem item)?
  itemBuilder;

  /// Creates a copy with optionally overridden values.
  OiChartLegendConfig copyWith({
    bool? show,
    OiResponsive<OiChartLegendPosition>? position,
    OiLegendWrapBehavior? wrapBehavior,
    bool? allowSeriesToggle,
    bool? allowExclusiveFocus,
    Widget Function(BuildContext context, OiChartLegendItem item)? itemBuilder,
  }) {
    return OiChartLegendConfig(
      show: show ?? this.show,
      position: position ?? this.position,
      wrapBehavior: wrapBehavior ?? this.wrapBehavior,
      allowSeriesToggle: allowSeriesToggle ?? this.allowSeriesToggle,
      allowExclusiveFocus: allowExclusiveFocus ?? this.allowExclusiveFocus,
      itemBuilder: itemBuilder ?? this.itemBuilder,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiChartLegendConfig &&
        other.show == show &&
        other.position == position &&
        other.wrapBehavior == wrapBehavior &&
        other.allowSeriesToggle == allowSeriesToggle &&
        other.allowExclusiveFocus == allowExclusiveFocus;
  }

  @override
  int get hashCode => Object.hash(
    show,
    position,
    wrapBehavior,
    allowSeriesToggle,
    allowExclusiveFocus,
  );
}
