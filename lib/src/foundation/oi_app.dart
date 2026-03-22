import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/inputs/oi_select.dart';
import 'package:obers_ui/src/foundation/oi_accessibility.dart';
import 'package:obers_ui/src/foundation/oi_input_modality.dart';
import 'package:obers_ui/src/foundation/oi_overlays.dart';
import 'package:obers_ui/src/foundation/oi_platform.dart';
import 'package:obers_ui/src/foundation/oi_shortcut_scope.dart';
import 'package:obers_ui/src/foundation/oi_tour_scope.dart';
import 'package:obers_ui/src/foundation/oi_undo_stack.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_driver.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_provider.dart';
import 'package:obers_ui/src/foundation/theme/oi_animation_config.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';

/// Controls which theme is used by [OiApp].
///
/// {@category Foundation}
enum OiThemeMode {
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
  /// Throws a [FlutterError] if no [OiDensityScope] ancestor is found.
  /// Wrap your widget tree with [OiApp] to provide a density scope.
  static OiDensity of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<OiDensityScope>();
    if (scope == null) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('No OiDensityScope found in the widget tree.'),
        ErrorHint('Ensure that OiApp wraps your widget.'),
      ]);
    }
    return scope.density;
  }

  @override
  bool updateShouldNotify(OiDensityScope oldWidget) =>
      density != oldWidget.density;
}

/// The root widget of an obers_ui application.
///
/// [OiApp] replaces [WidgetsApp] / MaterialApp / CupertinoApp as the
/// root widget. It injects all design-system services — theme, overlays,
/// undo stack, accessibility scope, platform data, density, shortcut scope,
/// tour scope, and optional settings persistence — into the widget tree.
///
/// Use the default constructor for simple (non-router) apps, and
/// [OiApp.router] for apps that use a declarative routing package such as
/// go_router.
///
/// ```dart
/// void main() {
///   runApp(
///     OiApp(
///       theme: OiThemeData.light(),
///       darkTheme: OiThemeData.dark(),
///       themeMode: OiThemeMode.system,
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
    required Widget this.home,
    this.theme,
    this.darkTheme,
    this.themeMode = OiThemeMode.system,
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
  }) : routerConfig = null,
       _useRouter = false;

  /// Creates an [OiApp] that uses a declarative router.
  ///
  /// Pass a [RouterConfig] (e.g. from go_router) as [routerConfig].
  /// All other parameters behave identically to the default constructor.
  const OiApp.router({
    required this.routerConfig,
    this.theme,
    this.darkTheme,
    this.themeMode = OiThemeMode.system,
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
  }) : home = null,
       _useRouter = true;

  /// The root widget displayed when no router is used.
  ///
  /// Always `null` when [OiApp.router] constructor is used.
  final Widget? home;

  /// The router configuration used when [OiApp.router] constructor is used.
  ///
  /// Always `null` when the default [OiApp] constructor is used.
  final RouterConfig<Object>? routerConfig;

  // Whether the router constructor was used.
  final bool _useRouter;

  /// The light theme. Defaults to [OiThemeData.light] if null.
  final OiThemeData? theme;

  /// The dark theme.
  ///
  /// When null, [theme] is used for both light and dark modes instead of
  /// falling back to [OiThemeData.dark].
  final OiThemeData? darkTheme;

  /// Determines which theme to use when both [theme] and [darkTheme] are set.
  final OiThemeMode themeMode;

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
    // When darkTheme is null, use the primary (light) theme for both modes.
    final darkTheme = widget.darkTheme ?? lightTheme;

    OiThemeData resolved;
    switch (widget.themeMode) {
      case OiThemeMode.light:
        resolved = lightTheme;
      case OiThemeMode.dark:
        resolved = darkTheme;
      case OiThemeMode.system:
        resolved = platformBrightness == Brightness.dark
            ? darkTheme
            : lightTheme;
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

  /// Maps a [Locale] to the appropriate [TextDirection].
  ///
  /// RTL is used for Arabic, Hebrew, Persian, Urdu, and related scripts.
  /// Falls back to [TextDirection.ltr] when [locale] is null.
  TextDirection _resolveTextDirection(Locale? locale) {
    if (locale == null) return TextDirection.ltr;
    const rtlLanguageCodes = {
      'ar', // Arabic
      'he', // Hebrew
      'fa', // Persian / Farsi
      'ur', // Urdu
      'ps', // Pashto
      'sd', // Sindhi
      'ug', // Uyghur
      'yi', // Yiddish
      'dv', // Divehi / Maldivian
    };
    return rtlLanguageCodes.contains(locale.languageCode)
        ? TextDirection.rtl
        : TextDirection.ltr;
  }

  /// Builds the full injection scaffold that wraps the navigated content.
  ///
  /// Injection order (outermost → innermost):
  /// [OiTheme] → [Directionality] → [OiDensityScope] → [OiA11yScope]
  /// → [OiInputModalityDetector] (provides [OiPlatform])
  /// → [OiUndoStackProvider] → [OiShortcutScope]
  /// → [OiTourScope] → OiOverlaysHost
  Widget _buildScaffold(BuildContext context, Widget? child) {
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    var themeData = _resolveTheme(platformBrightness);

    if (MediaQuery.disableAnimationsOf(context)) {
      themeData = themeData.copyWith(
        animations: const OiAnimationConfig.standard(reducedMotion: true),
      );
    }

    Widget result = OiTheme(
      data: themeData,
      child: Directionality(
        textDirection: _resolveTextDirection(widget.locale),
        child: OiDensityScope(
          density: _resolveDensity(),
          child: OiA11yScope(
            child: OiInputModalityDetector(
              child: OiUndoStackProvider(
                stack: _undoStack,
                child: OiShortcutScope(
                  child: OiTourScope(
                    child: OiSelectScope(
                      child: buildOiOverlaysHost(
                        service: _overlaysService,
                        child: child ?? const SizedBox(),
                      ),
                    ),
                  ),
                ),
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
  }

  @override
  Widget build(BuildContext context) {
    if (widget._useRouter) {
      return WidgetsApp.router(
        color: const Color(0xFF2563EB),
        locale: widget.locale,
        localizationsDelegates: widget.localizationsDelegates,
        supportedLocales: widget.supportedLocales,
        title: widget.title,
        debugShowCheckedModeBanner: widget.debugShowCheckedModeBanner,
        routerConfig: widget.routerConfig,
        builder: _buildScaffold,
      );
    }

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
      builder: _buildScaffold,
      home: widget.home,
    );
  }
}
