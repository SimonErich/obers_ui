import 'package:flutter/foundation.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_data.dart';

/// Layout mode for list views.
///
/// {@category Models}
enum OiListViewLayout {
  /// A vertical list of rows.
  list,

  /// A grid of cards.
  grid,

  /// A tabular view with columns.
  table,
}

/// Settings for [OiListView] that can be persisted.
///
/// All fields have sensible defaults so that [OiListViewSettings] is usable
/// without any explicit configuration.
///
/// {@category Models}
@immutable
class OiListViewSettings with OiSettingsData {
  /// Creates an [OiListViewSettings] with optional field overrides.
  const OiListViewSettings({
    this.schemaVersion = 1,
    this.layout = OiListViewLayout.list,
    this.activeSortId,
    this.activeFilters = const {},
    this.pageSize,
  });

  /// Deserializes an [OiListViewSettings] from a JSON map.
  factory OiListViewSettings.fromJson(Map<String, dynamic> json) {
    return OiListViewSettings(
      schemaVersion: (json['schemaVersion'] as int?) ?? 1,
      layout: _parseEnum(
        json['layout'] as String?,
        OiListViewLayout.values,
        OiListViewLayout.list,
      ),
      activeSortId: json['activeSortId'] as String?,
      activeFilters: _parseDynamicMap(json['activeFilters']),
      pageSize: json['pageSize'] as int?,
    );
  }

  /// Schema version for migration.
  @override
  final int schemaVersion;

  /// Current layout mode.
  final OiListViewLayout layout;

  /// ID of the active sort configuration, or `null` if no sort is active.
  final String? activeSortId;

  /// Active filter state — map of filter ID to its current value.
  final Map<String, dynamic> activeFilters;

  /// Number of items per page, or `null` for no pagination.
  final int? pageSize;

  /// Serializes this settings object to a JSON-encodable map.
  @override
  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'layout': layout.name,
    'activeSortId': activeSortId,
    'activeFilters': activeFilters,
    'pageSize': pageSize,
  };

  /// Returns new settings, filling in fields from [defaults] where this
  /// instance has empty or default values.
  ///
  /// Explicit user settings are preserved; only uninitialised fields fall
  /// back to [defaults].
  OiListViewSettings mergeWith(OiListViewSettings defaults) {
    return OiListViewSettings(
      schemaVersion: schemaVersion,
      layout: layout,
      activeSortId: activeSortId ?? defaults.activeSortId,
      activeFilters: activeFilters.isEmpty
          ? defaults.activeFilters
          : activeFilters,
      pageSize: pageSize ?? defaults.pageSize,
    );
  }

  /// Returns a copy of this object with the specified fields replaced.
  OiListViewSettings copyWith({
    int? schemaVersion,
    OiListViewLayout? layout,
    Object? activeSortId = _sentinel,
    Map<String, dynamic>? activeFilters,
    Object? pageSize = _sentinel,
  }) {
    return OiListViewSettings(
      schemaVersion: schemaVersion ?? this.schemaVersion,
      layout: layout ?? this.layout,
      activeSortId: identical(activeSortId, _sentinel)
          ? this.activeSortId
          : activeSortId as String?,
      activeFilters: activeFilters ?? this.activeFilters,
      pageSize: identical(pageSize, _sentinel)
          ? this.pageSize
          : pageSize as int?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiListViewSettings) return false;
    return schemaVersion == other.schemaVersion &&
        layout == other.layout &&
        activeSortId == other.activeSortId &&
        _mapEquals(activeFilters, other.activeFilters) &&
        pageSize == other.pageSize;
  }

  @override
  int get hashCode => Object.hash(
    schemaVersion,
    layout,
    activeSortId,
    Object.hashAll(
      activeFilters.entries.map((e) => Object.hash(e.key, e.value)),
    ),
    pageSize,
  );

  // ── Private helpers ────────────────────────────────────────────────────────

  static T _parseEnum<T extends Enum>(
    String? value,
    List<T> values,
    T fallback,
  ) {
    if (value == null) return fallback;
    for (final v in values) {
      if (v.name == value) return v;
    }
    return fallback;
  }

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

  static bool _mapEquals<K, V>(Map<K, V> a, Map<K, V> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || b[key] != a[key]) return false;
    }
    return true;
  }
}

/// Sentinel used by [OiListViewSettings.copyWith] to distinguish an explicit
/// `null` argument from "not provided".
const Object _sentinel = Object();
