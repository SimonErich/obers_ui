import 'dart:async';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
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

part 'oi_upload_dialog/oi_upload_dialog_interaction.part.dart';
part 'oi_upload_dialog/oi_upload_dialog_layout.part.dart';
part 'oi_upload_dialog/oi_upload_dialog_validation.part.dart';

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
  bool _isDragOver = false;
  bool _picking = false;

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

  void _updateState(VoidCallback update) {
    if (!mounted) return;
    setState(update);
  }

  @override
  Widget build(BuildContext context) {
    return _buildDialog(context);
  }
}

class _UploadEntry {
  _UploadEntry({required this.file, this.error});

  final OiFileData file;
  final String? error;
}
