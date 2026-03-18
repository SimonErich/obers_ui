import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/foundation/oi_app.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_decoration_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_surface.dart';

/// A single item in an [OiButtonGroup].
///
/// Each item must have a [label] (required for accessibility even when only an
/// [icon] is displayed). Provide [semanticLabel] to override the accessible
/// description.
///
/// In non-exclusive groups, [onTap] is called when the user taps this item.
/// In exclusive groups, [onTap] is ignored; the group's [OiButtonGroup.onSelect]
/// is used instead.
///
/// {@category Components}
class OiButtonGroupItem {
  /// Creates an [OiButtonGroupItem].
  const OiButtonGroupItem({
    required this.label,
    this.icon,
    this.onTap,
    this.enabled = true,
    this.semanticLabel,
  });

  /// The text label displayed on the button.
  final String label;

  /// An optional leading icon displayed alongside the [label].
  final IconData? icon;

  /// Called when this item is tapped in non-exclusive mode.
  ///
  /// Ignored when [OiButtonGroup.exclusive] is `true`.
  final VoidCallback? onTap;

  /// Whether this item can be interacted with.
  final bool enabled;

  /// Override for the screen-reader accessible label.  Defaults to [label].
  final String? semanticLabel;
}

/// A group of buttons displayed inline with a connected or gapped visual
/// appearance.
///
/// Buttons in a group can operate in two modes:
///
/// - **Connected** ([spacing] == 0): All items share a single [OiSurface]
///   container with a shared outer border radius.  The first child gets the
///   left corner radii, the last child gets the right corner radii, and middle
///   children have no corner radii.  A 1 logical-pixel divider is drawn between
///   adjacent items.
/// - **Gapped** ([spacing] > 0): Each item is rendered with full corner radii
///   separated by [spacing] logical pixels.
///
/// In exclusive mode ([exclusive] == `true`) exactly one item is active at a
/// time (the one at [selectedIndex]).  Tapping any item calls [onSelect] with
/// its index.  The selected item uses the *soft* variant; all others use
/// *ghost*.  Individual item [OiButtonGroupItem.onTap] is ignored in exclusive
/// mode.  Arrow-key navigation is supported: horizontal groups respond to ←/→
/// and vertical groups respond to ↑/↓.
///
/// In non-exclusive mode ([exclusive] == `false`, the default), each item
/// fires its own [OiButtonGroupItem.onTap] independently.  Disabled items
/// cannot be tapped and show reduced opacity.
///
/// On compact breakpoints a horizontal group with [wrap] enabled will
/// automatically re-orient to vertical.
///
/// ```dart
/// OiButtonGroup(
///   exclusive: true,
///   items: const [
///     OiButtonGroupItem(label: 'Day'),
///     OiButtonGroupItem(label: 'Week'),
///     OiButtonGroupItem(label: 'Month'),
///   ],
///   selectedIndex: _tab,
///   onSelect: (i) => setState(() => _tab = i),
/// )
/// ```
///
/// {@category Components}
class OiButtonGroup extends StatefulWidget {
  /// Creates an [OiButtonGroup].
  const OiButtonGroup({
    required this.items,
    this.size = OiButtonSize.medium,
    this.direction = Axis.horizontal,
    this.spacing = 0,
    this.exclusive = false,
    this.selectedIndex,
    this.onSelect,
    this.wrap = true,
    super.key,
  });

  /// The items to render inside the group.
  final List<OiButtonGroupItem> items;

  /// The size applied to every item in the group.
  final OiButtonSize size;

  /// Whether items are arranged horizontally or vertically.
  ///
  /// Defaults to [Axis.horizontal].  On compact breakpoints, horizontal groups
  /// with [wrap] enabled will wrap to vertical.
  final Axis direction;

  /// The gap in logical pixels between items.
  ///
  /// A value of `0` produces a connected group (items share borders with
  /// dividers between them).  Any positive value produces a gapped group where
  /// items have individual corner radii.
  final double spacing;

  /// When `true`, the group acts as a single-select toggle: exactly one item
  /// is active at a time.
  ///
  /// The selected item (identified by [selectedIndex]) uses
  /// [OiButtonVariant.soft]; all others use [OiButtonVariant.ghost].  Tapping
  /// an item calls [onSelect] with the item's index.  Individual item
  /// [OiButtonGroupItem.onTap] callbacks are ignored.  Arrow-key navigation
  /// moves the selection.
  ///
  /// Defaults to `false`.
  final bool exclusive;

  /// The index of the currently selected item when [exclusive] is `true`.
  final int? selectedIndex;

  /// Called with the tapped item's index when [exclusive] is `true`.
  final ValueChanged<int>? onSelect;

  /// When `true` (the default), a horizontal group automatically wraps to
  /// vertical on compact breakpoints.
  final bool wrap;

  @override
  State<OiButtonGroup> createState() => _OiButtonGroupState();
}

// ── State ─────────────────────────────────────────────────────────────────────

class _OiButtonGroupState extends State<OiButtonGroup> {
  int _focusIndex = 0;

  @override
  void initState() {
    super.initState();
    _focusIndex = widget.selectedIndex ?? 0;
  }

  @override
  void didUpdateWidget(OiButtonGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != null) {
      _focusIndex = widget.selectedIndex!;
    }
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (!widget.exclusive) return KeyEventResult.ignored;
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final effectiveDir = _effectiveDirection(context);
    final isForward = effectiveDir == Axis.horizontal
        ? event.logicalKey == LogicalKeyboardKey.arrowRight
        : event.logicalKey == LogicalKeyboardKey.arrowDown;
    final isBack = effectiveDir == Axis.horizontal
        ? event.logicalKey == LogicalKeyboardKey.arrowLeft
        : event.logicalKey == LogicalKeyboardKey.arrowUp;

