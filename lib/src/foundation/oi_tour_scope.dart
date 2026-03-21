import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiApp;
import 'package:obers_ui/src/foundation/oi_app.dart' show OiApp;

/// Immutable data provided by [OiTourScope].
///
/// This is a stub used to satisfy the injection requirement.
/// The full onboarding tour implementation extends this via a composite layer.
///
/// {@category Foundation}
class OiTourScopeData {
  /// Creates an [OiTourScopeData].
  const OiTourScopeData();
}

/// Provides [OiTourScopeData] to all descendants.
///
/// [OiApp] places this widget in the injection chain so that tour-aware
/// components can call [OiTourScope.maybeOf] without crashing even when no
/// full onboarding composite is present.
///
/// {@category Foundation}
class OiTourScope extends InheritedWidget {
  /// Creates an [OiTourScope].
  const OiTourScope({required super.child, super.key});

  /// Returns the [OiTourScopeData] from the nearest [OiTourScope].
  ///
  /// Throws if no [OiTourScope] is found in the widget tree.
  static OiTourScopeData of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<OiTourScope>();
    assert(scope != null, 'No OiTourScope found in the widget tree.');
    return const OiTourScopeData();
  }

  /// Returns the [OiTourScopeData] from the nearest [OiTourScope],
  /// or `null` if none is found.
  static OiTourScopeData? maybeOf(BuildContext context) {
    final found = context.dependOnInheritedWidgetOfExactType<OiTourScope>();
    return found != null ? const OiTourScopeData() : null;
  }

  @override
  bool updateShouldNotify(OiTourScope oldWidget) => false;
}
