import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_driver.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_provider.dart';
import 'package:obers_ui/src/models/settings/oi_chart_settings.dart';

/// Connects a chart widget to the [OiSettingsDriver] persistence system.
///
/// [OiChartSettingsDriverBinding] encapsulates the load/save/restore
/// lifecycle for [OiChartSettings], making it easy to persist chart state
/// (hidden series, viewport, selection, legend groups, comparison mode)
/// without charts inventing a separate persistence mechanism.
///
/// ```dart
/// final binding = OiChartSettingsDriverBinding(
///   key: 'revenue-chart',
///   driver: driver,
///   autoSave: true,
///   restoreOnInit: true,
/// );
/// await binding.init();
///
/// // Read the restored (or default) settings:
/// final settings = binding.currentSettings;
///
/// // Update and auto-save:
/// binding.update(settings.copyWith(hiddenSeriesIds: {'series-a'}));
///
/// // Clean up:
/// binding.dispose();
/// ```
///
/// {@category Foundation}
class OiChartSettingsDriverBinding extends ChangeNotifier {
  /// Creates a binding.
  ///
  /// The [key] is used as the sub-key within the `oi_chart` namespace.
  /// Pass [driver] explicitly, or use [OiChartSettingsDriverBinding.of]
  /// to resolve it from the widget tree.
  OiChartSettingsDriverBinding({
    required this.key,
    required this.driver,
    this.autoSave = true,
    this.restoreOnInit = true,
    this.debounceDuration = const Duration(milliseconds: 500),
    OiChartSettings? defaultSettings,
  }) : _settings = defaultSettings ?? const OiChartSettings();

  /// The storage namespace used for all chart settings.
  static const String namespace = 'oi_chart';

  /// Creates a binding using the [OiSettingsDriver] found in the
  /// ancestor [OiSettingsProvider].
  ///
  /// Returns `null` if no provider is found.
  static OiChartSettingsDriverBinding? of(
    BuildContext context, {
    required String key,
    bool autoSave = true,
    bool restoreOnInit = true,
    Duration debounceDuration = const Duration(milliseconds: 500),
    OiChartSettings? defaultSettings,
  }) {
    final driver = OiSettingsProvider.of(context);
    if (driver == null) return null;
    return OiChartSettingsDriverBinding(
      key: key,
      driver: driver,
      autoSave: autoSave,
      restoreOnInit: restoreOnInit,
      debounceDuration: debounceDuration,
      defaultSettings: defaultSettings,
    );
  }

  /// The sub-key identifying this chart's settings within the namespace.
  final String key;

  /// The driver used for persistence.
  final OiSettingsDriver driver;

  /// When `true`, every call to [update] schedules a debounced save.
  final bool autoSave;

  /// When `true`, [init] restores previously saved settings from the
  /// driver.
  final bool restoreOnInit;

  /// The debounce window for auto-save writes.
  final Duration debounceDuration;

  OiChartSettings _settings;
  Timer? _debounceTimer;
  bool _initialized = false;
  bool _disposed = false;

  /// The current in-memory settings value.
  OiChartSettings get currentSettings => _settings;

  /// Whether [init] has completed.
  bool get initialized => _initialized;

  /// Initializes the binding.
  ///
  /// If [restoreOnInit] is `true`, loads settings from the driver. If no
  /// persisted data is found, or if the load fails, the default settings
  /// are kept.
  Future<void> init() async {
    if (_disposed) return;

    if (restoreOnInit) {
      try {
        final saved = await driver.load<OiChartSettings>(
          namespace: namespace,
          key: key,
          deserialize: OiChartSettings.fromJson,
        );
        if (saved != null && !_disposed) {
          _settings = saved.mergeWith(_settings);
        }
      } on Exception {
        // Gracefully keep defaults on any load error.
      }
    }

    _initialized = true;
    if (!_disposed) notifyListeners();
  }

  /// Updates the settings in memory and optionally schedules a save.
  void update(OiChartSettings settings) {
    if (_disposed) return;
    if (_settings == settings) return;

    _settings = settings;
    notifyListeners();

    if (autoSave) {
      _scheduleSave();
    }
  }

  /// Immediately persists the current settings to the driver.
  Future<void> saveNow() async {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    await _persist();
  }

  /// Deletes the persisted settings and resets to the provided defaults.
  Future<void> reset([OiChartSettings defaults = const OiChartSettings()]) async {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    await driver.delete(namespace: namespace, key: key);
    _settings = defaults;
    if (!_disposed) notifyListeners();
  }

  /// Reloads settings from the driver.
  Future<void> reload() async {
    if (_disposed) return;
    try {
      final saved = await driver.load<OiChartSettings>(
        namespace: namespace,
        key: key,
        deserialize: OiChartSettings.fromJson,
      );
      if (saved != null && !_disposed) {
        _settings = saved.mergeWith(_settings);
        notifyListeners();
      }
    } on Exception {
      // Keep current settings on error.
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _debounceTimer?.cancel();
    _debounceTimer = null;
    super.dispose();
  }

  // ── Private helpers ──────────────────────────────────────────────────

  void _scheduleSave() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceDuration, () => unawaited(_persist()));
  }

  Future<void> _persist() async {
    if (_disposed) return;
    await driver.save<OiChartSettings>(
      namespace: namespace,
      key: key,
      data: _settings,
      serialize: (s) => s.toJson(),
    );
  }
}
