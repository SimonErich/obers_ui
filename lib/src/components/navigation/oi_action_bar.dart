import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/buttons/oi_icon_button.dart';
import 'package:obers_ui/src/components/display/oi_badge.dart';
import 'package:obers_ui/src/components/display/oi_popover.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';
import 'package:obers_ui/src/primitives/layout/oi_row.dart';

/// The visual style of an [OiActionBar].
///
/// {@category Components}
enum OiActionBarStyle {
  /// No background, border, or elevation.
  flat,

  /// A filled surface background.
  surface,

  /// A border around the bar.
  outlined,

  /// An elevated bar with a shadow.
  elevated,
}

/// A single action displayed in an [OiActionBar].
///
/// {@category Components}
@immutable
class OiActionBarItem {
  /// Creates an [OiActionBarItem].
  const OiActionBarItem({
    required this.icon,
    required this.label,
    required this.semanticLabel,
    this.onTap,
    this.enabled = true,
    this.toggled = false,
    this.variant = OiButtonVariant.ghost,
    this.tooltip,
    this.group,
    this.badge,
    this.loading = false,
    this.confirm,
  });

  /// The icon glyph for this action.
  final IconData icon;

  /// The text label for this action.
  final String label;

  /// Accessibility label announced by screen readers.
  final String semanticLabel;

  /// Called when the action is tapped.
  final VoidCallback? onTap;

  /// Whether this action is interactive.
  final bool enabled;

  /// Whether this action is in a toggled/active state.
  final bool toggled;

  /// The visual style variant of the action button.
  final OiButtonVariant variant;

  /// An optional tooltip shown on hover.
  final String? tooltip;

  /// An optional group identifier used for separator placement.
  final String? group;

  /// An optional badge value displayed on the action.
  final String? badge;

  /// Whether this action is in a loading state.
  final bool loading;

  /// An optional confirmation message. When set, the first tap shows the
  /// message and a second tap executes [onTap].
  final String? confirm;
}

/// A contextual entity action toolbar for single-entity operations.
///
/// Displays a row of icon buttons (or icon+label buttons when [showLabels]
/// is true) derived from [actions]. Optional [leading] and [trailing] widgets
/// bookend the action row.
///
/// When [separator] is `true`, a thin vertical divider is rendered between
/// actions that belong to different [OiActionBarItem.group] values.
///
/// ```dart
/// OiActionBar(
///   label: 'Document actions',
///   actions: [
///     OiActionBarItem(
///       icon: OiIcons.pencil,
///       label: 'Edit',
///       semanticLabel: 'Edit document',
///       onTap: () => edit(),
///     ),
///     OiActionBarItem(
///       icon: OiIcons.trash,
///       label: 'Delete',
///       semanticLabel: 'Delete document',
///       onTap: () => delete(),
///       variant: OiButtonVariant.destructive,
///     ),
///   ],
/// )
/// ```
///
/// {@category Components}
class OiActionBar extends StatelessWidget {
  /// Creates an [OiActionBar].
  const OiActionBar({
    required this.actions,
    required this.label,
    this.overflowActions,
    this.leading,
    this.trailing,
    this.style = OiActionBarStyle.flat,
    this.showLabels,
    this.size = OiButtonSize.medium,
    this.separator = false,
    this.semanticLabel,
    super.key,
  });

  /// The primary visible action buttons.
  final List<OiActionBarItem> actions;

  /// An accessibility label for the action bar.
  final String label;

  /// Actions shown behind an overflow "more" menu.
  final List<OiActionBarItem>? overflowActions;

  /// A widget rendered before the action buttons.
  final Widget? leading;

  /// A widget rendered after the action buttons.
  final Widget? trailing;

  /// The visual style of the bar.
  final OiActionBarStyle style;

  /// Whether to show text labels alongside icons.
  ///
  /// When `null`, labels are shown automatically on expanded breakpoints
  /// and hidden on compact ones.
  final bool? showLabels;

  /// The size tier for action buttons.
  final OiButtonSize size;

  /// Whether to render vertical dividers between different action groups.
  final bool separator;

