import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

/// Available theme presets for the showcase app.
enum ThemePreset {
  /// Alpine (forest green) — the default Obers UI theme.
  alpine,

  /// Blue Danube (teal/cyan) — TapTap Design System inspired.
  blueDanube,

  /// Arco (blue) — ByteDance Arco Design System inspired.
  arco,

  /// Finesse (indigo/violet) — Finesse UI Design System inspired.
  finesse,
}

/// Global theme state notifier.
///
/// Wraps an [OiThemeMode] and [ThemePreset] so the showcase can toggle
/// between light/dark mode and switch between theme presets.
class ThemeState extends ValueNotifier<OiThemeMode> {
  /// Starts in light mode.
  ThemeState() : super(OiThemeMode.light);

  ThemePreset _preset = ThemePreset.alpine;

  /// The currently active theme preset.
  ThemePreset get preset => _preset;

  /// Toggle between light and dark.
  void toggle() {
    value = value == OiThemeMode.light ? OiThemeMode.dark : OiThemeMode.light;
  }

  /// Switch to a different theme preset and notify listeners.
  void setPreset(ThemePreset newPreset) {
    if (_preset != newPreset) {
      _preset = newPreset;
      // Force notify even if OiThemeMode hasn't changed
      notifyListeners();
    }
  }

  /// Cycle to the next theme preset.
  void cyclePreset() {
    const values = ThemePreset.values;
    final next = (values.indexOf(_preset) + 1) % values.length;
    setPreset(values[next]);
  }
}
