import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/display/oi_badge.dart';
import 'package:obers_ui/src/components/display/oi_tooltip.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/oi_navigation_item.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';

/// Controls when labels are visible on an [OiNavigationRail].
///
/// {@category Components}
enum OiRailLabelBehavior {
  /// Labels are always visible for all items.
  all,

  /// Only the selected item shows its label.
  selected,

  /// Labels are never visible (items still carry labels for accessibility).
  none,
}

/// A compact vertical navigation rail for persistent top-level navigation.
///
/// The rail renders a narrow vertical strip with icon + label items. It is
/// typically placed along the leading edge of a layout on medium and larger
/// breakpoints.
///
/// Set [expanded] to `true` to smoothly widen the rail and reveal inline labels
/// next to icons (useful for hover-to-expand side navigation). The animation
/// interpolates between [collapsedWidth] and [width].
///
/// ```dart
/// OiNavigationRail(
///   items: const [
///     OiNavigationItem(icon: OiIcons.house, label: 'Home'),
///     OiNavigationItem(icon: OiIcons.search, label: 'Search'),
///     OiNavigationItem(icon: OiIcons.user, label: 'Profile'),
///   ],
///   currentIndex: _selectedIndex,
///   onTap: (index) => setState(() => _selectedIndex = index),
/// )
/// ```
///
/// {@category Components}
class OiNavigationRail extends StatefulWidget {
  /// Creates an [OiNavigationRail].
  const OiNavigationRail({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.leading,
    this.trailing,
    this.width = 72,
    this.collapsedWidth,
    this.expanded,
    this.expandDuration = const Duration(milliseconds: 200),
    this.labelBehavior = OiRailLabelBehavior.all,
    this.groupAlignment = -1.0,
    this.itemAlignment = CrossAxisAlignment.center,
    this.backgroundColor,
    this.indicatorColor,
    this.indicatorShape,
    this.borderColor,
    this.borderWidth,
    this.elevation,
    this.semanticLabel,
    super.key,
  });

  /// The navigation items to display.
  final List<OiNavigationItem> items;

  /// The index of the currently active item.
  final int currentIndex;

  /// Called when an item is tapped.
  final ValueChanged<int> onTap;

  /// An optional widget displayed above the items (e.g. a logo).
  final Widget? leading;

  /// An optional widget displayed below the items (e.g. a settings icon).
  final Widget? trailing;

  /// The width of the rail in logical pixels (expanded state when [expanded]
  /// is used, or the fixed width otherwise).
  final double width;

  /// The width when collapsed. Only used when [expanded] is non-null.
  /// Defaults to 48 logical pixels.
  final double? collapsedWidth;

  /// When non-null, enables expand/collapse animation. `true` = expanded
  /// (full [width] with inline labels), `false` = collapsed ([collapsedWidth],
  /// icons only). When null the rail behaves as before with a fixed [width].
  final bool? expanded;

  /// The duration of the expand/collapse animation.
  /// Defaults to 200ms.
  final Duration expandDuration;

  /// Controls when item labels are visible.
  final OiRailLabelBehavior labelBehavior;

  /// The vertical alignment of the items group within the rail.
  ///
  /// Ranges from -1.0 (top) through 0.0 (center) to 1.0 (bottom).
  final double groupAlignment;

  /// The cross-axis (horizontal) alignment of items within the rail.
  ///
  /// Defaults to [CrossAxisAlignment.center].
  final CrossAxisAlignment itemAlignment;

  /// The background color of the rail.
  ///
  /// Defaults to the theme's surface color.
  final Color? backgroundColor;

  /// The color of the selected indicator pill.
  ///
  /// Defaults to the theme's muted primary color.
  final Color? indicatorColor;

  /// The shape of the selected indicator.
  ///
  /// Defaults to a stadium (pill) shape.
  final ShapeBorder? indicatorShape;

  /// The color of the right border.
  ///
  /// Defaults to the theme's subtle border color.
  final Color? borderColor;

