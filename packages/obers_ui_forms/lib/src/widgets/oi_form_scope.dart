import 'package:flutter/widgets.dart';
import 'package:obers_ui_forms/src/controllers/oi_form_controller.dart';

/// Provides an [OiFormController] to descendant widgets via the widget tree.
///
/// Wrap your form UI in an [OiFormScope] to enable auto-binding of
/// [OiFormElement] widgets to their respective field controllers.
///
/// ```dart
/// OiFormScope<SignupFields>(
///   controller: myFormController,
///   child: Column(children: [...]),
/// )
/// ```
class OiFormScope<E extends Enum>
    extends InheritedNotifier<OiFormController<E>> {
  const OiFormScope({
    required OiFormController<E> controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  /// The form controller provided to descendants.
  OiFormController<E> get controller => notifier!;

  /// Returns the nearest [OiFormController] of type [E], or throws.
  static OiFormController<E> of<E extends Enum>(BuildContext context) {
    final controller = maybeOf<E>(context);
    assert(
      controller != null,
      'No OiFormScope<$E> found in the widget tree. '
      'Wrap your form in OiFormScope<$E>(controller: ..., child: ...).',
    );
    return controller!;
  }

  /// Returns the nearest [OiFormController] of type [E], or null.
  static OiFormController<E>? maybeOf<E extends Enum>(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<OiFormScope<E>>()
        ?.controller;
  }
}
