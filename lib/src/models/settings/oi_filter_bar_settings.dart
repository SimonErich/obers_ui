import 'package:flutter/foundation.dart';
import 'package:obers_ui/obers_ui.dart' show OiFilterBar;
import 'package:obers_ui/src/composites/navigation/oi_filter_bar.dart'
    show OiFilterBar;
import 'package:obers_ui/src/foundation/persistence/oi_settings_data.dart';

/// Settings for [OiFilterBar] that can be persisted.
///
/// All fields have sensible defaults so that [OiFilterBarSettings] is usable
/// without any explicit configuration.
///
/// {@category Models}
@immutable
class OiFilterBarSettings with OiSettingsData {
  /// Creates an [OiFilterBarSettings] with optional field overrides.
  const OiFilterBarSettings({
    this.schemaVersion = 1,
    this.activeFilters = const {},
    this.filterOrder = const [],
  });

  /// Deserializes an [OiFilterBarSettings] from a JSON map.
  factory OiFilterBarSettings.fromJson(Map<String, dynamic> json) {
    return OiFilterBarSettings(
      schemaVersion: (json['schemaVersion'] as int?) ?? 1,
      activeFilters: _parseDynamicMap(json['activeFilters']),
      filterOrder: _parseStringList(json['filterOrder']),
    );
  }

  /// Schema version for migration.
  @override
  final int schemaVersion;

  /// Active filter values keyed by filter definition key.
  final Map<String, dynamic> activeFilters;

  /// Ordered list of filter keys defining display order.
  final List<String> filterOrder;

  /// Serializes this settings object to a JSON-encodable map.
  @override
  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'activeFilters': activeFilters,
    'filterOrder': filterOrder,
  };

  /// Returns new settings, filling in fields from [defaults] where this
  /// instance has empty or default values.
  OiFilterBarSettings mergeWith(OiFilterBarSettings defaults) {
    return OiFilterBarSettings(
      schemaVersion: schemaVersion,
      activeFilters: activeFilters.isEmpty
          ? defaults.activeFilters
          : activeFilters,
      filterOrder: filterOrder.isEmpty ? defaults.filterOrder : filterOrder,
    );
  }

  /// Returns a copy of this object with the specified fields replaced.
  OiFilterBarSettings copyWith({
    int? schemaVersion,
    Map<String, dynamic>? activeFilters,
    List<String>? filterOrder,
  }) {
    return OiFilterBarSettings(
      schemaVersion: schemaVersion ?? this.schemaVersion,
      activeFilters: activeFilters ?? this.activeFilters,
      filterOrder: filterOrder ?? this.filterOrder,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiFilterBarSettings) return false;
    return schemaVersion == other.schemaVersion &&
        _mapEquals(activeFilters, other.activeFilters) &&
        _listEquals(filterOrder, other.filterOrder);
  }

  @override
  int get hashCode => Object.hash(
    schemaVersion,
    Object.hashAll(
      activeFilters.entries.map((e) => Object.hash(e.key, e.value)),
    ),
    Object.hashAll(filterOrder),
  );

  // ── Private helpers ────────────────────────────────────────────────────────

  static Map<String, dynamic> _parseDynamicMap(dynamic value) {
    if (value == null) return const {};
    if (value is Map) {
      return Map<String, dynamic>.fromEntries(
        value.entries
            .where((e) => e.key is String)
            .map((e) => MapEntry(e.key as String, e.value)),
      );
    }
    return const {};
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return const [];
    if (value is List) {
      return List<String>.from(value.whereType<String>());
    }
    return const [];
  }

  static bool _mapEquals<K, V>(Map<K, V> a, Map<K, V> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || b[key] != a[key]) return false;
    }
    return true;
  }

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
