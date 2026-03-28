import 'package:flutter/widgets.dart';
import 'package:obers_ui_autoforms/src/foundation/oi_af_enums.dart';
import 'package:obers_ui_autoforms/src/runtime/controller/oi_af_controller.dart';
import 'package:obers_ui_autoforms/src/runtime/controller/oi_af_field_controller.dart';
import 'package:obers_ui_autoforms/src/widgets/root/oi_af_scope.dart';

/// Shared binding base for all OiAf* field widgets.
///
/// Manages controller lookup, focus node registration, listener lifecycle,
/// and rebuild on field state change.
///
/// The [TValue] generic is used only for typed value access via [typedValue]
/// and [onValueChanged]. The underlying [fieldCtrl] stores values as [Object?].
mixin OiAfFieldBinderMixin<
  TWidget extends StatefulWidget,
  TField extends Enum,
  TValue
>
    on State<TWidget> {
  late OiAfController<TField, Object?> form;
  late OiAfFieldController<TField> fieldCtrl;
  late FocusNode _focusNode;
  bool _bound = false;

  /// The enum key this widget binds to.
  TField get fieldEnum;

  /// The expected field type for assertion.
  OiAfFieldType get expectedType;

  /// The widget's label for presentation metadata.
  String? get widgetLabel;

  /// Whether this widget's own `enabled` prop is true.
  bool get widgetEnabled;

  /// Whether the actual field type is compatible with the expected type.
  ///
  /// Allows checkbox/switcher interoperability since both use bool values.
  static bool _isCompatibleType(OiAfFieldType actual, OiAfFieldType expected) {
    if (actual == expected) return true;
    const boolTypes = {OiAfFieldType.checkbox, OiAfFieldType.switcher};
    if (boolTypes.contains(actual) && boolTypes.contains(expected)) return true;
    return false;
  }

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bindField();
  }

  void _bindField() {
    form = OiAfScope.of<TField, Object?>(context);
    final next = form.fieldController(fieldEnum);

    assert(
      _isCompatibleType(next.type, expectedType),
      'OiAf widget for $expectedType bound to field of type ${next.type}.',
    );

    if (_bound && fieldCtrl == next) return;

    if (_bound) {
      fieldCtrl
        ..removeListener(_onFieldChanged)
        ..unregisterFocusNode(_focusNode)
        ..detachWidget();
    }

    fieldCtrl = next;
    fieldCtrl
      ..attachWidget()
      ..addListener(_onFieldChanged)
      ..registerPresentationMetadata(label: widgetLabel);
    fieldCtrl.registeredFocusNode = _focusNode;
    _bound = true;
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
    onFieldControllerChanged();
  }

  /// Override this to add custom behavior when the field controller changes.
  /// Called after setState.
  @protected
  void onFieldControllerChanged() {}

  void _onFocusChange() {
    fieldCtrl.setFocused(focused: _focusNode.hasFocus);
  }

  /// The effective enabled state combining form, field controller, and widget.
  bool get effectiveEnabled =>
      widgetEnabled && form.isEnabled && fieldCtrl.isEnabled;

  /// The focus node managed by the binder.
  FocusNode get focusNode => _focusNode;

  /// The current field value, cast to [TValue].
  ///
  /// This is the primary typed access point for widget build methods.
  TValue? get typedValue => fieldCtrl.value as TValue?;

  /// Called when the user changes the value.
  void onValueChanged(TValue? value) {
    fieldCtrl.setValue(value);
  }

  /// Handle enter/submit from text fields.
  void onFieldSubmitted(String value) {
    if (form.isLastFocusableField(fieldEnum) &&
        form.submitOnEnterFromLastField) {
      form.submit();
    } else {
      form.focusNextField(fieldEnum);
    }
  }

  @override
  void dispose() {
    if (_bound) {
      fieldCtrl
        ..removeListener(_onFieldChanged)
        ..unregisterFocusNode(_focusNode)
        ..detachWidget();
    }
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    super.dispose();
  }
}
