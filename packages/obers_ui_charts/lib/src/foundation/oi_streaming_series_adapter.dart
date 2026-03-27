import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart' show OiChartBehavior;
import 'package:obers_ui_charts/src/foundation/oi_chart_behavior.dart' show OiChartBehavior;

import 'package:obers_ui_charts/src/foundation/oi_ring_buffer.dart';
import 'package:obers_ui_charts/src/foundation/oi_streaming_data_source.dart';

/// How the adapter handles incoming data batches.
///
/// {@category Foundation}
enum OiStreamingAppendMode {
  /// Append new data to the existing buffer.
  append,

  /// Replace the entire buffer contents with each emission.
  replace,
}

/// Adapter that connects an [OiStreamingDataSource] to a chart, managing
/// the subscription lifecycle, ring buffer storage, throttled notifications,
/// and error state.
///
/// Attach/detach mirrors the behavior lifecycle pattern used by
/// [OiChartBehavior].
///
/// {@category Foundation}
class OiStreamingSeriesAdapter<T> extends ChangeNotifier {
  /// Creates an adapter for the given [source].
  OiStreamingSeriesAdapter(
    this.source, {
    this.appendMode = OiStreamingAppendMode.append,
    this.windowDuration,
  });

  /// The streaming data source this adapter reads from.
  final OiStreamingDataSource<T> source;

  /// How incoming data batches are handled.
  final OiStreamingAppendMode appendMode;

  /// When set, data older than this duration is evicted on each emission.
  ///
  /// Requires the data source to provide a time-based ordering.
  final Duration? windowDuration;

  OiRingBuffer<T>? _buffer;
  StreamSubscription<List<T>>? _subscription;
  Timer? _throttleTimer;
  bool _pendingNotify = false;

  Object? _error;

  /// The current buffered data points in insertion order.
  List<T> get currentData => _buffer?.items ?? [];

  /// Whether an error has occurred on the stream.
  bool get hasError => _error != null;

  /// The most recent stream error, or null if no error.
  Object? get error => _error;

  /// Whether this adapter is currently subscribed to the data stream.
  bool get isAttached => _subscription != null;

  /// Begins listening to the data source.
  ///
  /// If already attached, detaches first to prevent duplicate subscriptions.
  void attach() {
    detach();
    _buffer = OiRingBuffer<T>(source.maxRetainedPoints);
    _subscription = source.dataStream.listen(_onData, onError: _onError);
  }

  /// Stops listening to the data source and cancels any pending throttle.
  void detach() {
    _subscription?.cancel();
    _subscription = null;
    _throttleTimer?.cancel();
    _throttleTimer = null;
    _pendingNotify = false;
  }

  void _onData(List<T> data) {
    _error = null;
    if (appendMode == OiStreamingAppendMode.replace) {
      _buffer?.clear();
    }
    _buffer?.addAll(data);
    _scheduleNotify();
  }

  void _onError(Object error, StackTrace stackTrace) {
    _error = error;
    _scheduleNotify();
  }

  void _scheduleNotify() {
    if (source.updateInterval == Duration.zero) {
      notifyListeners();
      return;
    }

    _pendingNotify = true;
    if (_throttleTimer?.isActive ?? false) return;

    _throttleTimer = Timer(source.updateInterval, () {
      if (_pendingNotify) {
        _pendingNotify = false;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    detach();
    super.dispose();
  }
}
