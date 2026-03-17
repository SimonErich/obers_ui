import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_animation_config.dart';
import 'package:obers_ui/src/foundation/theme/oi_color_scheme.dart';
import 'package:obers_ui/src/foundation/theme/oi_component_themes.dart';
import 'package:obers_ui/src/foundation/theme/oi_decoration_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_effects_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_radius_scale.dart';
import 'package:obers_ui/src/foundation/theme/oi_shadow_scale.dart';
import 'package:obers_ui/src/foundation/theme/oi_spacing_scale.dart';
import 'package:obers_ui/src/foundation/theme/oi_text_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';

/// Provides an [OiThemeData] to all descendant widgets.
///
/// Place this widget near the top of the widget tree (e.g. inside [OiApp])
/// and access the theme from any descendant via [OiTheme.of] or the
/// [BuildContext] extension [OiBuildContextThemeExt].
///
/// To override the theme for a subtree, use [OiThemeScope].
///
/// {@category Foundation}
class OiTheme extends InheritedWidget {
  /// Creates an [OiTheme] that provides [data] to all descendants.
  const OiTheme({
    required this.data,
    required super.child,
    super.key,
  });

  /// The theme data to inject into the subtree.
  final OiThemeData data;

  /// Returns the nearest [OiThemeData] from the widget tree.
  ///
  /// Throws a [FlutterError] if no [OiTheme] ancestor is found.
  /// Use [maybeOf] for a nullable fallback.
  static OiThemeData of(BuildContext context) {
    final theme = maybeOf(context);
    assert(
      theme != null,
      'No OiTheme found in the widget tree. '
      'Ensure that OiApp or OiTheme wraps your widget.',
    );
    return theme!;
  }

  /// Returns the nearest [OiThemeData], or null if none is found.
  static OiThemeData? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<OiTheme>()?.data;
  }

  @override
  bool updateShouldNotify(OiTheme oldWidget) => data != oldWidget.data;
}

/// Scopes an [OiThemeData] override to a subtree.
///
/// Use this to provide a different theme to a specific part of your UI
/// without changing the global theme.
///
/// ```dart
/// OiThemeScope(
///   data: OiTheme.of(context).copyWith(
///     colors: customColors,
///   ),
///   child: MyWidget(),
/// )
/// ```
///
/// {@category Foundation}
class OiThemeScope extends StatelessWidget {
  /// Creates an [OiThemeScope] that overrides the theme for [child].
  const OiThemeScope({
    required this.data,
    required this.child,
    super.key,
  });

  /// The overriding theme data.
  final OiThemeData data;

  /// The subtree to receive the overridden theme.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return OiTheme(data: data, child: child);
  }
}

/// Extensions on [BuildContext] for convenient access to [OiThemeData].
///
/// All getters assert that an [OiTheme] ancestor exists in the widget tree.
///
/// {@category Foundation}
extension OiBuildContextThemeExt on BuildContext {
  /// The full [OiThemeData] from the nearest [OiTheme].
  OiThemeData get theme => OiTheme.of(this);

  /// The [OiColorScheme] from the nearest [OiTheme].
  OiColorScheme get colors => OiTheme.of(this).colors;

  /// The [OiTextTheme] from the nearest [OiTheme].
  OiTextTheme get textTheme => OiTheme.of(this).textTheme;

  /// The [OiSpacingScale] from the nearest [OiTheme].
  OiSpacingScale get spacing => OiTheme.of(this).spacing;

  /// The [OiRadiusScale] from the nearest [OiTheme].
  OiRadiusScale get radius => OiTheme.of(this).radius;

  /// The [OiShadowScale] from the nearest [OiTheme].
  OiShadowScale get shadows => OiTheme.of(this).shadows;

  /// The [OiEffectsTheme] from the nearest [OiTheme].
  OiEffectsTheme get effects => OiTheme.of(this).effects;

  /// The [OiAnimationConfig] from the nearest [OiTheme].
  OiAnimationConfig get animations => OiTheme.of(this).animations;

  /// The [OiDecorationTheme] from the nearest [OiTheme].
  OiDecorationTheme get decoration => OiTheme.of(this).decoration;

  /// The [OiComponentThemes] from the nearest [OiTheme].
  OiComponentThemes get components => OiTheme.of(this).components;
}
