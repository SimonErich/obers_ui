import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' hide OiFormController;
import 'package:obers_ui_forms/src/controllers/oi_form_controller.dart';
import 'package:obers_ui_forms/src/widgets/oi_form_scope.dart';

/// Wraps a form input widget with label, error display, and form binding.
///
/// Connects the child input to the [OiFormController] via the [fieldKey],
/// automatically displaying validation errors and managing visibility.
///
/// ```dart
/// OiFormElement<SignupFields>(
///   fieldKey: SignupFields.name,
///   label: 'Full Name',
///   child: OiTextInput(onChanged: (v) => controller.set(SignupFields.name, v)),
/// )
/// ```
class OiFormElement<E extends Enum> extends StatefulWidget {
  const OiFormElement({
    required this.fieldKey,
    required this.child,
    this.label,
    this.hideIf,
    this.showIf,
    this.revalidateOnChangeOf,
    this.focusNode,
    super.key,
  });

  /// The enum key linking this element to its field controller.
  final E fieldKey;

  /// Optional label displayed above the input.
  final String? label;

  /// The input widget to wrap.
  final Widget child;

  /// Hide this field when the callback returns true.
  final bool Function(OiFormController<E> controller)? hideIf;

  /// Show this field when the callback returns true.
  /// Takes precedence over [hideIf].
  final bool Function(OiFormController<E> controller)? showIf;

  /// Re-validate this field when any of these fields change.
  final List<E>? revalidateOnChangeOf;

  /// Optional focus node for this field.
  final FocusNode? focusNode;

  @override
  State<OiFormElement<E>> createState() => _OiFormElementState<E>();
}

class _OiFormElementState<E extends Enum> extends State<OiFormElement<E>> {
  OiFormController<E>? _controller;
  final Map<E, VoidCallback> _revalidateListeners = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = OiFormScope.maybeOf<E>(context);
    if (controller != _controller) {
      _removeRevalidateListeners();
      _controller = controller;
      _setupRevalidateListeners();
    }
  }

  void _setupRevalidateListeners() {
    if (_controller == null || widget.revalidateOnChangeOf == null) return;
    for (final key in widget.revalidateOnChangeOf!) {
      final listener = () {
        _controller!
            .getInputController(widget.fieldKey)
            .validateSync(_controller);
      };
      _revalidateListeners[key] = listener;
      _controller!.getInputController(key).addListener(listener);
    }
  }

  void _removeRevalidateListeners() {
    if (_controller == null) return;
    for (final entry in _revalidateListeners.entries) {
      try {
        _controller!.getInputController(entry.key).removeListener(entry.value);
      } catch (_) {
        // Controller may have been disposed
      }
    }
    _revalidateListeners.clear();
  }

  @override
  void dispose() {
    _removeRevalidateListeners();
    super.dispose();
  }

  bool _isVisible(OiFormController<E> controller) {
    // showIf takes precedence
    if (widget.showIf != null) return widget.showIf!(controller);
    if (widget.hideIf != null) return !widget.hideIf!(controller);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final controller = OiFormScope.maybeOf<E>(context);

    // No scope — render standalone
    if (controller == null) {
      return _buildContent(context, errors: []);
    }

    // Check visibility
    if (!_isVisible(controller)) {
      return const SizedBox.shrink();
    }

    final field = controller.getInputController(widget.fieldKey);
    return _buildContent(
      context,
      errors: field.errors,
      isRequired: field.required,
      isDisabled: !field.enabled,
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required List<String> errors,
    bool isRequired = false,
    bool isDisabled = false,
  }) {
    final colors = context.colors;
    final spacing = context.spacing;

    final labelText = widget.label != null && isRequired
        ? '${widget.label!} *'
        : widget.label;

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (labelText != null)
          Padding(
            padding: EdgeInsets.only(bottom: spacing.xs),
            child: Semantics(
              label: isRequired ? '${widget.label}, required' : null,
              child: OiLabel.small(labelText),
            ),
          ),
        widget.child,
        if (errors.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: spacing.xs),
            child: Semantics(
              liveRegion: true,
              child: OiLabel.small(errors.first, color: colors.error.base),
            ),
          ),
      ],
    );

    if (isDisabled) {
      content = Opacity(opacity: 0.6, child: IgnorePointer(child: content));
    }

    return content;
  }
}
