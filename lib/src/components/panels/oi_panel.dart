import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/overlays/oi_sheet.dart'
    show OiPanelSide, OiSheet;
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_focus_trap.dart';

/// A persistent slide-in side panel for navigation or auxiliary content.
///
/// [OiPanel] animates in from [side] when [open] is `true` and slides back
/// out when `false`. Unlike [OiSheet] there are no drag handles or snap
/// points — this component is designed for pointer-first desktop UIs.
///
/// [OiFocusTrap] keeps keyboard focus inside the panel while it is open.
/// When [dismissible] is `true` and [showScrim] is `true`, tapping the scrim
/// calls [onClose]. The scrim is always shown when [showScrim] is `true`.
///
/// {@category Components}
class OiPanel extends StatefulWidget {
  /// Creates an [OiPanel].
  const OiPanel({
    required this.label,
    required this.child,
    required this.open,
    this.onClose,
    this.side = OiPanelSide.left,
    this.size,
    this.dismissible = true,
    this.showScrim = false,
    super.key,
  });

  /// Accessible label describing the panel for screen readers.
  final String label;

  /// The content displayed inside the panel.
  final Widget child;

  /// Whether the panel is currently open.
  final bool open;

  /// Called when the panel should close (e.g. scrim tap or Escape key).
  final VoidCallback? onClose;

  /// The edge from which the panel slides in. Defaults to [OiPanelSide.left].
  final OiPanelSide side;

  /// Fixed width (left/right panels) or height (top/bottom panels) in logical
  /// pixels. When null the panel sizes itself to its content.
  final double? size;

  /// Whether tapping the scrim dismisses the panel. Defaults to `true`.
  final bool dismissible;

  /// Whether a semi-transparent scrim is shown behind the panel.
  /// Defaults to `false`.
  final bool showScrim;

  @override
  State<OiPanel> createState() => _OiPanelState();
}

class _OiPanelState extends State<OiPanel> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  bool get _isVertical =>
      widget.side == OiPanelSide.top || widget.side == OiPanelSide.bottom;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
      value: widget.open ? 1.0 : 0.0,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.duration =
        context.animations.reducedMotion ||
            MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 240);
  }

  @override
  void didUpdateWidget(OiPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.open != oldWidget.open) {
      if (widget.open) {
        unawaited(_controller.forward());
      } else {
        unawaited(_controller.reverse());
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
      case OiPanelSide.left:
        return const Offset(-1, 0);
      case OiPanelSide.right:
        return const Offset(1, 0);
      case OiPanelSide.top:
        return const Offset(0, -1);
      case OiPanelSide.bottom:
        return const Offset(0, 1);
    }
  }

  AlignmentGeometry _alignment() {
    switch (widget.side) {
      case OiPanelSide.left:
        return Alignment.centerLeft;
      case OiPanelSide.right:
        return Alignment.centerRight;
      case OiPanelSide.top:
        return Alignment.topCenter;
      case OiPanelSide.bottom:
        return Alignment.bottomCenter;
    }
  }

  BorderRadius _borderRadius() {
    const r = Radius.circular(12);
    switch (widget.side) {
      case OiPanelSide.left:
        return const BorderRadius.horizontal(right: r);
      case OiPanelSide.right:
        return const BorderRadius.horizontal(left: r);
      case OiPanelSide.top:
        return const BorderRadius.vertical(bottom: r);
      case OiPanelSide.bottom:
        return const BorderRadius.vertical(top: r);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final slideAnim = Tween<Offset>(
      begin: _slideBegin(),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Widget panel = Container(
      width: _isVertical ? null : widget.size,
      height: _isVertical ? widget.size : null,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: _borderRadius(),
      ),
      child: widget.child,
    );

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
          if (widget.showScrim && widget.open)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.dismissible ? widget.onClose : null,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (_, _) => ColoredBox(
                    color: colors.overlay.withValues(
                      alpha: 0.5 * _controller.value,
                    ),
                  ),
                ),
              ),
            ),
          Align(alignment: _alignment(), child: panel),
        ],
      ),
    );
  }
}
