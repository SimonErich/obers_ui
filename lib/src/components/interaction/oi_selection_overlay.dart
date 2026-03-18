import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// A rubber-band (lasso) selection overlay that lets users click-and-drag on
/// empty space to select multiple files by drawing a rectangle.
///
/// Items whose bounds intersect the rectangle get selected.
///
/// ```dart
/// OiSelectionOverlay(
///   onSelectionRect: (rect) => updateSelection(rect),
///   onSelectionStart: () => startSelection(),
///   onSelectionEnd: () => endSelection(),
///   child: fileListContent,
/// )
/// ```
///
/// {@category Components}
class OiSelectionOverlay extends StatefulWidget {
  /// Creates an [OiSelectionOverlay].
  const OiSelectionOverlay({
    required this.child,
    required this.onSelectionRect,
    required this.onSelectionStart,
    required this.onSelectionEnd,
    this.enabled = true,
    this.selectionColor,
    this.borderColor,
    super.key,
  });

  /// The child widget that contains selectable items.
  final Widget child;

  /// Fires continuously during drag with the current selection rectangle.
  final ValueChanged<Rect> onSelectionRect;

  /// Fires when the drag selection starts.
  final VoidCallback onSelectionStart;

  /// Fires when the drag selection ends.
  final VoidCallback onSelectionEnd;

  /// Whether selection is enabled.
  final bool enabled;

  /// Override the selection rectangle fill color.
  final Color? selectionColor;

  /// Override the selection rectangle border color.
  final Color? borderColor;

  @override
  State<OiSelectionOverlay> createState() => _OiSelectionOverlayState();
}

class _OiSelectionOverlayState extends State<OiSelectionOverlay> {
  Offset? _start;
  Offset? _current;
  bool _selecting = false;

  Rect? get _selectionRect {
    if (_start == null || _current == null) return null;
    return Rect.fromPoints(_start!, _current!);
  }

  void _onPanStart(DragStartDetails details) {
    if (!widget.enabled) return;
    setState(() {
      _start = details.localPosition;
      _current = details.localPosition;
      _selecting = true;
    });
    widget.onSelectionStart();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_selecting) return;
    setState(() {
      _current = details.localPosition;
    });
    final rect = _selectionRect;
    if (rect != null) {
      widget.onSelectionRect(rect);
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_selecting) return;
    setState(() {
      _selecting = false;
      _start = null;
      _current = null;
    });
    widget.onSelectionEnd();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fillColor = widget.selectionColor ??
        colors.primary.muted.withValues(alpha: 0.2);
    final stroke =
        widget.borderColor ?? colors.primary.base;

    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: [
          widget.child,
          if (_selecting && _selectionRect != null)
            Positioned(
              left: _selectionRect!.left,
              top: _selectionRect!.top,
              width: _selectionRect!.width,
              height: _selectionRect!.height,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    color: fillColor,
                    border: Border.all(color: stroke, width: 1),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
