/// Abstract contract for a streaming data source that provides real-time
/// data points to chart visualizations.
///
/// Implementations connect to WebSocket feeds, sensor data, polling APIs,
/// or any other continuous data source.
///
/// {@category Foundation}
abstract class OiStreamingDataSource<T> {
  /// A stream of incoming data points.
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
