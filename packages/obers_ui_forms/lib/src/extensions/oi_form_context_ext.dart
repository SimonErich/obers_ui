import 'package:flutter/widgets.dart';
import 'package:obers_ui_forms/src/controllers/oi_form_controller.dart';
import 'package:obers_ui_forms/src/widgets/oi_form_scope.dart';

/// Convenient access to the form controller from [BuildContext].
extension OiFormContextExt on BuildContext {
  /// Returns the nearest [OiFormController] of type [E], or throws.
  OiFormController<E> formController<E extends Enum>() =>
      OiFormScope.of<E>(this);

  /// Returns the nearest [OiFormController] of type [E], or null.
  OiFormController<E>? maybeFormController<E extends Enum>() =>
      OiFormScope.maybeOf<E>(this);
}
