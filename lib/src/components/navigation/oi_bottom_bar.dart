import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

/// A single item in an [OiBottomBar].
///
/// {@category Components}
class OiBottomBarItem {
  /// Creates an [OiBottomBarItem].
  const OiBottomBarItem({
    required this.icon,
    required this.label,
    this.badgeCount = 0,
  });

  /// The icon to display.
  final IconData icon;

  /// The label shown below the icon.
  final String label;

  /// An optional badge count shown over the icon; 0 hides the badge.
  final int badgeCount;
}

/// The visual style of an [OiBottomBar].
///
/// {@category Components}
enum OiBottomBarStyle {
  /// A standard full-width bottom bar flush with the screen edge.
  standard,

  /// A floating pill-shaped bar with rounded corners and a drop shadow.
  floating,
}

/// A bottom navigation bar with icon + label items.
///
/// Items are distributed evenly across the bar width. Tapping an item calls
/// [onSelected] with that item's index. The item at [selectedIndex] is
/// highlighted with the primary colour; all others use the muted text colour.
///
/// An optional badge count on each [OiBottomBarItem] overlays a small
/// indicator over the icon when non-zero.
///
/// Use [style] to switch between a [OiBottomBarStyle.standard] bar and a
/// [OiBottomBarStyle.floating] pill that floats above the screen content.
///
/// Safe-area padding (`MediaQuery.of(context).padding.bottom`) is added
/// automatically so content is not obscured by system UI.
///
/// ```dart
/// OiBottomBar(
///   items: const [
///     OiBottomBarItem(icon: Icons.home, label: 'Home'),
///     OiBottomBarItem(icon: Icons.search, label: 'Search'),
///     OiBottomBarItem(icon: Icons.person, label: 'Profile'),
///   ],
///   selectedIndex: _tab,
///   onSelected: (i) => setState(() => _tab = i),
/// )
/// ```
///
/// {@category Components}
class OiBottomBar extends StatelessWidget {
  /// Creates an [OiBottomBar].
  const OiBottomBar({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.style = OiBottomBarStyle.standard,
    super.key,
  });

  /// The navigation items to display.
  final List<OiBottomBarItem> items;

  /// The index of the currently active item.
  final int selectedIndex;

  /// Called when an item is tapped.
  final ValueChanged<int> onSelected;

  /// Whether to render as a standard or floating bar.
  final OiBottomBarStyle style;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final row = Row(
      children: List<Widget>.generate(items.length, (i) {
        final item = items[i];
        final isSelected = i == selectedIndex;
        final iconColor = isSelected ? colors.primary.base : colors.textMuted;
        final labelColor = isSelected ? colors.primary.base : colors.textMuted;

        Widget iconWidget = Icon(item.icon, size: 24, color: iconColor);

        // Badge overlay.
        if (item.badgeCount > 0) {
          iconWidget = Stack(
            clipBehavior: Clip.none,
            children: [
              iconWidget,
              Positioned(
                top: -4,
                right: -6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: colors.error.base,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    item.badgeCount > 99 ? '99+' : '${item.badgeCount}',
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

        return Expanded(
          child: OiTappable(
            onTap: () => onSelected(i),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  iconWidget,
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
                ],
              ),
            ),
          ),
        );
      }),
    );

    final content = Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: row,
    );

    if (style == OiBottomBarStyle.floating) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: bottomPadding + 12,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: row,
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.borderSubtle)),
      ),
      child: content,
    );
  }
}
