import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_accessibility.dart';
import 'package:obers_ui/src/foundation/oi_overlays.dart';
import 'package:obers_ui/src/foundation/oi_platform.dart';
import 'package:obers_ui/src/foundation/oi_undo_stack.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_driver.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_provider.dart';
import 'package:obers_ui/src/foundation/theme/oi_animation_config.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';

/// Controls which theme is used by [OiApp].
///
/// {@category Foundation}
enum ThemeMode {
  /// Always use the light theme.
  light,

  /// Always use the dark theme.
  dark,

  /// Follow the system's brightness setting.
  system,
}

/// The information density mode for the UI.
///
/// {@category Foundation}
enum OiDensity {
  /// Comfortable density — larger touch targets and more padding.
  ///
  /// Typically used on touch devices.
  comfortable,

  /// Compact density — balanced sizing suitable for most platforms.
  ///
  /// The default for pointer devices.
  compact,

  /// Dense density — maximised information density with minimal padding.
  ///
  /// Suitable for data-heavy desktop applications.
  dense,
}

/// Provides the current [OiDensity] to all descendant widgets.
///
/// {@category Foundation}
class OiDensityScope extends InheritedWidget {
  /// Creates an [OiDensityScope] that provides [density] to descendants.
  const OiDensityScope({
    required this.density,
    required super.child,
    super.key,
  });

  /// The active information density.
  final OiDensity density;

  /// Returns the [OiDensity] from the nearest [OiDensityScope].
  ///
  /// Defaults to [OiDensity.compact] if no scope is found.
  static OiDensity of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<OiDensityScope>()
            ?.density ??
        OiDensity.compact;
  }

  @override
  bool updateShouldNotify(OiDensityScope oldWidget) =>
      density != oldWidget.density;
}

/// The root widget of an obers_ui application.
///
/// [OiApp] replaces [WidgetsApp] / MaterialApp / CupertinoApp as the
/// root widget. It injects all design-system services — theme, overlays,
/// undo stack, accessibility scope, platform data, density, and optional
/// settings persistence — into the widget tree.
///
/// ```dart
/// void main() {
///   runApp(
///     OiApp(
///       theme: OiThemeData.light(),
///       darkTheme: OiThemeData.dark(),
///       themeMode: ThemeMode.system,
///       home: const MyHomePage(),
///     ),
///   );
/// }
/// ```
///
/// {@category Foundation}
class OiApp extends StatefulWidget {
  /// Creates an [OiApp] with a simple [home] widget (no routing).
  const OiApp({
    required this.home,
    this.theme,
    this.darkTheme,
    this.themeMode = ThemeMode.system,
    this.density,
    this.performanceConfig,
    this.settingsDriver,
    this.undoStackMaxHistory = 50,
    this.locale,
    this.localizationsDelegates,
    this.supportedLocales = const [Locale('en', 'US')],
    this.title = '',
    this.debugShowCheckedModeBanner = true,
    super.key,
  });

  /// The root widget displayed when no router is used.
  final Widget home;

  /// The light theme. Defaults to [OiThemeData.light] if null.
  final OiThemeData? theme;

  /// The dark theme. Defaults to [OiThemeData.dark] if null.
  final OiThemeData? darkTheme;

  /// Determines which theme to use when both [theme] and [darkTheme] are set.
  final ThemeMode themeMode;

  /// The information density. When null, auto-detected from the platform.
  final OiDensity? density;

  /// Optional performance configuration applied to both [theme] and [darkTheme].
  ///
  /// When provided, overrides the `performanceConfig` of the resolved theme.
  /// When null, the theme's own [OiThemeData.performanceConfig] is used.
  final OiPerformanceConfig? performanceConfig;

  /// Optional global settings persistence driver.
  ///
  /// When provided, all widgets that support persistence will use this driver
  /// unless they specify their own [OiSettingsDriver] explicitly.
  final OiSettingsDriver? settingsDriver;

  /// Maximum number of undo actions retained in history. Default is 50.
  final int undoStackMaxHistory;

  /// The locale for this app.
  final Locale? locale;

  /// Localization delegates.
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;

  /// The locales this app supports.
  final Iterable<Locale> supportedLocales;

  /// The title of the app.
  final String title;

  /// Whether to show the debug banner.
  final bool debugShowCheckedModeBanner;

  @override
  State<OiApp> createState() => _OiAppState();
}

class _OiAppState extends State<OiApp> {
  late final OiUndoStack _undoStack;
  late final OiOverlaysService _overlaysService;

  @override
  void initState() {
    super.initState();
    _undoStack = OiUndoStack(maxHistory: widget.undoStackMaxHistory);
    _overlaysService = createOiOverlaysService();
  }

  @override
  void dispose() {
    _undoStack.dispose();
    super.dispose();
  }

  OiThemeData _resolveTheme(Brightness platformBrightness) {
    final lightTheme = widget.theme ?? OiThemeData.light();
    final darkTheme = widget.darkTheme ?? OiThemeData.dark();

    OiThemeData resolved;
    switch (widget.themeMode) {
      case ThemeMode.light:
        resolved = lightTheme;
      case ThemeMode.dark:
        resolved = darkTheme;
      case ThemeMode.system:
        resolved =
            platformBrightness == Brightness.dark ? darkTheme : lightTheme;
    }

    if (widget.performanceConfig != null) {
      return resolved.copyWith(performanceConfig: widget.performanceConfig);
    }
    return resolved;
  }

  OiDensity _resolveDensity() {
    if (widget.density != null) return widget.density!;
    // Auto-detect: use comfortable on touch devices
    if (kIsWeb) return OiDensity.compact;
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.android:
        return OiDensity.comfortable;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return OiDensity.compact;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      color: const Color(0xFF2563EB),
      locale: widget.locale,
      localizationsDelegates: widget.localizationsDelegates,
      supportedLocales: widget.supportedLocales,
      title: widget.title,
      debugShowCheckedModeBanner: widget.debugShowCheckedModeBanner,
      pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) {
        return PageRouteBuilder<T>(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
        );
      },
      builder: (context, child) {
        final platformBrightness = MediaQuery.platformBrightnessOf(context);
        final themeData = _resolveTheme(platformBrightness);

        Widget result = OiTheme(
          data: themeData,
          child: OiDensityScope(
            density: _resolveDensity(),
            child: OiA11yScope(
              child: OiPlatform.fromContext(
                context: context,
                child: OiUndoStackProvider(
                  stack: _undoStack,
                  child: buildOiOverlaysHost(
                    service: _overlaysService,
                    child: child ?? const SizedBox(),
                  ),
                ),
              ),
            ),
          ),
        );

        if (widget.settingsDriver != null) {
          result = OiSettingsProvider(
            driver: widget.settingsDriver!,
            child: result,
          );
        }

        return result;
      },
      home: widget.home,
    );
  }
}
