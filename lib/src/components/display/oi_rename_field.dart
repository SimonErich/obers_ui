import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// Illegal characters in file/folder names.
const _illegalChars = <String>['/', r'\', ':', '*', '?', '"', '<', '>', '|'];

/// A specialized inline text input for renaming files/folders.
///
/// Auto-selects the filename (without extension) on mount, validates against
/// illegal characters, and fires save/cancel callbacks.
///
/// ```dart
/// OiRenameField(
///   currentName: 'report.pdf',
///   onRename: (name) => rename(name),
///   onCancel: () => cancel(),
/// )
/// ```
///
/// {@category Components}
class OiRenameField extends StatefulWidget {
  /// Creates an [OiRenameField].
  const OiRenameField({
    required this.currentName,
    required this.onRename,
    required this.onCancel,
    this.isFolder = false,
    this.validate,
    this.showButtons = false,
    this.semanticsLabel,
    super.key,
  });

  /// The current file/folder name.
  final String currentName;

  /// Called with the new name when the user confirms.
  final ValueChanged<String> onRename;

  /// Called when the user cancels renaming.
  final VoidCallback onCancel;

  /// Whether renaming a folder (selects entire name instead of name-only).
  final bool isFolder;

  /// Custom validation function. Return an error string or null.
  final String? Function(String)? validate;

  /// Whether to show confirm/cancel buttons.
  final bool showButtons;

  /// Accessibility label.
  final String? semanticsLabel;

  @override
  State<OiRenameField> createState() => _OiRenameFieldState();
}

class _OiRenameFieldState extends State<OiRenameField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentName);
    _focusNode = FocusNode();

    // Auto-select the name part (without extension) on mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _selectNamePart();
    });
  }

  void _selectNamePart() {
    final text = _controller.text;
    if (widget.isFolder) {
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: text.length,
      );
    } else {
      final dotIndex = text.lastIndexOf('.');
      if (dotIndex > 0) {
        _controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: dotIndex,
        );
      } else {
        _controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: text.length,
        );
      }
    }
  }

  String? _validate(String value) {
    if (value.trim().isEmpty) return 'Name cannot be empty';
    for (final char in _illegalChars) {
      if (value.contains(char)) return 'Name cannot contain "$char"';
    }
    return widget.validate?.call(value);
  }

  void _submit() {
    final name = _controller.text.trim();
    final error = _validate(name);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    widget.onRename(name);
  }

  void _cancel() {
    widget.onCancel();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      label: widget.semanticsLabel ?? 'Rename file',
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.escape) {
              _cancel();
            } else if (event.logicalKey == LogicalKeyboardKey.enter) {
              _submit();
            }
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OiTextInput(
                    controller: _controller,
                    focusNode: _focusNode,
                    autofocus: true,
                    onSubmitted: (_) => _submit(),
                    onChanged: (value) {
                      if (_error != null) {
                        setState(() => _error = _validate(value));
                      }
                    },
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        _error!,
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.error.base,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (widget.showButtons) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: _submit,
                child: Icon(
                  OiIcons.check, // check
                  size: 18,
                  color: colors.success.base,
                ),
              ),
              const SizedBox(width: 2),
              GestureDetector(
                onTap: _cancel,
                child: Icon(
                  OiIcons.xMark, // close
                  size: 18,
                  color: colors.error.base,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
