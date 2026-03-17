import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/_internal/oi_input_frame.dart';
import 'package:obers_ui/src/primitives/input/oi_raw_input.dart';

/// A themed single- or multi-line text input component.
///
/// Wraps [OiRawInput] inside an [OiInputFrame] which renders a label, border
/// (normal / focused / error), hint, and leading/trailing slots.
///
/// {@category Components}
class OiTextInput extends StatefulWidget {
  /// Creates an [OiTextInput].
  const OiTextInput({
    this.controller,
    this.label,
    this.hint,
    this.placeholder,
    this.error,
    this.leading,
    this.trailing,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.autofocus = false,
    this.inputFormatters,
    this.focusNode,
    super.key,
  });

  /// An optional controller for the text field.
  ///
  /// When null an internal controller is created and managed automatically.
  final TextEditingController? controller;

  /// Optional label rendered above the input frame.
  final String? label;

  /// Optional hint text rendered below the input frame.
  final String? hint;

  /// Placeholder text shown inside the field when it is empty.
  final String? placeholder;

  /// Validation error message. When non-null the error border is shown and
  /// the message is rendered below the frame instead of [hint].
  final String? error;

  /// An optional widget placed at the start of the input row.
  final Widget? leading;

  /// An optional widget placed at the end of the input row.
  final Widget? trailing;

  /// Maximum number of lines. Defaults to 1 (single-line).
  final int? maxLines;

  /// Maximum number of characters the user may enter.
  final int? maxLength;

  /// Keyboard type hint for the platform IME.
  final TextInputType? keyboardType;

  /// The action button shown on the soft keyboard.
  final TextInputAction? textInputAction;

  /// Called when the text value changes.
  final ValueChanged<String>? onChanged;

  /// Called when the user finishes editing.
  final VoidCallback? onEditingComplete;

  /// Called when the user submits the input.
  final ValueChanged<String>? onSubmitted;

  /// Whether the field accepts input. Defaults to true.
  final bool enabled;

  /// Whether the field is read-only.
  final bool readOnly;

  /// Whether to obscure the text (e.g. for passwords).
  final bool obscureText;

  /// Whether to request focus when first inserted into the tree.
  final bool autofocus;

  /// Optional list of input formatters applied to each keystroke.
  final List<TextInputFormatter>? inputFormatters;

  /// Optional external focus node. When null one is created internally.
  final FocusNode? focusNode;

  @override
  State<OiTextInput> createState() => _OiTextInputState();
}

class _OiTextInputState extends State<OiTextInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _ownsController = false;
  bool _ownsFocusNode = false;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = TextEditingController();
      _ownsController = true;
    } else {
      _controller = widget.controller!;
    }
    if (widget.focusNode == null) {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    } else {
      _focusNode = widget.focusNode!;
    }
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(OiTextInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (_ownsController) {
        _controller.dispose();
      }
      if (widget.controller == null) {
        _controller = TextEditingController();
        _ownsController = true;
      } else {
        _controller = widget.controller!;
        _ownsController = false;
      }
    }
    if (oldWidget.focusNode != widget.focusNode) {
      _focusNode.removeListener(_handleFocusChange);
      if (_ownsFocusNode) {
        _focusNode.dispose();
      }
      if (widget.focusNode == null) {
        _focusNode = FocusNode();
        _ownsFocusNode = true;
      } else {
        _focusNode = widget.focusNode!;
        _ownsFocusNode = false;
      }
      _focusNode.addListener(_handleFocusChange);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (_ownsController) _controller.dispose();
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    final focused = _focusNode.hasFocus;
    if (focused != _focused) {
      setState(() => _focused = focused);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OiInputFrame(
      label: widget.label,
      hint: widget.hint,
      error: widget.error,
      focused: _focused,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      leading: widget.leading,
      trailing: widget.trailing,
      child: OiRawInput(
        controller: _controller,
        focusNode: _focusNode,
        placeholder: widget.placeholder,
        maxLines: widget.maxLines,
        maxLength: widget.maxLength,
        keyboardType: widget.keyboardType ?? TextInputType.text,
        textInputAction: widget.textInputAction ?? TextInputAction.done,
        onChanged: widget.onChanged,
        onEditingComplete: widget.onEditingComplete,
        onSubmitted: widget.onSubmitted,
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        obscureText: widget.obscureText,
        autofocus: widget.autofocus,
        inputFormatters: widget.inputFormatters,
      ),
    );
  }
}
