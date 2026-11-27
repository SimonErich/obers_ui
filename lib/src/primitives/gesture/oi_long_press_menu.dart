import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_touch_target.dart';
import 'package:obers_ui/src/primitives/overlay/oi_floating.dart';

/// A menu item for the long-press context menu.
///
/// Each item has a [label], an [onTap] callback, and an optional [icon].
class OiLongPressMenuItem {
  /// Creates an [OiLongPressMenuItem].
  const OiLongPressMenuItem({
    required this.label,
    required this.onTap,
    this.icon,
  });

  /// The text label shown in the menu.
  final String label;

  /// Called when this menu item is tapped.
  final VoidCallback onTap;

  /// Optional icon shown alongside the [label].
  final IconData? icon;
}

/// A widget that shows a context menu overlay when its [child] is long-pressed.
///
/// When the user long-presses [child], a menu containing [items] opens at
/// the press location, moved as far as needed to stay inside the screen.
/// Tapping any item invokes its [OiLongPressMenuItem.onTap] and closes the
/// menu. Tapping outside the menu, or scrolling an ancestor, also closes it.
/// When [enabled] is `false` the long press is ignored.
///
/// The menu is positioned with [OiFloating] and takes its colours, radius
/// and shadow from the theme.
///
/// ```dart
/// OiLongPressMenu(
///   items: [
///     OiLongPressMenuItem(label: 'Copy', onTap: _copy),
///     OiLongPressMenuItem(label: 'Share', onTap: _share),
///   ],
///   child: const Text('Long press me'),
/// )
/// ```
///
/// {@category Primitives}
class OiLongPressMenu extends StatefulWidget {
  /// Creates an [OiLongPressMenu].
  const OiLongPressMenu({
    required this.child,
    required this.items,
    this.enabled = true,
    this.direction = Axis.vertical,
    this.trailing,
    super.key,
  });

  /// The child that triggers the menu on long press.
  final Widget child;

  /// The menu items to show.
  final List<OiLongPressMenuItem> items;

  /// Whether the menu is enabled.
  ///
  /// When `false`, long presses on [child] are ignored.
  final bool enabled;

  /// The layout direction for menu items.
  ///
  /// Defaults to [Axis.vertical]. Use [Axis.horizontal] for compact
  /// emoji-style menus.
  final Axis direction;

  /// An optional trailing widget appended after all [items].
  final Widget? trailing;

  @override
  State<OiLongPressMenu> createState() => _OiLongPressMenuState();
}

class _OiLongPressMenuState extends State<OiLongPressMenu> {
  /// Identifies the box the menu is anchored to, so the press point can be
  /// expressed relative to it.
  final GlobalKey _anchorKey = GlobalKey();

  bool _open = false;
  Offset _pressPosition = Offset.zero;

  /// Offset that moves the menu from its default spot (below the child's
  /// bottom-left corner) to the press point.
  Offset _menuOffset = Offset.zero;

  void _showMenu() {
    final box = _anchorKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return;
    final local = box.globalToLocal(_pressPosition);
    setState(() {
      _menuOffset = Offset(local.dx, local.dy - box.size.height);
      _open = true;
    });
  }

  void _removeMenu() {
    if (!_open || !mounted) return;
    setState(() => _open = false);
  }

  @override
  Widget build(BuildContext context) {
    return OiTouchTarget(
      child: GestureDetector(
        onLongPress: widget.enabled ? _showMenu : null,
        onLongPressStart: widget.enabled
            ? (details) {
                _pressPosition = details.globalPosition;
              }
            : null,
        // OiFloating keeps the menu inside the screen (with its default
        // margin) whatever the press point, and renders it in the overlay.
        child: OiFloating(
          visible: _open,
          gap: 0,
          offset: _menuOffset,
          // No flipping or edge snapping relative to the child: the menu
          // belongs to the press point and is only clamped to the screen.
          overflow: OiFloatingOverflow.none,
          onDismiss: _removeMenu,
          anchor: Listener(
            key: _anchorKey,
            // OiFloating leaves taps on the anchor alone; for a context menu
            // a tap on the child is a tap outside the menu.
            onPointerDown: _open ? (_) => _removeMenu() : null,
            child: widget.child,
          ),
          child: _OiMenuPanel(
            items: widget.items,
            onClose: _removeMenu,
            direction: widget.direction,
            trailing: widget.trailing,
          ),
        ),
      ),
    );
  }
}

/// Internal panel that renders the list of menu items.
class _OiMenuPanel extends StatelessWidget {
  const _OiMenuPanel({
    required this.items,
    required this.onClose,
    required this.direction,
    this.trailing,
  });

  final List<OiLongPressMenuItem> items;
  final VoidCallback onClose;
  final Axis direction;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final horizontal = direction == Axis.horizontal;

    final itemWidgets = items
        .map<Widget>(
          (item) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              onClose();
              item.onTap();
            },
            child: Padding(
              padding: horizontal
                  ? const EdgeInsets.symmetric(horizontal: 5, vertical: 5)
                  : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                item.label,
                style: horizontal ? const TextStyle(fontSize: 20) : null,
              ),
            ),
          ),
        )
        .toList();

    if (trailing != null) {
      itemWidgets.add(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: horizontal
                ? const EdgeInsets.symmetric(horizontal: 8, vertical: 8)
                : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: trailing,
          ),
        ),
      );
    }

    return DecoratedBox(
      key: const ValueKey('oi_long_press_menu_panel'),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: context.radius.md,
        boxShadow: context.shadows.md,
      ),
      // The panel sits in the overlay, outside the page's text style, so set
      // a readable one for its surface colour.
      child: DefaultTextStyle(
        style: context.textTheme.body.copyWith(color: colors.text),
        child: horizontal
            ? Row(mainAxisSize: MainAxisSize.min, children: itemWidgets)
            : IntrinsicWidth(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: itemWidgets,
                ),
              ),
      ),
    );
  }
}
