/// Mixin that all settings data classes must implement.
///
/// Provides a standard serialization contract so persistence drivers can
/// store and retrieve typed settings without knowing the concrete type.
///
/// Implement this mixin on an `@immutable` data class:
/// ```dart
/// @immutable
/// class MySettings with OiSettingsData {
///   const MySettings({this.pageSize = 25});
///   final int pageSize;
///
///   @override int get schemaVersion => 1;
///
///   @override
///   Map<String, dynamic> toJson() => {'pageSize': pageSize, 'schemaVersion': schemaVersion};
///
///   factory MySettings.fromJson(Map<String, dynamic> json) =>
///       MySettings(pageSize: (json['pageSize'] as int?) ?? 25);
/// }
/// ```
///
/// {@category Foundation}
mixin OiSettingsData {
  /// Serializes this settings object to a JSON-encodable map.
  ///
  /// The map must include a `'schemaVersion'` key.
  Map<String, dynamic> toJson();

  /// The schema version of this settings class.
  ///
  /// Increment when adding, removing, or renaming fields to enable
  /// backwards-compatibility detection in mergeWith implementations.
  int get schemaVersion;
}
