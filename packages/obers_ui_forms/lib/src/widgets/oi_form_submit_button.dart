import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' hide OiFormController;
import 'package:obers_ui_forms/src/controllers/oi_form_controller.dart';
import 'package:obers_ui_forms/src/widgets/oi_auto_form.dart';
import 'package:obers_ui_forms/src/widgets/oi_form_scope.dart';

/// A submit button that auto-disables when the form is invalid or validating.
///
/// When placed inside an [OiAutoForm], automatically uses the form's
/// [onSubmit] callback. Can also receive an explicit [onSubmit].
///
/// ```dart
/// OiFormSubmitButton<SignupFields>(label: 'Sign Up')
/// ```
class OiFormSubmitButton<E extends Enum> extends StatelessWidget {
  const OiFormSubmitButton({
    required this.label,
    this.onSubmit,
    this.icon,
    this.variant = OiButtonVariant.primary,
    super.key,
  });

  /// The button label text.
  final String label;

  /// Explicit submit callback. If null, uses [OiAutoForm]'s onSubmit.
  final void Function(Map<E, dynamic> data, OiFormController<E> controller)?
  onSubmit;

  /// Optional icon for the button.
  final IconData? icon;

  /// The button variant style (defaults to primary).
  final OiButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final controller = OiFormScope.maybeOf<E>(context);

    if (controller == null) {
      return OiButton.primary(label: label, icon: icon, enabled: false);
    }

    // Resolve onSubmit: explicit > OiAutoForm > null
    final resolvedOnSubmit = onSubmit ?? OiAutoForm.onSubmitOf<E>(context);
    final isEnabled = controller.isValid && !controller.isValidating;

    Widget button;
    switch (variant) {
      case OiButtonVariant.primary:
        button = OiButton.primary(
          label: label,
          icon: icon,
          enabled: isEnabled,
          onTap: isEnabled ? () => controller.submit(resolvedOnSubmit) : null,
        );
      case OiButtonVariant.secondary:
        button = OiButton.secondary(
          label: label,
          icon: icon,
          enabled: isEnabled,
          onTap: isEnabled ? () => controller.submit(resolvedOnSubmit) : null,
        );
      case OiButtonVariant.outline:
        button = OiButton.outline(
          label: label,
          icon: icon,
          enabled: isEnabled,
          onTap: isEnabled ? () => controller.submit(resolvedOnSubmit) : null,
        );
      case OiButtonVariant.ghost:
        button = OiButton.ghost(
          label: label,
          icon: icon,
          enabled: isEnabled,
          onTap: isEnabled ? () => controller.submit(resolvedOnSubmit) : null,
        );
      case OiButtonVariant.destructive:
        button = OiButton.destructive(
          label: label,
          icon: icon,
          enabled: isEnabled,
          onTap: isEnabled ? () => controller.submit(resolvedOnSubmit) : null,
        );
      case OiButtonVariant.soft:
        button = OiButton.soft(
          label: label,
          icon: icon,
          enabled: isEnabled,
          onTap: isEnabled ? () => controller.submit(resolvedOnSubmit) : null,
        );
    }

    return button;
  }
}
