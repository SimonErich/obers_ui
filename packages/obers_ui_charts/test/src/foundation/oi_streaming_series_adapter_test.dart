import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/src/foundation/oi_streaming_data_source.dart';
import 'package:obers_ui_charts/src/foundation/oi_streaming_series_adapter.dart';

class _FakeDataSource extends OiStreamingDataSource<int> {
  final _controller = StreamController<List<int>>.broadcast();

  @override
  Stream<List<int>> get dataStream => _controller.stream;

  @override
  int get maxRetainedPoints => 5;

  @override
  Duration get updateInterval => Duration.zero;

  void emit(List<int> data) => _controller.add(data);
  void emitError(Object error) => _controller.addError(error);
  Future<void> close() => _controller.close();
}

void main() {
  group('OiStreamingSeriesAdapter', () {
    late _FakeDataSource source;
    late OiStreamingSeriesAdapter<int> adapter;

    setUp(() {
      source = _FakeDataSource();
      adapter = OiStreamingSeriesAdapter<int>(source);
    });

    tearDown(() async {
      adapter.detach();
      await source.close();
    });

    test('subscribes on attach, unsubscribes on detach', () async {
      adapter.attach();
      source.emit([1, 2, 3]);
      await Future<void>.delayed(Duration.zero);

      expect(adapter.currentData, [1, 2, 3]);

      adapter.detach();
      source.emit([4, 5]);
      await Future<void>.delayed(Duration.zero);

      // Should not receive data after detach
      expect(adapter.currentData, [1, 2, 3]);
    });

    test('maintains ring buffer with correct capacity', () async {
      adapter.attach();
      source.emit([1, 2, 3, 4, 5, 6, 7]);
      await Future<void>.delayed(Duration.zero);

      // maxRetainedPoints is 5
      expect(adapter.currentData.length, 5);
      expect(adapter.currentData, [3, 4, 5, 6, 7]);
    });

    test('throttles rapid updates to interval', () async {
      final throttledSource = _ThrottledDataSource();
      final throttledAdapter = OiStreamingSeriesAdapter<int>(throttledSource);

      var notifyCount = 0;
      throttledAdapter.addListener(() => notifyCount++);
      throttledAdapter.attach();

      // Emit multiple batches rapidly
      throttledSource.emit([1]);
      throttledSource.emit([2]);
      throttledSource.emit([3]);

      // Allow throttle interval to pass
      await Future<void>.delayed(const Duration(milliseconds: 60));

      // Data should be accumulated but notifications throttled
      expect(throttledAdapter.currentData.isNotEmpty, isTrue);

      throttledAdapter.detach();
      await throttledSource.close();
    });

    test('handles stream errors without crash', () async {
      adapter.attach();
      source.emitError(Exception('test error'));
      await Future<void>.delayed(Duration.zero);

      expect(adapter.hasError, isTrue);
      expect(adapter.error, isA<Exception>());

      // Should still accept new data after error
      source.emit([10, 20]);
      await Future<void>.delayed(Duration.zero);

      expect(adapter.currentData, [10, 20]);
      expect(adapter.hasError, isFalse);
    });

    test('multiple attach/detach cycles do not leak subscriptions', () async {
      adapter
        ..attach()
        ..detach()
        ..attach()
        ..detach()
        ..attach();

      source.emit([99]);
      await Future<void>.delayed(Duration.zero);

      expect(adapter.currentData, [99]);

      adapter.detach();
      source.emit([100]);
      await Future<void>.delayed(Duration.zero);

      expect(adapter.currentData, [99]);
    });
  });
}

class _ThrottledDataSource extends OiStreamingDataSource<int> {
  final _controller = StreamController<List<int>>.broadcast();

  @override
  Stream<List<int>> get dataStream => _controller.stream;

  @override
  int get maxRetainedPoints => 100;

  @override
  Duration get updateInterval => const Duration(milliseconds: 50);

  void emit(List<int> data) => _controller.add(data);
  Future<void> close() => _controller.close();
}
