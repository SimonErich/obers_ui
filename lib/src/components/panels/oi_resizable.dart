import 'package:flutter/widgets.dart';

/// Edges on which an [OiResizable] panel can be resized by dragging.
///
/// {@category Components}
enum OiResizeEdge {
  /// The top edge.
  top,

  /// The bottom edge.
  bottom,

  /// The left edge.
  left,

  /// The right edge.
  right,

  /// The top-left corner.
  topLeft,

  /// The top-right corner.
  topRight,

  /// The bottom-left corner.
  bottomLeft,

  /// The bottom-right corner.
  bottomRight,
}

/// A widget that lets the user resize [child] by dragging its edges or corners.
///
/// The set of draggable [resizeEdges] controls which handles are active.
/// [minWidth], [maxWidth], [minHeight], and [maxHeight] clamp the dimensions.
/// [initialWidth] and [initialHeight] set the starting size; when null the
/// panel sizes to its content.
///
/// [onResized] is called whenever the size changes.
///
/// Each handle is a thin transparent strip (or square for corners) overlaid
/// on the appropriate edge. Mouse cursors update to resize cursors on hover.
///
/// {@category Components}
class OiResizable extends StatefulWidget {
  /// Creates an [OiResizable].
  const OiResizable({
    required this.child,
    this.resizeEdges = const {
      OiResizeEdge.right,
      OiResizeEdge.bottom,
      OiResizeEdge.bottomRight,
    },
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
    this.initialWidth,
    this.initialHeight,
    this.onResized,
    this.handleSize = 8,
    super.key,
  });

  /// The widget to render inside the resizable container.
  final Widget child;

  /// The set of edges / corners that support drag-to-resize.
  final Set<OiResizeEdge> resizeEdges;

  /// Minimum allowed width in logical pixels.
  final double? minWidth;

  /// Maximum allowed width in logical pixels.
  final double? maxWidth;

  /// Minimum allowed height in logical pixels.
  final double? minHeight;

  /// Maximum allowed height in logical pixels.
  final double? maxHeight;

  /// Initial width in logical pixels. Defaults to content size when null.
  final double? initialWidth;

  /// Initial height in logical pixels. Defaults to content size when null.
  final double? initialHeight;

  /// Called with the new (width, height) whenever the panel is resized.
  final void Function(double width, double height)? onResized;

  /// The hit-area width of each resize handle in logical pixels. Defaults to 8.
  final double handleSize;

  @override
  State<OiResizable> createState() => _OiResizableState();
}

class _OiResizableState extends State<OiResizable> {
  double? _width;
  double? _height;

  @override
  void initState() {
    super.initState();
    _width = widget.initialWidth;
    _height = widget.initialHeight;
  }

  double _clampW(double v) {
    var w = v;
    if (widget.minWidth != null) w = w.clamp(widget.minWidth!, double.infinity);
    if (widget.maxWidth != null) w = w.clamp(0, widget.maxWidth!);
    return w;
  }

  double _clampH(double v) {
    var h = v;
    if (widget.minHeight != null) {
      h = h.clamp(widget.minHeight!, double.infinity);
    }
    if (widget.maxHeight != null) h = h.clamp(0, widget.maxHeight!);
    return h;
  }

  void _onDrag(OiResizeEdge edge, DragUpdateDetails d) {
    setState(() {
      final dx = d.delta.dx;
      final dy = d.delta.dy;
      final curW = _width ?? 0;
      final curH = _height ?? 0;

      switch (edge) {
        case OiResizeEdge.right:
          _width = _clampW(curW + dx);
        case OiResizeEdge.left:
          _width = _clampW(curW - dx);
        case OiResizeEdge.bottom:
          _height = _clampH(curH + dy);
        case OiResizeEdge.top:
          _height = _clampH(curH - dy);
        case OiResizeEdge.bottomRight:
          _width = _clampW(curW + dx);
          _height = _clampH(curH + dy);
        case OiResizeEdge.bottomLeft:
          _width = _clampW(curW - dx);
          _height = _clampH(curH + dy);
        case OiResizeEdge.topRight:
          _width = _clampW(curW + dx);
          _height = _clampH(curH - dy);
        case OiResizeEdge.topLeft:
          _width = _clampW(curW - dx);
          _height = _clampH(curH - dy);
      }
    });
    if (_width != null || _height != null) {
      widget.onResized?.call(_width ?? 0, _height ?? 0);
    }
  }

  MouseCursor _cursorFor(OiResizeEdge edge) {
    switch (edge) {
      case OiResizeEdge.left:
      case OiResizeEdge.right:
        return SystemMouseCursors.resizeColumn;
      case OiResizeEdge.top:
      case OiResizeEdge.bottom:
        return SystemMouseCursors.resizeRow;
      case OiResizeEdge.topLeft:
      case OiResizeEdge.bottomRight:
        return SystemMouseCursors.resizeUpLeftDownRight;
      case OiResizeEdge.topRight:
      case OiResizeEdge.bottomLeft:
        return SystemMouseCursors.resizeUpRightDownLeft;
    }
  }

  Widget _handle(OiResizeEdge edge) {
    final s = widget.handleSize;
    final cursor = _cursorFor(edge);

    // Position values — null means "flush to the opposite edge" (Positioned
    // defaults) which we override per edge.
    double? top;
    double? bottom;
    double? left;
    double? right;
    double? width;
    double? height;

    switch (edge) {
      case OiResizeEdge.right:
        right = 0;
        top = s;
        bottom = s;
        width = s;
      case OiResizeEdge.left:
        left = 0;
        top = s;
        bottom = s;
        width = s;
      case OiResizeEdge.bottom:
        bottom = 0;
        left = s;
        right = s;
        height = s;
      case OiResizeEdge.top:
        top = 0;
        left = s;
        right = s;
        height = s;
      case OiResizeEdge.bottomRight:
        right = 0;
        bottom = 0;
        width = s;
        height = s;
      case OiResizeEdge.bottomLeft:
        left = 0;
        bottom = 0;
        width = s;
        height = s;
      case OiResizeEdge.topRight:
        right = 0;
        top = 0;
        width = s;
        height = s;
      case OiResizeEdge.topLeft:
        left = 0;
        top = 0;
        width = s;
        height = s;
    }

    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      width: width,
      height: height,
      child: MouseRegion(
        cursor: cursor,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanUpdate: (d) => _onDrag(edge, d),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ignore: omit_local_variable_types — reassigned conditionally below
    Widget content = widget.child;
    if (_width != null || _height != null) {
      content = SizedBox(width: _width, height: _height, child: content);
    }

    final handles = widget.resizeEdges.map(_handle).toList();

    return Stack(
      clipBehavior: Clip.none,
      children: [content, ...handles],
    );
  }
}
