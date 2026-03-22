import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

/// Global theme state notifier.
///
/// Wraps an [OiThemeMode] so the showcase can toggle between
/// Alpine (light) and Vienna Night (dark) from anywhere.
class ThemeState extends ValueNotifier<OiThemeMode> {
  /// Starts in light mode (Alpine).
  ThemeState() : super(OiThemeMode.light);

  /// Toggle between light and dark.
  void toggle() {
    value = value == OiThemeMode.light ? OiThemeMode.dark : OiThemeMode.light;
  }
}
