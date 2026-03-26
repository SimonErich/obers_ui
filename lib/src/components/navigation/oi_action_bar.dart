import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/buttons/oi_icon_button.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
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

    if (showLabel) {
      return OiButton.ghost(
        label: action.label,
        icon: action.icon,
        onTap: action.enabled ? action.onTap : null,
        size: size,
        enabled: action.enabled,
        semanticLabel: action.semanticLabel,
      );
    }

    return OiIconButton(
      icon: action.icon,
      onTap: action.enabled ? action.onTap : null,
      size: size,
      variant: effectiveVariant,
      enabled: action.enabled,
      semanticLabel: action.semanticLabel,
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
