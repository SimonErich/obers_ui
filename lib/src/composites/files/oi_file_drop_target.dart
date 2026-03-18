import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/display/oi_drop_highlight.dart';
import 'package:obers_ui/src/models/oi_file_node_data.dart';
import 'package:obers_ui/src/modules/oi_chat.dart';
import 'package:obers_ui/src/primitives/drag_drop/oi_drop_zone.dart';

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
  final void Function(
      List<OiFileNodeData> files, OiFileNodeData? targetFolder) onInternalDrop;

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
  bool _isDragOver = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return OiDropZone<List<OiFileNodeData>>(
      onWillAccept: (_) => widget.enabled,
      onAccept: (files) {
        setState(() => _isDragOver = false);
        widget.onInternalDrop(files, null);
      },
      builder: (context, state) {
        final isHovering = state == OiDropState.hovering;
        if (isHovering != _isDragOver) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _isDragOver = isHovering);
          });
        }

        return OiDropHighlight(
          active: _isDragOver,
          style: OiDropHighlightStyle.area,
          message: widget.dropMessage ?? 'Drop files here',
          icon: const IconData(0xe9e4, fontFamily: 'MaterialIcons'), // upload
          child: widget.child,
        );
      },
    );
  }
}
