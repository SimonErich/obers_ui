import 'package:flutter/widgets.dart';
import 'package:obers_ui_autoforms/src/foundation/oi_af_enums.dart';
import 'package:obers_ui_autoforms/src/foundation/oi_af_submit_result.dart';
import 'package:obers_ui_autoforms/src/foundation/oi_af_typedefs.dart';
import 'package:obers_ui_autoforms/src/runtime/controller/oi_af_controller.dart';
import 'package:obers_ui_autoforms/src/widgets/root/oi_af_scope.dart';

/// Root form widget that provides an [OiAfController] to the widget subtree.
///
/// Place [OiAfForm] at the root of your form layout. Any [OiAf*] field widget
/// inside the subtree will automatically bind to the controller.
///
/// ```dart
/// OiAfForm<MyField, MyData>(
///   controller: myController,
///   onSubmit: (data, ctrl) async { await api.save(data); },
///   child: OiColumn(children: [
///     OiAfTextInput(field: MyField.name, label: 'Name'),
///     OiAfSubmitButton(label: 'Save'),
///   ]),
/// )
/// ```
class OiAfForm<TField extends Enum, TData> extends StatefulWidget {
  const OiAfForm({
    required this.controller,
    required this.child,
    this.onSubmit,
    this.onSubmitResult,
    this.errorMapper,
    this.validateMode = OiAfValidateMode.onBlurThenChange,
    this.autofocusFirstField = false,
    this.submitOnEnterFromLastField = true,
    this.focusFirstInvalidFieldOnSubmitFailure = true,
    this.clearGlobalErrorsOnFieldChange = true,
    this.enabled = true,
    super.key,
  });

  /// The form controller that manages all field state.
  final OiAfController<TField, TData> controller;

  /// The form content. Place OiAf* field widgets here.
  final Widget child;

  /// Called when the form submits successfully.
  final Future<void> Function(
    TData data,
    OiAfController<TField, TData> controller,
  )?
  onSubmit;

  /// Called with the result of every submit attempt.
  final void Function(
    OiAfSubmitResult<TData> result,
    OiAfController<TField, TData> controller,
  )?
  onSubmitResult;

  /// Maps submit exceptions to field/global errors.
  final OiAfSubmitErrorMapper<TField, TData>? errorMapper;

  /// When to auto-validate fields.
  final OiAfValidateMode validateMode;

  /// Whether to focus the first field on mount.
  final bool autofocusFirstField;

  /// Whether Enter on the last field triggers submit.
  final bool submitOnEnterFromLastField;

  /// Whether to focus the first invalid field after a failed submit.
  final bool focusFirstInvalidFieldOnSubmitFailure;

  /// Whether changing a field clears global errors.
  final bool clearGlobalErrorsOnFieldChange;

  /// Whether the entire form is enabled.
  final bool enabled;

  @override
  State<OiAfForm<TField, TData>> createState() =>
      _OiAfFormState<TField, TData>();
}

class _OiAfFormState<TField extends Enum, TData>
    extends State<OiAfForm<TField, TData>> {
  @override
  void initState() {
    super.initState();
    _attach();
    if (widget.autofocusFirstField) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.controller.focusFirstAvailableField();
      });
    }
  }

  @override
  void didUpdateWidget(OiAfForm<TField, TData> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.detach();
      _attach();
    }
  }

  void _attach() {
    widget.controller.attach(
      validateMode: widget.validateMode,
      submitOnEnterFromLastField: widget.submitOnEnterFromLastField,
      focusFirstInvalidFieldOnSubmitFailure:
          widget.focusFirstInvalidFieldOnSubmitFailure,
      clearGlobalErrorsOnFieldChange: widget.clearGlobalErrorsOnFieldChange,
      enabled: widget.enabled,
      onSubmit: widget.onSubmit,
      onSubmitResult: widget.onSubmitResult,
      errorMapper: widget.errorMapper,
    );
  }

  @override
  void dispose() {
    widget.controller.detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OiAfScope(rawController: widget.controller, child: widget.child);
  }
}
