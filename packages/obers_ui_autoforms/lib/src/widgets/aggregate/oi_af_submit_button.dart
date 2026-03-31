import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiButton, OiButtonVariant;
import 'package:obers_ui_autoforms/src/runtime/controller/oi_af_controller.dart';
import 'package:obers_ui_autoforms/src/widgets/root/oi_af_scope.dart';

/// A submit button that binds to the form controller's aggregate state.
///
/// Shows a loading state when the form is submitting. Optionally disables
/// when the form is invalid or clean.
class OiAfSubmitButton<TField extends Enum, TData> extends StatefulWidget {
  const OiAfSubmitButton({
    required this.label,
    this.loadingLabel,
    this.icon,
    this.variant = OiButtonVariant.primary,
    this.disableWhenInvalid = false,
    this.disableWhenClean = false,
    this.fullWidth = false,
    this.onTap,
    super.key,
  });

  /// The button label text.
  final String label;

  /// Label shown during submit. Defaults to [label].
  final String? loadingLabel;

  /// Optional leading icon.
  final IconData? icon;

  /// The visual variant of the button.
  final OiButtonVariant variant;

  /// Whether to disable when the form has validation errors.
  final bool disableWhenInvalid;

  /// Whether to disable when the form has no dirty fields.
  final bool disableWhenClean;

  /// Whether the button should stretch to fill its container.
  final bool fullWidth;

  /// Additional callback after submit completes.
  final VoidCallback? onTap;

  @override
  State<OiAfSubmitButton<TField, TData>> createState() =>
      _OiAfSubmitButtonState<TField, TData>();
}

class _OiAfSubmitButtonState<TField extends Enum, TData>
    extends State<OiAfSubmitButton<TField, TData>> {
  OiAfController<TField, Object?>? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller?.removeListener(_onChanged);
    _controller = OiAfScope.of<TField, Object?>(context);
    _controller!.addListener(_onChanged);
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  bool get _isDisabled {
    final ctrl = _controller;
    if (ctrl == null) return true;
    if (!ctrl.isEnabled) return true;
    if (ctrl.isSubmitting) return true;
    if (widget.disableWhenInvalid && !ctrl.isValid) return true;
    if (widget.disableWhenClean && !ctrl.isDirty) return true;
    return false;
  }

  Future<void> _handleSubmit() async {
    final ctrl = _controller;
    if (ctrl == null) return;
    await ctrl.submit();
    widget.onTap?.call();
  }

  @override
  void dispose() {
    _controller?.removeListener(_onChanged);
    super.dispose();
  }

  Widget _buildButton({
    required String label,
    required bool isLoading,
    required bool isDisabled,
    IconData? icon,
  }) {
    switch (widget.variant) {
      case OiButtonVariant.primary:
        return OiButton.primary(
          label: label,
          icon: icon,
          loading: isLoading,
          enabled: !isDisabled,
          onTap: isDisabled ? null : _handleSubmit,
          fullWidth: widget.fullWidth,
        );
      case OiButtonVariant.secondary:
        return OiButton.secondary(
          label: label,
          icon: icon,
          loading: isLoading,
          enabled: !isDisabled,
          onTap: isDisabled ? null : _handleSubmit,
          fullWidth: widget.fullWidth,
        );
      case OiButtonVariant.outline:
        return OiButton.outline(
          label: label,
          icon: icon,
          loading: isLoading,
          enabled: !isDisabled,
          onTap: isDisabled ? null : _handleSubmit,
          fullWidth: widget.fullWidth,
        );
      case OiButtonVariant.ghost:
        return OiButton.ghost(
          label: label,
          icon: icon,
          loading: isLoading,
          enabled: !isDisabled,
          onTap: isDisabled ? null : _handleSubmit,
          fullWidth: widget.fullWidth,
        );
      case OiButtonVariant.destructive:
        return OiButton.destructive(
          label: label,
          icon: icon,
          loading: isLoading,
          enabled: !isDisabled,
          onTap: isDisabled ? null : _handleSubmit,
          fullWidth: widget.fullWidth,
        );
      case OiButtonVariant.soft:
        return OiButton.soft(
          label: label,
          icon: icon,
          loading: isLoading,
          enabled: !isDisabled,
          onTap: isDisabled ? null : _handleSubmit,
          fullWidth: widget.fullWidth,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = _controller;
    final isLoading = ctrl?.isSubmitting ?? false;

    return _buildButton(
      label: isLoading ? (widget.loadingLabel ?? widget.label) : widget.label,
      isLoading: isLoading,
      isDisabled: _isDisabled,
      icon: widget.icon,
    );
  }
}