  /// The width of the right border.
  final double? borderWidth;

  /// Shadow elevation applied to the rail surface.
  final List<BoxShadow>? elevation;

  /// The accessibility label for the entire rail.
  ///
  /// Defaults to `'Navigation'`.
  final String? semanticLabel;

  @override
  State<OiNavigationRail> createState() => _OiNavigationRailState();
}

class _OiNavigationRailState extends State<OiNavigationRail>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  int _focusedIndex = -1;
  final Set<int> _hoveredIndices = {};
  AnimationController? _expandController;

  bool get _isExpandable => widget.expanded != null;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusedIndex = widget.currentIndex;
    if (_isExpandable) {
      _expandController = AnimationController(
        vsync: this,
        duration: widget.expandDuration,
        value: widget.expanded! ? 1.0 : 0.0,
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reducedMotion =
        context.animations.reducedMotion ||
        MediaQuery.disableAnimationsOf(context);
    _expandController?.duration = reducedMotion
        ? Duration.zero
        : widget.expandDuration;
  }

  @override
  void didUpdateWidget(OiNavigationRail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      _focusedIndex = widget.currentIndex;
    }
    if (widget.expanded != oldWidget.expanded && _expandController != null) {
      if (widget.expanded!) {
        unawaited(_expandController!.forward());
      } else {
        unawaited(_expandController!.reverse());
      }
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _expandController?.dispose();
    super.dispose();
  }

  // ── Keyboard navigation ───────────────────────────────────────────────────

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final itemCount = widget.items.length;
    if (itemCount == 0) return KeyEventResult.ignored;

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() {
        _focusedIndex = (_focusedIndex - 1) % itemCount;
        if (_focusedIndex < 0) _focusedIndex = itemCount - 1;
      });
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() {
        _focusedIndex = (_focusedIndex + 1) % itemCount;
      });
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space) {
      if (_focusedIndex >= 0 && _focusedIndex < itemCount) {
        widget.onTap(_focusedIndex);
      }
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final animations = context.animations;
    final reducedMotion =
        animations.reducedMotion || MediaQuery.disableAnimationsOf(context);
    final effectiveBg = widget.backgroundColor ?? colors.surface;
    final effectiveBorderColor = widget.borderColor ?? colors.borderSubtle;
    final effectiveBorderWidth = widget.borderWidth ?? 1.0;

    final effectiveCollapsedWidth = widget.collapsedWidth ?? 48.0;

    // Build the items list.
    final itemWidgets = <Widget>[];
    for (var i = 0; i < widget.items.length; i++) {
      if (i > 0) itemWidgets.add(const SizedBox(height: 4));
      itemWidgets.add(_buildItem(context, i, reducedMotion));
    }

    // Determine main-axis alignment from groupAlignment.
    final MainAxisAlignment alignment;
    if (widget.groupAlignment <= -0.5) {
      alignment = MainAxisAlignment.start;
    } else if (widget.groupAlignment >= 0.5) {
      alignment = MainAxisAlignment.end;
    } else {
      alignment = MainAxisAlignment.center;
    }

    final rail = DecoratedBox(
      decoration: BoxDecoration(
        color: effectiveBg,
        border: Border(
          right: BorderSide(
            color: effectiveBorderColor,
            width: effectiveBorderWidth,
          ),
        ),
        boxShadow: widget.elevation,
      ),
      child: Column(
        crossAxisAlignment: _isExpandable
            ? CrossAxisAlignment.stretch
            : CrossAxisAlignment.center,
        children: [
          if (widget.leading != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: widget.leading,
            ),
          Expanded(
            child: Column(
              mainAxisAlignment: alignment,
              crossAxisAlignment: widget.itemAlignment,
              children: itemWidgets,
            ),
          ),
          if (widget.trailing != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: widget.trailing,
            ),
        ],
      ),
    );

    // When expandable, animate the width. Otherwise use fixed width.
    Widget sized;
    if (_isExpandable && _expandController != null) {
      sized = AnimatedBuilder(
        animation: _expandController!,
        builder: (context, child) {
          final w =
              effectiveCollapsedWidth +
              (_expandController!.value *
                  (widget.width - effectiveCollapsedWidth));
          return SizedBox(width: w, child: child);
        },
        child: rail,
      );
    } else {
      sized = SizedBox(width: widget.width, child: rail);
    }

    return Semantics(
      container: true,
      label: widget.semanticLabel ?? 'Navigation',
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: _handleKeyEvent,
        child: _isExpandable ? ClipRect(child: sized) : sized,
      ),
    );
  }

  // ── Item builder ──────────────────────────────────────────────────────────

  Widget _buildItem(BuildContext context, int index, bool reducedMotion) {
    final colors = context.colors;
    final item = widget.items[index];
    final isSelected = index == widget.currentIndex;
    final isFocused = index == _focusedIndex && _focusNode.hasFocus;
    final isHovered = _hoveredIndices.contains(index);
    final iconColor = (isSelected || isHovered)
        ? colors.primary.base
        : colors.textMuted;
    final labelColor = (isSelected || isHovered)
        ? colors.primary.base
        : colors.textMuted;

    // Determine whether to show the label (non-expandable mode).
    final showLabel = switch (widget.labelBehavior) {
      OiRailLabelBehavior.all => true,
      OiRailLabelBehavior.selected => isSelected,
      OiRailLabelBehavior.none => false,
    };

    // ── Icon with indicator background ──────────────────────────────────

    final iconWidget = Icon(
      isSelected ? (item.activeIcon ?? item.icon) : item.icon,
      size: 24,
      color: iconColor,
    );

    final iconWidth = _isExpandable ? (widget.collapsedWidth ?? 48.0) : 56.0;
    Widget iconArea = SizedBox(
      width: iconWidth,
      height: 32,
      child: Center(child: iconWidget),
    );

    // ── Badge overlay ───────────────────────────────────────────────────

    if (item.badge != null) {
      iconArea = Stack(
        clipBehavior: Clip.none,
        children: [
          iconArea,
          Positioned(
            top: 0,
            right: 6,
            child: OiBadge.filled(
              label: item.badge!,
              color: OiBadgeColor.error,
              size: OiBadgeSize.small,
            ),
          ),
        ],
      );
    }

    // ── Compose item layout ─────────────────────────────────────────────

    final Widget itemContent;

    if (_isExpandable && _expandController != null) {
      // Expandable mode: horizontal row with icon + animated label.
      itemContent = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconArea,
          Flexible(
            child: FadeTransition(
              opacity: CurvedAnimation(
                parent: _expandController!,
                curve: const Interval(0.3, 1, curve: Curves.easeIn),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 4, right: 8),
                child: OiLabel.small(
                  item.label,
                  color: labelColor,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      // Classic mode: vertical column with icon + optional label below.
      itemContent = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconArea,
          if (showLabel) ...[
            const SizedBox(height: 4),
            OiLabel.tiny(
              item.label,
              color: labelColor,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      );
    }

    // ── Focus ring ──────────────────────────────────────────────────────

    var tappableContent = itemContent;
    if (isFocused) {
      tappableContent = DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          border: Border.all(color: colors.borderFocus, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: itemContent,
      );
    }

    // ── Tappable wrapper ────────────────────────────────────────────────

    Widget tappableItem = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hoveredIndices.add(index)),
      onExit: (_) => setState(() => _hoveredIndices.remove(index)),
      child: GestureDetector(
        onTap: () => widget.onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Semantics(
          label: item.label,
          button: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: tappableContent,
          ),
        ),
      ),
    );

    // ── Tooltip ─────────────────────────────────────────────────────────

    if (item.tooltip != null) {
      tappableItem = OiTooltip(
        label: item.label,
        message: item.tooltip!,
        child: tappableItem,
      );
    }

    return tappableItem;
  }
}
