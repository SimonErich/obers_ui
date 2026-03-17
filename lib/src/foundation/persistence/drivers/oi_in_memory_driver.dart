import 'dart:async';

import 'package:obers_ui/src/foundation/persistence/oi_settings_data.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_driver.dart';

/// An in-memory settings driver for testing and session-only persistence.
///
/// Settings are stored in a [Map] and lost when the driver instance is
/// garbage-collected. Use in tests to verify persistence behavior without
/// touching the file system or network.
///
/// ```dart
/// final driver = OiInMemorySettingsDriver();
/// // Inspect [store] directly in test assertions.
/// expect(driver.store['oi_table::my-table'], isNotNull);
/// ```
///
/// {@category Foundation}
class OiInMemorySettingsDriver extends OiSettingsDriver {
  /// Creates an [OiInMemorySettingsDriver] with an empty store.
  OiInMemorySettingsDriver();

  /// The raw internal store. Key is [resolveKey] output, value is the JSON map.
  ///
  /// Exposed for test assertions. Do not mutate directly in production code.
  final Map<String, Map<String, dynamic>> store = {};

  @override
  Future<T?> load<T extends OiSettingsData>({
    required String namespace,
    required T Function(Map<String, dynamic> json) deserialize,
    String? key,
  }) async {
    final storageKey = resolveKey(namespace, key);
    final data = store[storageKey];
    if (data == null) return null;
    try {
      return deserialize(Map<String, dynamic>.from(data));
    } on Exception {
      return null;
    }
  }

  @override
  Future<void> save<T extends OiSettingsData>({
    required String namespace,
    required T data,
    required Map<String, dynamic> Function(T data) serialize,
    String? key,
  }) async {
    final storageKey = resolveKey(namespace, key);
    store[storageKey] = serialize(data);
  }

  @override
  Future<void> delete({required String namespace, String? key}) async {
    final storageKey = resolveKey(namespace, key);
    store.remove(storageKey);
  }

  @override
  Future<bool> exists({required String namespace, String? key}) async {
    final storageKey = resolveKey(namespace, key);
    return store.containsKey(storageKey);
  }

  /// Clears all stored settings.
  ///
  /// Call in [tearDown] to reset state between tests.
  void clear() => store.clear();
}
