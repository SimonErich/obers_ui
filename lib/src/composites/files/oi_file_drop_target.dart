import 'dart:async';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/display/oi_drop_highlight.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/models/oi_file_node_data.dart';
import 'package:obers_ui/src/modules/oi_chat.dart';
import 'package:obers_ui/src/primitives/drag_drop/oi_drop_zone.dart';
import 'package:obers_ui/src/utils/file_utils.dart';

/// A wrapper composite that makes the entire content area a drop target for
/// both internal file moves and external OS-level file drops.
///
/// Shows [OiDropHighlight] overlay when files are dragged over.
///
/// {@category Composites}
class OiFileDropTarget extends StatefulWidget {
  /// Creates an [OiFileDropTarget].
  const OiFileDropTarget({
    required this.child,
    required this.onInternalDrop,
    required this.onExternalDrop,
    this.enabled = true,
    this.dropMessage,
    super.key,
  });

  /// The child widget.
  final Widget child;

  /// Called when files are dropped internally (from sidebar or content area).
  final void Function(List<OiFileNodeData> files, OiFileNodeData? targetFolder)
  onInternalDrop;

  /// Called when files are dropped from the OS.
  final ValueChanged<List<OiFileData>> onExternalDrop;

  /// Whether drop is enabled.
  final bool enabled;

  /// Custom message to show in the drop highlight.
  final String? dropMessage;

  @override
  State<OiFileDropTarget> createState() => _OiFileDropTargetState();
}

class _OiFileDropTargetState extends State<OiFileDropTarget> {
  bool _isInternalDragOver = false;
  bool _isExternalDragOver = false;

  bool get _isDragOver => _isInternalDragOver || _isExternalDragOver;

  Future<void> _handleExternalDrop(DropDoneDetails details) async {
    final files = <OiFileData>[];
    for (final item in details.files) {
      // Skip directories.
      if (item is DropItemDirectory) continue;
      try {
        final bytes = await item.readAsBytes();
        files.add(
          OiFileData(
            name: item.name,
            size: bytes.length,
            bytes: bytes,
            mimeType:
                item.mimeType ??
                OiFileUtils.mimeType(OiFileUtils.extension(item.name)),
          ),
        );
      } on Exception {
        // Skip files that cannot be read (e.g. sandbox restrictions).
        continue;
      }
    }
    if (files.isNotEmpty) widget.onExternalDrop(files);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    // Wrap with desktop_drop for OS-level file drops, then with
    // OiDropZone for in-app Flutter DragTarget drops.
    return DropTarget(
      onDragEntered: (_) => setState(() => _isExternalDragOver = true),
      onDragExited: (_) => setState(() => _isExternalDragOver = false),
      onDragDone: (details) {
        setState(() => _isExternalDragOver = false);
        unawaited(_handleExternalDrop(details));
      },
      child: OiDropZone<List<OiFileNodeData>>(
        onWillAccept: (_) => widget.enabled,
        onAccept: (files) {
          setState(() => _isInternalDragOver = false);
          widget.onInternalDrop(files, null);
        },
        builder: (context, state) {
          final isHovering = state == OiDropState.hovering;
          if (isHovering != _isInternalDragOver) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _isInternalDragOver = isHovering);
            });
          }

          return OiDropHighlight(
            active: _isDragOver,
            message: widget.dropMessage ?? 'Drop files here',
            icon: OiIcons.cloudUpload,
            child: widget.child,
          );
        },
      ),
    );
  }
}
