import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/display/oi_file_icon.dart';
import 'package:obers_ui/src/components/display/oi_folder_icon.dart';
import 'package:obers_ui/src/components/inputs/oi_checkbox.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/oi_file_node_data.dart';

/// The texts of an [OiDeleteDialog], in English by default; pass
/// translations to localize the dialog.
///
/// {@category Components}
class OiDeleteDialogLabels {
  /// Creates an [OiDeleteDialogLabels].
  const OiDeleteDialogLabels({
    this.deleteOne = englishDeleteOne,
    this.deleteMany = englishDeleteMany,
    this.itemsInside = englishItemsInside,
    this.andMore = englishAndMore,
    this.cannotBeUndone = 'This action cannot be undone.',
    this.dontAskAgain = "Don't ask me again",
    this.cancel = 'Cancel',
    this.delete = 'Delete',
    this.dialog = 'Delete confirmation dialog',
  });

  /// "Delete report.pdf?": the default [deleteOne].
  static String englishDeleteOne(String name) => 'Delete $name?';

  /// "Delete 3 items?": the default [deleteMany].
  static String englishDeleteMany(int count) => 'Delete $count items?';

  /// " (4 items inside)": the default [itemsInside].
  static String englishItemsInside(int count) => ' ($count items inside)';

  /// "and 2 more...": the default [andMore].
  static String englishAndMore(int count) => 'and $count more...';

  /// Title when a single file or folder, named by the argument, is deleted.
  final String Function(String name) deleteOne;

  /// Title when several files or folders, counted by the argument, are
  /// deleted.
  final String Function(int count) deleteMany;

  /// Appended to a folder's name to say how many items it holds.
  final String Function(int count) itemsInside;

  /// Shown below the list when more files are deleted than it shows.
  final String Function(int count) andMore;

  /// Warning shown when [OiDeleteDialog.permanent] is set.
  final String cannotBeUndone;

  /// Label of the checkbox shown when [OiDeleteDialog.showDontAskAgain] is
  /// set.
  final String dontAskAgain;

  /// Label of the cancel button.
  final String cancel;

  /// Label of the delete button.
  final String delete;

  /// Screen-reader label of the dialog.
  final String dialog;
}

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
    this.labels = const OiDeleteDialogLabels(),
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

  /// The dialog's texts; pass translations to localize it.
  final OiDeleteDialogLabels labels;

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
      return widget.labels.deleteOne(widget.files.first.name);
    }
    return widget.labels.deleteMany(widget.files.length);
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
                          if (file.folder)
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
                                  (file.folder && file.itemCount != null
                                      ? widget.labels.itemsInside(
                                          file.itemCount!,
                                        )
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
                    widget.labels.andMore(widget.files.length - 5),
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
                        widget.labels.cannotBeUndone,
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
                        widget.labels.dontAskAgain,
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
                  OiButton.ghost(
                    label: widget.labels.cancel,
                    onTap: widget.onCancel,
                  ),
                  SizedBox(width: spacing.sm),
                  OiButton.destructive(
                    label: widget.labels.delete,
                    onTap: widget.onDelete,
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
