import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/inputs/oi_checkbox.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/animation/oi_animated_list.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/display/oi_surface.dart';
import 'package:obers_ui/src/primitives/layout/oi_row.dart';

/// Visual variant for a bulk action button.
///
/// {@category Components}
enum OiBulkActionVariant {
  /// Default ghost-styled button.
  ghost,

  /// Destructive-styled button for delete/remove actions.
  destructive,
}

/// A single action in an [OiBulkBar].
///
/// {@category Components}
@immutable
class OiBulkAction {
  /// Creates an [OiBulkAction].
  const OiBulkAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.variant = OiBulkActionVariant.ghost,
    this.loading = false,
    this.confirm = false,
    this.confirmLabel,
  });

  /// The label for this action.
  final String label;

  /// The icon for this action.
  final IconData icon;

  /// Called when the action is triggered.
  final VoidCallback onTap;

  /// The visual variant of the action button.
  final OiBulkActionVariant variant;

  /// Whether the action is currently loading.
  final bool loading;

  /// Whether the action requires two-press confirmation.
  final bool confirm;

  /// The label shown during the confirmation step.
  /// Defaults to "Confirm {label}" if not provided.
  final String? confirmLabel;
}

/// A floating toolbar that appears when items are selected in a list or table.
///
/// Slides in from the bottom when [selectedCount] >= 1. Displays the selection
/// count, a select-all/deselect-all toggle, and a row of action buttons.
///
/// The consumer is responsible for positioning this widget (e.g. in a [Stack]
/// with `Positioned(bottom: 0)`).
///
/// ```dart
/// OiBulkBar(
///   selectedCount: 3,
///   totalCount: 10,
///   label: 'items',
///   actions: [
///     OiBulkAction(
///       label: 'Delete',
///       icon: Icons.delete,
///       onTap: () => deleteSelected(),
///       variant: OiBulkActionVariant.destructive,
///       confirm: true,
///     ),
///   ],
///   onSelectAll: () => selectAll(),
///   onDeselectAll: () => deselectAll(),
///   allSelected: false,
/// )
/// ```
///
/// {@category Components}
///
/// Coverage: REQ-0010
class OiBulkBar extends StatefulWidget {
  /// Creates an [OiBulkBar].
  const OiBulkBar({
    required this.selectedCount,
    required this.totalCount,
    required this.label,
    required this.actions,
    this.onSelectAll,
    this.onDeselectAll,
    this.allSelected = false,
    super.key,
  });

  /// The number of currently selected items.
  final int selectedCount;

  /// The total number of items available.
  final int totalCount;

  /// A descriptive label for the items (e.g. "items", "users", "rows").
  final String label;

  /// The list of available bulk actions.
  final List<OiBulkAction> actions;

  /// Called when the select-all checkbox is tapped while not all are selected.
  final VoidCallback? onSelectAll;

  /// Called when the select-all checkbox is tapped while all are selected.
  final VoidCallback? onDeselectAll;

  /// Whether all items are currently selected.
  final bool allSelected;

  @override
  State<OiBulkBar> createState() => _OiBulkBarState();
}

class _OiBulkBarState extends State<OiBulkBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    if (_isVisible) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(OiBulkBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasVisible = oldWidget.selectedCount > 0;
    if (_isVisible && !wasVisible) {
      _maybeAnimate(forward: true);
    } else if (!_isVisible && wasVisible) {
      _maybeAnimate(forward: false);
    }
  }

  void _maybeAnimate({required bool forward}) {
    final reducedMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reducedMotion) {
      _animationController.value = forward ? 1.0 : 0.0;
    } else {
      if (forward) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  bool get _isVisible => widget.selectedCount > 0;

  int get _clampedCount => widget.selectedCount > widget.totalCount
      ? widget.totalCount
      : widget.selectedCount;

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildSelectionInfo(BuildContext context) {
    final spacing = context.spacing;
    final bp = context.breakpoint;

    return OiRow(
      breakpoint: bp,
      gap: OiResponsive<double>(spacing.sm),
      children: [
        OiCheckbox(
          value: widget.allSelected,
          onChanged: (_) {
            if (widget.allSelected) {
              widget.onDeselectAll?.call();
            } else {
              widget.onSelectAll?.call();
            }
          },
          label: widget.allSelected ? 'Deselect all' : 'Select all',
        ),
        OiLabel.bodyStrong(
          '$_clampedCount of ${widget.totalCount} ${widget.label} selected',
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, OiBulkAction action) {
    if (action.confirm) {
      return OiButton.confirm(
        label: action.label,
        confirmLabel: action.confirmLabel ?? 'Confirm ${action.label}',
        onConfirm: action.onTap,
        variant: action.variant == OiBulkActionVariant.destructive
            ? OiButtonVariant.destructive
            : OiButtonVariant.ghost,
        size: OiButtonSize.small,
      );
    }

    if (action.variant == OiBulkActionVariant.destructive) {
      return OiButton.destructive(
        label: action.label,
        icon: action.icon,
        onTap: action.onTap,
        loading: action.loading,
        size: OiButtonSize.small,
        semanticLabel: action.label,
      );
    }

    return OiButton.ghost(
      label: action.label,
      icon: action.icon,
      onTap: action.onTap,
      loading: action.loading,
      size: OiButtonSize.small,
      semanticLabel: action.label,
    );
  }

  Widget _buildActions(BuildContext context) {
    if (widget.actions.isEmpty) return const SizedBox.shrink();

    return OiAnimatedList<OiBulkAction>(
      items: widget.actions,
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      itemBuilder: (context, action, animation, index) {
        return _buildActionButton(context, action);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colors = context.colors;
    final shadows = context.shadows;

    return SlideTransition(
      position: _slideAnimation,
      child: Semantics(
        label: '${widget.label} bulk actions',
        container: true,
        explicitChildNodes: true,
        child: OiSurface(
          color: colors.surface,
          shadow: shadows.lg,
          borderRadius: context.radius.md,
          padding: EdgeInsets.symmetric(
            horizontal: spacing.md,
            vertical: spacing.sm,
          ),
          child: OiRow(
            breakpoint: context.breakpoint,
            gap: OiResponsive<double>(spacing.md),
            children: [
              _buildSelectionInfo(context),
              if (widget.actions.isNotEmpty) ...[
                Container(width: 1, height: 24, color: colors.borderSubtle),
                Flexible(child: _buildActions(context)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
