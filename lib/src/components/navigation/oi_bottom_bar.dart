import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

/// A single item in an [OiBottomBar].
///
/// [label] is always required even in icon-only style for accessibility.
///
/// {@category Components}
class OiBottomBarItem {
  /// Creates an [OiBottomBarItem].
  const OiBottomBarItem({
    required this.icon,
    required this.label,
    this.activeIcon,
    this.badgeCount,
    this.showBadge = true,
  });

  /// The icon shown when this item is not selected.
  final IconData icon;

  /// The label shown below the icon (always required for accessibility).
  final String label;

  /// An optional icon shown instead of [icon] when this item is selected.
  final IconData? activeIcon;

  /// An optional badge count shown over the icon.  Counts >99 display as '99+'.
  final int? badgeCount;

  /// Whether to show the badge overlay.  Defaults to `true`.
  ///
  /// The badge is only visible when both [showBadge] is `true` and
  /// [badgeCount] is non-null and greater than zero.
  final bool showBadge;
}

/// The visual style of an [OiBottomBar].
///
/// {@category Components}
enum OiBottomBarStyle {
  /// A standard full-width bar, equal-width tabs, always showing icon + label.
  fixed,

  /// Active item shows icon + label; inactive items show icon only.
  shifting,

  /// All items show icon + label (alias for [fixed] with explicit semantics).
  labeled,

  /// All items show only the icon; labels are still required on items for a11y.
  iconOnly,
}

/// Landscape behaviour for [OiBottomBar] when the screen is compact + landscape.
///
/// {@category Components}
enum OiBottomBarLandscapeMode {
  /// Reduce vertical padding to keep the bar compact.
  compact,

  /// Render a vertical icon strip anchored to the left edge instead of the
  /// bottom bar.
  rail,

  /// Hide the bar entirely in landscape orientation.
  hidden,
}