    if (!isForward && !isBack) return KeyEventResult.ignored;

    final count = widget.items.length;
    final delta = isForward ? 1 : -1;
    final next = (_focusIndex + delta + count) % count;
    setState(() => _focusIndex = next);
    widget.onSelect?.call(next);
    return KeyEventResult.handled;
  }

  Axis _effectiveDirection(BuildContext context) {
    if (widget.wrap &&
        context.isCompact &&
        widget.direction == Axis.horizontal) {
      return Axis.vertical;
    }
    return widget.direction;
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.items.length;
    if (count == 0) return const SizedBox.shrink();

    final effectiveDir = _effectiveDirection(context);
    final radius = context.components.button?.borderRadius ?? context.radius.sm;
    final connected = widget.spacing == 0;

    return connected
        ? _buildConnected(context, count, effectiveDir, radius)
        : _buildGapped(context, count, effectiveDir, radius);
  }

  // ── Connected layout (shared OiSurface) ─────────────────────────────────

  Widget _buildConnected(
    BuildContext context,
    int count,
    Axis direction,
    BorderRadius radius,
  ) {
    final dividerColor = context.colors.border;
    final children = <Widget>[];

    for (var i = 0; i < count; i++) {
      children.add(
        _buildItem(
          context,
          i,
          _connectedItemRadius(i, count, direction, radius),
        ),
      );
      if (i < count - 1) {
        // Divider between adjacent items.
        children.add(
          direction == Axis.horizontal
              ? Container(width: 1, color: dividerColor)
              : Container(height: 1, color: dividerColor),
        );
      }
    }

    final content = direction == Axis.horizontal
        ? Row(mainAxisSize: MainAxisSize.min, children: children)
        : Column(mainAxisSize: MainAxisSize.min, children: children);

    return Focus(
      onKeyEvent: _onKeyEvent,
      child: OiSurface(
        color: const Color(0x00000000),
        border: OiBorderStyle.solid(
          context.colors.border,
          1,
          borderRadius: radius,
        ),
        borderRadius: radius,
        child: ClipRRect(borderRadius: radius, child: content),
      ),
    );
  }

  /// Returns the per-position border radius for a button inside a connected
  /// group.  The first item gets the leading corners, the last item gets the
  /// trailing corners, and middle items get no radius.
  BorderRadius _connectedItemRadius(
    int index,
    int count,
    Axis direction,
    BorderRadius radius,
  ) {
    final isFirst = index == 0;
    final isLast = index == count - 1;

    if (direction == Axis.horizontal) {
      if (count == 1) return radius;
      if (isFirst) {
        return BorderRadius.only(
          topLeft: radius.topLeft,
          bottomLeft: radius.bottomLeft,
        );
      }
      if (isLast) {
        return BorderRadius.only(
          topRight: radius.topRight,
          bottomRight: radius.bottomRight,
        );
      }
      return BorderRadius.zero;
    } else {
      // Axis.vertical
      if (count == 1) return radius;
      if (isFirst) {
        return BorderRadius.only(
          topLeft: radius.topLeft,
          topRight: radius.topRight,
        );
      }
      if (isLast) {
        return BorderRadius.only(
          bottomLeft: radius.bottomLeft,
          bottomRight: radius.bottomRight,
        );
      }
      return BorderRadius.zero;
    }
  }

  // ── Gapped layout (individual items) ─────────────────────────────────────

  Widget _buildGapped(
    BuildContext context,
    int count,
    Axis direction,
    BorderRadius radius,
  ) {
    final gap = widget.spacing;
    final separated = <Widget>[];
    for (var i = 0; i < count; i++) {
      separated.add(_buildItem(context, i, radius));
      if (i < count - 1) {
        separated.add(
          direction == Axis.horizontal
              ? SizedBox(width: gap)
              : SizedBox(height: gap),
        );
      }
    }

    final Widget layout = direction == Axis.horizontal
        ? Row(mainAxisSize: MainAxisSize.min, children: separated)
        : Column(mainAxisSize: MainAxisSize.min, children: separated);

    return Focus(onKeyEvent: _onKeyEvent, child: layout);
  }

  // ── Single item widget ────────────────────────────────────────────────────

  Widget _buildItem(
    BuildContext context,
    int index,
    BorderRadius borderRadius,
  ) {
    final item = widget.items[index];

    final Widget button;
    if (widget.exclusive) {
      // Exclusive mode: group manages selection; item.onTap is ignored.
      final isSelected = widget.selectedIndex == index;
      if (isSelected) {
        button = OiButton.soft(
          label: item.label,
          icon: item.icon,
          size: widget.size,
          enabled: item.enabled,
          onTap: () => widget.onSelect?.call(index),
          semanticLabel: item.semanticLabel,
          borderRadius: borderRadius,
        );
      } else {
        button = OiButton.ghost(
          label: item.label,
          icon: item.icon,
          size: widget.size,
          enabled: item.enabled,
          onTap: () => widget.onSelect?.call(index),
          semanticLabel: item.semanticLabel,
          borderRadius: borderRadius,
        );
      }
      return Semantics(selected: isSelected, child: button);
    } else {
      // Non-exclusive mode: each item fires its own onTap.
      button = OiButton.ghost(
        label: item.label,
        icon: item.icon,
        size: widget.size,
        enabled: item.enabled,
        onTap: item.onTap,
        semanticLabel: item.semanticLabel,
        borderRadius: borderRadius,
      );
      return button;
    }
  }
}
