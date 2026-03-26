import 'package:flutter/widgets.dart';

import 'package:obers_ui_charts/src/foundation/oi_streaming_series_adapter.dart';
import 'package:obers_ui_charts/src/models/oi_chart_series.dart';

/// Shared mixin for chart [State] classes that manage streaming adapters.
///
/// Creates and manages [OiStreamingSeriesAdapter] instances for each
/// series that has a `streamingSource`. Listens for data changes and
/// triggers rebuilds.
mixin ChartStreamingHost<T extends StatefulWidget> on State<T> {
  /// Override to return the current list of series.
  List<OiChartSeries<dynamic>> get streamingSeries;

  final Map<String, OiStreamingSeriesAdapter<dynamic>> _adapters = {};

  /// Attaches streaming adapters for all series with streaming sources.
  ///
  /// Call from [initState] and [didUpdateWidget].
  void attachStreamingAdapters() {
    detachStreamingAdapters();
    for (final series in streamingSeries) {
      if (series.streamingSource != null) {
        final adapter = OiStreamingSeriesAdapter<dynamic>(
          series.streamingSource!,
        );
        adapter
          ..addListener(_onStreamingUpdate)
          ..attach();
        _adapters[series.id] = adapter;
      }
    }
  }

  /// Detaches and disposes all streaming adapters.
  ///
  /// Call from [dispose].
  void detachStreamingAdapters() {
    for (final adapter in _adapters.values) {
      adapter
        ..removeListener(_onStreamingUpdate)
        ..dispose();
    }
    _adapters.clear();
  }

  /// Returns the current data from the streaming adapter for [seriesId],
  /// or null if no adapter exists for that series.
  List<dynamic>? streamingDataFor(String seriesId) {
    return _adapters[seriesId]?.currentData;
  }

  void _onStreamingUpdate() {
    if (mounted) {
      // ignore: invalid_use_of_protected_member
      setState(() {});
    }
  }
}
