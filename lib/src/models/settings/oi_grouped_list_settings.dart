import 'package:flutter/foundation.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_data.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_driver.dart';

/// Persisted state for `OiGroupedList`.
///
/// Stores the set of group keys that are currently collapsed so the collapsed
/// state can be restored across sessions when a [OiSettingsDriver] is provided.
///
/// {@category Models}
@immutable
class OiGroupedListSettings with OiSettingsData {
  /// Creates an [OiGroupedListSettings].
  const OiGroupedListSettings({
    this.schemaVersion = 1,
    this.collapsedGroups = const {},
  });

  /// Deserializes an [OiGroupedListSettings] from a JSON map.
  factory OiGroupedListSettings.fromJson(Map<String, dynamic> json) {
    return OiGroupedListSettings(
      schemaVersion: (json['schemaVersion'] as int?) ?? 1,
      collapsedGroups: _parseStringSet(json['collapsedGroups']),
    );
  }

  @override
  final int schemaVersion;

  /// Set of group keys that are currently collapsed.
  final Set<String> collapsedGroups;

  @override
  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'collapsedGroups': collapsedGroups.toList(),
  };

  /// Merges saved settings with current defaults.
  OiGroupedListSettings mergeWith(OiGroupedListSettings defaults) {
    return OiGroupedListSettings(
      schemaVersion: schemaVersion,
      collapsedGroups: collapsedGroups,
    );
  }

  /// Returns a copy with the specified fields replaced.
  OiGroupedListSettings copyWith({
    int? schemaVersion,
    Set<String>? collapsedGroups,
  }) {
    return OiGroupedListSettings(
      schemaVersion: schemaVersion ?? this.schemaVersion,
      collapsedGroups: collapsedGroups ?? this.collapsedGroups,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiGroupedListSettings) return false;
    return schemaVersion == other.schemaVersion &&
        _setEquals(collapsedGroups, other.collapsedGroups);
  }

  @override
  int get hashCode =>
      Object.hash(schemaVersion, Object.hashAll(collapsedGroups));

  static Set<String> _parseStringSet(dynamic value) {
    if (value == null) return const {};
    if (value is List) return Set<String>.from(value.whereType<String>());
    return const {};
  }

  static bool _setEquals<T>(Set<T> a, Set<T> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }
}
