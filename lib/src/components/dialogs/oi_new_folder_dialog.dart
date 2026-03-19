import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/display/oi_folder_icon.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

const _illegalChars = <String>['/', r'\', ':', '*', '?', '"', '<', '>', '|'];

/// A dialog for creating a new folder.
///
/// Contains a single text input for the folder name with validation.
///
/// {@category Components}
class OiNewFolderDialog extends StatefulWidget {
  /// Creates an [OiNewFolderDialog].
  const OiNewFolderDialog({
    required this.onCreate,
    this.onCancel,
    this.defaultName = 'New Folder',
    this.validate,
    this.parentFolderName,
    super.key,
  });

  /// Called with the folder name when the user confirms.
  final ValueChanged<String> onCreate;

  /// Called when the user cancels.
  final VoidCallback? onCancel;

  /// Default name pre-filled in the input.
  final String defaultName;

  /// Custom validation. Return an error string or null.
  final String? Function(String)? validate;

  /// Optional parent folder name for context.
  final String? parentFolderName;

  @override
  State<OiNewFolderDialog> createState() => _OiNewFolderDialogState();
}

class _OiNewFolderDialogState extends State<OiNewFolderDialog> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.defaultName);
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
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

  String? _validate(String value) {
    if (value.trim().isEmpty) return 'Name cannot be empty';
    for (final char in _illegalChars) {
      if (value.contains(char)) return 'Name cannot contain "$char"';
    }
    return widget.validate?.call(value);
  }

  bool get _isValid => _validate(_controller.text) == null;

  void _submit() {
    final name = _controller.text.trim();
    final error = _validate(name);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    widget.onCreate(name);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Semantics(
      label: 'New folder dialog',
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.escape) {
            widget.onCancel?.call();
          }
        },
        child: Padding(
          padding: EdgeInsets.all(spacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const OiFolderIcon(),
                  SizedBox(width: spacing.sm),
                  Text(
                    'New Folder',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors.text,
                    ),
                  ),
                ],
              ),
              if (widget.parentFolderName != null) ...[
                SizedBox(height: spacing.sm),
                Text(
                  'Parent: ${widget.parentFolderName}',
                  style: TextStyle(fontSize: 12, color: colors.textMuted),
                ),
              ],
              SizedBox(height: spacing.md),
              // Input
              Text(
                'Folder name',
                style: TextStyle(fontSize: 12, color: colors.textSubtle),
              ),
              SizedBox(height: spacing.xs),
              OiTextInput(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: true,
                onSubmitted: (_) => _submit(),
                onChanged: (value) {
                  setState(() => _error = _validate(value));
                },
              ),
              if (_error != null)
                Padding(
                  padding: EdgeInsets.only(top: spacing.xs),
                  child: Text(
                    _error!,
                    style: TextStyle(fontSize: 11, color: colors.error.base),
                  ),
                ),
              SizedBox(height: spacing.lg),
              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OiButton.ghost(
                    label: 'Cancel',
                    onTap: widget.onCancel,
                  ),
                  SizedBox(width: spacing.sm),
                  OiButton.primary(
                    label: 'Create',
                    onTap: _isValid ? _submit : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
