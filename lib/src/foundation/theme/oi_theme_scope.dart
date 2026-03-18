import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';

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
  const OiThemeScope({required this.data, required this.child, super.key});

  /// The overriding theme data.
  final OiThemeData data;

  /// The subtree to receive the overridden theme.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return OiTheme(data: data, child: child);
  }
}
