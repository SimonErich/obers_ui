import 'package:flutter/widgets.dart';

/// Per-series legend configuration.
///
/// Controls how an individual series appears in the chart legend.
///
/// {@category Models}
@immutable
class OiSeriesLegendConfig {
  /// Creates an [OiSeriesLegendConfig].
  const OiSeriesLegendConfig({
    this.show = true,
    this.label,
    this.iconBuilder,
    this.order,
  });

  /// Whether this series appears in the legend.
  final bool show;

  /// Custom label override for the legend entry.
  ///
  /// When null, the series' label is used.
  final String? label;

  /// Custom icon builder for the legend entry.
  ///
  /// Receives the series color and size. When null, a default marker is used.
  final Widget Function(Color color, double size)? iconBuilder;

  /// Sort order within the legend. Lower values appear first.
  ///
  /// When null, series appear in declaration order.
  final int? order;

  /// Creates a copy with optionally overridden values.
  OiSeriesLegendConfig copyWith({
    bool? show,
    String? label,
    Widget Function(Color color, double size)? iconBuilder,
    int? order,
  }) {
    return OiSeriesLegendConfig(
      show: show ?? this.show,
      label: label ?? this.label,
      iconBuilder: iconBuilder ?? this.iconBuilder,
      order: order ?? this.order,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiSeriesLegendConfig &&
        other.show == show &&
        other.label == label &&
        other.order == order;
  }

  @override
  int get hashCode => Object.hash(show, label, order);
}
