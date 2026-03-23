import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_overlays.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_focus_trap.dart';

/// The side from which an [OiSheet] slides in.
///
/// {@category Components}
enum OiPanelSide {
  /// Slides in from the top edge.
  top,

  /// Slides in from the bottom edge.
  bottom,

  /// Slides in from the left edge.
  left,

  /// Slides in from the right edge.
  right,
}

/// A slide-in sheet panel that animates from a specified [side].
///
/// When [open] is `true`, the sheet slides into view; when `false` it slides
/// back off screen. A semi-transparent scrim is placed behind the sheet; when
/// [dismissible] is `true`, tapping the scrim calls [onClose].
///
/// [OiFocusTrap] keeps keyboard focus inside the sheet while it is open.
/// When [dragHandle] is `true` a pill-shaped handle is rendered along the
/// near edge of the panel.
///
/// [snapPoints] accepts a list of fractions (0.0–1.0) relative to the
/// relevant screen dimension. A drag gesture snaps to the nearest snap point;
/// dragging past the smallest snap point closes the sheet.
///
/// Use [OiSheet.show] to push a sheet into the overlay stack.
///
/// {@category Components}
class OiSheet extends StatefulWidget {
  /// Creates an [OiSheet].
  const OiSheet({
    required this.label,
    required this.child,
    required this.open,
    this.onClose,
    this.side = OiPanelSide.bottom,
    this.size,
    this.dismissible = true,
    this.dragHandle = false,
    this.snapPoints,
    super.key,
  });

  /// Accessible label describing the sheet for screen readers.
  final String label;

  /// The content displayed inside the sheet.
  final Widget child;

  /// Whether the sheet is currently open.
  final bool open;

  /// Called when the sheet should close (scrim tap or drag-dismiss).
  final VoidCallback? onClose;

  /// The side from which the sheet slides in. Defaults to [OiPanelSide.bottom].
  final OiPanelSide side;

  /// Fixed height (for top/bottom sheets) or width (for left/right sheets) in
  /// logical pixels. When null, the sheet sizes itself to its content.
  final double? size;

  /// Whether tapping the scrim dismisses the sheet. Defaults to `true`.
  final bool dismissible;

  /// Whether a pill-shaped drag handle is shown on the near edge.
  final bool dragHandle;

  /// Optional list of snap-point fractions (e.g. `[0.3, 0.7, 1.0]`).
  ///
  /// The sheet snaps to the nearest fraction of the screen dimension after
  /// a drag ends. Dragging past the lowest snap point closes the sheet.
  final List<double>? snapPoints;

  /// Shows a sheet above the current widget tree.
  ///
  /// Uses [OiOverlays.of] when available; otherwise falls back to the raw
  /// Flutter [Overlay]. Returns an [OiOverlayHandle] for programmatic control.
  static OiOverlayHandle show(
    BuildContext context, {
    required String label,
    required Widget child,
    OiPanelSide side = OiPanelSide.bottom,
    double? size,
    bool dismissible = true,
    bool dragHandle = false,
    List<double>? snapPoints,
    VoidCallback? onClose,
  }) {
    final service = OiOverlays.maybeOf(context);

    if (service != null) {
      late final OiOverlayHandle handle;
      handle = service.show(
        label: label,
        builder: (_) => OiSheet(
          label: label,
          open: true,
          side: side,
          size: size,
          dismissible: dismissible,
          dragHandle: dragHandle,
          snapPoints: snapPoints,
          onClose: () {
            onClose?.call();
            handle.dismiss();
          },
          child: child,
        ),
        zOrder: OiOverlayZOrder.panel,
        dismissible: false,
      );
      return handle;
    }

    // Fallback path: create the entry first so the handle is available to
    // the onClose closure before sheet() is ever called.
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => OiSheet(
        label: label,
        open: true,
        side: side,
        size: size,
        dismissible: dismissible,
        dragHandle: dragHandle,
        snapPoints: snapPoints,
        onClose: () {
          onClose?.call();
          entry
            ..remove()
            ..dispose();
        },
        child: child,
      ),
    );
    Overlay.of(context).insert(entry);
    return createOiOverlayHandle(entry);
  }

  @override
  State<OiSheet> createState() => _OiSheetState();
}

