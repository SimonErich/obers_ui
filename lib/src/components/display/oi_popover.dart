import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_focus_trap.dart';
import 'package:obers_ui/src/primitives/overlay/oi_floating.dart';

/// A popover overlay anchored to a widget.
///
/// When [open] is `true`, [content] is shown via [OiFloating] positioned
/// relative to [anchor] using [alignment]. [OiFocusTrap] is used inside the
/// popover so that keyboard focus stays within it and Escape calls [onClose].
/// Tapping the barrier (outside the popover) also calls [onClose].
///
/// {@category Components}
class OiPopover extends StatefulWidget {
  /// Creates an [OiPopover].
  const OiPopover({
    required this.label,
    required this.anchor,
    required this.content,
    this.open = false,
    this.onClose,
    this.alignment = OiFloatingAlignment.bottomStart,
    this.initialFocus = true,
    this.borderRadius,
    super.key,
  });

  /// The accessible label describing the open popover content.
  /// The [anchor] owns its trigger label independently.
  final String label;

  /// The widget that serves as the anchor for positioning.
  final Widget anchor;

  /// The popover content displayed when [open] is `true`.
  final Widget content;

  /// Whether the popover is visible.
  final bool open;

  /// Called when the popover should close (Escape key or tap-outside).
  final VoidCallback? onClose;

  /// Alignment of the popover relative to the anchor.
  final OiFloatingAlignment alignment;

  /// Whether the first focusable descendant should receive focus when the
  /// popover opens.
  final bool initialFocus;

  /// Surface corners; defaults to an 8-pixel radius.
  final BorderRadius? borderRadius;

  @override
  State<OiPopover> createState() => _OiPopoverState();
}

class _OiPopoverState extends State<OiPopover> {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final popoverContent = OiFocusTrap(
      initialFocus: widget.initialFocus,
      onEscape: widget.onClose,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: colors.overlay.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: colors.border),
        ),
        child: widget.content,
      ),
    );

    return OiFloating(
      visible: widget.open,
      alignment: widget.alignment,
      onDismiss: widget.onClose,
      anchor: widget.anchor,
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        label: widget.label,
        child: popoverContent,
      ),
    );
  }
}
