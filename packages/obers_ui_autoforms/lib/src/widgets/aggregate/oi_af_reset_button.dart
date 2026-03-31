import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiButton, OiButtonVariant;
import 'package:obers_ui_autoforms/src/foundation/oi_af_enums.dart';
import 'package:obers_ui_autoforms/src/runtime/controller/oi_af_controller.dart';
import 'package:obers_ui_autoforms/src/widgets/root/oi_af_scope.dart';

/// A reset button that binds to the form controller.
///
/// Calls `controller.reset()` with the configured [resetMode].
class OiAfResetButton<TField extends Enum> extends StatefulWidget {
  const OiAfResetButton({
    required this.label,
    this.variant = OiButtonVariant.secondary,
    this.hideWhenClean = false,
    this.resetMode = OiAfResetMode.toInitial,
    this.fullWidth = false,
    super.key,
  });

  /// The button label text.
  final String label;

  /// The visual variant of the button.
  final OiButtonVariant variant;

  /// Whether to hide the button when the form has no dirty fields.
  final bool hideWhenClean;

  /// The reset behavior.
  final OiAfResetMode resetMode;

  /// Whether the button should stretch to fill its container.
  final bool fullWidth;

  @override
  State<OiAfResetButton<TField>> createState() => _OiAfResetButtonState<TField>();
}

class _OiAfResetButtonState<TField extends Enum>
    extends State<OiAfResetButton<TField>> {
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

  void _handleReset() {
    _controller?.reset(mode: widget.resetMode);
  }

  @override
  void dispose() {
    _controller?.removeListener(_onChanged);
    super.dispose();
  }

  Widget _buildButton({
    required String label,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    switch (widget.variant) {
      case OiButtonVariant.primary:
        return OiButton.primary(
          label: label,
          enabled: isEnabled,
          onTap: onTap,
          fullWidth: widget.fullWidth,
        );
      case OiButtonVariant.secondary:
        return OiButton.secondary(
          label: label,
          enabled: isEnabled,
          onTap: onTap,
          fullWidth: widget.fullWidth,
        );
      case OiButtonVariant.outline:
        return OiButton.outline(
          label: label,
          enabled: isEnabled,
          onTap: onTap,
          fullWidth: widget.fullWidth,
        );
      case OiButtonVariant.ghost:
        return OiButton.ghost(
          label: label,
          enabled: isEnabled,
          onTap: onTap,
          fullWidth: widget.fullWidth,
        );
      case OiButtonVariant.destructive:
        return OiButton.destructive(
          label: label,
          enabled: isEnabled,
          onTap: onTap,
          fullWidth: widget.fullWidth,
        );
      case OiButtonVariant.soft:
        return OiButton.soft(
          label: label,
          enabled: isEnabled,
          onTap: onTap,
          fullWidth: widget.fullWidth,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = _controller;
    if (ctrl == null) return const SizedBox.shrink();
    if (widget.hideWhenClean && !ctrl.isDirty) return const SizedBox.shrink();

    return _buildButton(
      label: widget.label,
      isEnabled: ctrl.isEnabled,
      onTap: _handleReset,
    );
  }
}
