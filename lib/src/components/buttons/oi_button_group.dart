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
/// {@category Components}
class OiButtonGroupItem {
  /// Creates an [OiButtonGroupItem].
  const OiButtonGroupItem({
    required this.label,
    this.icon,
    this.enabled = true,
    this.semanticLabel,
  });

  /// The text label displayed on the button.
  final String label;

  /// An optional leading icon displayed alongside the [label].
  final IconData? icon;

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
///   container with a shared outer border radius.  The first child gets left
///   corner radii, the last child gets right corner radii, and middle children
///   have no corner radii.
/// - **Gapped** ([spacing] > 0): Each item is rendered with full corner radii
///   separated by [spacing] logical pixels.
///
/// In single-select mode ([multiSelect] == `false`) exactly one item is active
/// at a time (the one at [selectedIndex]).  Tapping any item calls [onSelect]
/// with its index.  Selected items use the *soft* variant; all others use
/// *ghost*.
///
/// Arrow-key navigation is supported in single-select mode: horizontal groups
/// respond to ←/→ and vertical groups respond to ↑/↓.
///
/// On compact breakpoints a horizontal group with [wrap] enabled will
/// automatically re-orient to vertical.
///
/// ```dart
/// OiButtonGroup(
///   items: const [
///     OiButtonGroupItem(label: 'Day'),
///     OiButtonGroupItem(label: 'Week'),
///     OiButtonGroupItem(label: 'Month'),
///   ],
///   multiSelect: false,
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
    this.multiSelect = true,
    this.selectedIndex,
    this.selectedIndices,
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
  /// A value of `0` produces a connected group (items share borders).
  /// Any positive value produces a gapped group where items have individual
  /// corner radii.
  final double spacing;

  /// When `false`, at most one item is selected at a time (single-select mode).
  ///
  /// The selected item uses [OiButtonVariant.soft]; others use
  /// [OiButtonVariant.ghost].  Arrow-key navigation moves focus between items.
  /// Defaults to `true` (multi-select allowed).
  final bool multiSelect;

  /// The index of the currently selected item when [multiSelect] is `false`.
  final int? selectedIndex;

  /// The indices of the currently selected items when [multiSelect] is `true`.
  ///
  /// Items whose index is contained in this set are rendered with the *soft*
  /// variant; all others use *ghost*.  When `null` no items appear selected.
  final Set<int>? selectedIndices;

  /// Called with the tapped item's index when [multiSelect] is `false`.
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
    if (widget.multiSelect) return KeyEventResult.ignored;
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
    final children = List<Widget>.generate(count, (i) {
      return _buildItem(context, i, BorderRadius.zero);
    });

    final content = direction == Axis.horizontal
        ? Row(mainAxisSize: MainAxisSize.min, children: children)
        : Column(mainAxisSize: MainAxisSize.min, children: children);

    return Focus(
      onKeyEvent: _onKeyEvent,
      child: OiSurface(
        color: const Color(0x00000000),
        border: OiBorderStyle.solid(context.colors.border, 1,
            borderRadius: radius),
        borderRadius: radius,
        child: ClipRRect(borderRadius: radius, child: content),
      ),
    );
  }

  // ── Gapped layout (individual items) ─────────────────────────────────────

  Widget _buildGapped(
    BuildContext context,
    int count,
    Axis direction,
    BorderRadius radius,
  ) {
    final gap = widget.spacing;
    final children = List<Widget>.generate(count, (i) {
      return _buildItem(context, i, radius);
    });

    final separated = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      separated.add(children[i]);
      if (i < children.length - 1) {
        separated.add(direction == Axis.horizontal
            ? SizedBox(width: gap)
            : SizedBox(height: gap));
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
    final isSelected = widget.multiSelect
        ? (widget.selectedIndices?.contains(index) ?? false)
        : widget.selectedIndex == index;

    final Widget button;
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
  }
}
