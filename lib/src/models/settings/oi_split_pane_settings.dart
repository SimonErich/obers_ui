import 'package:flutter/foundation.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_data.dart';

/// Settings for [OiSplitPane] that can be persisted.
///
/// All fields have sensible defaults so that [OiSplitPaneSettings] is usable
/// without any explicit configuration.
///
/// {@category Models}
@immutable
class OiSplitPaneSettings with OiSettingsData {
  /// Creates an [OiSplitPaneSettings] with optional field overrides.
  const OiSplitPaneSettings({
    this.schemaVersion = 1,
    this.dividerPosition = 0.5,
    this.paneCollapsed = false,
  });

  /// Deserializes an [OiSplitPaneSettings] from a JSON map.
  factory OiSplitPaneSettings.fromJson(Map<String, dynamic> json) {
    return OiSplitPaneSettings(
      schemaVersion: (json['schemaVersion'] as int?) ?? 1,
      dividerPosition:
          (json['dividerPosition'] as num?)?.toDouble() ?? 0.5,
      paneCollapsed: (json['paneCollapsed'] as bool?) ?? false,
    );
  }

  /// Schema version for migration.
  @override
  final int schemaVersion;

  /// Fractional position of the divider (0.0 – 1.0).
  final double dividerPosition;

  /// Whether one of the panes is collapsed.
  final bool paneCollapsed;

  /// Serializes this settings object to a JSON-encodable map.
  @override
  Map<String, dynamic> toJson() => {
        'schemaVersion': schemaVersion,
        'dividerPosition': dividerPosition,
        'paneCollapsed': paneCollapsed,
      };

  /// Returns new settings, filling in fields from [defaults] where this
  /// instance has empty or default values.
  ///
  /// Explicit user settings are preserved; only uninitialised fields fall
  /// back to [defaults].
  OiSplitPaneSettings mergeWith(OiSplitPaneSettings defaults) {
    return OiSplitPaneSettings(
      schemaVersion: schemaVersion,
      dividerPosition: dividerPosition,
      paneCollapsed: paneCollapsed,
    );
  }

  /// Returns a copy of this object with the specified fields replaced.
  OiSplitPaneSettings copyWith({
    int? schemaVersion,
    double? dividerPosition,
    bool? paneCollapsed,
  }) {
    return OiSplitPaneSettings(
      schemaVersion: schemaVersion ?? this.schemaVersion,
      dividerPosition: dividerPosition ?? this.dividerPosition,
      paneCollapsed: paneCollapsed ?? this.paneCollapsed,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiSplitPaneSettings) return false;
    return schemaVersion == other.schemaVersion &&
        dividerPosition == other.dividerPosition &&
        paneCollapsed == other.paneCollapsed;
  }

  @override
  int get hashCode => Object.hash(
        schemaVersion,
        dividerPosition,
        paneCollapsed,
      );
}
