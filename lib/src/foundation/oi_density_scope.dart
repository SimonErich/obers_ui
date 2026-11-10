import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_density.dart';

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
  /// Wrap your widget tree with the root app to provide a density scope.
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
