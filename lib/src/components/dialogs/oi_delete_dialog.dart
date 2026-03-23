import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/display/oi_file_icon.dart';
import 'package:obers_ui/src/components/display/oi_folder_icon.dart';
import 'package:obers_ui/src/components/inputs/oi_checkbox.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/oi_file_node_data.dart';

/// A confirmation dialog for deleting files/folders.
///
/// Shows what will be deleted, warns about folder contents, and has a
/// destructive action button.
///
/// {@category Components}
class OiDeleteDialog extends StatefulWidget {
  /// Creates an [OiDeleteDialog].
  const OiDeleteDialog({
    required this.files,
    required this.onDelete,
    this.onCancel,
    this.showDontAskAgain = false,
    this.onDontAskAgainChange,
    this.permanent = false,
    super.key,
  });

  /// Files/folders to be deleted.
  final List<OiFileNodeData> files;

  /// Called when the user confirms deletion.
  final VoidCallback onDelete;

  /// Called when the user cancels.
  final VoidCallback? onCancel;

  /// Whether to show the "Don't ask again" checkbox.
  final bool showDontAskAgain;

  /// Called when the "Don't ask again" checkbox changes.
  final ValueChanged<bool>? onDontAskAgainChange;

  /// Whether the deletion is permanent (not just trash).
  final bool permanent;

  @override
  State<OiDeleteDialog> createState() => _OiDeleteDialogState();
}

class _OiDeleteDialogState extends State<OiDeleteDialog> {
  bool _dontAskAgain = false;
  late final FocusNode _escapeFocusNode;

  @override
  void initState() {
    super.initState();
    _escapeFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _escapeFocusNode.dispose();
    super.dispose();
  }

  String get _title {
    if (widget.files.length == 1) {
      return 'Delete ${widget.files.first.name}?';
    }
    return 'Delete ${widget.files.length} items?';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Semantics(
      label: 'Delete confirmation dialog',
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
              // Title
              Text(
                _title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.text,
                ),
              ),
              SizedBox(height: spacing.md),
              // File list
              ...widget.files
                  .take(5)
                  .map(
                    (file) => Padding(
                      padding: EdgeInsets.only(bottom: spacing.xs),
                      child: Row(
                        children: [
                          if (file.isFolder)
                            const OiFolderIcon(size: OiFolderIconSize.sm)
                          else
                            OiFileIcon(
                              fileName: file.name,
                              size: OiFileIconSize.sm,
                            ),
                          SizedBox(width: spacing.sm),
                          Expanded(
                            child: Text(
                              file.name +
                                  (file.isFolder && file.itemCount != null
                                      ? ' (${file.itemCount} items inside)'
                                      : ''),
                              style: TextStyle(
                                fontSize: 13,
                                color: colors.text,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              if (widget.files.length > 5)
                Padding(
                  padding: EdgeInsets.only(bottom: spacing.xs),
                  child: Text(
                    'and ${widget.files.length - 5} more...',
                    style: TextStyle(fontSize: 12, color: colors.textMuted),
                  ),
                ),
              // Permanent warning
              if (widget.permanent) ...[
                SizedBox(height: spacing.sm),
                Row(
                  children: [
                    Icon(
                      OiIcons.circleAlert, // warning
                      size: 16,
                      color: colors.warning.base,
                    ),
                    SizedBox(width: spacing.xs),
                    Expanded(
                      child: Text(
                        'This action cannot be undone.',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.warning.base,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              // Don't ask again
              if (widget.showDontAskAgain) ...[
                SizedBox(height: spacing.md),
                GestureDetector(
                  onTap: () {
                    setState(() => _dontAskAgain = !_dontAskAgain);
                    widget.onDontAskAgainChange?.call(!_dontAskAgain);
                  },
                  child: Row(
                    children: [
                      OiCheckbox(
                        value: _dontAskAgain,
                        onChanged: (v) {
                          setState(() => _dontAskAgain = v);
                          widget.onDontAskAgainChange?.call(v);
                        },
                      ),
                      SizedBox(width: spacing.xs),
                      Text(
                        "Don't ask me again",
                        style: TextStyle(fontSize: 12, color: colors.text),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: spacing.lg),
              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OiButton.ghost(label: 'Cancel', onTap: widget.onCancel),
                  SizedBox(width: spacing.sm),
                  OiButton.destructive(label: 'Delete', onTap: widget.onDelete),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
