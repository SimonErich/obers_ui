import 'package:flutter/widgets.dart';

import 'package:obers_ui_charts/src/foundation/oi_streaming_data_source.dart';
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
  /// Call from [initState]. Replaces every existing adapter; to pick up
  /// changed sources on an update use [syncStreamingAdapters] instead.
  void attachStreamingAdapters() {
    detachStreamingAdapters();
    syncStreamingAdapters();
  }

  /// Brings the adapters in line with the current [streamingSeries].
  ///
  /// Call from [didUpdateWidget]. Compares per series id: an adapter whose
  /// source is unchanged keeps its subscription and buffered data, a changed
  /// source gets a fresh adapter, and adapters of series that lost their
  /// source or are gone are disposed.
  ///
  /// A source counts as unchanged when it is `==` to the previous one, or
  /// has the same settings and a `dataStream` that is `==`, so a source
  /// object built inline in `build` does not resubscribe on every parent
  /// rebuild. A single subscription stream cannot be listened to twice.
  void syncStreamingAdapters() {
    final wanted = {
      for (final series in streamingSeries)
        if (series.streamingSource != null) series.id: series.streamingSource!,
    };

    final stale = [
      for (final entry in _adapters.entries)
        if (!_sameSource(wanted[entry.key], entry.value.source)) entry.key,
    ];
    for (final id in stale) {
      _adapters.remove(id)!
        ..removeListener(_onStreamingUpdate)
        ..dispose();
    }

    for (final entry in wanted.entries) {
      if (_adapters.containsKey(entry.key)) continue;
      _adapters[entry.key] = OiStreamingSeriesAdapter<dynamic>(entry.value)
        ..addListener(_onStreamingUpdate)
        ..attach();
    }
  }

  static bool _sameSource(
    OiStreamingDataSource<dynamic>? wanted,
    OiStreamingDataSource<dynamic> current,
  ) {
    if (wanted == null) return false;
    if (wanted == current) return true;
    // The adapter sizes its buffer and throttle from the source once, so a
    // source with other settings needs a fresh adapter.
    return wanted.maxRetainedPoints == current.maxRetainedPoints &&
        wanted.updateInterval == current.updateInterval &&
        wanted.dataStream == current.dataStream;
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
      // setState is protected in State but safe to call here because this
      // mixin is constrained to State<T> and is only invoked while mounted.
      setState(() {});
    }
  }
}
