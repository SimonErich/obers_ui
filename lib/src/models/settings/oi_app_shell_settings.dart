import 'package:flutter/foundation.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_data.dart';

/// Settings for [OiAppShell] that can be persisted.
///
/// Stores the sidebar collapsed state so it is preserved across sessions.
///
/// {@category Models}
@immutable
class OiAppShellSettings with OiSettingsData {
  /// Creates an [OiAppShellSettings] with optional field overrides.
  const OiAppShellSettings({
    this.schemaVersion = 1,
    this.sidebarCollapsed = false,
  });

  /// Deserializes an [OiAppShellSettings] from a JSON map.
  factory OiAppShellSettings.fromJson(Map<String, dynamic> json) {
    return OiAppShellSettings(
      schemaVersion: (json['schemaVersion'] as int?) ?? 1,
      sidebarCollapsed: (json['sidebarCollapsed'] as bool?) ?? false,
    );
  }

  /// Schema version for migration.
  @override
  final int schemaVersion;

  /// Whether the sidebar is in collapsed (compact) state.
  final bool sidebarCollapsed;

  /// Serializes this settings object to a JSON-encodable map.
  @override
  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'sidebarCollapsed': sidebarCollapsed,
  };

  /// Returns new settings, filling in fields from [defaults] where this
  /// instance has default values.
  OiAppShellSettings mergeWith(OiAppShellSettings defaults) {
    return OiAppShellSettings(
      schemaVersion: schemaVersion,
      sidebarCollapsed: sidebarCollapsed,
    );
  }

  /// Returns a copy of this object with the specified fields replaced.
  OiAppShellSettings copyWith({int? schemaVersion, bool? sidebarCollapsed}) {
    return OiAppShellSettings(
      schemaVersion: schemaVersion ?? this.schemaVersion,
      sidebarCollapsed: sidebarCollapsed ?? this.sidebarCollapsed,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiAppShellSettings) return false;
    return schemaVersion == other.schemaVersion &&
        sidebarCollapsed == other.sidebarCollapsed;
  }

  @override
  int get hashCode => Object.hash(schemaVersion, sidebarCollapsed);
}
