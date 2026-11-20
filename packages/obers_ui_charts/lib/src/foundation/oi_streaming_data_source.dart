/// Abstract contract for a streaming data source that provides real-time
/// data points to chart visualizations.
///
/// Implementations connect to WebSocket feeds, sensor data, polling APIs,
/// or any other continuous data source.
///
/// When a chart rebuilds, it keeps its subscription if the new source is
/// `==` to the old one, or has the same settings and a [dataStream] that is
/// `==`. Otherwise it subscribes again, which fails for a single
/// subscription stream. So either keep one source instance (for example in
/// a `State`), or return the same stream from [dataStream] every time.
///
/// {@category Foundation}
abstract class OiStreamingDataSource<T> {
  /// A stream of incoming data points.
  ///
  /// Read whenever the chart compares sources, so it must be cheap and free
  /// of side effects: open connections outside the getter and return the
  /// same stream each time, not a new `map` or `where` of it.
  Stream<List<T>> get dataStream;

  /// Maximum number of data points to retain in memory.
  ///
  /// Older points beyond this limit are evicted using a ring buffer.
  int get maxRetainedPoints;

  /// Minimum interval between UI updates in milliseconds.
  ///
  /// Rapid incoming data is throttled to this interval to avoid excessive
  /// rebuilds. Defaults to 16ms (~60fps).
  Duration get updateInterval => const Duration(milliseconds: 16);
}
