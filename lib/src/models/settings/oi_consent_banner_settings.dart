import 'package:flutter/foundation.dart';
import 'package:obers_ui/obers_ui.dart' show OiConsentBanner, OiSettingsDriver;
import 'package:obers_ui/src/foundation/persistence/oi_settings_data.dart';

/// Persisted consent state for an [OiConsentBanner].
///
/// Stores whether the user has consented, the per-category preference map,
/// and an optional ISO-8601 timestamp of when consent was given. This state
/// can be restored across sessions when a [OiSettingsDriver] is provided.
///
/// {@category Models}
@immutable
class OiConsentBannerSettings with OiSettingsData {
  /// Creates an [OiConsentBannerSettings].
  const OiConsentBannerSettings({
    this.schemaVersion = 1,
    this.consented = false,
    this.preferences = const {},
    this.consentedAt,
  });

  /// Deserializes an [OiConsentBannerSettings] from a JSON map.
  factory OiConsentBannerSettings.fromJson(Map<String, dynamic> json) {
    return OiConsentBannerSettings(
      schemaVersion: (json['schemaVersion'] as int?) ?? 1,
      consented: (json['consented'] as bool?) ?? false,
      preferences:
          (json['preferences'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v as bool),
          ) ??
          const {},
      consentedAt: json['consentedAt'] as String?,
    );
  }

  @override
  final int schemaVersion;

  /// Whether the user has given consent.
  final bool consented;

  /// Per-category consent preferences keyed by category identifier.
  final Map<String, bool> preferences;

  /// ISO-8601 timestamp of when consent was given.
  final String? consentedAt;

  @override
  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'consented': consented,
    'preferences': preferences,
    'consentedAt': consentedAt,
  };

  /// Merges saved settings with [defaults], keeping saved values where present.
  OiConsentBannerSettings mergeWith(OiConsentBannerSettings defaults) {
    return OiConsentBannerSettings(
      schemaVersion: schemaVersion,
      consented: consented,
      preferences: {...defaults.preferences, ...preferences},
      consentedAt: consentedAt ?? defaults.consentedAt,
    );
  }

  /// Returns a copy with the specified fields replaced.
  OiConsentBannerSettings copyWith({
    int? schemaVersion,
    bool? consented,
    Map<String, bool>? preferences,
    String? consentedAt,
  }) {
    return OiConsentBannerSettings(
      schemaVersion: schemaVersion ?? this.schemaVersion,
      consented: consented ?? this.consented,
      preferences: preferences ?? this.preferences,
      consentedAt: consentedAt ?? this.consentedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiConsentBannerSettings) return false;
    return schemaVersion == other.schemaVersion &&
        consented == other.consented &&
        mapEquals(preferences, other.preferences) &&
        consentedAt == other.consentedAt;
  }

  @override
  int get hashCode => Object.hash(schemaVersion, consented, consentedAt);
}
