import 'package:flutter/foundation.dart';
import 'package:obers_ui/obers_ui.dart' show OiTabs;
import 'package:obers_ui/src/components/navigation/oi_tabs.dart' show OiTabs;
import 'package:obers_ui/src/foundation/persistence/oi_settings_data.dart';

/// Settings for [OiTabs] that can be persisted.
///
/// All fields have sensible defaults so that [OiTabsSettings] is usable
/// without any explicit configuration.
///
/// {@category Models}
@immutable
class OiTabsSettings with OiSettingsData {
  /// Creates an [OiTabsSettings] with optional field overrides.
  const OiTabsSettings({
    this.schemaVersion = 1,
    this.selectedIndex = 0,
    this.tabOrder = const [],
  });

  /// Deserializes an [OiTabsSettings] from a JSON map.
  factory OiTabsSettings.fromJson(Map<String, dynamic> json) {
    return OiTabsSettings(
      schemaVersion: (json['schemaVersion'] as int?) ?? 1,
      selectedIndex: (json['selectedIndex'] as int?) ?? 0,
      tabOrder: _parseIntList(json['tabOrder']),
    );
  }

  /// Schema version for migration.
  @override
  final int schemaVersion;

  /// Index of the currently selected tab.
  final int selectedIndex;

  /// Order of tab indices when tabs are reorderable.
  final List<int> tabOrder;

  /// Serializes this settings object to a JSON-encodable map.
  @override
  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'selectedIndex': selectedIndex,
    'tabOrder': tabOrder,
  };

  /// Returns new settings, filling in fields from [defaults] where this
  /// instance has empty or default values.
  OiTabsSettings mergeWith(OiTabsSettings defaults) {
    return OiTabsSettings(
      schemaVersion: schemaVersion,
      selectedIndex: selectedIndex,
      tabOrder: tabOrder.isEmpty ? defaults.tabOrder : tabOrder,
    );
  }

  /// Returns a copy of this object with the specified fields replaced.
  OiTabsSettings copyWith({
    int? schemaVersion,
    int? selectedIndex,
    List<int>? tabOrder,
  }) {
    return OiTabsSettings(
      schemaVersion: schemaVersion ?? this.schemaVersion,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      tabOrder: tabOrder ?? this.tabOrder,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiTabsSettings) return false;
    return schemaVersion == other.schemaVersion &&
        selectedIndex == other.selectedIndex &&
        _listEquals(tabOrder, other.tabOrder);
  }

  @override
  int get hashCode =>
      Object.hash(schemaVersion, selectedIndex, Object.hashAll(tabOrder));

  // ── Private helpers ────────────────────────────────────────────────────────

  static List<int> _parseIntList(dynamic value) {
    if (value == null) return const [];
    if (value is List) {
      return List<int>.from(value.whereType<int>());
    }
    return const [];
  }

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
