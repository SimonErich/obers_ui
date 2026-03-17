import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_data.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_driver.dart';

/// A mixin for [StatefulWidget] states that need to load, save, and reset
/// typed settings via an [OiSettingsDriver].
///
/// Handles debounced saves, load-on-init, and graceful defaults.
///
/// ```dart
/// class _MyWidgetState extends State<MyWidget>
///     with OiSettingsMixin<MySettings> {
///   @override String get settingsNamespace => 'my_feature';
///   @override OiSettingsDriver? get settingsDriver => widget.driver;
///   @override MySettings get defaultSettings => const MySettings();
///   @override MySettings deserializeSettings(Map<String, dynamic> json) =>
///       MySettings.fromJson(json);
///   @override MySettings mergeSettings(MySettings saved, MySettings defaults) =>
///       saved;
///
///   @override
///   Widget build(BuildContext context) { ... }
/// }
/// ```
///
/// {@category Foundation}
mixin OiSettingsMixin<T extends OiSettingsData> on State<StatefulWidget> {
  /// The namespace used as the primary storage key.
  String get settingsNamespace;

  /// An optional sub-key within the namespace (e.g. a record ID).
  String? get settingsKey => null;

  /// The driver to use for persistence. When `null`, settings are not persisted.
  OiSettingsDriver? get settingsDriver;

  /// The default settings returned when nothing has been saved yet.
  T get defaultSettings;

  /// Converts a raw JSON map into a typed settings object.
  T deserializeSettings(Map<String, dynamic> json);

  /// Merges saved settings with the current defaults.
  ///
  /// Called after a successful load so callers can forward-fill any fields
  /// added since the settings were last saved.
  T mergeSettings(T saved, T defaults);

  // ── State ─────────────────────────────────────────────────────────────────

  T? _settings;

  /// The current in-memory settings value.
  T get currentSettings => _settings ?? defaultSettings;

  /// Whether the initial load from the driver has completed.
  bool get settingsLoaded => _loaded;
  bool _loaded = false;

  Timer? _debounceTimer;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _settings = defaultSettings;
    unawaited(_loadSettings());
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// Schedules a debounced save of [settings].
  ///
  /// Calling this repeatedly within [debounce] will cancel the previous timer.
  /// Set [debounce] to [Duration.zero] to save on the next event-loop tick.
  @protected
  void updateSettings(
    T settings, {
    Duration debounce = const Duration(milliseconds: 500),
  }) {
    _settings = settings;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounce, () => unawaited(_persist()));
    if (mounted) setState(() {});
  }

  /// Flushes any pending debounced save immediately.
  @protected
  Future<void> saveSettingsNow() async {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    await _persist();
  }

  /// Deletes persisted settings and resets to [defaultSettings].
  @protected
  Future<void> resetSettings() async {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    await settingsDriver?.delete(
      namespace: settingsNamespace,
      key: settingsKey,
    );
    _settings = defaultSettings;
    if (mounted) setState(() {});
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<void> _loadSettings() async {
    final driver = settingsDriver;
    if (driver != null) {
      final saved = await driver.load<T>(
        namespace: settingsNamespace,
        key: settingsKey,
        deserialize: deserializeSettings,
      );
      if (saved != null) {
        _settings = mergeSettings(saved, defaultSettings);
      }
    }
    _loaded = true;
    if (mounted) setState(() {});
  }

  Future<void> _persist() async {
    final driver = settingsDriver;
    if (driver == null) return;
    final current = _settings;
    if (current == null) return;
    await driver.save<T>(
      namespace: settingsNamespace,
      key: settingsKey,
      data: current,
      serialize: (d) => d.toJson(),
    );
  }
}
