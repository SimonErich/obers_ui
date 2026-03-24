import 'package:flutter/widgets.dart';
import 'package:obers_ui_forms/src/controllers/oi_form_controller.dart';
import 'package:obers_ui_forms/src/widgets/oi_form_scope.dart';

/// A convenience form wrapper that combines [OiFormScope] with an
/// optional [onSubmit] callback and error summary.
///
/// ```dart
/// OiAutoForm<SignupFields>(
///   controller: myController,
///   onSubmit: (data, ctrl) => handleSignup(data),
///   child: Column(children: [
///     OiAutoFormTextInput(fieldKey: SignupFields.name, label: 'Name'),
///     OiFormSubmitButton(label: 'Submit'),
///   ]),
/// )
/// ```
class OiAutoForm<E extends Enum> extends StatelessWidget {
  const OiAutoForm({
    required this.controller,
    required this.child,
    this.onSubmit,
    super.key,
  });

  /// The form controller managing all field state.
  final OiFormController<E> controller;

  /// The form content (typically a Column of OiFormElement/OiAutoForm* widgets).
  final Widget child;

  /// Called when the form is submitted and valid.
  final void Function(Map<E, dynamic> data, OiFormController<E> controller)?
  onSubmit;

  @override
  Widget build(BuildContext context) {
    return _OiAutoFormInherited<E>(
      onSubmit: onSubmit,
      child: OiFormScope<E>(controller: controller, child: child),
    );
  }

  /// Gets the onSubmit callback from the nearest [OiAutoForm] ancestor.
  static void Function(Map<E, dynamic> data, OiFormController<E> controller)?
  onSubmitOf<E extends Enum>(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_OiAutoFormInherited<E>>()
        ?.onSubmit;
  }
}

class _OiAutoFormInherited<E extends Enum> extends InheritedWidget {
  const _OiAutoFormInherited({required super.child, this.onSubmit, super.key});

  final void Function(Map<E, dynamic> data, OiFormController<E> controller)?
  onSubmit;

  @override
  bool updateShouldNotify(_OiAutoFormInherited<E> oldWidget) =>
      onSubmit != oldWidget.onSubmit;
}
