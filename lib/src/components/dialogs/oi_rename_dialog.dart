import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/display/oi_file_icon.dart';
import 'package:obers_ui/src/components/display/oi_folder_icon.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/oi_file_node_data.dart';
import 'package:obers_ui/src/utils/file_utils.dart';

/// The texts of an [OiRenameDialog], in English by default; pass
/// translations to localize the dialog.
///
/// {@category Components}
class OiRenameDialogLabels {
  /// Creates an [OiRenameDialogLabels].
  const OiRenameDialogLabels({
    this.title = 'Rename',
    this.nameEmpty = 'Name cannot be empty',
    this.nameInvalidCharacter = englishNameInvalidCharacter,
    this.cancel = 'Cancel',
    this.rename = 'Rename',
    this.dialog = 'Rename dialog',
  });

  /// 'Name cannot contain "/"': the default [nameInvalidCharacter].
  static String englishNameInvalidCharacter(String character) =>
      'Name cannot contain "$character"';

  /// Title of the dialog.
  final String title;

  /// Error shown when the name is empty.
  final String nameEmpty;

  /// Error shown when the name contains a character that is not allowed.
  final String Function(String character) nameInvalidCharacter;

  /// Label of the cancel button.
  final String cancel;

  /// Label of the rename button.
  final String rename;

  /// Screen-reader label of the dialog.
  final String dialog;
}

/// A dialog for renaming a file or folder.
///
/// Pre-fills the current name with the filename portion selected (not extension).
///
/// {@category Components}
class OiRenameDialog extends StatefulWidget {
  /// Creates an [OiRenameDialog].
  const OiRenameDialog({
    required this.file,
    required this.onRename,
    this.onCancel,
    this.validate,
    this.labels = const OiRenameDialogLabels(),
    super.key,
  });

  /// The file/folder being renamed.
  final OiFileNodeData file;

  /// Called with the new name when the user confirms.
  final ValueChanged<String> onRename;

  /// Called when the user cancels.
  final VoidCallback? onCancel;

  /// Custom validation. Return an error string or null.
  final String? Function(String)? validate;

  /// The dialog's texts; pass translations to localize it.
  final OiRenameDialogLabels labels;

  @override
  State<OiRenameDialog> createState() => _OiRenameDialogState();
}

class _OiRenameDialogState extends State<OiRenameDialog> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late final FocusNode _escapeFocusNode;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.file.name);
    _focusNode = FocusNode();
    _escapeFocusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _selectNamePart();
    });
  }

  void _selectNamePart() {
    final text = _controller.text;
    if (widget.file.folder) {
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

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _escapeFocusNode.dispose();
    super.dispose();
  }

  String? _validate(String value) {
    if (value.trim().isEmpty) return widget.labels.nameEmpty;
    for (final char in OiFileUtils.illegalNameChars) {
      if (value.contains(char)) return widget.labels.nameInvalidCharacter(char);
    }
    return widget.validate?.call(value);
  }

  bool get _isValid =>
      _validate(_controller.text) == null &&
      _controller.text != widget.file.name;

  void _submit() {
    final name = _controller.text.trim();
    final error = _validate(name);
    if (error != null || name == widget.file.name) {
      setState(() => _error = error);
      return;
    }
    widget.onRename(name);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Semantics(
      label: widget.labels.dialog,
      child: KeyboardListener(
        focusNode: _escapeFocusNode,
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
              // Header with file icon
              Row(
                children: [
                  if (widget.file.folder)
                    const OiFolderIcon()
                  else
                    OiFileIcon(
                      fileName: widget.file.name,
                      mimeType: widget.file.mimeType,
                    ),
                  SizedBox(width: spacing.sm),
                  Text(
                    widget.labels.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors.text,
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing.md),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OiButton.ghost(
                    label: widget.labels.cancel,
                    onTap: widget.onCancel,
                  ),
                  SizedBox(width: spacing.sm),
                  OiButton.primary(
                    label: widget.labels.rename,
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
