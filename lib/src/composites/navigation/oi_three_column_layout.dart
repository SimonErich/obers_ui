import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// A configurable three-column layout with resizable dividers.
///
/// Used by IDE-style interfaces with a navigation sidebar (left),
/// main content area (middle), and optional detail/preview panel (right).
///
/// The left and right columns can be resized by dragging the thin vertical
/// dividers between them. Column widths are clamped to the configured
/// minimum and maximum values during drags.
///
/// {@category Composites}
class OiThreeColumnLayout extends StatefulWidget {
  /// Creates an [OiThreeColumnLayout].
  const OiThreeColumnLayout({
    required this.leftColumn,
    required this.middleColumn,
    required this.label,
    this.leftColumnWidth = 260,
    this.leftColumnMinWidth = 200,
    this.leftColumnMaxWidth = 400,
    this.rightColumn,
    this.rightColumnWidth = 320,
    this.rightColumnMinWidth = 250,
    this.rightColumnMaxWidth = 500,
    this.showRightColumn = true,
    this.resizable = true,
    this.onColumnWidthChanged,
    this.equalMiddleSplit = false,
    this.middleLeftColumn,
    this.middleRightColumn,
    super.key,
  });

  /// The widget displayed in the left column (navigation sidebar).
  final Widget leftColumn;

  /// The widget displayed in the middle column (main content area).
  final Widget middleColumn;

  /// The semantic label for accessibility.
  final String label;

  /// The initial width of the left column in logical pixels.
  final double leftColumnWidth;

  /// The minimum width the left column can be resized to.
  final double leftColumnMinWidth;

  /// The maximum width the left column can be resized to.
  final double leftColumnMaxWidth;

  /// The widget displayed in the right column (detail/preview panel).
  ///
  /// When `null`, the right column is not rendered regardless of
  /// [showRightColumn].
  final Widget? rightColumn;

  /// The initial width of the right column in logical pixels.
  final double rightColumnWidth;

  /// The minimum width the right column can be resized to.
  final double rightColumnMinWidth;

  /// The maximum width the right column can be resized to.
  final double rightColumnMaxWidth;

  /// Whether the right column is visible.
  ///
  /// When `false` or when [rightColumn] is `null`, only the left and middle
  /// columns are displayed.
  final bool showRightColumn;

  /// Whether the dividers between columns are draggable.
  ///
  /// When `false` the columns are fixed at their initial widths.
  final bool resizable;

  /// Called whenever the left or right column width changes due to a drag.
  ///
  /// Receives the new left width and the new right width so the parent can
  /// persist them (e.g. via OiSettingsDriver).
  final void Function(double leftWidth, double rightWidth)?
  onColumnWidthChanged;

  /// When `true`, the middle area is split into two equal columns using
  /// [middleLeftColumn] and [middleRightColumn] instead of [middleColumn].
  final bool equalMiddleSplit;

  /// Left half of the middle area when [equalMiddleSplit] is `true`.
  final Widget? middleLeftColumn;

  /// Right half of the middle area when [equalMiddleSplit] is `true`.
  final Widget? middleRightColumn;

  @override
  State<OiThreeColumnLayout> createState() => _OiThreeColumnLayoutState();
}

class _OiThreeColumnLayoutState extends State<OiThreeColumnLayout> {
  late double _leftWidth;
  late double _rightWidth;

  @override
  void initState() {
    super.initState();
    _leftWidth = widget.leftColumnWidth;
    _rightWidth = widget.rightColumnWidth;
  }

  void _onLeftDividerDrag(DragUpdateDetails details) {
    setState(() {
      _leftWidth = (_leftWidth + details.delta.dx).clamp(
        widget.leftColumnMinWidth,
        widget.leftColumnMaxWidth,
      );
    });
    widget.onColumnWidthChanged?.call(_leftWidth, _rightWidth);
  }

  void _onRightDividerDrag(DragUpdateDetails details) {
    setState(() {
      // Dragging right makes the right column narrower,
      // dragging left makes it wider.
      _rightWidth = (_rightWidth - details.delta.dx).clamp(
        widget.rightColumnMinWidth,
        widget.rightColumnMaxWidth,
      );
    });
    widget.onColumnWidthChanged?.call(_leftWidth, _rightWidth);
  }

  bool get _showRight => widget.showRightColumn && widget.rightColumn != null;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const dividerWidth = 2.0;

    Widget buildDivider({required GestureDragUpdateCallback onDrag}) {
      return MouseRegion(
        cursor: widget.resizable
            ? SystemMouseCursors.resizeColumn
            : MouseCursor.defer,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: widget.resizable ? onDrag : null,
          child: SizedBox(
            width: dividerWidth,
            child: DecoratedBox(
              decoration: BoxDecoration(color: colors.borderSubtle),
            ),
          ),
        ),
      );
    }

    return Semantics(
      label: widget.label,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left column
          SizedBox(width: _leftWidth, child: widget.leftColumn),

          // Left divider
          buildDivider(onDrag: _onLeftDividerDrag),

          // Middle column (takes remaining space).
          // When equalMiddleSplit is true, split into two equal halves.
          if (widget.equalMiddleSplit &&
              widget.middleLeftColumn != null &&
              widget.middleRightColumn != null)
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: widget.middleLeftColumn!),
                  buildDivider(onDrag: (_) {}),
                  Expanded(child: widget.middleRightColumn!),
                ],
              ),
            )
          else
            Expanded(child: widget.middleColumn),

          // Right divider + right column
          if (_showRight) ...[
            buildDivider(onDrag: _onRightDividerDrag),
            SizedBox(width: _rightWidth, child: widget.rightColumn),
          ],
        ],
      ),
    );
  }
}
