import 'package:flutter/widgets.dart';

import 'package:obers_ui_charts/src/foundation/oi_streaming_data_source.dart';

/// Abstract base class for all chart series types.
///
/// Series use mapper functions to extract chart values from domain models,
/// allowing any data shape to be visualized without transformation.
///
/// {@category Models}
abstract class OiChartSeries<T> {
  /// Creates a series with static [data] or a [streamingSource].
  ///
  /// Exactly one of [data] or [streamingSource] must be provided.
  /// Throws [ArgumentError] if both or neither are specified.
  OiChartSeries({
    required this.id,
    required this.label,
    this.data,
    this.streamingSource,
    this.visible = true,
    this.color,
    this.semanticLabel,
  }) {
    if (data != null && streamingSource != null) {
      throw ArgumentError(
        'OiChartSeries "$id": provide either data or streamingSource, not both',
      );
    }
    if (data == null && streamingSource == null) {
      throw ArgumentError(
        'OiChartSeries "$id": one of data or streamingSource is required',
      );
    }
  }

  /// Unique identifier for this series.
  final String id;

  /// Human-readable label for legends and accessibility.
  final String label;

  /// Static data points. Mutually exclusive with [streamingSource].
  final List<T>? data;

  /// Streaming data source. Mutually exclusive with [data].
  final OiStreamingDataSource<T>? streamingSource;

  /// Whether this series is currently visible.
  final bool visible;

  /// Optional series color override.
  final Color? color;

  /// Accessibility label for screen readers.
  final String? semanticLabel;
}
