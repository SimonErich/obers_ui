import 'package:flutter/foundation.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_data.dart';

/// Settings for [OiKanban] that can be persisted.
///
/// All fields have sensible defaults so that [OiKanbanSettings] is usable
/// without any explicit configuration.
///
/// {@category Models}
@immutable
class OiKanbanSettings with OiSettingsData {
  /// Creates an [OiKanbanSettings] with optional field overrides.
  const OiKanbanSettings({
    this.schemaVersion = 1,
    this.columnOrder = const [],
    this.collapsedColumnKeys = const {},
  });

  /// Deserializes an [OiKanbanSettings] from a JSON map.
  factory OiKanbanSettings.fromJson(Map<String, dynamic> json) {
    return OiKanbanSettings(
      schemaVersion: (json['schemaVersion'] as int?) ?? 1,
      columnOrder: _parseStringList(json['columnOrder']),
      collapsedColumnKeys: _parseStringSet(json['collapsedColumnKeys']),
    );
  }

  /// Schema version for migration.
  @override
  final int schemaVersion;

  /// Ordered list of column identifiers defining display order.
  final List<Object> columnOrder;

  /// Set of column keys whose columns are currently collapsed.
  final Set<Object> collapsedColumnKeys;

  /// Serializes this settings object to a JSON-encodable map.
  @override
  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'columnOrder': columnOrder.map((e) => e.toString()).toList(),
    'collapsedColumnKeys': collapsedColumnKeys
        .map((e) => e.toString())
        .toList(),
  };

  /// Returns new settings, filling in fields from [defaults] where this
  /// instance has empty or default values.
  ///
  /// Explicit user settings are preserved; only uninitialised fields fall
  /// back to [defaults].
  OiKanbanSettings mergeWith(OiKanbanSettings defaults) {
    return OiKanbanSettings(
      schemaVersion: schemaVersion,
      columnOrder: columnOrder.isEmpty ? defaults.columnOrder : columnOrder,
      collapsedColumnKeys: collapsedColumnKeys.isEmpty
          ? defaults.collapsedColumnKeys
          : collapsedColumnKeys,
    );
  }

  /// Returns a copy of this object with the specified fields replaced.
  OiKanbanSettings copyWith({
    int? schemaVersion,
    List<Object>? columnOrder,
    Set<Object>? collapsedColumnKeys,
  }) {
    return OiKanbanSettings(
      schemaVersion: schemaVersion ?? this.schemaVersion,
      columnOrder: columnOrder ?? this.columnOrder,
      collapsedColumnKeys: collapsedColumnKeys ?? this.collapsedColumnKeys,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiKanbanSettings) return false;
    return schemaVersion == other.schemaVersion &&
        _listEquals(columnOrder, other.columnOrder) &&
        _setEquals(collapsedColumnKeys, other.collapsedColumnKeys);
  }

  @override
  int get hashCode => Object.hash(
    schemaVersion,
    Object.hashAll(columnOrder),
    Object.hashAll(collapsedColumnKeys),
  );

  // ── Private helpers ────────────────────────────────────────────────────────

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return const [];
    if (value is List) {
      return List<String>.from(value.whereType<String>());
    }
    return const [];
  }

  static Set<String> _parseStringSet(dynamic value) {
    if (value == null) return const {};
    if (value is List) {
      return Set<String>.from(value.whereType<String>());
    }
    return const {};
  }

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static bool _setEquals<T>(Set<T> a, Set<T> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }
}
