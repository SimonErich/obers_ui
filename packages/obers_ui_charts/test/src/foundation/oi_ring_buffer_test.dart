import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/src/foundation/oi_ring_buffer.dart';

void main() {
  group('OiRingBuffer', () {
    test('add within capacity retains all items', () {
      final buffer = OiRingBuffer<int>(5)
        ..add(1)
        ..add(2)
        ..add(3);

      expect(buffer.length, 3);
      expect(buffer.items, [1, 2, 3]);
    });

    test('add beyond capacity evicts oldest', () {
      final buffer = OiRingBuffer<int>(3)
        ..add(1)
        ..add(2)
        ..add(3)
        ..add(4)
        ..add(5);

      expect(buffer.length, 3);
      expect(buffer.items, [3, 4, 5]);
      expect(buffer.isFull, isTrue);
    });

    test('addAll with batch larger than capacity keeps last N', () {
      final buffer = OiRingBuffer<int>(3)..addAll([1, 2, 3, 4, 5, 6, 7]);

      expect(buffer.length, 3);
      expect(buffer.items, [5, 6, 7]);
    });

    test('items returned in insertion order', () {
      final buffer = OiRingBuffer<int>(4)
        ..add(10)
        ..add(20)
        ..add(30)
        ..add(40)
        ..add(50); // evicts 10

      expect(buffer.items, [20, 30, 40, 50]);

      // Iterate via iterable
      final collected = <int>[];
      for (final item in buffer) {
        collected.add(item);
      }
      expect(collected, [20, 30, 40, 50]);
    });

    test('clear resets to empty', () {
      final buffer = OiRingBuffer<int>(5)
        ..add(1)
        ..add(2)
        ..add(3)
        ..clear();

      expect(buffer.isEmpty, isTrue);
      expect(buffer.length, 0);
      expect(buffer.items, isEmpty);
    });

    test('capacity 0 edge case', () {
      final buffer = OiRingBuffer<int>(0)
        ..add(1)
        ..add(2);

      expect(buffer.length, 0);
      expect(buffer.isEmpty, isTrue);
      expect(buffer.items, isEmpty);
    });

    test('negative capacity throws ArgumentError', () {
      expect(() => OiRingBuffer<int>(-1), throwsArgumentError);
    });
  });
}
