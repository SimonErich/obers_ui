import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/inline_edit/oi_editable.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/foundation/theme/oi_text_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

/// An inline-editable text field that toggles between a label display and
/// a text input.
///
/// In display mode a [OiLabel] renders [value] with an optional hover
/// underline on pointer devices. Tapping (or calling `startEdit`) switches
/// to edit mode which shows an auto-focused [OiTextInput]. Pressing Enter or
/// losing focus commits the edit; pressing Escape cancels.
///
/// {@category Components}
class OiEditableText extends StatelessWidget {
  /// Creates an [OiEditableText].
  const OiEditableText({
    required this.value,
    this.onChanged,
    this.enabled = true,
    this.variant = OiLabelVariant.body,
    this.style,
    super.key,
  });

  /// The current text value.
  final String value;

  /// Called when the user commits a new value.
  final ValueChanged<String>? onChanged;

  /// Whether editing is enabled.
  final bool enabled;

  /// The typographic variant used to display the text in read-only mode.
  final OiLabelVariant variant;

  /// An optional [TextStyle] override applied on top of the theme style.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return OiEditable<String>(
      value: value,
      onChanged: onChanged,
      enabled: enabled,
      displayBuilder: (ctx, v, startEdit) {
        final colors = ctx.colors;
        final effectiveStyle = style ??
            TextStyle(fontSize: 14, color: colors.text);
        return OiTappable(
          onTap: enabled ? startEdit : null,
          enabled: enabled,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Text(v.isEmpty ? ' ' : v, style: effectiveStyle),
          ),
        );
      },
      editBuilder: (ctx, v, commit, cancel) {
        return _EditingTextField(
          initialValue: v,
          style: style,
          onCommit: commit,
          onCancel: cancel,
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Edit helper — auto-focused text field
// ---------------------------------------------------------------------------

class _EditingTextField extends StatefulWidget {
  const _EditingTextField({
    required this.initialValue,
    required this.onCommit,
    required this.onCancel,
    this.style,
  });

  final String initialValue;
  final TextStyle? style;
  final void Function(String) onCommit;
  final VoidCallback onCancel;

  @override
  State<_EditingTextField> createState() => _EditingTextFieldState();
}

class _EditingTextFieldState extends State<_EditingTextField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      widget.onCommit(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OiTextInput(
      controller: _controller,
      focusNode: _focusNode,
      autofocus: true,
      onSubmitted: widget.onCommit,
      onEditingComplete: () => widget.onCommit(_controller.text),
    );
  }
}
