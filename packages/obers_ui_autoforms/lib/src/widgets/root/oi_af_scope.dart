import 'package:flutter/widgets.dart';
import 'package:obers_ui_autoforms/src/runtime/controller/oi_af_controller.dart';

/// InheritedWidget that provides the [OiAfController] to the widget subtree.
///
/// Uses a non-generic class for reliable lookup via
/// `dependOnInheritedWidgetOfExactType`, with typed accessor methods that
/// perform runtime casts.
class OiAfScope extends InheritedWidget {
  /// Creates an [OiAfScope] wrapping the given controller.
  const OiAfScope({
    required this.rawController,
    required super.child,
    super.key,
  });

  /// The form controller stored as dynamic to avoid generic type mismatch
  /// with `dependOnInheritedWidgetOfExactType`.
  final OiAfController<dynamic, dynamic> rawController;

  /// Retrieve the nearest [OiAfController] from the widget tree.
  static OiAfController<TField, Object?> of<TField extends Enum, TData>(
    BuildContext context,
  ) {
    final scope = context.dependOnInheritedWidgetOfExactType<OiAfScope>();
    assert(
      scope != null,
      'OiAfScope not found. '
      'Wrap your OiAf* field widgets inside an OiAfForm.',
    );
    return scope!.rawController as OiAfController<TField, Object?>;
  }

  /// Try to retrieve the nearest [OiAfController], returning null if not found.
  static OiAfController<TField, TData>? maybeOf<TField extends Enum, TData>(
    BuildContext context,
  ) {
    final scope = context.dependOnInheritedWidgetOfExactType<OiAfScope>();
    if (scope == null) return null;
    return scope.rawController as OiAfController<TField, TData>;
  }

  @override
  bool updateShouldNotify(OiAfScope oldWidget) {
    return rawController != oldWidget.rawController;
  }
}
