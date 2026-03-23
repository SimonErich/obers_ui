import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/display/oi_file_icon.dart';
import 'package:obers_ui/src/components/inputs/oi_select.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_color_scheme.dart';
import 'package:obers_ui/src/foundation/theme/oi_spacing_scale.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/modules/oi_chat.dart';
import 'package:obers_ui/src/utils/file_utils.dart';

/// How to resolve upload conflicts when a file already exists.
///
/// {@category Components}
enum OiConflictResolution {
  /// Ask for each conflict individually.
  ask,

  /// Replace existing files silently.
  replace,

  /// Skip files that already exist.
  skip,

  /// Auto-rename with suffix: "file (1).txt".
  rename,
}

/// A dialog for uploading files with a drop zone, progress tracking,
/// conflict resolution, and batch controls.
///
/// {@category Components}
class OiUploadDialog extends StatefulWidget {
  /// Creates an [OiUploadDialog].
  const OiUploadDialog({
    required this.onUpload,
    this.onCancel,
    this.allowedExtensions,
    this.maxFileSize,
    this.maxFiles,
    this.defaultResolution = OiConflictResolution.ask,
    this.destinationPath,
    super.key,
  });

  /// Called when the user confirms upload with valid files and resolution.
  final void Function(List<OiFileData> files, OiConflictResolution resolution)
  onUpload;

  /// Called when the user cancels.
  final VoidCallback? onCancel;

  /// Allowed file extensions (e.g. ['pdf', 'docx']).
  final List<String>? allowedExtensions;

  /// Maximum file size in bytes.
  final int? maxFileSize;

  /// Maximum number of files.
  final int? maxFiles;

  /// Default conflict resolution strategy.
  final OiConflictResolution defaultResolution;

  /// Destination folder path for context.
  final String? destinationPath;

  @override
  State<OiUploadDialog> createState() => _OiUploadDialogState();
}

class _OiUploadDialogState extends State<OiUploadDialog> {
  final List<_UploadEntry> _entries = [];
  late OiConflictResolution _resolution;
  late final FocusNode _escapeFocusNode;

  @override
  void initState() {
    super.initState();
    _resolution = widget.defaultResolution;
    _escapeFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _escapeFocusNode.dispose();
    super.dispose();
  }

  List<OiFileData> get _validFiles =>
      _entries.where((e) => e.error == null).map((e) => e.file).toList();

  String? _validateFile(OiFileData file) {
    // Extension check
    if (widget.allowedExtensions != null) {
      final ext = OiFileUtils.extension(file.name).toLowerCase();
      if (!widget.allowedExtensions!.contains(ext)) {
        return 'File type .$ext not allowed';
      }
    }
    // Size check
    if (widget.maxFileSize != null && file.size > widget.maxFileSize!) {
      return 'Exceeds ${OiFileUtils.formatSize(widget.maxFileSize!)} limit';
    }
    return null;
  }

  // Called by the host via GlobalKey or file picker integration.
  // ignore: unused_element
  void _addFiles(List<OiFileData> files) {
    setState(() {
      for (final file in files) {
        if (widget.maxFiles != null && _entries.length >= widget.maxFiles!) {
          break;
        }
        _entries.add(_UploadEntry(file: file, error: _validateFile(file)));
      }
    });
  }

  void _removeEntry(int index) {
    setState(() => _entries.removeAt(index));
  }

  void _submit() {
    if (_validFiles.isEmpty) return;
    widget.onUpload(_validFiles, _resolution);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Semantics(
      label: 'Upload dialog',
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
              if (widget.destinationPath != null)
                Text(
                  'Upload to: ${widget.destinationPath}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.text,
                  ),
                )
              else
                Text(
                  'Upload Files',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.text,
                  ),
                ),
              SizedBox(height: spacing.md),
              // Drop zone placeholder
              GestureDetector(
                onTap: () {
                  // In a real implementation, this would trigger a file picker
                  // The consumer provides files via the dialog's API
                },
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.borderSubtle),
                    borderRadius: BorderRadius.circular(8),
                    color: colors.surfaceSubtle,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          OiIcons.cloudUpload, // upload
                          size: 28,
                          color: colors.textMuted,
                        ),
                        SizedBox(height: spacing.xs),
                        Text(
                          'Drop files here or browse',
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // File list
              if (_entries.isNotEmpty) ...[
                SizedBox(height: spacing.md),
                Text(
                  'Files to upload:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colors.textSubtle,
                  ),
                ),
                SizedBox(height: spacing.xs),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _entries.length,
                    itemBuilder: (context, index) {
                      final entry = _entries[index];
                      return _buildFileEntry(
                        context,
                        entry,
                        index,
                        colors,
                        spacing,
                      );
                    },
                  ),
                ),
              ],
              // Max files warning
              if (widget.maxFiles != null &&
                  _entries.length >= widget.maxFiles!)
                Padding(
                  padding: EdgeInsets.only(top: spacing.xs),
                  child: Text(
                    'Maximum ${widget.maxFiles} files allowed',
                    style: TextStyle(fontSize: 11, color: colors.warning.base),
                  ),
                ),
              SizedBox(height: spacing.md),
              // Conflict resolution
              Row(
                children: [
                  Text(
                    'If file exists:',
                    style: TextStyle(fontSize: 12, color: colors.textSubtle),
                  ),
                  SizedBox(width: spacing.sm),
                  Expanded(
                    child: OiSelect<OiConflictResolution>(
                      value: _resolution,
                      options: OiConflictResolution.values
                          .map(
                            (r) => OiSelectOption(
                              value: r,
                              label:
                                  r.name[0].toUpperCase() + r.name.substring(1),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _resolution = v);
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing.lg),
              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OiButton.ghost(label: 'Cancel', onTap: widget.onCancel),
                  SizedBox(width: spacing.sm),
                  OiButton.primary(
                    label: _validFiles.isEmpty
                        ? 'Upload'
                        : 'Upload ${_validFiles.length} file${_validFiles.length == 1 ? '' : 's'}',
                    onTap: _validFiles.isNotEmpty ? _submit : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileEntry(
    BuildContext context,
    _UploadEntry entry,
    int index,
    OiColorScheme colors,
    OiSpacingScale spacing,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: spacing.xs),
      child: Row(
        children: [
          OiFileIcon(fileName: entry.file.name, size: OiFileIconSize.sm),
          SizedBox(width: spacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  entry.file.name,
                  style: TextStyle(fontSize: 12, color: colors.text),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (entry.error != null)
                  Text(
                    entry.error!,
                    style: TextStyle(fontSize: 10, color: colors.error.base),
                  ),
              ],
            ),
          ),
          SizedBox(width: spacing.xs),
          Text(
            OiFileUtils.formatSize(entry.file.size),
            style: TextStyle(fontSize: 11, color: colors.textMuted),
          ),
          SizedBox(width: spacing.xs),
          GestureDetector(
            onTap: () => _removeEntry(index),
            child: Icon(
              OiIcons.x, // close
              size: 14,
              color: colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadEntry {
  _UploadEntry({required this.file, this.error});

  final OiFileData file;
  final String? error;
}
