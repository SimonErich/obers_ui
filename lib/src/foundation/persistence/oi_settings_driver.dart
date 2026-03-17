import 'package:flutter/foundation.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_data.dart';

/// The core interface that all settings persistence drivers implement.
///
/// A driver stores and retrieves serialized settings data. The interface
/// is intentionally minimal — 4 methods cover all use cases.
///
/// Drivers are stateless; they do not cache. Caching is the responsibility
/// of the widget using [OiSettingsMixin].
///
/// {@category Foundation}
abstract class OiSettingsDriver {
  /// Creates an [OiSettingsDriver].
  const OiSettingsDriver();

  /// Loads settings for the given [namespace] and optional [key].
  ///
  /// Returns `null` if no settings have been saved yet, or if the stored
  /// data is corrupted or incompatible. Never throws.
  ///
  /// The [deserialize] function converts the raw `Map<String, dynamic>`
  /// back into the typed settings object.
  Future<T?> load<T extends OiSettingsData>({
    required String namespace,
    required T Function(Map<String, dynamic> json) deserialize,
    String? key,
  });

  /// Saves settings for the given [namespace] and optional [key].
  ///
  /// The [serialize] function converts the typed settings object into a
  /// JSON-encodable map.
  Future<void> save<T extends OiSettingsData>({
    required String namespace,
    required T data,
    required Map<String, dynamic> Function(T data) serialize,
    String? key,
  });

  /// Deletes settings for the given [namespace] and optional [key].
  ///
  /// After deletion, [load] returns `null` and [exists] returns `false`.
  Future<void> delete({
    required String namespace,
    String? key,
  });

  /// Returns `true` if settings exist for the given [namespace] and [key].
  Future<bool> exists({
    required String namespace,
    String? key,
  });

  /// Computes the storage key from [namespace] and optional [key].
  ///
  /// Default format:
  /// - Without key: `"$namespace"`
  /// - With key: `"$namespace::$key"`
  ///
  /// Drivers may override this (e.g. for path-based REST APIs).
  @protected
  String resolveKey(String namespace, String? key) {
    if (key == null) return namespace;
    return '$namespace::$key';
  }
}
