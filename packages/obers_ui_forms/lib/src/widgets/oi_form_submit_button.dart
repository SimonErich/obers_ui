import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' hide OiFormController;
import 'package:obers_ui_forms/src/controllers/oi_form_controller.dart';
import 'package:obers_ui_forms/src/widgets/oi_form_scope.dart';

/// A submit button that auto-disables when the form is invalid or validating.
///
/// Must be placed inside an [OiFormScope]. Wraps [OiButton.primary] by default.
///
/// ```dart
/// OiFormSubmitButton<SignupFields>(
///   label: 'Sign Up',
///   onSubmit: (data, controller) => print(data),
/// )
/// ```
class OiFormSubmitButton<E extends Enum> extends StatelessWidget {
  const OiFormSubmitButton({
    required this.label,
    this.onSubmit,
    this.icon,
    super.key,
  });

  /// The button label text.
  final String label;

  /// Callback when the form is submitted and valid.
  final void Function(Map<E, dynamic> data, OiFormController<E> controller)?
  onSubmit;

  /// Optional icon for the button.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final controller = OiFormScope.maybeOf<E>(context);

    if (controller == null) {
      return OiButton.primary(label: label, icon: icon, enabled: false);
    }

    final isEnabled = controller.isValid && !controller.isValidating;

    return OiButton.primary(
      label: label,
      icon: icon,
      enabled: isEnabled,
      onTap: isEnabled ? () => controller.submit(onSubmit) : null,
    );
  }
}
