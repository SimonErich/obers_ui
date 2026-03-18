import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/components/overlays/oi_dialog.dart';

/// A dialog that prompts the user to enter a name.
///
/// Wraps [OiDialog] with a single [OiTextInput] pre-filled with [defaultName].
/// On open the input is auto-focused and the default text is fully selected so
/// the user can immediately start typing a replacement.
///
/// **Keyboard shortcuts:**
/// - **Enter** — calls [onCreate] with the current value (when valid).
/// - **Escape** — calls [onCancel].
///
/// An optional [validate] function controls whether the create action is
/// enabled and displays an inline error message when the input is invalid.
///
/// ```dart
/// OiNameDialog(
///   title: 'New folder',
///   defaultName: 'Untitled',
///   onCreate: (name) => createFolder(name),
///   onCancel: () => closeDialog(),
/// )
/// ```
///
/// {@category Composites}
class OiNameDialog extends StatefulWidget {
  /// Creates an [OiNameDialog].
  const OiNameDialog({
    required this.title,
    required this.onCreate,
    this.onCancel,
    this.defaultName = '',
    this.inputLabel,
    this.createLabel = 'Create',
    this.cancelLabel = 'Cancel',
    this.validate,
    super.key,
  });

  /// The heading text displayed at the top of the dialog.
  final String title;

  /// The initial name pre-filled in the input. Defaults to an empty string.
  final String defaultName;

  /// Optional label rendered above the text input.
  final String? inputLabel;

  /// The label for the create button. Defaults to `'Create'`.
  final String createLabel;

  /// The label for the cancel button. Defaults to `'Cancel'`.
  final String cancelLabel;

  /// Called with the entered name when the user confirms.
  final ValueChanged<String> onCreate;

  /// Called when the user cancels the dialog.
  final VoidCallback? onCancel;

  /// An optional validation function.
  ///
  /// Returns an error message string when the value is invalid, or `null`
  /// when valid. When the validator returns a non-null value, the create
  /// action is disabled and the error is shown below the input.
  final String? Function(String)? validate;

  @override
  State<OiNameDialog> createState() => _OiNameDialogState();
}

class _OiNameDialogState extends State<OiNameDialog> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.defaultName);
    _focusNode = FocusNode();

    // After the first frame: focus the input and select all text so the user
    // can immediately type a replacement name.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusNode.requestFocus();
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ── Validation ──────────────────────────────────────────────────────────────

  void _handleChanged(String value) {
    if (widget.validate != null) {
      setState(() => _error = widget.validate!(value));
    }
  }

  bool get _isValid {
    final text = _controller.text;
    if (text.isEmpty) return false;
    if (widget.validate != null) return widget.validate!(text) == null;
    return true;
  }

  // ── Actions ─────────────────────────────────────────────────────────────────

  void _handleCreate() {
    if (!_isValid) return;
    widget.onCreate(_controller.text);
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return OiDialog.standard(
      label: widget.title,
      title: widget.title,
      onClose: widget.onCancel,
      dismissible: false,
      content: OiTextInput(
        controller: _controller,
        focusNode: _focusNode,
        label: widget.inputLabel,
        error: _error,
        autofocus: true,
        onChanged: _handleChanged,
        onSubmitted: (_) => _handleCreate(),
      ),
      actions: [
        OiButton.ghost(
          label: widget.cancelLabel,
          onTap: widget.onCancel,
        ),
        OiButton.primary(
          label: widget.createLabel,
          onTap: _isValid ? _handleCreate : null,
          enabled: _isValid,
        ),
      ],
    );
  }
}