  /// An optional semantic label override for the bar container.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty && overflowActions == null) {
      return const SizedBox.shrink();
    }

    final colors = context.colors;
    final spacing = context.spacing;
    final bp = context.breakpoint;
    final effectiveShowLabels =
        showLabels ?? (bp.compareTo(OiBreakpoint.expanded) >= 0);

    final children = <Widget>[];

    if (leading != null) {
      children.add(leading!);
    }

    String? lastGroup;
    for (var i = 0; i < actions.length; i++) {
      final action = actions[i];

      // Insert separator between different groups.
      if (separator && i > 0 && action.group != lastGroup) {
        children.add(
          Container(width: 1, height: 20, color: colors.borderSubtle),
        );
      }
      lastGroup = action.group;

      children.add(_buildAction(context, action, effectiveShowLabels));
    }

    // Add overflow "more" button when overflowActions is populated.
    if (overflowActions != null && overflowActions!.isNotEmpty) {
      children.add(_OverflowMenuButton(actions: overflowActions!, size: size));
    }

    if (trailing != null) {
      children.add(trailing!);
    }

    Widget bar = OiRow(
      breakpoint: bp,
      gap: OiResponsive<double>(spacing.xs),
      children: children,
    );

    // Apply style decoration.
    switch (style) {
      case OiActionBarStyle.flat:
        break;
      case OiActionBarStyle.surface:
        bar = DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surfaceSubtle,
            borderRadius: context.radius.md,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.sm,
              vertical: spacing.xs,
            ),
            child: bar,
          ),
        );
      case OiActionBarStyle.outlined:
        bar = DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: colors.borderSubtle),
            borderRadius: context.radius.md,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.sm,
              vertical: spacing.xs,
            ),
            child: bar,
          ),
        );
      case OiActionBarStyle.elevated:
        bar = DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: context.radius.md,
            boxShadow: context.shadows.md,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.sm,
              vertical: spacing.xs,
            ),
            child: bar,
          ),
        );
    }

    return Semantics(
      label: semanticLabel ?? label,
      container: true,
      explicitChildNodes: true,
      child: bar,
    );
  }

  Widget _buildAction(
    BuildContext context,
    OiActionBarItem action,
    bool showLabel,
  ) {
    if (action.loading) {
      return SizedBox(
        width: size == OiButtonSize.small
            ? 28
            : (size == OiButtonSize.large ? 44 : 36),
        height: size == OiButtonSize.small
            ? 28
            : (size == OiButtonSize.large ? 44 : 36),
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: _LoadingIndicator(),
        ),
      );
    }

    final effectiveVariant = action.toggled
        ? OiButtonVariant.primary
        : action.variant;

    Widget actionWidget;

    if (showLabel) {
      actionWidget = OiButton.ghost(
        label: action.label,
        icon: action.icon,
        onTap: action.enabled ? action.onTap : null,
        size: size,
        enabled: action.enabled,
        semanticLabel: action.semanticLabel,
      );
    } else {
      actionWidget = OiIconButton(
        icon: action.icon,
        onTap: action.enabled ? action.onTap : null,
        size: size,
        variant: effectiveVariant,
        enabled: action.enabled,
        semanticLabel: action.semanticLabel,
      );
    }

    // Overlay badge when present.
    if (action.badge != null) {
      actionWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          actionWidget,
          Positioned(
            top: -4,
            right: -4,
            child: OiBadge.filled(
              label: action.badge!,
              size: OiBadgeSize.small,
            ),
          ),
        ],
      );
    }

    // Wrap with confirm gate when present.
    if (action.confirm != null) {
      actionWidget = _ConfirmableAction(item: action, child: actionWidget);
    }

    return actionWidget;
  }
}

/// An overflow "more" button that opens a popover listing [actions].
class _OverflowMenuButton extends StatefulWidget {
  const _OverflowMenuButton({required this.actions, required this.size});

  final List<OiActionBarItem> actions;
  final OiButtonSize size;

  @override
  State<_OverflowMenuButton> createState() => _OverflowMenuButtonState();
}

class _OverflowMenuButtonState extends State<_OverflowMenuButton> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return OiPopover(
      label: '',
      open: _open,
      onClose: () => setState(() => _open = false),
      anchor: OiIconButton(
        icon: OiIcons.ellipsisVertical,
        semanticLabel: 'More actions',
        size: widget.size,
        onTap: () => setState(() => _open = !_open),
      ),
      content: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final action in widget.actions)
              OiTappable(
                semanticLabel: action.semanticLabel,
                onTap: action.enabled && action.onTap != null
                    ? () {
                        setState(() => _open = false);
                        action.onTap!();
                      }
                    : null,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.md,
                    vertical: spacing.sm,
                  ),
                  child: OiRow(
                    breakpoint: context.breakpoint,
                    gap: OiResponsive<double>(spacing.sm),
                    children: [
                      OiIcon.decorative(
                        icon: action.icon,
                        size: 16,
                        color: colors.text,
                      ),
                      OiLabel.body(action.label, color: colors.text),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A stateful wrapper that intercepts the first tap to show a confirmation
/// label and only executes the action on the second tap.
class _ConfirmableAction extends StatefulWidget {
  const _ConfirmableAction({required this.item, required this.child});

  final OiActionBarItem item;
  final Widget child;

  @override
  State<_ConfirmableAction> createState() => _ConfirmableActionState();
}

class _ConfirmableActionState extends State<_ConfirmableAction> {
  bool _confirming = false;

  @override
  Widget build(BuildContext context) {
    if (_confirming) {
      return OiButton.ghost(
        label: widget.item.confirm!,
        onTap: () {
          widget.item.onTap?.call();
          setState(() => _confirming = false);
        },
      );
    }

    // Absorb the child's own onTap so the first tap triggers confirmation.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _confirming = true),
      child: IgnorePointer(child: widget.child),
    );
  }
}

/// A simple animated loading indicator that does not depend on Material.
class _LoadingIndicator extends StatefulWidget {
  const _LoadingIndicator();

  @override
  State<_LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<_LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return RotationTransition(
      turns: _controller,
      child: CustomPaint(painter: _SpinnerPainter(color: colors.textMuted)),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  _SpinnerPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Offset.zero & size;
    canvas.drawArc(rect, 0, 4.7, false, paint);
  }

  @override
  bool shouldRepaint(_SpinnerPainter oldDelegate) => color != oldDelegate.color;
}
