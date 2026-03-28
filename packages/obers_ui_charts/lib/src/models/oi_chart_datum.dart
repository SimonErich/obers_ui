import 'package:flutter/widgets.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart' show OiCartesianSeries;
import 'package:obers_ui_charts/src/models/oi_cartesian_series.dart' show OiCartesianSeries;

/// A normalized internal data point used by the chart rendering pipeline.
///
/// Chart series mappers produce raw values from domain models; the chart
/// engine then normalizes these into [OiChartDatum] instances that carry
/// both the raw and scaled (pixel-space) values needed for rendering.
///
/// {@category Models}
@immutable
class OiChartDatum {
  /// Creates a normalized chart datum.
  const OiChartDatum({
    required this.seriesId,
    required this.index,
    required this.rawItem,
    this.xRaw,
    this.yRaw,
    this.xScaled,
    this.yScaled,
    this.colorRaw,
    this.label,
    this.isMissing = false,
    this.extra = const {},
  });

  /// The ID of the series this datum belongs to.
  final String seriesId;

  /// The index of this datum within its series.
  final int index;

  /// The original domain model object.
  final Object? rawItem;

  /// The raw x value before scale transformation.
  final Object? xRaw;

  /// The raw y value before scale transformation.
  final Object? yRaw;

  /// The x value after scale transformation (pixel coordinate).
  final double? xScaled;

  /// The y value after scale transformation (pixel coordinate).
  final double? yScaled;

  /// The raw color value for this datum (e.g., for heatmaps).
  final Color? colorRaw;

  /// An optional display label for this datum.
  final String? label;

  /// Whether this datum represents a missing/null data point.
  final bool isMissing;

  /// Additional metadata for custom rendering or behaviors.
  final Map<String, Object?> extra;

  /// Creates a copy with optional field overrides.
  OiChartDatum copyWith({
    String? seriesId,
    int? index,
    Object? rawItem,
    Object? xRaw,
    Object? yRaw,
    double? xScaled,
    double? yScaled,
    Color? colorRaw,
    String? label,
    bool? isMissing,
    Map<String, Object?>? extra,
  }) {
    return OiChartDatum(
      seriesId: seriesId ?? this.seriesId,
      index: index ?? this.index,
      rawItem: rawItem ?? this.rawItem,
      xRaw: xRaw ?? this.xRaw,
      yRaw: yRaw ?? this.yRaw,
      xScaled: xScaled ?? this.xScaled,
      yScaled: yScaled ?? this.yScaled,
      colorRaw: colorRaw ?? this.colorRaw,
      label: label ?? this.label,
      isMissing: isMissing ?? this.isMissing,
      extra: extra ?? this.extra,
    );
  }
}

/// Extension for normalizing a [OiCartesianSeries] into [OiChartDatum] list.
///
/// This is used internally by the chart engine to convert mapper-based
/// series data into the normalized format needed for rendering.
List<OiChartDatum> normalizeSeries<T>({
  required String seriesId,
  required List<T> data,
  required dynamic Function(T item) xMapper,
  required num Function(T item) yMapper,
  String Function(T item)? pointLabel,
  bool Function(T item)? isMissing,
}) {
  return [
    for (var i = 0; i < data.length; i++)
      OiChartDatum(
        seriesId: seriesId,
        index: i,
        rawItem: data[i],
        xRaw: xMapper(data[i]),
        yRaw: yMapper(data[i]),
        label: pointLabel?.call(data[i]),
        isMissing: isMissing?.call(data[i]) ?? false,
      ),
  ];
}
