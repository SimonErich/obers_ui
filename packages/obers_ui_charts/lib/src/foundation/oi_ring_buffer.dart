/// A fixed-capacity circular buffer that evicts the oldest items when full.
///
/// Used by streaming chart data sources to retain a sliding window of the
/// most recent data points without unbounded memory growth.
///
/// {@category Foundation}
class OiRingBuffer<T> extends Iterable<T> {
  /// Creates a ring buffer with the given [capacity].
  ///
  /// Throws [ArgumentError] if [capacity] is negative.
  OiRingBuffer(this.capacity) {
    if (capacity < 0) {
      throw ArgumentError.value(capacity, 'capacity', 'must be non-negative');
    }
    _buffer = List<T?>.filled(capacity, null);
  }

  /// The maximum number of items this buffer can hold.
  final int capacity;

  late final List<T?> _buffer;
  int _head = 0;
  int _length = 0;

  /// The number of items currently in the buffer.
  @override
  int get length => _length;

  /// Whether the buffer contains no items.
  @override
  bool get isEmpty => _length == 0;

  /// Whether the buffer is at capacity.
  bool get isFull => _length == capacity;

  /// Adds [item] to the buffer. If the buffer is full, the oldest item is
  /// evicted.
  void add(T item) {
    if (capacity == 0) return;
    final writeIndex = (_head + _length) % capacity;
    if (_length == capacity) {
      // Overwrite oldest, advance head
      _buffer[_head] = item;
      _head = (_head + 1) % capacity;
    } else {
      _buffer[writeIndex] = item;
      _length++;
    }
  }

  /// Adds all [items] to the buffer. If the total exceeds capacity, only
  /// the last [capacity] items are retained.
  void addAll(Iterable<T> items) {
    final list = items.toList();
    if (capacity == 0) return;

    // Optimization: if batch is larger than capacity, only add the tail.
    if (list.length >= capacity) {
      _head = 0;
      _length = capacity;
      for (var i = 0; i < capacity; i++) {
        _buffer[i] = list[list.length - capacity + i];
      }
      return;
    }

    for (final item in list) {
      add(item);
    }
  }

  /// Removes all items from the buffer.
  void clear() {
    for (var i = 0; i < _length; i++) {
      _buffer[(_head + i) % capacity] = null;
    }
    _head = 0;
    _length = 0;
  }

  /// Returns all items in insertion order (oldest first).
  List<T> get items {
    final result = <T>[];
    for (var i = 0; i < _length; i++) {
      result.add(_buffer[(_head + i) % capacity] as T);
    }
    return result;
  }

  @override
  Iterator<T> get iterator => _RingBufferIterator(this);
}

class _RingBufferIterator<T> implements Iterator<T> {
  _RingBufferIterator(this._buffer);

  final OiRingBuffer<T> _buffer;
  int _index = -1;

  @override
  T get current =>
      _buffer._buffer[(_buffer._head + _index) % _buffer.capacity]!;

  @override
  bool moveNext() {
    _index++;
    return _index < _buffer._length;
  }
}
