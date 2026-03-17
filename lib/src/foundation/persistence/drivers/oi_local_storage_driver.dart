import 'dart:convert';

import 'package:obers_ui/src/foundation/persistence/drivers/_platform_storage_stub.dart'
    if (dart.library.js_interop) 'package:obers_ui/src/foundation/persistence/drivers/_platform_storage_web.dart'
    if (dart.library.io) 'package:obers_ui/src/foundation/persistence/drivers/_platform_storage_io.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_data.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_driver.dart';

/// A settings driver that persists to platform-native local storage.
///
/// On Android/iOS/desktop, uses [SharedPreferences].
/// On web, uses `window.localStorage`.
///
/// ```dart
/// final driver = OiLocalStorageDriver();
/// ```
///
/// {@category Foundation}
class OiLocalStorageDriver extends OiSettingsDriver {
  /// Creates an [OiLocalStorageDriver].
  ///
  /// [prefix] is prepended to every storage key using the format
  /// `"$prefix.$namespace"` or `"$prefix.$namespace::$key"`.
  /// Defaults to `'obers_ui'`.
  const OiLocalStorageDriver({this.prefix = 'obers_ui'});

  /// The prefix prepended to every storage key.
  final String prefix;

  @override
  String resolveKey(String namespace, String? key) {
    if (key == null) return '$prefix.$namespace';
    return '$prefix.$namespace::$key';
  }

  @override
  Future<T?> load<T extends OiSettingsData>({
    required String namespace,
    required T Function(Map<String, dynamic> json) deserialize,
    String? key,
  }) async {
    final storageKey = resolveKey(namespace, key);
    try {
      final raw = await platformRead(storageKey);
      if (raw == null) return null;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return deserialize(json);
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
    final json = serialize(data);
    await platformWrite(storageKey, jsonEncode(json));
  }

  @override
  Future<void> delete({required String namespace, String? key}) async {
    final storageKey = resolveKey(namespace, key);
    await platformDelete(storageKey);
  }

  @override
  Future<bool> exists({required String namespace, String? key}) async {
    final storageKey = resolveKey(namespace, key);
    return platformExists(storageKey);
  }
}
