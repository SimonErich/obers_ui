import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/display/oi_folder_icon.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/utils/file_utils.dart';

/// The texts of an [OiNewFolderDialog], in English by default; pass
/// translations to localize the dialog.
///
/// {@category Components}
class OiNewFolderDialogLabels {
  /// Creates an [OiNewFolderDialogLabels].
  const OiNewFolderDialogLabels({
    this.title = 'New Folder',
    this.parent = englishParent,
    this.folderName = 'Folder name',
    this.nameEmpty = 'Name cannot be empty',
    this.nameInvalidCharacter = englishNameInvalidCharacter,
    this.cancel = 'Cancel',
    this.create = 'Create',
    this.dialog = 'New folder dialog',
  });

  /// "Parent: Documents": the default [parent].
  static String englishParent(String folder) => 'Parent: $folder';

  /// 'Name cannot contain "/"': the default [nameInvalidCharacter].
  static String englishNameInvalidCharacter(String character) =>
      'Name cannot contain "$character"';

  /// Title of the dialog.
  final String title;

  /// Names the parent folder, shown when
  /// [OiNewFolderDialog.parentFolderName] is set.
  final String Function(String folder) parent;

  /// Label of the name input.
  final String folderName;

  /// Error shown when the name is empty.
  final String nameEmpty;

  /// Error shown when the name contains a character that is not allowed.
  final String Function(String character) nameInvalidCharacter;

  /// Label of the cancel button.
  final String cancel;

  /// Label of the create button.
  final String create;

  /// Screen-reader label of the dialog.
  final String dialog;
}

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
    this.labels = const OiNewFolderDialogLabels(),
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

  /// The dialog's texts; pass translations to localize it.
  final OiNewFolderDialogLabels labels;

  @override
  State<OiNewFolderDialog> createState() => _OiNewFolderDialogState();
}

class _OiNewFolderDialogState extends State<OiNewFolderDialog> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late final FocusNode _escapeFocusNode;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.defaultName);
    _focusNode = FocusNode();
    _escapeFocusNode = FocusNode();
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
              // Header
              Row(
                children: [
                  const OiFolderIcon(),
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
              if (widget.parentFolderName != null) ...[
                SizedBox(height: spacing.sm),
                Text(
                  widget.labels.parent(widget.parentFolderName!),
                  style: TextStyle(fontSize: 12, color: colors.textMuted),
                ),
              ],
              SizedBox(height: spacing.md),
              // Input
              Text(
                widget.labels.folderName,
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
                    label: widget.labels.cancel,
                    onTap: widget.onCancel,
                  ),
                  SizedBox(width: spacing.sm),
                  OiButton.primary(
                    label: widget.labels.create,
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
