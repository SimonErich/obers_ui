import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart'
    show BrowserContextMenu, SystemUiOverlayStyle;
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/inputs/oi_select_scope.dart';
import 'package:obers_ui/src/foundation/oi_accessibility.dart';
import 'package:obers_ui/src/foundation/oi_density.dart';
import 'package:obers_ui/src/foundation/oi_density_scope.dart';
import 'package:obers_ui/src/foundation/oi_input_modality_detector.dart';
import 'package:obers_ui/src/foundation/oi_overlays.dart';
import 'package:obers_ui/src/foundation/oi_platform.dart';
import 'package:obers_ui/src/foundation/oi_scroll_behavior.dart';
import 'package:obers_ui/src/foundation/oi_shortcut_scope.dart';
import 'package:obers_ui/src/foundation/oi_theme_mode.dart';
import 'package:obers_ui/src/foundation/oi_tour_scope.dart';
import 'package:obers_ui/src/foundation/oi_undo_stack.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_driver.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_provider.dart';
import 'package:obers_ui/src/foundation/theme/oi_animation_config.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';

export 'oi_density.dart';
export 'oi_density_scope.dart';
export 'oi_theme_mode.dart';

part 'oi_app/oi_app_state.part.dart';
part 'oi_app/oi_attached_focus_policy.part.dart';

/// The root widget of an obers_ui application.
///
/// [OiApp] replaces [WidgetsApp] / MaterialApp / CupertinoApp as the
/// root widget. It injects all design-system services — theme, overlays,
/// undo stack, accessibility scope, platform data, density, shortcut scope,
/// tour scope, and optional settings persistence — into the widget tree.
///
/// System reduced motion zeroes authored durations without replacing page
/// transition kinds or curves. When the preference clears, the current theme's
/// authored configuration is used again.
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