class _OiSheetState extends State<OiSheet> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Drag tracking (for snap points).
  double _dragOffset = 0;
  bool _dragging = false;

  bool get _isVertical =>
      widget.side == OiPanelSide.bottom || widget.side == OiPanelSide.top;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      value: widget.open ? 1.0 : 0.0,
    );
    if (widget.open) _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.duration =
        context.animations.reducedMotion ||
            MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 260);
  }

  @override
  void didUpdateWidget(OiSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.open != oldWidget.open) {
      if (widget.open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Offset _slideBegin() {
    switch (widget.side) {
      case OiPanelSide.bottom:
        return const Offset(0, 1);
      case OiPanelSide.top:
        return const Offset(0, -1);
      case OiPanelSide.left:
        return const Offset(-1, 0);
      case OiPanelSide.right:
        return const Offset(1, 0);
    }
  }

  void _handleDragUpdate(DragUpdateDetails d) {
    if (!widget.open) return;
    setState(() {
      _dragging = true;
      _dragOffset += _isVertical ? d.delta.dy : d.delta.dx;
    });
  }

  void _handleDragEnd(DragEndDetails d, Size screen) {
    if (!_dragging) return;
    setState(() => _dragging = false);

    final dimension = _isVertical ? screen.height : screen.width;
    final fraction = _dragOffset.abs() / dimension;

    // Positive drag offset means dragging toward off-screen.
    if (_dragOffset > 0) {
      final snap = widget.snapPoints;
      if (snap != null && snap.isNotEmpty) {
        // Find nearest snap point above current drag.
        final remaining = 1.0 - fraction;
        final nearest = snap.reduce(
          (a, b) => (a - remaining).abs() < (b - remaining).abs() ? a : b,
        );
        if (nearest < snap.first) {
          widget.onClose?.call();
        }
        // Snap animation is handled by releasing drag and re-animating.
      } else if (fraction > 0.3) {
        widget.onClose?.call();
      }
    }
    setState(() => _dragOffset = 0);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final screenSize = MediaQuery.sizeOf(context);

    final slideAnim = Tween<Offset>(
      begin: _slideBegin(),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Build the drag handle pill.
    Widget? handle;
    if (widget.dragHandle) {
      handle = Container(
        width: _isVertical ? 40 : 4,
        height: _isVertical ? 4 : 40,
        decoration: BoxDecoration(
          color: colors.border,
          borderRadius: BorderRadius.circular(2),
        ),
      );
    }

    // Build the panel content.
    Widget panel = Container(
      width: _isVertical ? null : widget.size,
      height: _isVertical ? widget.size : null,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: _borderRadius(),
        boxShadow: [
          BoxShadow(
            color: colors.overlay.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: _shadowOffset(),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (handle != null && _isVertical)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Center(child: handle),
            ),
          Flexible(child: widget.child),
          if (handle != null && widget.side == OiPanelSide.top)
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 4),
              child: Center(child: handle),
            ),
        ],
      ),
    );

    // Add drag gesture for snap points / dismiss.
    if (widget.dragHandle || widget.snapPoints != null) {
      panel = GestureDetector(
        onVerticalDragUpdate: _isVertical ? _handleDragUpdate : null,
        onVerticalDragEnd: _isVertical
            ? (d) => _handleDragEnd(d, screenSize)
            : null,
        onHorizontalDragUpdate: !_isVertical ? _handleDragUpdate : null,
        onHorizontalDragEnd: !_isVertical
            ? (d) => _handleDragEnd(d, screenSize)
            : null,
        child: panel,
      );
    }

    panel = OiFocusTrap(
      onEscape: widget.onClose,
      child: SlideTransition(position: slideAnim, child: panel),
    );

    return Semantics(
      label: widget.label,
      scopesRoute: true,
      explicitChildNodes: true,
      child: Stack(
        children: [
          // Scrim.
          if (widget.open)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.dismissible ? widget.onClose : null,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (_, __) => ColoredBox(
                    color: colors.overlay.withValues(
                      alpha: 0.6 * _controller.value,
                    ),
                  ),
                ),
              ),
            ),
          // Panel aligned to the correct edge.
          Align(alignment: _alignment(), child: panel),
        ],
      ),
    );
  }

  AlignmentGeometry _alignment() {
    switch (widget.side) {
      case OiPanelSide.bottom:
        return Alignment.bottomCenter;
      case OiPanelSide.top:
        return Alignment.topCenter;
      case OiPanelSide.left:
        return Alignment.centerLeft;
      case OiPanelSide.right:
        return Alignment.centerRight;
    }
  }

  BorderRadius _borderRadius() {
    const r = Radius.circular(12);
    switch (widget.side) {
      case OiPanelSide.bottom:
        return const BorderRadius.vertical(top: r);
      case OiPanelSide.top:
        return const BorderRadius.vertical(bottom: r);
      case OiPanelSide.left:
        return const BorderRadius.horizontal(right: r);
      case OiPanelSide.right:
        return const BorderRadius.horizontal(left: r);
    }
  }

  Offset _shadowOffset() {
    switch (widget.side) {
      case OiPanelSide.bottom:
        return const Offset(0, -4);
      case OiPanelSide.top:
        return const Offset(0, 4);
      case OiPanelSide.left:
        return const Offset(4, 0);
      case OiPanelSide.right:
        return const Offset(-4, 0);
    }
  }
}