/// A bottom navigation bar with icon + label items.
///
/// Items are distributed evenly across the bar width.  Tapping an item calls
/// [onTap] with that item's index.  The item at [currentIndex] is highlighted
/// with the primary colour; all others use the muted text colour.
///
/// ## Visibility rules
///
/// - Always hidden on *expanded* breakpoints and above.  On those layouts the
///   consumer should use an `OiSidebar` instead.
/// - Optionally shown on *medium* breakpoints via [showOnMedium].
/// - Hidden when the virtual keyboard is visible (detected from
///   `MediaQuery.viewInsets.bottom`).
/// - Behaviour in landscape + compact is controlled by [landscapeMode].
///
/// ## Safe area
///
/// Bottom and horizontal safe-area insets are added automatically.
///
/// ```dart
/// OiBottomBar(
///   items: const [
///     OiBottomBarItem(icon: Icons.home, label: 'Home'),
///     OiBottomBarItem(icon: Icons.search, label: 'Search'),
///     OiBottomBarItem(icon: Icons.person, label: 'Profile'),
///   ],
///   currentIndex: _tab,
///   onTap: (i) => setState(() => _tab = i),
/// )
/// ```
///
/// {@category Components}
class OiBottomBar extends StatelessWidget {
  /// Creates an [OiBottomBar].
  const OiBottomBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.style = OiBottomBarStyle.fixed,
    this.floatingAction,
    this.showLabels = true,
    this.haptic = false,
    this.showDot = false,
    this.showOnMedium = false,
    this.landscapeMode = OiBottomBarLandscapeMode.compact,
    super.key,
  });

  /// The navigation items to display.
  final List<OiBottomBarItem> items;

  /// The index of the currently active item.
  final int currentIndex;

  /// Called when an item is tapped.
  final ValueChanged<int> onTap;

  /// The visual style of this bar.
  ///
  /// Defaults to [OiBottomBarStyle.fixed].
  final OiBottomBarStyle style;

  /// An optional widget centered between the navigation items (e.g. a FAB).
  final Widget? floatingAction;

  /// Whether to show text labels.
  ///
  /// Defaults to `true`.  Setting to `false` hides labels regardless of
  /// [style].  Labels on items are always required for accessibility.
  final bool showLabels;

  /// When `true`, triggers a haptic selection feedback on every tap.
  final bool haptic;

  /// When `true`, shows a small dot indicator below the selected item's icon.
  ///
  /// Defaults to `false`.
  final bool showDot;

  /// Whether the bar should also appear on medium breakpoints.
  ///
  /// On expanded+ breakpoints the bar is always hidden.  Defaults to `false`.
  final bool showOnMedium;

  /// How the bar behaves in landscape orientation on compact breakpoints.
  ///
  /// Defaults to [OiBottomBarLandscapeMode.compact].
  final OiBottomBarLandscapeMode landscapeMode;

  @override
  Widget build(BuildContext context) {
    // ── Responsive visibility ─────────────────────────────────────────────
    final isExpanded = context.isExpandedOrWider;
    final isMedium = context.isMedium;
    if (isExpanded) return const SizedBox.shrink();
    if (isMedium && !showOnMedium) return const SizedBox.shrink();

    // ── Keyboard visibility ───────────────────────────────────────────────
    final viewInsets = MediaQuery.of(context).viewInsets;
    if (viewInsets.bottom > 0) return const SizedBox.shrink();

    // ── Landscape mode on compact ─────────────────────────────────────────
    final isLandscape = context.isLandscape;
    final isCompact = context.isCompact;
    if (isLandscape && isCompact) {
      switch (landscapeMode) {
        case OiBottomBarLandscapeMode.hidden:
          return const SizedBox.shrink();
        case OiBottomBarLandscapeMode.rail:
          return _buildRail(context);
        case OiBottomBarLandscapeMode.compact:
          break; // rendered below with reduced padding
      }
    }

    return _buildBar(context, isLandscape && isCompact);
  }

  // ── Standard bar layout ───────────────────────────────────────────────────

  Widget _buildBar(BuildContext context, bool compactLandscape) {
    final colors = context.colors;
    final mq = MediaQuery.of(context);
    final safeBottom = mq.padding.bottom;
    final safeLeft = mq.padding.left;
    final safeRight = mq.padding.right;

    final vertPad = compactLandscape ? 4.0 : 8.0;

    final itemWidgets = List<Widget>.generate(items.length, (i) {
      return Expanded(child: _buildItem(context, i, vertPad));
    });

    // Insert centered floatingAction between middle items.
    final List<Widget> rowChildren;
    if (floatingAction != null) {
      final mid = itemWidgets.length ~/ 2;
      rowChildren = [
        ...itemWidgets.take(mid),
        floatingAction!,
        ...itemWidgets.skip(mid),
      ];
    } else {
      rowChildren = itemWidgets;
    }

    final bar = DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.borderSubtle)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: safeBottom,
          left: safeLeft,
          right: safeRight,
        ),
        child: Row(children: rowChildren),
      ),
    );

    return bar;
  }

  // ── Rail layout (landscape compact) ──────────────────────────────────────

  Widget _buildRail(BuildContext context) {
    final colors = context.colors;
    final mq = MediaQuery.of(context);
    final safeTop = mq.padding.top;
    final safeBottom = mq.padding.bottom;
    final safeLeft = mq.padding.left;

    final railItems = List<Widget>.generate(items.length, (i) {
      final item = items[i];
      final isSelected = i == currentIndex;
      final iconColor = isSelected ? colors.primary.base : colors.textMuted;
      final iconData = isSelected && item.activeIcon != null
          ? item.activeIcon!
          : item.icon;

      return OiTappable(
        onTap: () => _handleTap(i),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Semantics(
            label: item.label,
            selected: isSelected,
            child: _buildIconWithBadge(context, item, iconData, iconColor),
          ),
        ),
      );
    });

    return Align(
      alignment: Alignment.centerLeft,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(right: BorderSide(color: colors.borderSubtle)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            top: safeTop,
            bottom: safeBottom,
            left: safeLeft,
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: railItems),
        ),
      ),
    );
  }

  // ── Single item (bar) ─────────────────────────────────────────────────────

  Widget _buildItem(BuildContext context, int index, double vertPad) {
    final colors = context.colors;
    final item = items[index];
    final isSelected = index == currentIndex;
    final iconColor = isSelected ? colors.primary.base : colors.textMuted;
    final labelColor = isSelected ? colors.primary.base : colors.textMuted;
    final iconData = isSelected && item.activeIcon != null
        ? item.activeIcon!
        : item.icon;

    final showItemLabel = _shouldShowLabel(index);

    return OiTappable(
      onTap: () => _handleTap(index),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: vertPad),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              label: item.label,
              selected: isSelected,
              child: _buildIconWithBadge(context, item, iconData, iconColor),
            ),
            if (showItemLabel) ...[
              const SizedBox(height: 4),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: labelColor,
                  height: 1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ] else if (showDot && isSelected) ...[
              const SizedBox(height: 4),
              _buildDot(context),
            ],
          ],
        ),
      ),
    );
  }

  // ── Selection dot indicator ───────────────────────────────────────────────

  Widget _buildDot(BuildContext context) {
    final colors = context.colors;
    return Container(
      key: const Key('oi_bottom_bar_dot'),
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        color: colors.primary.base,
        shape: BoxShape.circle,
      ),
    );
  }

  // ── Icon with badge overlay ────────────────────────────────────────────────

  Widget _buildIconWithBadge(
    BuildContext context,
    OiBottomBarItem item,
    IconData iconData,
    Color iconColor,
  ) {
    final colors = context.colors;
    Widget iconWidget = Icon(iconData, size: 24, color: iconColor);

    final effectiveBadgeCount = item.badgeCount;
    final hasBadge =
        item.showBadge &&
        effectiveBadgeCount != null &&
        effectiveBadgeCount > 0;

    if (hasBadge) {
      iconWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          iconWidget,
          Positioned(
            top: -4,
            right: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: colors.error.base,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Text(
                effectiveBadgeCount > 99 ? '99+' : '$effectiveBadgeCount',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: colors.error.foreground,
                  height: 1,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return iconWidget;
  }

  // ── Label visibility logic ─────────────────────────────────────────────────

  bool _shouldShowLabel(int index) {
    if (!showLabels) return false;
    switch (style) {
      case OiBottomBarStyle.iconOnly:
        return false;
      case OiBottomBarStyle.shifting:
        return index == currentIndex;
      case OiBottomBarStyle.fixed:
      case OiBottomBarStyle.labeled:
        return true;
    }
  }

  // ── Tap handler ────────────────────────────────────────────────────────────

  void _handleTap(int index) {
    if (haptic) {
      HapticFeedback.selectionClick();
    }
    onTap(index);
  }
}
